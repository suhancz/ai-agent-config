"""Generic-agent quota regression tests."""
from datetime import datetime, timedelta
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

import track_agent_usage as usage


class GenericQuotaTests(unittest.TestCase):
    """Keep built-in adapters compatible while allowing explicit new metrics."""

    def test_generic_metric_and_legacy_parser(self):
        with patch.dict(usage.METRICS, clear=False):
            usage.configure_agent("opencode", ["provider-daily"])
            self.assertEqual(usage.parse_snapshot("opencode", "provider-daily 75% remaining")["provider-daily"]["remaining_percent"], 75)
            self.assertEqual(usage.parse_snapshot("copilot", "chat 25% remaining")["chat"]["remaining_percent"], 25)
            self.assertEqual(usage.parse_snapshot("codex", "5-hour 40% remaining")["5-hour"]["remaining_percent"], 40)

    def test_unavailable_does_not_invent_metrics(self):
        with patch.dict(usage.METRICS, clear=False):
            usage.configure_agent("qwen", [])
            self.assertEqual(usage.parse_snapshot("qwen", "quota unavailable"), {})

    def test_rejects_invalid_identity_and_builtin_replacement(self):
        for agent, labels in (("../bad", ["daily"]), ("opencode", ["bad\nlabel"]), ("codex", ["other"])):
            with self.subTest(agent=agent):
                with self.assertRaises(ValueError):
                    usage.configure_agent(agent, labels)

    def test_forecast_is_agent_isolated(self):
        now = datetime.now().astimezone().replace(hour=12, minute=0, second=0, microsecond=0)
        rows = [
            {"timestamp": (now - timedelta(minutes=10)).isoformat(), "agent": "opencode", "quota": "provider-daily", "remaining_percent": 60},
            {"timestamp": now.isoformat(), "agent": "opencode", "quota": "provider-daily", "remaining_percent": 50},
        ]
        self.assertTrue(usage.analyze(rows, "opencode", now)["provider-daily"].startswith("WARNING:"))
        self.assertEqual(usage.analyze(rows, "qwen", now), {})

    def test_cli_environment_and_private_roundtrip(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "usage.jsonl"
            env = dict(os.environ, AI_AGENT_QUOTA_METRICS="provider-daily")
            result = subprocess.run(
                [sys.executable, usage.__file__, "--agent", "opencode", "--data-file", str(path)],
                input="provider-daily 75% remaining", capture_output=True, text=True, env=env, check=True,
            )
            self.assertIn("Recorded Opencode", result.stdout)
            self.assertEqual(usage.load_rows(path)[0]["agent"], "opencode")
            self.assertEqual(path.stat().st_mode & 0o777, 0o600)
