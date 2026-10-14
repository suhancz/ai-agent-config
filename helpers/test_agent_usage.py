import json
from datetime import datetime, timezone
import os
from pathlib import Path
import tempfile
import unittest

from track_agent_usage import analyze, load_rows, parse_snapshot, save_rows


class AgentUsageTests(unittest.TestCase):
    def test_parse_copilot_metrics(self):
        metrics = parse_snapshot(
            "copilot",
            "Copilot credits: AI credit quota — chat 16.5% remaining, "
            "completions 98.9% remaining; resets 2026-10-14 20:30 UTC (local time).",
        )
        self.assertEqual(metrics["chat"]["remaining_percent"], 16.5)
        self.assertEqual(metrics["completions"]["remaining_percent"], 98.9)
    def test_parse_codex_limits(self):
        metrics = parse_snapshot(
            "codex",
            "Codex credits: Business individual limit 40% remaining "
            "(renews 2026-10-14 21:00 UTC); 5-hour 70% remaining "
            "(renews 2026-10-14 23:00 UTC); weekly 90% remaining (renewal unknown).",
        )
        self.assertEqual(metrics["business individual limit"]["remaining_percent"], 40)
        self.assertNotIn("individual limit", metrics)
        self.assertEqual(metrics["5-hour"]["remaining_percent"], 70)
        self.assertEqual(metrics["weekly"]["remaining_percent"], 90)

    def test_warns_when_linear_usage_reaches_zero_before_midnight(self):
        now = datetime(2026, 10, 14, 12, 20, tzinfo=timezone.utc)
        rows = [
            {
                "timestamp": "2026-10-14T12:00:00+00:00",
                "agent": "copilot",
                "quota": "chat",
                "remaining_percent": 50,
            },
            {
                "timestamp": "2026-10-14T12:15:00+00:00",
                "agent": "copilot",
                "quota": "chat",
                "remaining_percent": 40,
            },
        ]
        result = analyze(rows, "copilot", now)
        self.assertTrue(result[0].startswith("WARNING: Copilot chat"))

    def test_quota_replenishment_starts_a_new_trend(self):
        now = datetime(2026, 10, 14, 12, 40, tzinfo=timezone.utc)
        rows = [
            {
                "timestamp": "2026-10-14T12:00:00+00:00",
                "agent": "copilot",
                "quota": "chat",
                "remaining_percent": 50,
            },
            {
                "timestamp": "2026-10-14T12:15:00+00:00",
                "agent": "copilot",
                "quota": "chat",
                "remaining_percent": 40,
            },
            {
                "timestamp": "2026-10-14T12:21:00+00:00",
                "agent": "copilot",
                "quota": "chat",
                "remaining_percent": 100,
            },
            {
                "timestamp": "2026-10-14T12:36:00+00:00",
                "agent": "copilot",
                "quota": "chat",
                "remaining_percent": 90,
            },
        ]
        result = analyze(rows, "copilot", now)
        self.assertIn("40.0%/hour", result[0])

    def test_usage_log_is_private_and_round_trips(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / ".agent-usage.jsonl"
            row = {
                "timestamp": "2026-10-14T12:00:00+00:00",
                "agent": "copilot",
                "quota": "chat",
                "remaining_percent": 50,
                "reset_at": None,
            }
            save_rows(path, [row])
            self.assertEqual(load_rows(path), [row])
            self.assertEqual(os.stat(path).st_mode & 0o777, 0o600)
            self.assertEqual(json.loads(path.read_text()), row)

    def test_malformed_usage_log_is_reported(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / ".agent-usage.jsonl"
            path.write_text("{invalid json\n", encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "Invalid usage sample"):
                load_rows(path)


if __name__ == "__main__":
    unittest.main()
