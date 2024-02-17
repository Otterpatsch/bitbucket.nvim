local NuiTree = require("nui.tree")
local Line = require("nui.line")
local Text = require("nui.text")
local M = {}

function M.add_node_to_tree(id, sometree, nodes)
	if sometree:get_node(id) then
		return
	end

	local node = nodes[id]
	if not node then
		return
	end

	local parent_id = node.parent_id
	if parent_id and not sometree:get_node(parent_id) then
		M.add_node_to_tree(parent_id, sometree, nodes)
	end
	sometree:add_node(node, parent_id)
end

function M.values_to_nodes(values)
	local node_by_id = {}
	for _, value in ipairs(values) do
		local text = value["content"]["raw"]
		local author = value["user"]["display_name"]
		local id = tostring(value["id"]) -- id needs to be string
		local parent_id = value["parent"] and tostring(value["parent"]["id"]) -- id needs to be string
		local inline = value["inline"]
		local node = NuiTree.Node({
			text = text,
			author = author,
			id = id,
			parent_id = parent_id,
			date = value["created_on"],
			lastchild = false,
			inline = M.get_inline_info(inline),
		}, {})
		node_by_id[id] = node
	end
	return node_by_id
end

function M.extract_date(datetime)
	return string.sub(datetime, 1, 10)
end

function M.extract_time(datetime)
	return string.sub(datetime, 12, 16)
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
		.. M.extract_time(datetime)
		.. " on "
		.. M.extract_date(datetime)
		.. " "
	header_text = header_text .. string.rep("─", line_length - string.len(header_text) - node:get_depth())
	if node:is_expanded() then
		if node:get_depth() > 1 then
			line:append("├")
		else
			line:append("╭")
		end
		line:append(string.rep("─", node:get_depth()) .. header_text)
		local lines = { line }
		for _, raw_line in ipairs(vim.split(node.text, "\n")) do
			table.insert(lines, Line({ Text("│ " .. raw_line) }))
		end
		if not node:has_children() then
			table.insert(lines, Line({ Text("╰─" .. string.rep("─", line_length)) }))
			if node.last_child then
				table.insert(lines, Line({}))
			end
		else
			table.insert(lines, Line({ Text("│") }))
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

return M
