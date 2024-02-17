NuiTree = require("nui.tree")
local M = {}

function M.add_node_to_tree(node_by_id, currenttree)
	for id in pairs(node_by_id) do
		local node = currenttree:get_node(id)
		if node then
			return
		end

		node = node_by_id[id]
		if not node then
			return
		end

		local parent_id = node.parent_id
		if parent_id and not currenttree:get_node(parent_id) then
			-- ensure parent is added before the child
			M.add_node_to_tree(parent_id, currenttree)
		end
		currenttree:add_node(node, parent_id)
	end
end

function M.values_to_nodes(values)
	local node_by_id = {}
	for _, value in ipairs(values) do
		local text = value["content"]["raw"]
		local author = value["user"]["display_name"]
		local id = tostring(value["id"]) -- id needs to be string
		local parent_id = value["parent"] and tostring(value["parent"]["id"]) -- id needs to be string
		local node = NuiTree.Node({
			text = text,
			author = author,
			id = id,
			parent_id = parent_id,
			date = value["created_on"],
		}, {})
		node_by_id[id] = node
	end
	return node_by_id
end

return M
