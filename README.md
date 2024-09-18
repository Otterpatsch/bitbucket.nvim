# bitbucket.nvim

First of all. This plugin is in a very raw state and not feature complete! 

This Neovim plugin is designed to make it easy to review BitBucket PRs ( inspired by [gitlab.nvim](https://github.com/harrisoncramer/gitlab.nvim/)).

- Create, approve, and merge PRs for the current selected branch. ❌
- Read and edit an PR description ✅
- Add or remove reviewers ❌
- Resolve, reply to, and unresolve discussion threads ❌
- Create, edit, delete and solve tasks ❌
- Create, edit, delete, and reply to comments ✅
- View pipeline status ❌
- attach files ❌

## Quick Start

1. Add configuration (not implemented yet)
2. Checkout/switch your feature branch: `git switch feature/branch-name`
3. Open Neovim
4. Run `:lua require("bitbucket").review()` to open the reviewer pane

## Installation

With <a href="https://github.com/folke/lazy.nvim">Lazy</a>:

```lua
return {
  "Otterpatsch/bitbucket.nvim",
        deps = {
                "MunifTanjim/nui.nvim",
                "nvim-lua/plenary.nvim",
                "sindrets/diffview.nvim",
                "stevearc/dressing.nvim",
                "folke/noice.nvim",
                "rcarriga/nvim-notify",
        },
        config = function()
                require("bitbucket")
        end,

}
```

## Connecting to BitBucket

This plugin requires an app password to connect to Bitbucket and your username.  Both are set via environment variable. Both names are not ideal and just currently service as a placeholder during the active development. 

```bash
export APP_PASSWORD="your_app_password"
export USER_NAME="your_username"
```
