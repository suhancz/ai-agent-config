#!/usr/bin/env python3
"""Prepare, validate and send the user's HTML completion reports via sendmail."""

import argparse
from datetime import datetime
from email import policy
from email.message import EmailMessage
from email.parser import BytesParser
from email.utils import format_datetime, make_msgid
import getpass
from html.parser import HTMLParser
import os
from pathlib import Path
import re
import subprocess
import textwrap

SENDMAIL = "/usr/sbin/sendmail"
ADDRESS_FILE = Path(
    os.environ.get(
        "AI_AGENT_REPORT_ADDRESS_FILE",
        Path.home() / ".config" / "ai-agent-config" / "report-address",
    )
)
SSMTP_CONFIG_FILE = Path("/etc/ssmtp/ssmtp.conf")
SSMTP_REVALIASES_FILE = Path("/etc/ssmtp/revaliases")


def configured_sender_address():
    username = getpass.getuser()
    for aliases_file in (
        Path.home() / ".ssmtp" / "revaliases",
        SSMTP_REVALIASES_FILE,
    ):
        try:
            lines = aliases_file.read_text(encoding="utf-8").splitlines()
        except FileNotFoundError:
            continue
        except OSError as error:
            raise RuntimeError(
                "Unable to read local sSMTP sender mappings from %s" % aliases_file
            ) from error

        for line in lines:
            fields = line.split("#", 1)[0].strip().split(":")
            if len(fields) >= 2 and fields[0].strip() == username:
                address = fields[1].strip()
                if re.fullmatch(r"[^@\s:]+@[^@\s:]+", address):
                    return address
                raise ValueError("Invalid sSMTP sender mapping for the current user")

    try:
        lines = SSMTP_CONFIG_FILE.read_text(encoding="utf-8").splitlines()
    except FileNotFoundError as error:
        raise RuntimeError(
            "No report recipient configured and no local sSMTP sender mapping found"
        ) from error
    except OSError as error:
        raise RuntimeError(
            "No report recipient configured and unable to read %s" % SSMTP_CONFIG_FILE
        ) from error

    for line in lines:
        key, separator, value = line.partition("=")
        if separator and key.strip().lower() == "root":
            address = value.split("#", 1)[0].strip()
            if re.fullmatch(r"[^@\s:]+@[^@\s:]+", address):
                return address
            raise ValueError("Invalid sSMTP root mailbox address")

    raise RuntimeError(
        "No report recipient configured and no sender address found in sSMTP configuration"
    )


def report_address():
    try:
        address = ADDRESS_FILE.read_text(encoding="utf-8").strip()
    except FileNotFoundError:
        address = configured_sender_address()
    except OSError as error:
        raise RuntimeError("Configure the local report recipient in %s" % ADDRESS_FILE) from error
    if not re.fullmatch(r"[^@\s]+@[^@\s]+|[A-Za-z0-9_.+-]+", address):
        raise ValueError("Invalid local report recipient in %s" % ADDRESS_FILE)
    return address


class VisibleText(HTMLParser):
    def __init__(self):
        super().__init__()
        self.hidden = 0
        self.text = []

    def handle_starttag(self, tag, attrs):
        if tag in ("style", "script"):
            self.hidden += 1

    def handle_endtag(self, tag):
        if tag in ("style", "script"):
            self.hidden = max(0, self.hidden - 1)

    def handle_data(self, data):
        if not self.hidden:
            self.text.append(data)


def visible(html):
    parser = VisibleText()
    parser.feed(html)
    return " ".join(" ".join(parser.text).split())


def prepare(subject, html):
    if not visible(html):
        raise ValueError("HTML report has no visible body text")
    address = report_address()
    # HTML whitespace is collapsed by mail clients; wrapping between words
    # preserves content while respecting the SMTP 998-octet line limit.
    lines = []
    for line in html.replace("\r\n", "\n").replace("\r", "\n").splitlines():
        lines.extend(
            textwrap.wrap(line, width=200, break_long_words=False, break_on_hyphens=False) or [""]
        )
    wrapped = "\n".join(lines)
    message = EmailMessage(policy=policy.SMTP)
    message["From"] = address
    message["To"] = address
    message["Subject"] = subject
    message["Date"] = format_datetime(datetime.now().astimezone())
    message["Message-ID"] = make_msgid(domain="localhost")
    message.set_content(wrapped, subtype="html", charset="utf-8", cte="8bit")
    raw = message.as_bytes()
    validate(raw)
    assert visible(wrapped) == visible(html), "HTML wrapping changed visible content"
    return raw


