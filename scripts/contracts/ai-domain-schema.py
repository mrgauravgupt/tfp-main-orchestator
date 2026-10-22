"""Check actual AI enrichment SELECTs against scalar columns in Prisma schema.

This is a static name/shape contract, not a PostgreSQL execution certificate.
SQLite prepares the bounded SELECT grammar without reading application data.
"""
from __future__ import annotations

import ast
from contextlib import closing
from pathlib import Path
import re
import sqlite3

ROOT = Path(__file__).resolve().parents[2]
METHODS = {"load_entity_text_fields", "load_translation_entity"}


def validate(schema: str, worker: str) -> int:
    models = re.findall(r"model\s+(\w+)\s*\{(.*?)\n\}", schema, re.S)
    model_names = {name for name, _ in models}
    with closing(sqlite3.connect(":memory:")) as db:
        for name, body in models:
            mapped = re.search(r'@@map\("([^"]+)"\)', body)
            table = mapped[1] if mapped else name
            columns = []
            for line in body.splitlines():
                field = re.match(r"\s*(\w+)\s+([\w?\[\]]+)(.*)", line)
                if not field or field[2].rstrip("?[]") in model_names or "@ignore" in field[3]:
                    continue
                mapped_field = re.search(r'@map\("([^"]+)"\)', field[3])
                columns.append(mapped_field[1] if mapped_field else field[1])
            db.execute(f'CREATE TABLE "{table}" (' + ",".join(f'"{c}" TEXT' for c in columns) + ")")
        count = 0
        found = set()
        for method in ast.walk(ast.parse(worker)):
            if not isinstance(method, ast.FunctionDef) or method.name not in METHODS:
                continue
            found.add(method.name)
            queries = []
            for node in ast.walk(method):
                if isinstance(node, ast.Constant) and isinstance(node.value, str) and re.match(r"SELECT\s", node.value):
                    # JoinedStr fragments are handled as a complete query below.
                    if node.value.strip().endswith("FROM"):
                        continue
                    queries.append(node.value)
                elif isinstance(node, ast.JoinedStr):
                    template = "".join(n.value if isinstance(n, ast.Constant) else "{table}" for n in node.values)
                    if not template.lstrip().startswith("SELECT "):
                        continue
                    mappings = [n for n in ast.walk(method) if isinstance(n, ast.Dict)]
                    tables = {v.value for mapping in mappings for v in mapping.values if isinstance(v, ast.Constant) and isinstance(v.value, str)}
                    if not tables:
                        raise ValueError("Missing translation table allowlist")
                    queries.extend(template.replace("{table}", table) for table in sorted(tables))
            if not queries:
                raise ValueError(f"No SQL checked for {method.name}")
            for query in queries:
                query = query.replace("%s", "?")
                db.execute("EXPLAIN " + query, [None] * query.count("?"))
                count += 1
        if found != METHODS:
            raise ValueError("Missing AI enrichment method")
        return count


if __name__ == "__main__":
    count = validate(
        (ROOT / "tfpphotographers/packages/database/prisma/schema.prisma").read_text(),
        (ROOT / "tfp-ai-interface/src/tfp_ai_interface/worker_repository.py").read_text(),
    )
    print(f"AI domain schema contract: {count} actual enrichment SELECTs checked")
