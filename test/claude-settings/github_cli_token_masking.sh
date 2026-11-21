#!/bin/bash

set -e

source dev-container-features-test-lib

SETTINGS=/etc/claude-code/managed-settings.json

check "jq installed" command -v jq
check "GH_TOKEN masked" jq -e '.sandbox.credentials.envVars[] | select(.name == "GH_TOKEN") | .mode == "mask" and .injectHosts == ["api.github.com"]' "$SETTINGS"
check "GITHUB_TOKEN still denied" jq -e '.sandbox.credentials.envVars | any(.name == "GITHUB_TOKEN" and .mode == "deny")' "$SETTINGS"
check "api.github.com allowed" jq -e '.sandbox.network.allowedDomains | index("api.github.com")' "$SETTINGS"
check "results-receiver allowed" jq -e '.sandbox.network.allowedDomains | index("results-receiver.actions.githubusercontent.com")' "$SETTINGS"
check "no wildcard githubusercontent/blob domains" jq -e '.sandbox.network.allowedDomains | all(test("^\\*") | not)' "$SETTINGS"
check "gh cache writable" jq -e '.sandbox.filesystem.allowWrite | index("~/.cache/gh") and index("/.jbdevcontainer/gh") and index("~/.npm")' "$SETTINGS"
check "gh cache readable" jq -e '.sandbox.filesystem.allowRead | index("~/.cache/gh")' "$SETTINGS"
check "cache parent not opened" jq -e '[.sandbox.filesystem.allowWrite[], .sandbox.filesystem.allowRead[]] | all(. != "~/.cache" and . != "/.jbdevcontainer")' "$SETTINGS"
check "home gh cache dir exists" test -d "$HOME/.cache/gh" -a -O "$HOME/.cache/gh"
check "JetBrains gh cache dir exists" test -d /.jbdevcontainer/gh -a -O /.jbdevcontainer/gh
check "TLS termination enabled" jq -e '.sandbox.network | has("tlsTerminate")' "$SETTINGS"
check "Weaker nested sandbox untouched" jq -e '.sandbox.enableWeakerNestedSandbox == false' "$SETTINGS"

reportResults
