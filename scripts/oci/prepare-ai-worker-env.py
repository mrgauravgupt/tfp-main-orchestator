#!/usr/bin/env python3
"""Populate ignored V2 worker secrets from the canonical app UAT environment."""

from __future__ import annotations

import secrets
import sys
from pathlib import Path
from urllib.parse import quote, urlsplit, urlunsplit


def read_env(*paths: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    for path in paths:
        for raw_line in path.read_text(encoding="utf-8").splitlines():
            line = raw_line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, value = line.split("=", 1)
            value = value.strip()
            if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
                value = value[1:-1]
            values[key.strip()] = value
    return values


def update_env(path: Path, updates: dict[str, str]) -> None:
    lines = path.read_text(encoding="utf-8").splitlines() if path.exists() else []
    seen: set[str] = set()
    output: list[str] = []
    for line in lines:
        if "=" not in line or line.lstrip().startswith("#"):
            output.append(line)
            continue
        key = line.split("=", 1)[0].strip()
        if key in updates:
            output.append(f"{key}={updates[key]}")
            seen.add(key)
        else:
            output.append(line)
    if output and output[-1]:
        output.append("")
    output.extend(f"{key}={value}" for key, value in updates.items() if key not in seen)
    path.write_text("\n".join(output).rstrip() + "\n", encoding="utf-8")
    path.chmod(0o600)


def main() -> None:
    root = Path(__file__).resolve().parents[2]
    app_values = read_env(
        root / "tfpphotographers/.env.uat",
        root / "tfpphotographers/.env.uat.local",
    )
    target = root / "tfp-ai-interface/.env.uat.local"
    current = read_env(target)
    parsed = urlsplit(app_values.get("DATABASE_URL", ""))
    database = parsed.path.lstrip("/")
    if not database:
        raise SystemExit("The app UAT DATABASE_URL is missing")
    existing_worker_url = urlsplit(current.get("TFP_AI_DATABASE_URL", ""))
    password = existing_worker_url.password or secrets.token_urlsafe(36)
    worker_netloc = f"tfp_ai_worker:{quote(password, safe='')}@127.0.0.1:5432"
    worker_url = urlunsplit(("postgresql", worker_netloc, f"/{database}", "schema=public", ""))

    def required(*names: str) -> str:
        value = next((app_values.get(name, "") for name in names if app_values.get(name)), "")
        if not value:
            raise SystemExit(f"Missing required app UAT secret: {' or '.join(names)}")
        return value

    update_env(target, {
        "TFP_AI_ENVIRONMENT": "production",
        "TFP_AI_REQUIRE_INTERNAL_API_KEY": "true",
        "TFP_AI_INTERNAL_API_KEY": required(
            "AIP_INTERNAL_API_KEY",
            "AIP__SECURITY__INTERNAL_API_KEY",
        ),
        "TFP_AI_WORKER_ENABLED": "true",
        "TFP_AI_DATABASE_URL": worker_url,
        "TFP_AI_STORAGE_ENDPOINT": required("B2_ENDPOINT", "BACKBLAZE_ENDPOINT"),
        "TFP_AI_STORAGE_REGION": app_values.get("B2_REGION") or app_values.get("BACKBLAZE_REGION") or "us-east-005",
        "TFP_AI_STORAGE_BUCKET": required("B2_PRIVATE_BUCKET_NAME", "B2_BUCKET_NAME", "BACKBLAZE_BUCKET_NAME"),
        "TFP_AI_STORAGE_ACCESS_KEY_ID": required("B2_PRIVATE_ACCESS_KEY_ID", "B2_ACCESS_KEY_ID", "BACKBLAZE_KEY_ID"),
        "TFP_AI_STORAGE_SECRET_ACCESS_KEY": required("B2_PRIVATE_SECRET_ACCESS_KEY", "B2_SECRET_ACCESS_KEY", "BACKBLAZE_APP_KEY"),
        "TFP_AI_WORKER_POLL_SECONDS": "2",
        "TFP_AI_WORKER_BATCH_SIZE": "4",
        "TFP_AI_WORKER_MAX_CONCURRENCY": "2",
        "TFP_AI_WORKER_MAX_ATTEMPTS": "36",
        "TFP_AI_WORKER_STALE_SECONDS": "300",
        "TFP_AI_TRANSLATION_CONVERTED_MODEL_DIR": (
            "/srv/tfp-ai-interface/shared/models/m2m100-418m-ct2"
        ),
        "TFP_AI_TRANSLATION_BEAM_SIZE": "4",
    })
    print(f"Prepared {target} without printing secrets")


if __name__ == "__main__":
    try:
        main()
    except OSError as exc:
        print(f"Failed to prepare V2 worker environment: {exc}", file=sys.stderr)
        raise SystemExit(1) from exc
