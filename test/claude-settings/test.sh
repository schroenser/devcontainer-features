#!/bin/bash

set -e

source dev-container-features-test-lib

check "Settings file created" cat /etc/claude-code/managed-settings.json | grep 'sandbox'

reportResults
