#!/usr/bin/env python3
"""Record an agent's quota snapshot and estimate whether it may run out today."""

import argparse
from datetime import datetime, time, timedelta
import json
import os
from pathlib import Path
import re
import sys

DATA_FILE = Path(__file__).resolve().parents[1] / ".agent-usage.jsonl"
MINIMUM_TREND_SECONDS = 600
METRICS = {
    "copilot": ("chat", "completions"),
    "codex": ("business individual limit", "individual limit", "5-hour", "weekly"),
}


def parse_reset(text, now):
    match = re.search(
        r"\b(?:renews|resets)\s+(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2})",
        text,
        re.IGNORECASE,
    )
    if not match:
        return None
    try:
        reset_date = datetime.strptime(
            f"{match.group(1)} {match.group(2)}", "%Y-%m-%d %H:%M"
        )
    except ValueError as error:
        raise ValueError("Invalid quota reset time in snapshot") from error
    local_timezone = now.tzinfo or now.astimezone().tzinfo
    return reset_date.replace(tzinfo=local_timezone).isoformat()


def parse_snapshot(agent, text, now):
    metrics = {}
    matched_ranges = []
    for label in sorted(METRICS[agent], key=len, reverse=True):
        pattern = re.compile(
            rf"(?<![\w-]){re.escape(label)}\s+(\d+(?:\.\d+)?)%\s+remaining"
            rf"(?:\s*\(([^)]*)\))?",
            re.IGNORECASE,
        )
        match = pattern.search(text)
        if not match or any(
            match.start() < end and match.end() > start
            for start, end in matched_ranges
        ):
            continue
        remaining = float(match.group(1))
        if not 0 <= remaining <= 100:
            raise ValueError(f"Invalid remaining percentage for {label}")
        reset_text = match.group(2) or text
        metrics[label] = {
            "remaining_percent": remaining,
            "reset_at": parse_reset(reset_text, now),
        }
        matched_ranges.append(match.span())
    return metrics


def load_rows(path):
    if not path.exists():
        return []
    rows = []
    with path.open(encoding="utf-8") as data:
        for line_number, line in enumerate(data, 1):
            try:
                row = json.loads(line)
                datetime.fromisoformat(row["timestamp"])
                if (
                    row["agent"] not in METRICS
                    or not isinstance(row["quota"], str)
                    or not 0 <= float(row["remaining_percent"]) <= 100
                ):
                    raise ValueError("invalid sample fields")
                rows.append(row)
            except (KeyError, TypeError, ValueError, json.JSONDecodeError) as error:
                raise ValueError(
                    f"Invalid usage sample at {path}:{line_number}"
                ) from error
    return rows


def save_rows(path, rows):
    path.parent.mkdir(parents=True, exist_ok=True)
    encoded = "".join(json.dumps(row, separators=(",", ":")) + "\n" for row in rows)
    descriptor = os.open(path, os.O_CREAT | os.O_APPEND | os.O_WRONLY, 0o600)
    try:
        os.fchmod(descriptor, 0o600)
        os.write(descriptor, encoded.encode("utf-8"))
    finally:
        os.close(descriptor)


def analyze(rows, agent, now):
    output = []
    today = now.date()
    midnight = datetime.combine(
        today + timedelta(days=1),
        time.min,
        tzinfo=now.tzinfo or now.astimezone().tzinfo,
    )
    current_rows = [
        row
        for row in rows
        if row["agent"] == agent
        and datetime.fromisoformat(row["timestamp"]).astimezone().date() == today
    ]

    for quota in sorted({row["quota"] for row in current_rows}):
        latest_reset = next(
            (
                row.get("reset_at")
                for row in reversed(current_rows)
                if row["quota"] == quota
            ),
            None,
        )
        samples = sorted(
            (
                row
                for row in current_rows
                if row["quota"] == quota and row.get("reset_at") == latest_reset
            ),
            key=lambda row: row["timestamp"],
        )
        if len(samples) < 2:
            output.append(
                f"{quota}: collecting a second {agent.title()} sample; no runout forecast yet."
            )
            continue

        last_increase = 0
        for index in range(1, len(samples)):
            if (
                float(samples[index]["remaining_percent"])
                > float(samples[index - 1]["remaining_percent"]) + 0.5
            ):
                last_increase = index
        samples = samples[last_increase:]
        if len(samples) < 2:
            output.append(
                f"{quota}: quota appears to have replenished; collecting a new trend."
            )
            continue

        first_time = datetime.fromisoformat(samples[0]["timestamp"])
        last_time = datetime.fromisoformat(samples[-1]["timestamp"])
        elapsed_seconds = (last_time - first_time).total_seconds()
        if elapsed_seconds < MINIMUM_TREND_SECONDS:
            output.append(
                f"{quota}: trend samples span less than 10 minutes; no runout forecast yet."
            )
            continue

        first_percent = float(samples[0]["remaining_percent"])
        last_percent = float(samples[-1]["remaining_percent"])
        consumed = first_percent - last_percent
        if consumed <= 0.1:
            output.append(f"{quota}: no measurable quota decline today.")
            continue

        percent_per_hour = consumed / (elapsed_seconds / 3600)
        exhaustion = now + timedelta(hours=last_percent / percent_per_hour)
        reset_at = samples[-1].get("reset_at")
        horizon = midnight
        if reset_at:
            reset_time = datetime.fromisoformat(reset_at)
            if now < reset_time < horizon:
                horizon = reset_time
        rate = f"{percent_per_hour:.1f}%/hour"
        if exhaustion <= horizon:
            output.append(
                f"WARNING: {agent.title()} {quota} is declining at about {rate}; "
                f"projected to run out around {exhaustion.astimezone().strftime('%H:%M %Z')}, "
                "before the next reset or local midnight."
            )
        else:
            output.append(
                f"{quota}: declining at about {rate}; no exhaustion projected before "
                f"{horizon.astimezone().strftime('%H:%M %Z')}."
            )
    return output


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--agent", required=True, choices=sorted(METRICS))
    parser.add_argument("--data-file", type=Path, default=DATA_FILE)
    args = parser.parse_args()
    snapshot = sys.stdin.read().strip()
    if not snapshot:
        parser.error("provide the current agent's quota status on stdin")

    now = datetime.now().astimezone()
    metrics = parse_snapshot(args.agent, snapshot, now)
    if not metrics:
        print(snapshot)
        print(
            f"No parseable {args.agent.title()} quota percentages; no usage sample was recorded."
        )
        return 0

    existing = load_rows(args.data_file)
    rows = [
        {
            "timestamp": now.isoformat(),
            "agent": args.agent,
            "quota": quota,
            **values,
        }
        for quota, values in metrics.items()
    ]
    save_rows(args.data_file, rows)

    print(snapshot)
    print(
        f"Recorded {args.agent.title()} quota sample in ignored {args.data_file.name}."
    )
    for message in analyze(existing + rows, args.agent, now):
        print(message)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError) as error:
        print(f"Usage tracking failed: {error}", file=sys.stderr)
        sys.exit(1)
