local M = {}
local curl = require("plenary").curl
local notify = require("notify")
local repo = require("bitbucket.repo")
--
---Send a request to receive the Pull request id by a commithash
---If no commithash is given then the current commit is taken
---@param commithash string: the shortened commit hash
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

return M
