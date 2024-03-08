local async_ok, async = pcall(require, "diffview.async")
local notify = require("notify")
local diffview_lib = require("diffview.lib")
local repo = require("bitbucket.repo")
local signs = require("bitbucket.view.sign")

---Creates and sets the diagonstic signs for each file
---@param comments_by_file
function M.setup_comment_indicators(file_path, comments)
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
		if file.path == file_path then
			notify(file.path)
			if not async_ok then
				notify("Could not load Diffview async", vim.log.levels.ERROR)
				return
			end
			async.await(view:set_file(file))
			-- TODO if old line then layout a else layout b
			-- layout.a.file.bufnr
			layout.a:focus()
			local buffer_number = vim.api.nvim_get_current_buf()
			local buffer_name = vim.api.nvim_buf_get_name(buffer_number)
			signs.place_sign_comment(tostring(file.path), buffer_name, 1)
			layout.b:focus()
			local buffer_number = vim.api.nvim_get_current_buf()
			local buffer_name = vim.api.nvim_buf_get_name(buffer_number)
			signs.place_sign_comment(tostring(file.path), buffer_name, 1)
			break
		end
	end
end

function M.get_root_nodes()
	local root_nodes = {}
	for _, node in ipairs(repo.comment_tree:get_nodes()) do
		if not node:get_parent_id() then
			table.insert(root_nodes, node)
		end
	end
	return root_nodes
end

function M.group_node_by_file(nodes)
	local nodes_by_file = {}
	for _, node in ipairs(nodes) do
		if nodes[node.inline.file] then
			table.insert(nodes[node.inline.file], node)
		else
			nodes[node.inline.file] = { node }
		end
	end
	return nodes_by_file
end

return M
