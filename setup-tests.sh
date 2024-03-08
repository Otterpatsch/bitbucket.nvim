#!/usr/bin/env bash
# setup-tests.sh

PACK_DIR=./.test-config/nvim/pack/tests/start

mkdir -p "$PACK_DIR"
git clone https://github.com/nvim-lua/plenary.nvim.git "$PACK_DIR/plenary.nvim"
git clone https://github.com/MunifTanjim/nui.nvim.git "$PACK_DIR/nui.nvim"
git clone https://github.com/carriga/nvim-notify.git "$PACK_DIR/notify.nvim"
git clone https://github.com/sindrets/diffview.nvim.git "$PACK_DIR/diffview.nvim"
