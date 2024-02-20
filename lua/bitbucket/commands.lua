local requests = require("bitbucket.requests.init")

vim.api.nvim_create_user_command("TestComments", function()
	requests.get_comments_by_commit()
end, {})

vim.api.nvim_create_user_command("Clear", function()
	require("lazy.core.loader").reload("bitbucket.nvim")
end, {})

vim.api.nvim_create_user_command("PR", function()
	vim.cmd("DiffviewOpen main")
	requests.get_comments_by_commit()
end, {})
