local M = {}
local curl = require("plenary").curl
local notify = require("notify")
local utils = require("bitbucket.utils")
local repo = require("bitbucket.repo")
local tree = require("bitbucket.comments.tree")
local bitbucket_api = "https://api.bitbucket.org/2.0/repositories"
local base_request_url = bitbucket_api .. "/" .. repo.workspace .. "/" .. repo.reposlug .. "/"

function M.get_pull_requests()
	-- get list of pull requests of PR
	-- Just to show where are PR
	-- and their corresponding branch
end

---Create the comments_view of a PR
---Calls the responding function to present the comments summary
---view for a pull request which contains the given commithash
---If no commithash is given then the current one is taken
---@param commithash string or nil: commit hash (optional)
---@return NuiTree: table which contains all the comments as nodes
function M.get_comments_by_commit(commithash)
	if repo.pr_id == nil then
		repo.pr_id = M.get_pullrequest_by_commit(commithash)
	end
	if repo.comments == nil then
		repo.comments = M.request_comments_table(repo.pr_id)
	end
	---check if return of request_comments_table is not the same as current comments if so
	if repo.comment_view ~= nil then
		repo.comment_view:unmount()
	end
	repo.comment_view = tree.comments_view(repo.comments)
	repo.comment_view:mount()
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

---Send a request to the bitbucket api to receive all comments on a given Pullrequest
---If multiple pages are existing the values are concatenated
---Afterwards all comments which where deleted are dropped
---@param pr_id string: the pull request id
---@return table: a table containing all the comments of a PR
function M.request_comments_table(pr_id)
	pr_id = pr_id or repo.pr_id
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
	return values, response.status
end

function M.create_pullrequest()
	-- post method
	request_url = base_request_url .. "pullrequests"
	curl.post()
end

---Creates and mount a popup to edit a comment
---@param comment_id string: the id of the comment which should be edited
---@param old_text table: a table which contains lines by string
function M.update_popup(comment_id, old_text)
	local popup = utils.create_popup("Update Comment")
	vim.api.nvim_buf_set_lines(popup.bufnr, 0, #old_text, false, old_text)
	popup:map("n", "<leader><CR>", function()
		local choice = vim.fn.confirm("Update comment?", "&Yes\n&No\n&Quit")
		if choice == 1 then
			new_text = vim.api.nvim_buf_get_lines(popup.bufnr, 0, vim.api.nvim_buf_line_count(popup.bufnr), false)
			local response = M.update_comment(comment_id, repo.pr_id, new_text)
			if response.status ~= 200 then
				notify(response.body, "error")
			elseif response.status == 200 then
				notify("Success", "Info")
				local respone_body = vim.fn.json_decode(response.body)
				local node = repo.comment_tree:get_node(comment_id)
				node.text = respone_body["content"]["raw"]
				node:expand()
				repo.comment_tree:render()
			end
			vim.api.nvim_buf_delete(popup.bufnr, {})
		elseif choice == 3 then
			vim.api.nvim_buf_delete(popup.bufnr, {})
		end
	end, { noremap = true })
	popup:mount()
end

---Creates and mount a popup to edit a comment
---@param parent_id string or nil: the id of the comment which should be edited
function M.new_comment_popup(parent_id)
	local popup = utils.create_popup("Create Comment")
	popup:map("n", "<leader><CR>", function()
		local choice = vim.fn.confirm("Send comment?", "&Yes\n&No\n&Quit")
		if choice == 1 then
			local response = M.new_comment(
				parent_id,
				repo.pr_id,
				vim.api.nvim_buf_get_lines(popup.bufnr, 0, vim.api.nvim_buf_line_count(popup.bufnr), false)
			)
			if response.status ~= 201 then
				notify(response.body, "error")
			elseif response.status == 201 then
				notify("Success", "Info")
				local response_body = vim.fn.json_decode(response.body)
				local node = tree.create_node(response_body, false)
				node:expand()
				repo.comment_tree:add_node(node, parent_id)
				repo.comment_tree:render()
				vim.api.nvim_buf_delete(popup.bufnr, {})
			end
		elseif choice == 3 then
			vim.api.nvim_buf_delete(popup.bufnr, {})
		end
	end, { noremap = true })
	popup:mount()
end

function M.try_to_delete_comment(node_id)
	local response = M.delete_comment(node_id, repo.pr_id)
	if response.status == 204 then
		repo.comment_tree:remove_node(node_id)
		repo.comment_tree:render()
		notify("Comment deleted")
	else
		notify(response.body, "error")
	end
end

---Send a post request to create the comment with the given text
---@param parent_id string or nil: parent id
---@param pr_id string nil: pr id to which the comment belong
---@param new_text string or table: the updated text
---@return table: the response from the api call
function M.new_comment(parent_id, pr_id, new_text)
	new_text = utils.lines_to_raw_text(new_text)
	local request_url = base_request_url .. "pullrequests/" .. pr_id .. "/comments"
	local data = nil

	if parent_id then
		data = vim.fn.json_encode({
			content = {
				raw = new_text,
			},
			parent = {
				id = tonumber(parent_id),
			},
		})
	else
		data = vim.fn.json_encode({
			content = {
				raw = new_text,
			},
		})
	end

	local response = curl.post(request_url, {
		auth = repo.username .. ":" .. repo.app_password,
		body = data,
		headers = {
			content_type = "application/json",
		},
	})
	return response
end

---Send a put request to update the comment with the given text
---@param comment_id string: comment id to update
---@param pr_id string: pr id to which the comment belong
---@param new_text string or table: the updated text
---@return table: the response from the api call
function M.update_comment(comment_id, pr_id, new_text)
	comment_id = tostring(comment_id)
	pr_id = tostring(pr_id)
	new_text = utils.lines_to_raw_text(new_text)
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
	return response
end

---Send a DEL request to del the comment with the given id
---@param comment_id string: comment id to update
---@param pr_id string: pr id to which the comment belong
---@return table: the response from the api call
function M.delete_comment(comment_id, pr_id)
	comment_id = tostring(comment_id)
	pr_id = tostring(pr_id)
	local request_url = base_request_url .. "pullrequests/" .. pr_id .. "/comments/" .. comment_id
	local response = curl.delete(request_url, {
		auth = repo.username .. ":" .. repo.app_password,
	})
	return response
end

return M
