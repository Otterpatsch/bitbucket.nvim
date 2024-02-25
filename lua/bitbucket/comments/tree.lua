local NuiTree = require("nui.tree")
local NuiSplit = require("nui.split")
local Line = require("nui.line")
local Text = require("nui.text")
local repo = require("bitbucket.repo")
local mapping = require("bitbucket.comments.mapping")
local M = {}

function M.get_inline_info(inline)
	if not inline then
		return false
	end
	return {
		file = inline["path"],
		from = inline["from"],
		to = inline["to"],
	}
end

local function extract_date(datetime)
	return string.sub(datetime, 1, 10)
end

local function extract_time(datetime)
	return string.sub(datetime, 12, 16)
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

	local node_by_id = M.values_to_nodes(values)

	repo.comment_tree = NuiTree({
		bufnr = comment_split.bufnr,
		get_node_id = function(node)
			-- this is telling NuiTree where we're storing the id
			return node.id
		end,
		prepare_node = function(node)
			local parent_node = node_by_id[node:get_parent_id()]
			return M.node_visualize(node, parent_node)
		end,
	})

	for id in pairs(node_by_id) do
		M.add_node_to_tree(id, node_by_id)
	end
	mapping.add_keymap_actions(comment_split, repo.comment_tree)

	repo.comment_tree:render()
	mapping.expand_tree(repo.comment_tree)
	return comment_split
end

function M.create_node(comment_content, lastchild) --text, author, id, parent_id, date, lastchild, inline, deleted)
	local parent_id = comment_content["parent"] and tostring(comment_content["parent"]["id"]) -- id needs to be string
	local inline = M.get_inline_info(comment_content["inline"])
	local node = NuiTree.Node({
		text = comment_content["content"]["raw"],
		author = comment_content["user"]["display_name"],
		id = tostring(comment_content["id"]),
		parent_id = parent_id,
		date = comment_content["created_on"],
		lastchild = lastchild,
		inline = inline,
		deleted = comment_content["deleted"],
		timestemp = comment_content["timestemp"],
	}, {})
	return node
end

local function add_parent_node(node, nodes)
	local parent_id = node.parent_id
	if parent_id and not repo.comment_tree:get_node(parent_id) then
		local parent_node = nodes[parent_id]
		if parent_node.deleted then
			parent_node.text = "Deleted Comment."
		end
		add_parent_node(parent_node, nodes)
	end
	if not repo.comment_tree:get_node(node.id) then
		repo.comment_tree:add_node(node, parent_id)
	end
end

function M.add_node_to_tree(id, nodes)
	if repo.comment_tree:get_node(id) then
		return
	end

	local node = nodes[id]
	if not node or node.deleted then
		return
	end

	local parent_id = node.parent_id
	if parent_id and not repo.comment_tree:get_node(parent_id) then
		add_parent_node(node, nodes)
	else
		repo.comment_tree:add_node(node, parent_id)
	end
end

function M.values_to_nodes(values)
	local node_by_id = {}
	for _, value in ipairs(values) do
		local id = tostring(value["id"]) -- id needs to be string
		node_by_id[id] = M.create_node(value, false)
	end
	return node_by_id
end

function M.node_visualize(node, parent_node)
	if parent_node then
		local parent_child_ids = parent_node:get_child_ids()
		local last_child = parent_child_ids[#parent_child_ids] == node.id
		node.last_child = last_child and parent_node.last_child
	else
		node.last_child = true
	end

	local line = Line()
	local datetime = node.date
	local line_length = 80
	local header_text = " "
		.. node.author
		.. " at "
		.. extract_time(datetime)
		.. " on "
		.. extract_date(datetime)
		.. " "
	header_text = header_text .. string.rep("─", line_length - string.len(header_text) - node:get_depth())
	if node:is_expanded() then
		if node:get_depth() > 1 then
			line:append("├")
		else
			line:append("╭")
		end
		line:append(string.rep("─", node:get_depth() * 2 - 1) .. header_text)
		local lines = { line }
		for _, raw_line in ipairs(vim.split(node.text, "\n")) do
			table.insert(lines, Line({ Text("│ " .. raw_line) }))
		end
		if not node:has_children() then
			if node.last_child then
				table.insert(lines, Line({ Text("╰" .. string.rep("─", line_length)) }))
				table.insert(lines, Line({}))
			else
				table.insert(lines, Line({ Text("├" .. string.rep("─", line_length)) }))
			end
		end
		return lines
	else
		if parent_node then
			if node.last_child then
				return {
					Line({ Text("├" .. string.rep("─", node:get_depth())), Text(header_text) }),
					Line({}),
				}
			else
				return {
					Line({ Text("├" .. string.rep("─", node:get_depth())), Text(header_text) }),
				}
			end
		else
			return {
				Line({ Text("", "SpecialChar"), Text(header_text) }),
				Line({}),
			}
		end
	end
end

return M
