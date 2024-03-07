--- User Commands
local actions = require("bitbucket.actions")

vim.api.nvim_create_user_command("Clear", function()
	require("lazy.core.loader").reload("bitbucket.nvim")
end, {})

vim.api.nvim_create_user_command("PR", actions.review, {})
