#!/usr/bin/env bash
# run_tests.sh

XDG_CONFIG_HOME=$(pwd)/.test-config
export XDG_CONFIG_HOME

nvim --headless -c "PlenaryBustedDirectory tests/bitbucket/"
