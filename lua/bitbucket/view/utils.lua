local async_ok, async = pcall(require, "diffview.async")
local notify = require("notify")
local diffview_lib = require("diffview.lib")
local repo = require("bitbucket.repo")
local signs = require("bitbucket.view.sign")

---Creates and sets the diagonstic signs for each file
---@param comments_by_file
function M.setup_comment_indicators(file, comments)
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
	local layout = view.cur_layout
	for _, node in ipairs(comments) do
		if not async_ok then
			notify("Could not load Diffview async", vim.log.levels.ERROR)
			return
		end
		async.await(view:set_file(file))
		if node.inline.from ~= vim.NIL then
			layout.a:focus()
			local buffer_number = vim.api.nvim_get_current_buf()
			local buffer_name = vim.api.nvim_buf_get_name(buffer_number)
			signs.place_sign_comment(buffer_name .. tostring(node.inline.from), buffer_name, node.inline.from)
		elseif node.inline.to ~= vim.NIl then
			layout.b:focus()
			local buffer_number = vim.api.nvim_get_current_buf()
			local buffer_name = vim.api.nvim_buf_get_name(buffer_number)
			signs.place_sign_comment(buffer_name .. tostring(node.inline.to), buffer_name, node.inline.to)
		end
	end
end

---Get root nodes
function M.get_root_nodes()
	local root_nodes = {}
	local nodes = repo.comment_tree:get_nodes()

	for _, node in ipairs(nodes) do
		if not node:get_parent_id() then
			table.insert(root_nodes, node)
		end
	end
	return root_nodes
end

---Group the given nodes by their file
---@param nodes NuiTree.Node
---@return table: whichs keys are the file and their corresponding comments
function M.group_node_by_file(nodes)
	local nodes_by_file = {}
	for _, node in pairs(nodes) do
		if node.inline then
			if nodes_by_file[node.inline.file] then
				table.insert(nodes_by_file[node.inline.file], node)
			else
				nodes_by_file[node.inline.file] = { node }
			end
		end
	end
	return nodes_by_file
end

return M
