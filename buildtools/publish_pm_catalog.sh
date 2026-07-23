#!/usr/bin/env bash

set -euo pipefail

REPO="${GITHUB_REPOSITORY:?GITHUB_REPOSITORY must be set}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CATALOG_URL="https://github.com/${REPO}/releases/download/ports-latest/ports.json"

# Nothing to publish for an empty (or bottles-only) repo.
if [[ ! -s "$ROOT/docs/ports.json" ]] || [[ "$(jq 'length' "$ROOT/docs/ports.json")" == "0" ]]; then
  echo "No ports in docs/ports.json; skipping PortMaster catalog."
  exit 0
fi

OUT="$(mktemp -d)"
trap 'rm -rf "$OUT"' EXIT

python3 "$ROOT/buildtools/generate_pm_catalog.py" --output "$OUT"

# The .source.json is what PortMaster users install to add this repo as a
# catalog source. Check in docs/<prefix>.source.json to control the
# prefix/display name, or let this script generate one from the repo name.
SRC_JSON=$(find "$ROOT/docs" -maxdepth 1 -name '*.source.json' 2>/dev/null | head -n1 || true)
if [[ -z "$SRC_JSON" ]]; then
  REPO_NAME="${REPO#*/}"
  PREFIX=$(echo "$REPO_NAME" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9')
  SRC_JSON="$OUT/${PREFIX}.source.json"
  jq -n --arg prefix "$PREFIX" --arg name "$REPO_NAME" --arg url "$CATALOG_URL" \
    '{prefix: $prefix, api: "PortMasterV3", name: $name, url: $url, last_checked: null, version: 1, data: {}}' \
    > "$SRC_JSON"
fi

# Skip images if they haven't changed
if curl -sfL -o "$OUT/current_catalog.json" "$CATALOG_URL"; then
  if cmp -s "$OUT/current_catalog.json" "$OUT/ports.json"; then
    echo "PortMaster catalog unchanged; skipping upload."
    exit 0
  fi
  OLD_MD5=$(jq -r '.utils["images.zip"].md5 // empty' "$OUT/current_catalog.json" || true)
  NEW_MD5=$(md5sum "$OUT/images.zip" | awk '{print $1}')
  if [[ -n "$OLD_MD5" && "$OLD_MD5" == "$NEW_MD5" ]]; then
    echo "images.zip unchanged; uploading catalog only."
    gh release upload ports-latest "$OUT/ports.json" "$SRC_JSON" --clobber
    exit 0
  fi
fi

gh release upload ports-latest \
  "$OUT/ports.json" \
  "$OUT/images.zip" \
  "$SRC_JSON" \
  --clobber
