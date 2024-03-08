--- User Commands
local review = require("bitbucket.actions.review")

vim.api.nvim_create_user_command("Clear", function()
	require("lazy.core.loader").reload("bitbucket.nvim")
end, {})

vim.api.nvim_create_user_command("PR", review.review, {})
