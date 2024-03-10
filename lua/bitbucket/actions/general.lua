local M = {}
local curl = require("plenary").curl
local notify = require("notify")
local repo = require("bitbucket.repo")

---Send a request to receive the Pull request id by a commithash
---If no commithash is given then the current commit is taken
---@param commithash string|nil: the shortened commit hash
---@return string: pull request id
function M.get_pullrequest_by_commit(commithash)
	local commit = commithash or vim.fn.system("git rev-parse --short HEAD"):gsub("%W", "")
	local request_url = repo.base_request_url .. "commit/" .. commit .. "/pullrequests"
	local response = curl.get(request_url, {
		accept = "application/json",
		auth = repo.username .. ":" .. repo.app_password,
	})
	local decoded_result = vim.fn.json_decode(response.body)
	if #decoded_result["values"] ~= 1 then
		-- Special chase if commit is present in multiple PRS
		-- Then popup to choose PR
		error("two elements: handling yet not implemented")
	else
		return tostring(decoded_result["values"][1]["id"]), response.status
	end
end

---Send a request to get the summary of a given pr id.
---@param pr_id string|nil: optional if none is given the repo.pr_id is used
function M.get_pullrequest_summary(pr_id)
	pr_id = pr_id or repo.pr_id
	local request_url = repo.base_request_url .. "pullrequests/" .. pr_id
	local response = curl.get(request_url, {
		accept = "application/json",
		auth = repo.username .. ":" .. repo.app_password,
	})
	local content = vim.fn.json_decode(response.body)
	if response.status ~= 200 then
		notify(content, "Error")
		return {
			status = response.status,
			content = content,
		}
	else
		-- Attributes which might be useful
		-- destination.commit.hash
		-- closed_by = content.closed_by.nickname,
		local closed_by = false
		if content.closed_by ~= vim.NIL then
			closed_by = content.closed_by.nickname
		end
		return {
			status = 200,
			title = content.title,
			summary = content.summary.raw,
			state = content.state,
			close_source_branch = content.close_source_branch,
			author = content.author.nickname,
			closed_by = closed_by,
			destination_branch = content.destination.branch.name,
			source_branch = content.source.branch.name,
			reviewers = content.reviewers,
		}
	end
end

return M
