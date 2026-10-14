"""Regression checks: python3.12 -m unittest discover -s helpers -p test_completion_report.py"""
import importlib.util
from pathlib import Path
import tempfile
import unittest
from types import SimpleNamespace
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('completion_report', Path(__file__).with_name('send-completion-report.py'))
report = importlib.util.module_from_spec(spec)
spec.loader.exec_module(report)

class ReportTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.config_dir = tempfile.TemporaryDirectory()
        cls.address_file = Path(cls.config_dir.name, 'report-address')
        cls.address_file.write_text('user@example.invalid\n')
        cls.address_file_patch = patch.object(report, 'ADDRESS_FILE', cls.address_file)
        cls.address_file_patch.start()

    @classmethod
    def tearDownClass(cls):
        cls.address_file_patch.stop()
        cls.config_dir.cleanup()

    def test_long_unicode_body_and_links_survive_wrapping(self):
        html = '<html><body><p>' + 'árvíztűrő ' * 600 + '</p><a href="https://example.com/report">Report</a></body></html>'
        raw = report.prepare('Report', html)
        parsed = report.validate(raw)
        self.assertEqual(report.visible(parsed.get_content()), report.visible(html))
        self.assertLessEqual(max(map(len, raw.split(b'\r\n'))), 998)
        self.assertIn('href="https://example.com/report"', parsed.get_content())

    def test_empty_body_rejected(self):
        with self.assertRaises(ValueError):
            report.prepare('Empty', '<html><body><style>p { color: red; }</style> </body></html>')

    def test_missing_address_file_falls_back_to_ssmtp_sender_mapping(self):
        missing_address_file = Path(self.config_dir.name, 'missing-report-address')
        aliases_file = Path(self.config_dir.name, 'revaliases')
        aliases_file.write_text('local-user:sender@example.invalid:mailhub.example.invalid\n')
        with patch.object(report, 'ADDRESS_FILE', missing_address_file), \
             patch.object(report, 'SSMTP_REVALIASES_FILE', aliases_file), \
             patch.object(report, 'SSMTP_CONFIG_FILE', Path(self.config_dir.name, 'missing-ssmtp.conf')), \
             patch.object(report.getpass, 'getuser', return_value='local-user'):
            raw = report.prepare('Report', '<p>Visible report</p>')
            parsed = report.validate(raw)
        self.assertEqual(parsed['From'], 'sender@example.invalid')
        self.assertEqual(parsed['To'], 'sender@example.invalid')

    def test_missing_address_file_uses_ssmtp_root_mailbox(self):
        missing_address_file = Path(self.config_dir.name, 'missing-report-address')
        config_file = Path(self.config_dir.name, 'ssmtp.conf')
        config_file.write_text('root=sender@example.invalid\n')
        with patch.object(report, 'ADDRESS_FILE', missing_address_file), \
             patch.object(report, 'SSMTP_REVALIASES_FILE', Path(self.config_dir.name, 'missing-revaliases')), \
             patch.object(report, 'SSMTP_CONFIG_FILE', config_file):
            parsed = report.validate(report.prepare('Report', '<p>Visible report</p>'))
        self.assertEqual(parsed['To'], 'sender@example.invalid')

    def test_double_cr_and_bare_lf_rejected(self):
        raw = report.prepare('Report', '<p>Visible report</p>')
        for broken in (raw.replace(b'\r\n', b'\r\r\n'), raw.replace(b'\r\n', b'\n')):
            with self.assertRaises(ValueError):
                report.validate(broken)

    def test_sendmail_transports_validated_message_and_confirms_queue(self):
        raw = report.prepare('Report', '<p>Visible report</p>')
        result = SimpleNamespace(
            returncode=0,
            stdout=b'',
            stderr=b'[<-] 250 2.6.0 Queued mail for delivery\n',
        )
        with patch.object(report.subprocess, 'run', return_value=result) as mock:
            self.assertIn('Queued', report.send(raw))
            mock.assert_called_once_with(
                [report.SENDMAIL, '-v', '-i', '-t'],
                input=raw.replace(b'\r\n', b'\n'),
                stdout=report.subprocess.PIPE,
                stderr=report.subprocess.PIPE,
                timeout=30,
                check=False,
            )

    def test_generic_250_is_not_claimed_as_queued(self):
        raw = report.prepare('Report', '<p>Visible report</p>')
        result = SimpleNamespace(
            returncode=0,
            stdout=b'',
            stderr=b'[<-] 250 OK\n',
        )
        with patch.object(report.subprocess, 'run', return_value=result):
            with self.assertRaises(RuntimeError):
                report.send(raw)

if __name__ == '__main__':
    unittest.main()
