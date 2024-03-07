--- User Commands
local diffview_lib = require("diffview.lib")
local requests = require("bitbucket.requests.init")
local repo = require("bitbucket.repo")
local tree = require("bitbucket.comments.tree")
local actions = require("bitbucket.comments.mapping")

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
		repo.tabnr = vim.api.nvim_get_current_tabpage()
	end
	requests.get_comments_by_commit()
	---check if return of request_comments_table is not the same as current comments if so
	if repo.comment_view ~= nil then
		repo.comment_view:unmount()
	end
	repo.comment_view = tree.comments_view(repo.comments)
	repo.comment_view:mount()
end, {})
