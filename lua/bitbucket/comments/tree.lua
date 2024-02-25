local NuiTree = require("nui.tree")
local Line = require("nui.line")
local Text = require("nui.text")
local M = {}

local function get_inline_info(inline)
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

local function create_node(text, author, id, parent_id, date, lastchild, inline, deleted)
	local node = NuiTree.Node({
		text = text,
		author = author,
		id = id,
		parent_id = parent_id,
		date = date,
		lastchild = lastchild,
		inline = inline,
		deleted = deleted,
	}, {})
	return node
end

local function add_parent_node(node, sometree, nodes)
	local parent_id = node.parent_id
	if parent_id and not sometree:get_node(parent_id) then
		local parent_node = nodes[parent_id]
		if parent_node.deleted then
			parent_node.text = "Deleted Comment."
		end
		add_parent_node(parent_node, sometree, nodes)
	end
	if not sometree:get_node(node.id) then
		sometree:add_node(node, parent_id)
	end
end

function M.add_node_to_tree(id, sometree, nodes)
	if sometree:get_node(id) then
		return
	end

	local node = nodes[id]
	if not node or node.deleted then
		return
	end

	local parent_id = node.parent_id
	if parent_id and not sometree:get_node(parent_id) then
		add_parent_node(node, sometree, nodes)
	else
		sometree:add_node(node, parent_id)
	end
end

function M.values_to_nodes(values)
	local node_by_id = {}
	for _, value in ipairs(values) do
		local text = value["content"]["raw"]
		local author = value["user"]["display_name"]
		local id = tostring(value["id"]) -- id needs to be string
		local parent_id = value["parent"] and tostring(value["parent"]["id"]) -- id needs to be string
		local inline = get_inline_info(value["inline"])
		local deleted = value["deleted"]
		node_by_id[id] = create_node(text, author, id, parent_id, value["created_on"], false, inline, deleted)
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
