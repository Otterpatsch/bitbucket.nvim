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

return M
