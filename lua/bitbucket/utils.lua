local NuiSplit = require("nui.split")
local NuiTree = require("nui.tree")
local Popup = require("nui.popup")
local tree_utils = require("bitbucket.tree")
local mapping = require("bitbucket.tree.mapping")
local M = {}

M.center_popup = Popup({
	position = "50%",
	size = {
		width = "80%",
		height = "60%",
	},
	enter = true,
	focusable = true,
	border = {
		style = "rounded",
		text = {
			top = "Request Content",
			top_align = "center",
		},
	},
})

-- Function which visualize the overall Pull Request Comments
-- Comments which are not put on some line of code/are linked to a specific file
function M.comments_view(values)
	local comment_split = NuiSplit({
		ns_id = "comments",
		relative = "editor",
		position = "bottom",
		size = "35%",
	})

	local node_by_id = tree_utils.values_to_nodes(values)

	local tree = NuiTree({
		bufnr = comment_split.bufnr,
		get_node_id = function(node)
			-- this is telling NuiTree where we're storing the id
			return node.id
		end,
		prepare_node = function(node)
			local parent_node = node_by_id[node:get_parent_id()]
			return tree_utils.node_visualize(node, parent_node)
		end,
	})

	for id in pairs(node_by_id) do
		tree_utils.add_node_to_tree(id, tree, node_by_id)
	end
	mapping.add_keymap_actions(comment_split, tree)

	tree:render()
	mapping.expand_tree(tree)
	comment_split:mount()
	return values
end

function M.dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. M.dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end

function M.create_vertial_split()
	vim.cmd("vsplit")
	local active_window = vim.api.nvim_get_current_win()
	local buffer_number = vim.api.nvim_create_buf(true, true)
	vim.api.nvim_win_set_buf(active_window, buffer_number)
	return buffer_number
end

function M.concate_tables(first, second)
	for i = 1, #second do
		first[#first + 1] = second[i]
	end
	return first
end

return M
