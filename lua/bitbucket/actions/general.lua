local M = {}
local curl = require("plenary").curl
local notify = require("notify")
local repo = require("bitbucket.repo")
local summary_layout = require("bitbucket.actions.summary_layout").create_summary_layout()

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
function M.get_pullrequest_summary()
	local request_url = repo.base_request_url .. "pullrequests/" .. repo.pr_id
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

function M.summary()
	local layout = summary_layout.layout
	local title_bufnr = summary_layout.title_bufnr
	local summary_bufnr = summary_layout.summary_bufnr
	local info_bufnr = summary_layout.info_bufnr

	local content = M.get_pullrequest_summary(true)
	local summary = {}
	for _, line in ipairs(vim.split(content.summary, "\n")) do
		table.insert(summary, line)
	end
	layout:mount()
	vim.api.nvim_buf_set_lines(title_bufnr, 0, 1, false, { content.title })
	vim.api.nvim_buf_set_option(title_bufnr, "modifiable", false)
	vim.api.nvim_buf_set_lines(summary_bufnr, 0, #summary, false, summary)
	vim.api.nvim_buf_set_option(summary_bufnr, "modifiable", false)
end

return M
