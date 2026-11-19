#!/bin/bash

set -e

source dev-container-features-test-lib

SETTINGS=/etc/claude-code/managed-settings.json

check "jq installed" command -v jq
check "GH_TOKEN masked" jq -e '.sandbox.credentials.envVars[] | select(.name == "GH_TOKEN") | .mode == "mask" and .injectHosts == ["api.github.com"]' "$SETTINGS"
check "GITHUB_TOKEN still denied" jq -e '.sandbox.credentials.envVars | any(.name == "GITHUB_TOKEN" and .mode == "deny")' "$SETTINGS"
check "api.github.com allowed" jq -e '.sandbox.network.allowedDomains | index("api.github.com")' "$SETTINGS"
check "TLS termination enabled" jq -e '.sandbox.network | has("tlsTerminate")' "$SETTINGS"
check "Weaker nested sandbox untouched" jq -e '.sandbox.enableWeakerNestedSandbox == false' "$SETTINGS"

reportResults
