require("bitbucket.commands")
M = {}
local curl = require("plenary").curl
local utils = require("bitbucket.utils")
local repo = require("bitbucket.repo")
local bitbucket_api = "https://api.bitbucket.org/2.0/repositories"
local workspace = repo.workspace
local reposlug = repo.reposlug
local username = repo.username
local app_password = repo.app_password
local base_request_url = bitbucket_api .. "/" .. workspace .. "/" .. reposlug .. "/"

function M.get_pull_requests()
	-- get list of pull requests of PR
	-- Just to show where are PR
	-- and their corresponding branch
end

---Create the comments_view of a PR
---Calls the responding function to present the comments summary
---view for a pull request which contains the given commithash
---If no commithash is given then the current one is taken
---@param commithash string: commit hash (optional)
---@return NuiTree: table which contains all the comments as nodes
function M.get_comments_by_commit(commithash)
	PR_ID = M.get_pullrequest_by_commit(commithash)
	PR_Comments = M.request_comments_table(PR_ID)
	CommentTree = utils.comments_view(PR_Comments)
	return CommentTree
end

---Send a request to receive the Pull request id by a commithash
---If no commithash is given then the current commit is taken
---@param commithash string: the shortened commit hash
---@return string: pull request id
function M.get_pullrequest_by_commit(commithash)
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
		-- Special chase if commit is present in multiple PRS
		-- Then popup to choose PR
		error("two elements: handling yet not implemented")
	else
		return tostring(decoded_result["values"][1]["id"])
	end
end

---Send a request to the bitbucket api to receive all comments on a given Pullrequest
---If multiple pages are existing the values are concatenated
---Afterwards all comments which where deleted are dropped
---@param pr_id string: the pull request id
---@return table: a table containing all the comments of a PR
function M.request_comments_table(pr_id)
	pr_id = pr_id or PR_ID
	local request_url = base_request_url .. "/pullrequests/" .. pr_id .. "/comments"
	local response = curl.get(request_url, {
		accept = "application/json",
		auth = repo.username .. ":" .. repo.app_password,
	})
	local content = vim.fn.json_decode(response.body)
	local values = content["values"]
	while content["next"] do
		request_url = content["next"]
		response = curl.get(request_url, {
			accept = "application/json",
			auth = repo.username .. ":" .. repo.app_password,
		})
		content = vim.fn.json_decode(response.body)
		values = utils.concate_tables(values, content["values"])
	end
	for index, value in ipairs(values) do
		if value["deleted"] then
			table.remove(values, index)
		end
	end
	return values
end

function M.create_pullrequest()
	-- post method
	request_url = base_request_url .. "pullrequests"
	curl.post()
end

---Creates and mount a popup to edit a comment
---@param comment_id string: the id of the comment which should be edited
---@param old_text table: a table which contains lines by string
function M.comment_popup(comment_id, old_text)
	local popup = utils.create_popup("Update Comment")
	vim.api.nvim_buf_set_lines(popup.bufnr, 0, #old_text, false, old_text)
	popup:map("n", "<leader><CR>", function()
		M.update_comment(
			comment_id,
			PR_ID,
			vim.api.nvim_buf_get_lines(popup.bufnr, 0, vim.api.nvim_buf_line_count(popup.bufnr), false)
		)
		-- TODO
		-- use notify to notify user of response.status
		--   403 permission denied
		--   200 success
		--   and so on
		-- update node itself on success
		--   have global tree
		--   update node.text
		--   rerender tree
	end, { noremap = true })
	popup:mount()
end

---Send a put request to update the comment with the given text
---@param comment_id string: comment id to update
---@param pr_id string: pr id to which the comment belong
---@param new_text string or table: the updated text
---@return table: the response from the api call
function M.update_comment(comment_id, pr_id, new_text)
	comment_id = tostring(comment_id)
	pr_id = tostring(pr_id)
	if type(new_text) == "table" then
		new_text = table.concat(new_text, "\n")
	end
	local request_url = base_request_url .. "pullrequests/" .. pr_id .. "/comments/" .. comment_id
	local data = vim.fn.json_encode({
		content = {
			raw = new_text,
		},
	})
	local response = curl.put(request_url, {
		auth = repo.username .. ":" .. repo.app_password,
		body = data,
		headers = {
			content_type = "application/json",
		},
	})
	if response.status ~= 200 then
		error("Failed with " .. tostring(response.status) .. "\n" .. utils.dump(response.body))
	end
	return response
end

return M
