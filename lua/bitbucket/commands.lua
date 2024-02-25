local diffview_lib = require("diffview.lib")
local requests = require("bitbucket.requests.init")

vim.api.nvim_create_user_command("TestComments", function()
	requests.get_comments_by_commit()
end, {})

vim.api.nvim_create_user_command("Clear", function()
	require("lazy.core.loader").reload("bitbucket.nvim")
end, {})

vim.api.nvim_create_user_command("PR", function()
	local view = diffview_lib.get_current_view()
	if not view then
		vim.cmd("DiffviewOpen main")
		require("bitbucket.comments.mapping").tabnr = vim.api.nvim_get_current_tabpage()
	end
	requests.get_comments_by_commit()
end, {})
