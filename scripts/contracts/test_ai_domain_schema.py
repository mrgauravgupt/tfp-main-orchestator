import importlib.util
from pathlib import Path
import sqlite3
import unittest

path = Path(__file__).with_name("ai-domain-schema.py")
spec = importlib.util.spec_from_file_location("ai_domain_schema", path)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class DomainSchemaContractTests(unittest.TestCase):
    def setUp(self):
        self.schema = (module.ROOT / "tfpphotographers/packages/database/prisma/schema.prisma").read_text()
        self.worker = (module.ROOT / "tfp-ai-interface/src/tfp_ai_interface/worker_repository.py").read_text()

    def test_actual_queries(self):
        self.assertEqual(module.validate(self.schema, self.worker), 10)

    def test_column_rename_rejected(self):
        with self.assertRaisesRegex(sqlite3.OperationalError, "no such column: professional_headline"):
            module.validate(self.schema.replace('@map("professional_headline")', '@map("renamed_headline")'), self.worker)

    def test_new_query_column_rejected(self):
        with self.assertRaisesRegex(sqlite3.OperationalError, "no such column: missing_caption"):
            module.validate(self.schema, self.worker.replace("SELECT title, caption, image_key", "SELECT title, missing_caption, image_key"))


if __name__ == "__main__":
    unittest.main()
