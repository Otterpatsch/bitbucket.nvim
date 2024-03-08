local async_ok, async = pcall(require, "diffview.async")
local notify = require("notify")
local diffview_lib = require("diffview.lib")
local repo = require("bitbucket.repo")
local signs = require("bitbucket.view.sign")

---Creates and sets the diagonstic signs for each file
---@param comments_by_file
function M.setup_comment_indicators(comments_by_file)
	if repo.tabnr == nil then
		notify("Can't jump to Diffvew. Is it open?", vim.log.levels.ERROR)
		return
	end
	vim.api.nvim_set_current_tabpage(repo.tabnr)
	vim.cmd("DiffviewFocusFiles")
	local view = diffview_lib.get_current_view()
	if view == nil then
		notify("Could not find Diffview view", vim.log.levels.ERROR)
		return
	end
	local files = view.panel:ordered_file_list()
	local layout = view.cur_layout
	for _, file in ipairs(files) do
		notify(file.path)
		--local comments_of_file = comments_by_file[file.path]
		--for _, comment in iparis(comments_of_file) do
		if not async_ok then
			notify("Could not load Diffview async", vim.log.levels.ERROR)
			return
		end
		async.await(view:set_file(file))
		-- TODO if old line then layout a else layout b
		layout.a:focus()
		local buffer_number = vim.api.nvim_get_current_buf()
		local buffer_name = vim.api.nvim_buf_get_name(buffer_number)
		signs.place_sign_comment(tostring(file.path), buffer_name, 1)
		--end
	end
end

return M
