#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Acquire an OCI Always Free Ampere A1 Flex instance with bounded, rate-limited retries.

Defaults are based on the current OCI CLI configuration for this workspace:
  region:              ap-mumbai-1
  compartment:         tfp-app
  availability domain: lqoG:AP-MUMBAI-1-AD-1
  subnet:              root tfp-public-subnet
  shape:               VM.Standard.A1.Flex
  sizing:              2 OCPU / 12 GB RAM, the current Always Free-safe target

Usage:
  scripts/oci/acquire-a1-free.sh [--once] [--daemon] [--name NAME]

Options:
  --once       Try one launch attempt and exit.
  --daemon     Start this script in the background with nohup and exit.
  --name NAME  Instance display name. Default: tfp-a1-free-2ocpu-12gb.
  -h, --help   Show this help.

Useful environment overrides:
  OCI_COMPARTMENT_ID, OCI_AVAILABILITY_DOMAIN, OCI_SUBNET_ID, OCI_IMAGE_ID
  OCI_SSH_PUBLIC_KEY_FILE, OCI_RETRY_SLEEP_SECONDS, OCI_MAX_ATTEMPTS
  OCI_OCPUS, OCI_MEMORY_GBS, OCI_REGION

Safety:
  By default this script refuses requests above 2 OCPU or 12 GB RAM. Set
  OCI_ALLOW_OVER_FREE_TIER=1 only if you intentionally want to bypass that guard.
EOF
}

timestamp() {
  date -u '+%Y-%m-%dT%H:%M:%SZ'
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOG_DIR="${ROOT_DIR}/.run-state/oci"
mkdir -p "$LOG_DIR"

INSTANCE_NAME="${INSTANCE_NAME:-tfp-a1-free-2ocpu-12gb}"
RUN_ONCE=0
DAEMON=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --once)
      RUN_ONCE=1
      shift
      ;;
    --daemon)
      DAEMON=1
      shift
      ;;
    --name)
      INSTANCE_NAME="${2:?Missing value for --name}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ "$DAEMON" == "1" ]]; then
  log_file="$LOG_DIR/acquire-a1-free-$(date +%Y%m%d-%H%M%S).log"
  nohup "$0" --name "$INSTANCE_NAME" >"$log_file" 2>&1 &
  echo "Started OCI A1 acquisition loop in background."
  echo "PID: $!"
  echo "Log: $log_file"
  exit 0
fi

command -v oci >/dev/null 2>&1 || {
  echo "OCI CLI is required but was not found in PATH." >&2
  exit 127
}

OCI_REGION="${OCI_REGION:-ap-mumbai-1}"
OCI_COMPARTMENT_ID="${OCI_COMPARTMENT_ID:-ocid1.compartment.oc1..aaaaaaaa3jhlvmtcmrdwj7enlrgj3bdzqe7drehb5lrlkokxrfkncpc3atqq}"
OCI_AVAILABILITY_DOMAIN="${OCI_AVAILABILITY_DOMAIN:-lqoG:AP-MUMBAI-1-AD-1}"
OCI_SUBNET_ID="${OCI_SUBNET_ID:-ocid1.subnet.oc1.ap-mumbai-1.aaaaaaaarkqh55u2liopwk2kdef5noeam7hgw4w7di57srcvzma4tftqbfla}"
OCI_SSH_PUBLIC_KEY_FILE="${OCI_SSH_PUBLIC_KEY_FILE:-$HOME/.ssh/id_ed25519.pub}"
OCI_OCPUS="${OCI_OCPUS:-2}"
OCI_MEMORY_GBS="${OCI_MEMORY_GBS:-12}"
OCI_RETRY_SLEEP_SECONDS="${OCI_RETRY_SLEEP_SECONDS:-90}"
OCI_MAX_ATTEMPTS="${OCI_MAX_ATTEMPTS:-0}"
OCI_ALLOW_OVER_FREE_TIER="${OCI_ALLOW_OVER_FREE_TIER:-0}"

if [[ "$OCI_ALLOW_OVER_FREE_TIER" != "1" ]]; then
  python3 - "$OCI_OCPUS" "$OCI_MEMORY_GBS" <<'PY'
import sys

ocpus = float(sys.argv[1])
memory = float(sys.argv[2])
if ocpus > 2 or memory > 12:
    raise SystemExit(
        "Refusing request above the Always Free-safe target of 2 OCPU / 12 GB RAM. "
        "Set OCI_ALLOW_OVER_FREE_TIER=1 to override intentionally."
    )
