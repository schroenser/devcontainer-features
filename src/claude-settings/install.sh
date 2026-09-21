#!/usr/bin/env bash
set -euo pipefail

echo "Activating feature 'claude-settings'"

FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET=/etc/claude-code/managed-settings.json

install -D -m 0644 "${FEATURE_DIR}/managed-settings.json" "$TARGET"

# Option env vars are the option name, uppercased
if [ "${WEAKERNESTEDSANDBOX:-false}" = "true" ]; then
  grep -Eq '"enableWeakerNestedSandbox"[[:space:]]*:[[:space:]]*false' "$TARGET" \
    || { echo "enableWeakerNestedSandbox: false not found in managed-settings.json" >&2; exit 1; }
  sed -i -E 's/("enableWeakerNestedSandbox"[[:space:]]*:[[:space:]]*)false/\1true/' "$TARGET"
  echo "  enableWeakerNestedSandbox: true"
fi

# Workaround for a podman/buildah quirk: committing this feature's layer drops
# /tmp from 1777 to 0755, which breaks VS Code's X11 forwarding
touch /tmp/.x && rm /tmp/.x
