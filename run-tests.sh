#!/usr/bin/env bash
# run_tests.sh

XDG_CONFIG_HOME=$(pwd)/.test-config
export XDG_CONFIG_HOME
export WORKSPACE=$TEST_WORKSPACE
export REPOSLUG=$TEST_REPOSLUG

source .secrets
nvim --headless -c "PlenaryBustedDirectory tests/bitbucket/ {init = 'tests/init.lua', sequential = true, keep_going=false}"
