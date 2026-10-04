"""Credential-free checks for actual OCI worker configuration selection."""

import importlib.util
from pathlib import Path
import unittest

script = Path(__file__).resolve().parents[1] / "prepare-ai-worker-env.py"
spec = importlib.util.spec_from_file_location("worker_env", script)
worker_env = importlib.util.module_from_spec(spec)
spec.loader.exec_module(worker_env)


class PrivateStorageBindings(unittest.TestCase):
    def legacy(self):
        return {"B2_ENDPOINT": "https://legacy.invalid", "B2_REGION": "legacy-region",
                "B2_PRIVATE_BUCKET_NAME": "private-fixture", "B2_PRIVATE_ACCESS_KEY_ID": "private-key",
                "B2_PRIVATE_SECRET_ACCESS_KEY": "synthetic-private-secret"}

    def test_canonical_private_role_wins_over_legacy_and_public(self):
        values = {**self.legacy(), "STORAGE_PRIVATE_ENDPOINT": "https://private.invalid",
                  "STORAGE_PRIVATE_REGION": "private-region", "STORAGE_PRIVATE_BUCKET_NAME": "canonical-private",
                  "STORAGE_PRIVATE_ACCESS_KEY_ID": "canonical-key", "STORAGE_PRIVATE_SECRET_ACCESS_KEY": "canonical-secret",
                  "STORAGE_PUBLIC_ENDPOINT": "https://public.invalid", "STORAGE_PUBLIC_ACCESS_KEY_ID": "public-key"}
        actual = worker_env.resolve_private_storage(values)
        self.assertEqual(actual, {"TFP_AI_STORAGE_ENDPOINT": "https://private.invalid",
                                 "TFP_AI_STORAGE_REGION": "private-region", "TFP_AI_STORAGE_BUCKET": "canonical-private",
                                 "TFP_AI_STORAGE_ACCESS_KEY_ID": "canonical-key",
                                 "TFP_AI_STORAGE_SECRET_ACCESS_KEY": "canonical-secret"})

    def test_legacy_scoped_role_remains_compatible(self):
        actual = worker_env.resolve_private_storage(self.legacy())
        self.assertEqual(actual["TFP_AI_STORAGE_BUCKET"], "private-fixture")
        self.assertEqual(actual["TFP_AI_STORAGE_REGION"], "legacy-region")

    def test_generic_and_public_credentials_cannot_fill_private_role(self):
        for missing in ["B2_PRIVATE_BUCKET_NAME", "B2_PRIVATE_ACCESS_KEY_ID", "B2_PRIVATE_SECRET_ACCESS_KEY"]:
            with self.subTest(binding=missing):
                values = self.legacy()
                del values[missing]
                values.update({"B2_BUCKET_NAME": "admin-bucket", "B2_ACCESS_KEY_ID": "admin-key",
                               "B2_SECRET_ACCESS_KEY": "do-not-leak-this-value", "STORAGE_PUBLIC_SECRET_ACCESS_KEY": "public-secret"})
                with self.assertRaises(ValueError) as caught:
                    worker_env.resolve_private_storage(values)
                self.assertIn(missing, str(caught.exception))
                self.assertNotIn("do-not-leak-this-value", str(caught.exception))

    def test_blank_canonical_values_use_configured_legacy_role(self):
        actual = worker_env.resolve_private_storage({**self.legacy(), "STORAGE_PRIVATE_ACCESS_KEY_ID": "   "})
        self.assertEqual(actual["TFP_AI_STORAGE_ACCESS_KEY_ID"], "private-key")


if __name__ == "__main__":
    unittest.main()
