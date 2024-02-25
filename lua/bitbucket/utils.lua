local NuiSplit = require("nui.split")
local NuiTree = require("nui.tree")
local Popup = require("nui.popup")
local tree_utils = require("bitbucket.comments.tree")
local mapping = require("bitbucket.comments.mapping")
local repo = require("bitbucket.repo")
local M = {}

function M.create_popup(titel, width, height)
	return Popup({
		position = "50%",
		relative = "editor",
		size = {
			width = width or 100,
			height = height or 30,
		},
		enter = true,
		focusable = true,
		border = {
			style = "rounded",
			text = {
				top = titel,
				top_align = "center",
			},
		},
	})
end

---Function which visualize the overall Pull Request Comments
---@param values table: a table containing all the non removed comments of a Pull Request
---@return NuiTree: tree which contains all the comment nodes
function M.comments_view(values)
	local comment_split = NuiSplit({
		ns_id = "comments",
		relative = "editor",
		position = "bottom",
		size = "35%",
	})

	local node_by_id = tree_utils.values_to_nodes(values)

	repo.comment_tree = NuiTree({
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
		tree_utils.add_node_to_tree(id, node_by_id)
	end
	mapping.add_keymap_actions(comment_split, repo.comment_tree)

	repo.comment_tree:render()
	mapping.expand_tree(repo.comment_tree)
	return comment_split
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

--- Function which concatenates two tables together
---@param first table: first table onto which the second is concatenated
---@param second  table: second table which will be added to the first table
---@return table: combined table
function M.concate_tables(first, second)
	for i = 1, #second do
		first[#first + 1] = second[i]
	end
	return first
end

return M
