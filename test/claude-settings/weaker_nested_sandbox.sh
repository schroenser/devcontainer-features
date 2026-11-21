#!/bin/bash

set -e

source dev-container-features-test-lib

SETTINGS=/etc/claude-code/managed-settings.json

check "jq installed" command -v jq
check "Weaker nested sandbox enabled" jq -e '.sandbox.enableWeakerNestedSandbox == true' "$SETTINGS"
check "GH_TOKEN still denied" jq -e '.sandbox.credentials.envVars | any(.name == "GH_TOKEN" and .mode == "deny")' "$SETTINGS"
check "gh cache not allowed" jq -e '.sandbox.filesystem.allowWrite == ["~/.npm"] and (.sandbox.filesystem.allowRead | index("~/.cache/gh") | not)' "$SETTINGS"
check "results-receiver not allowed" jq -e '.sandbox.network.allowedDomains | index("results-receiver.actions.githubusercontent.com") | not' "$SETTINGS"

reportResults
