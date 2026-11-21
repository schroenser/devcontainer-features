#!/usr/bin/env bash
set -euo pipefail

echo "Activating feature 'claude-settings'"

FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET=/etc/claude-code/managed-settings.json

# Option env vars are the option name, uppercased
WEAKERNESTEDSANDBOX="${WEAKERNESTEDSANDBOX:-false}"
GITHUBCLITOKENMASKING="${GITHUBCLITOKENMASKING:-false}"

install -D -m 0644 "${FEATURE_DIR}/managed-settings.json" "$TARGET"

ensure_jq() {
  command -v jq >/dev/null 2>&1 && return
  echo "  Installing jq"
  if command -v apt-get >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y --no-install-recommends jq
    rm -rf /var/lib/apt/lists/*
  elif command -v apk >/dev/null 2>&1; then
    apk add --no-cache jq
  elif command -v dnf >/dev/null 2>&1; then
    dnf install -y jq
  elif command -v microdnf >/dev/null 2>&1; then
    microdnf install -y jq
  elif command -v yum >/dev/null 2>&1; then
    yum install -y jq
  else
    echo "jq is required but no supported package manager was found" >&2
    exit 1
  fi
}

# Fails the build if the jq expression does not evaluate to true against $TARGET
require() {
  local filter="$1" message="$2"
  jq -e "$filter" "$TARGET" >/dev/null || { echo "$message" >&2; exit 1; }
}

# Applies a jq filter to $TARGET, keeping its mode
apply() {
  local filter="$1" tmp
  tmp="$(mktemp)"
  jq "$filter" "$TARGET" >"$tmp"
  install -m 0644 "$tmp" "$TARGET"
  rm -f "$tmp"
}

if [ "$WEAKERNESTEDSANDBOX" = "true" ] || [ "$GITHUBCLITOKENMASKING" = "true" ]; then
  ensure_jq
fi

if [ "$WEAKERNESTEDSANDBOX" = "true" ]; then
  require '.sandbox.enableWeakerNestedSandbox == false' \
    "sandbox.enableWeakerNestedSandbox: false not found in managed-settings.json"
  apply '.sandbox.enableWeakerNestedSandbox = true'
  echo "  enableWeakerNestedSandbox: true"
fi

if [ "$GITHUBCLITOKENMASKING" = "true" ]; then
  require '.sandbox.credentials.envVars | any(.name == "GH_TOKEN" and .mode == "deny")' \
    "GH_TOKEN deny entry not found in managed-settings.json"
  apply '
    .sandbox.credentials.envVars |= map(
      if .name == "GH_TOKEN" then .mode = "mask" | .injectHosts = ["api.github.com"] else . end
    )
    | .sandbox.network.allowedDomains |= (. + ["api.github.com", "results-receiver.actions.githubusercontent.com"] | unique)
    | .sandbox.network.tlsTerminate //= {}
    | .sandbox.filesystem.allowWrite |= (. + ["~/.cache/gh", "/.jbdevcontainer/gh"] | unique)
    | .sandbox.filesystem.allowRead |= (. + ["~/.cache/gh"] | unique)
  '
  echo "  GH_TOKEN: masked, injected for api.github.com"

  # gh caches run logs in ${XDG_CACHE_HOME:-~/.cache}/gh. JetBrains dev containers
  # set XDG_CACHE_HOME=/.jbdevcontainer at runtime, so both candidates are allowed.
  # The sandbox ignores paths that don't exist, so create them for the remote user.
  REMOTE_USER="${_REMOTE_USER:-root}"
  REMOTE_USER_HOME="${_REMOTE_USER_HOME:-$(getent passwd "$REMOTE_USER" | cut -d: -f6)}"
  ensure_user_dir() {
    local dir="$1"
    [ -d "$dir" ] && return
    ensure_user_dir "$(dirname "$dir")"
    mkdir "$dir"
    chown "$(id -u "$REMOTE_USER"):$(id -g "$REMOTE_USER")" "$dir"
  }
  ensure_user_dir "${REMOTE_USER_HOME}/.cache/gh"
  ensure_user_dir /.jbdevcontainer/gh
  echo "  gh cache: ${REMOTE_USER_HOME}/.cache/gh and /.jbdevcontainer/gh writable"
fi

# Workaround for a podman/buildah quirk: committing this feature's layer drops
# /tmp from 1777 to 0755, which breaks VS Code's X11 forwarding
touch /tmp/.x && rm /tmp/.x
