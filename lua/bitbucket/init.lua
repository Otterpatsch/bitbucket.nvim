require("bitbucket.commands")
M = {}
local curl = require("plenary").curl
local utils = require("bitbucket.utils")
local repo = require("bitbucket.repo")
local Popup = require("nui.popup")
local bitbucket_api = "https://api.bitbucket.org/2.0/repositories"
local workspace = repo.workspace
local reposlug = repo.reposlug
local username = repo.username
local app_password = repo.app_password
local base_request_url = bitbucket_api .. "/" .. workspace .. "/" .. reposlug .. "/"
local pull_request = {}
local discussion_bufnr = nil

function M.get_pull_requests()
	-- get list of pull requests of PR
	-- Just to show where are PR
	-- and their corresponding branch
end

function M.get_comments_by_commit(commithash)
	PR_ID = M.get_pullrequest_by_commit(commithash)
	print(PR_ID)
	local comments = M.get_comments_table(PR_ID)
	PR_Comments = utils.comments_view(comments)
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

function M.get_comments_table(pr_id)
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

function M.comment_popup(comment_id, old_text)
	local popup = utils.create_popup("Update Comment")
	vim.api.nvim_buf_set_lines(popup.bufnr, 0, #old_text, false, old_text)
	popup:map("n", "<leader><CR>", function()
		M.update_comment(
			comment_id,
			PR_ID,
			vim.api.nvim_buf_get_lines(popup.bufnr, 0, vim.api.nvim_buf_line_count(popup.bufnr), false)
		)
	end, { noremap = true })
	popup:mount()
end

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
