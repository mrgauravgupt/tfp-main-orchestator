import re
import subprocess
import unittest
from pathlib import Path


class PrivateListenerTest(unittest.TestCase):
    def check(self, extra="", missing=None):
        source = (Path(__file__).parents[1] / "verify-uat-stack.sh").read_text()
        program = re.search(r"awk '\n(.*?)\n}' <<<", source, re.S).group(1) + "\n}"
        rows = [f"LISTEN 0 128 127.0.0.1:{port} 0.0.0.0:*" for port in
                (4000, 5432, 7003, 7004, 7011, 8080) if port != missing]
        return subprocess.run(["awk", program], input="\n".join(rows) + "\n" + extra,
                              text=True, capture_output=True)

    def test_loopback_and_unrelated_public_port(self):
        result = self.check("LISTEN 0 128 [::1]:4000 [::]:*\nLISTEN 0 128 0.0.0.0:22 0.0.0.0:*")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_all_non_loopback_bindings_fail_even_with_loopback_present(self):
        for address in ["0.0.0.0", "10.0.1.114", "161.118.161.98", "[::]", "[2001:db8::1]", "*"]:
            with self.subTest(address=address):
                result = self.check(f"LISTEN 0 128 {address}:4000 *:*")
                self.assertEqual(result.returncode, 1)
                self.assertIn("exposed beyond loopback: 4000", result.stderr)

    def test_missing_required_ipv4_loopback_fails(self):
        result = self.check("LISTEN 0 128 [::1]:4000 [::]:*", missing=4000)
        self.assertEqual(result.returncode, 1)
        self.assertIn("Required loopback listener is missing: 127.0.0.1:4000", result.stderr)
