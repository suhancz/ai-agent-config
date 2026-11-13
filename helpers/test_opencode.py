"""Version-selection regression tests for the OpenCode adapter."""
import importlib.util
from pathlib import Path
import unittest

SPEC = importlib.util.spec_from_file_location(
    "opencode_version", Path(__file__).with_name("opencode-version.py")
)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class OpenCodeVersionTests(unittest.TestCase):
    """Unknown API families must not silently receive a known adapter."""

    def test_stable_versions(self):
        """Recognize supported stable major versions and build metadata."""
        for text, expected in (
            ("1.0.0", 1), ("v1.18.29", 1),
            ("opencode 2.0.0", 2), ("2.1.3+build.2", 2),
        ):
            with self.subTest(text=text):
                self.assertEqual(MODULE.family(text), expected)

    def test_rejected_versions(self):
        """Reject unknown, development, prerelease, and ambiguous output."""
        for text in (
            "0.9.0", "3.0.0", "2.0.0-beta.1", "development",
            "warning\n1.2.3", "1.2",
        ):
            with self.subTest(text=text):
                with self.assertRaises(ValueError):
                    MODULE.family(text)
