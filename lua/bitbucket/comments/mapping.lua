local async_ok, async = pcall(require, "diffview.async")
local notify = require("notify")
local diffview_lib = require("diffview.lib")
local M = {}

function M.expand_tree(tree)
	local updated = false

	for _, node in pairs(tree.nodes.by_id) do
		updated = node:expand() or updated
	end
	if updated then
		tree:render()
	end
end

function M.collapse__tree(tree)
	local updated = false

	for _, node in pairs(tree.nodes.by_id) do
		updated = node:collapse() or updated
	end

	if updated then
		tree:render()
	end
end

function M.add_keymap_actions(comment_split, tree)
	local map_options = { noremap = true, nowait = true }
	--- collpase current node ---
	comment_split:map("n", "g", function()
		local node = tree:get_node()

		if node:collapse() then
			tree:render()
		end
	end, map_options)
	----------------------------

	--- collpase all nodes ---
	comment_split:map("n", "G", function()
		M.collapse__tree(tree)
	end, map_options)
	----------------------------

	-- expand current node
	comment_split:map("n", "e", function()
		local node = tree:get_node()

		if node:expand() then
			tree:render()
		end
	end, map_options)

	--- expand all nodes ---
	comment_split:map("n", "E", function()
		M.expand_tree(tree)
	end, map_options)
	---------------------

	comment_split:map("n", "u", function()
		local node = tree:get_node()
		local lines = {}
		for _, raw_line in ipairs(vim.split(node.text, "\n")) do
			table.insert(lines, raw_line)
		end
		require("bitbucket.requests.init").update_popup(node.id, lines)
	end, map_options)

	comment_split:map("n", "c", function()
		require("bitbucket.requests.init").new_comment_popup()
	end, map_options)

	comment_split:map("n", "r", function()
		local node = tree:get_node()
		require("bitbucket.requests.init").new_comment_popup(node.id)
	end, map_options)

	comment_split:map("n", "d", function()
		local node = tree:get_node()
		if node:has_children() then
			vim.fn.confirm("Can not delete a comment with sub comments.", "&Ok")
			return
		end
		local choice = vim.fn.confirm("Delete comment?", "&Yes\n&No")
		if choice == 1 then
			require("bitbucket.requests.init").delete_comment(node.id, PR_ID)
		end
	end)

	comment_split:map("n", "<leader>j", function()
		local node = tree:get_node()
		if not node.inline then
			return
		end
		M.jump_to_diff(node.inline.file, node.inline.to, node.inline.from)
	end)
end

function M.jump_to_diff(file_path, updated_line, old_line)
	if M.tabnr == nil then
		notify("Can't jump to Diffvew. Is it open?", vim.log.levels.ERROR)
		return
	end
	vim.api.nvim_set_current_tabpage(M.tabnr)
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
			if not async_ok then
				notify("Could not load Diffview async", vim.log.levels.ERROR)
				return
			end
			async.await(view:set_file(file))
			if updated_line ~= vim.NIL then
				layout.b:focus()
				vim.api.nvim_win_set_cursor(0, { tonumber(updated_line), 0 })
			elseif old_line ~= vim.NIL then
				layout.a:focus()
				vim.api.nvim_win_set_cursor(0, { tonumber(old_line), 0 })
			end
			break
		end
	end
end

return M
