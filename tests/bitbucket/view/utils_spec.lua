local utils = require("bitbucket.view.utils")
local repo = require("bitbucket.repo")
local NuiTree = require("nui.tree")
local tree = require("bitbucket.view.tree")
local config = require("tests.config")

describe("view utils", function()
	local first = NuiTree.Node({
		text = "Text",
		id = tostring(1),
		parent_id = nil,
	}, {})
	local second = NuiTree.Node({
		text = "Text",
		id = tostring(2),
		parent_id = nil,
	}, {})
	local third = NuiTree.Node({
		text = "Text",
		id = tostring(3),
		parent_id = nil,
	}, {})
	local fourth = NuiTree.Node({
		text = "Text",
		id = tostring(4),
		parent_id = "3",
	}, {})
	it("get root nodes", function()
		local nodes_ids = { "1", "2", "3", "4 " }
		local node_by_id = {
			["1"] = first,
			["4"] = fourth,
			["3"] = third,
			["2"] = second,
		}
		repo.comment_tree = NuiTree({
			bufnr = 0,
			get_node_id = function(node)
				return node.id
			end,
			prepare_node = function(node)
				return ""
			end,
		})
		for _, id in pairs(nodes_ids) do
			tree.add_node_to_tree(id, node_by_id)
		end
		assert.are.same({ first, second, third }, utils.get_root_nodes())
	end)
	it("Nodes by file", function()
		local got = utils.group_node_by_file(config.raw_nodes)
		assert.are.same(2, #config.nodes_by_file["README.md"])
		assert.are.same(1, #config.nodes_by_file["src/fancy/otherfile.py"])
	end)
end)
