M = {}
local curl = require("plenary").curl
local utils = require("bitbucket.utils")
local repo = require("bitbucket.repo")
local Popup = require("nui.popup")
local NuiTree = require("nui.tree")
local mapping = require("bitbucket.tree.mapping")
local NuiSplit = require("nui.split")
local tree_utils = require("bitbucket.tree")
local bitbucket_api = "https://api.bitbucket.org/2.0/repositories/"
local workspace = repo.workspace
local reposlug = repo.reposlug
local username = repo.username
local app_password = repo.app_password
local base_request_url = bitbucket_api .. "/" .. workspace .. "/" .. reposlug .. "/"
local pull_request = {}
local pull_request_id
local discussion_bufnr = nil

function M.get_pull_requests()
	-- get list of pull requests of PR
	-- Just to show where are PR
	-- and their corresponding branch
end

function M.get_comments_by_commit(commithash)
	local pr_id = M.get_pullrequest_by_commit(commithash)
	PR_Comments = M.get_comments(pr_id)
end

function M.get_pullrequest_by_commit(commithash)
	-- Get pullrequests by given commit if none is given?
	-- Special chase if commit is present in multiple PRS
	-- Then popup to choose PR
	local commit = commithash or vim.fn.system("git rev-parse --short HEAD"):gsub("%W", "")
	local request_url = base_request_url .. "commit/" .. commit .. "/pullrequests"
	local response = curl.get(request_url, {
		accept = "application/json",
		auth = username .. ":" .. app_password,
	})
	if response.status ~= 200 then
		error("Failed " .. tostring(response.status) .. " " .. request_url)
	end
	local decoded_result = vim.fn.json_decode(response.body)
	if #decoded_result["values"] ~= 1 then
		error("two elements: handling yet not implemented")
	else
		return tostring(decoded_result["values"][1]["id"])
	end
end

-- Function which visualize the overall Pull Request Comments
-- Comments which are not put on some line of code/are linked to a specific file
function M.get_comments(pr_id)
	pr_id = pr_id or pull_request_id
	local comment_split = NuiSplit({
		ns_id = "comments",
		relative = "editor",
		position = "left",
		size = "35%",
	})
	local request_url = base_request_url .. "/pullrequests/" .. pr_id .. "/comments"
	local values = utils.get_comments_table(request_url)

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

function M.create_pullrequest()
	-- post method
	request_url = base_request_url .. "pullrequests"
	curl.post()
end

require("bitbucket.commands")
return M
