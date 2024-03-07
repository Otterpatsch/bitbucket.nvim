local diffview_lib = require("diffview.lib")
local requests = require("bitbucket.requests.init")
local repo = require("bitbucket.repo")
local tree = require("bitbucket.comments.tree")
M = {}
function M.review()
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
end

return M
