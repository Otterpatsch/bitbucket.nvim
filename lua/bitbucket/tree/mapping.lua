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
		require("bitbucket.init").comment_popup(node.id, lines)
	end, map_options)

	comment_split:map("n", "c", function()
		require("bitbucket.init").comment_creation_popup("", lines)
	end, map_options)
end

return M
