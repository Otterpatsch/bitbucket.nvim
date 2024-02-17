vim.api.nvim_create_user_command("TestComments", function()
	require("bitbucket").get_comments_by_commit()
end, {})

vim.api.nvim_create_user_command("Clear", function()
	require("lazy.core.loader").reload("bitbucket.nvim")
end, {})