PY
fi

if [[ ! -r "$OCI_SSH_PUBLIC_KEY_FILE" ]]; then
  echo "SSH public key not readable: $OCI_SSH_PUBLIC_KEY_FILE" >&2
  exit 1
fi

get_latest_ubuntu_aarch64_image() {
  oci compute image list \
    --region "$OCI_REGION" \
    --compartment-id "$OCI_COMPARTMENT_ID" \
    --shape VM.Standard.A1.Flex \
    --operating-system "Canonical Ubuntu" \
    --operating-system-version "24.04" \
    --all \
    --sort-by TIMECREATED \
    --sort-order DESC \
    --query 'data[0].id' \
    --raw-output
}

OCI_IMAGE_ID="${OCI_IMAGE_ID:-$(get_latest_ubuntu_aarch64_image)}"
if [[ -z "$OCI_IMAGE_ID" || "$OCI_IMAGE_ID" == "null" ]]; then
  echo "Could not resolve an Ubuntu 24.04 aarch64 image for VM.Standard.A1.Flex." >&2
  exit 1
fi

shape_config="$(mktemp)"
metadata_file="$(mktemp)"
trap 'rm -f "$shape_config" "$metadata_file"' EXIT

cat >"$shape_config" <<EOF
{
  "ocpus": $OCI_OCPUS,
  "memoryInGBs": $OCI_MEMORY_GBS
}
EOF

python3 - "$OCI_SSH_PUBLIC_KEY_FILE" "$metadata_file" <<'PY'
import json
import pathlib
import sys

key_path = pathlib.Path(sys.argv[1])
out_path = pathlib.Path(sys.argv[2])
out_path.write_text(json.dumps({"ssh_authorized_keys": key_path.read_text().strip()}))
PY

attempt=0
echo "Starting OCI A1 acquisition loop at $(timestamp)"
echo "Instance: $INSTANCE_NAME"
echo "Region: $OCI_REGION"
echo "AD: $OCI_AVAILABILITY_DOMAIN"
echo "Shape: VM.Standard.A1.Flex / ${OCI_OCPUS} OCPU / ${OCI_MEMORY_GBS} GB RAM"
echo "Subnet: $OCI_SUBNET_ID"
echo "Image: $OCI_IMAGE_ID"

while true; do
  attempt=$((attempt + 1))
  echo
  echo "Attempt $attempt at $(timestamp)"

  set +e
  output="$(
    oci compute instance launch \
      --region "$OCI_REGION" \
      --availability-domain "$OCI_AVAILABILITY_DOMAIN" \
      --compartment-id "$OCI_COMPARTMENT_ID" \
      --display-name "$INSTANCE_NAME" \
      --shape VM.Standard.A1.Flex \
      --shape-config "file://$shape_config" \
      --image-id "$OCI_IMAGE_ID" \
      --subnet-id "$OCI_SUBNET_ID" \
      --assign-public-ip true \
      --metadata "file://$metadata_file" \
      --freeform-tags '{"managed_by":"codex","purpose":"tfp-a1-free-acquisition"}' \
      --query 'data.{id:id,name:"display-name",state:"lifecycle-state",shape:shape,ocpus:"shape-config".ocpus,memory:"shape-config"."memory-in-gbs"}' \
      --output json 2>&1
  )"
  status=$?
  set -e

  if [[ "$status" -eq 0 ]]; then
    echo "$output"
    echo "OCI A1 instance launch accepted at $(timestamp)."
    exit 0
  fi

  echo "$output"

  if [[ "$RUN_ONCE" == "1" ]]; then
    exit "$status"
  fi

  if [[ "$OCI_MAX_ATTEMPTS" != "0" && "$attempt" -ge "$OCI_MAX_ATTEMPTS" ]]; then
    echo "Reached OCI_MAX_ATTEMPTS=$OCI_MAX_ATTEMPTS; exiting."
    exit "$status"
  fi

  retry_after="$(printf '%s\n' "$output" | awk 'BEGIN{IGNORECASE=1} /retry-after/ {gsub(/[^0-9]/, " "); print $1; exit}')"
  if [[ -n "$retry_after" && "$retry_after" =~ ^[0-9]+$ && "$retry_after" -gt 0 ]]; then
    sleep_for="$retry_after"
  else
    jitter=$((RANDOM % 31))
    sleep_for=$((OCI_RETRY_SLEEP_SECONDS + jitter))
  fi

  echo "Sleeping ${sleep_for}s before retry."
  sleep "$sleep_for"
done