def validate(raw):
    address = report_address()
    if b"\r\r\n" in raw:
        raise ValueError("Double carriage return in message")
    if b"\n" in raw.replace(b"\r\n", b"") or b"\r" in raw.replace(b"\r\n", b""):
        raise ValueError("Message must use canonical CRLF line endings")
    if b"\r\n\r\n" not in raw:
        raise ValueError("Missing MIME header/body separator")
    if max(map(len, raw.split(b"\r\n"))) > 998:
        raise ValueError("SMTP line exceeds 998 octets")
    message = BytesParser(policy=policy.default).parsebytes(raw)
    if message.defects or message.is_multipart():
        raise ValueError("Malformed or unexpected MIME structure")
    for name in ("From", "To", "Subject", "Date", "Message-ID", "MIME-Version"):
        if not message[name] or message[name].defects:
            raise ValueError("Missing or malformed header: " + name)
    if message["From"] != address or message["To"] != address:
        raise ValueError("Unexpected sender or recipient")
    if message.get_content_type() != "text/html" or message.get_content_charset() != "utf-8":
        raise ValueError("Report must be UTF-8 HTML")
    if str(message["Content-Transfer-Encoding"]).lower() != "8bit":
        raise ValueError("Report must use 8bit transfer encoding")
    if not visible(message.get_content()):
        raise ValueError("Parsed MIME message has no visible body text")
    return message


def send(raw):
    validate(raw)
    result = subprocess.run(
        [SENDMAIL, "-v", "-i", "-t"],
        input=raw.replace(b"\r\n", b"\n"),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        timeout=30,
        check=False,
    )
    transcript = result.stderr.decode("utf-8", errors="replace")
    responses = re.findall(r"(?m)^\[<-\]\s*(\d{3}(?:[ .-][^\r\n]*)?)$", transcript)
    queued = next(
        (line for line in responses if line.startswith("250 2.6.0 ") and "queued" in line.lower()),
        None,
    )
    if result.returncode != 0 or queued is None:
        detail = "; ".join(responses[-3:]) or "no SMTP response was reported"
        raise RuntimeError("sendmail failed (exit %d): %s" % (result.returncode, detail))
    return queued


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="action", required=True)
    p = sub.add_parser("prepare")
    p.add_argument("--subject")
    source = p.add_mutually_exclusive_group(required=True)
    source.add_argument("--html", type=Path)
    source.add_argument("--from-eml", type=Path)
    p.add_argument("--output", type=Path, required=True)
    for action in ("validate", "send"):
        sub.add_parser(action).add_argument("message", type=Path)
    args = parser.parse_args()
    if args.action == "prepare":
        if args.from_eml:
            old = BytesParser(policy=policy.default).parsebytes(args.from_eml.read_bytes())
            if old.get_content_type() != "text/html":
                raise ValueError("Expected an HTML source report")
            subject = args.subject or str(old["Subject"])
            html = old.get_content()
        else:
            if not args.subject:
                parser.error("--subject is required with --html")
            subject, html = args.subject, args.html.read_text(encoding="utf-8")
        raw = prepare(subject, html)
        args.output.write_bytes(raw)
        print(
            "Prepared and validated nonempty HTML report: %s (%d bytes)" % (args.output, len(raw))
        )
    elif args.action == "validate":
        message = validate(args.message.read_bytes())
        print(
            "Valid UTF-8 HTML report: %d visible characters; CRLF and line lengths verified."
            % len(visible(message.get_content()))
        )
    else:
        print(send(args.message.read_bytes()))


if __name__ == "__main__":
    main()
