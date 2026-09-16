#!/usr/bin/env bash
set -euo pipefail

echo "Activating feature 'claude-settings'"

FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install -D -m 0644 "${FEATURE_DIR}/managed-settings.json" /etc/claude-code/managed-settings.json
