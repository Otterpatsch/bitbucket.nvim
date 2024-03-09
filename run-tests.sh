#!/usr/bin/env bash
# run_tests.sh

XDG_CONFIG_HOME=$(pwd)/.test-config
export XDG_CONFIG_HOME

source .secrets
nvim --headless -c "PlenaryBustedDirectory tests/bitbucket/ {init = 'tests/init.lua', sequential = true, keep_going=false}"
