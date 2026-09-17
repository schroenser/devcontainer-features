#!/usr/bin/env bash
set -euo pipefail

echo "Activating feature 'claude-settings'"

FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install -D -m 0644 "${FEATURE_DIR}/managed-settings.json" /etc/claude-code/managed-settings.json

# Workaround for a podman/buildah quirk: committing this feature's layer drops
# /tmp from 1777 to 0755, which breaks VS Code's X11 forwarding
touch /tmp/.x && rm /tmp/.x
