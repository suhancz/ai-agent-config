"""Live CI regression checks for executable-mode repair and false positives."""
from pathlib import Path
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[1]
PROBE = "helpers/actions-mode-probe.sh"
MODULE = "helpers/test_actions_mode_probe.py"


def tracked_mode(path):
    """Read the actual Git index mode instead of trusting filesystem defaults."""
    entry = subprocess.check_output(
        ["git", "ls-files", "--stage", "--", path], cwd=ROOT, text=True
    )
    if not entry.strip():
        raise AssertionError("Expected a tracked test fixture")
    return entry.split()[0]


class ActionsModeProbeTests(unittest.TestCase):
    """Check the repaired branch snapshot used by the Actions lint job."""

    def test_entry_point_has_executable_git_mode(self):
        self.assertEqual(tracked_mode(PROBE), "100755")

    def test_imported_test_module_is_not_marked_executable(self):
        self.assertEqual(tracked_mode(MODULE), "100644")

    def test_entry_point_can_be_invoked_directly(self):
        result = subprocess.run(
            [str(ROOT / PROBE)], cwd=ROOT, check=True,
            capture_output=True, text=True, timeout=5,
        )
        self.assertEqual(result.stdout.strip(), "executable-mode-probe")
