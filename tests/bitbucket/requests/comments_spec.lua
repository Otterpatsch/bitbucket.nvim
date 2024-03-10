local requests = require("bitbucket.actions.comments")
local repo = require("bitbucket.repo")

describe("api comments", function()
	local comment_id = nil
	it("new_comment", function()
		local text = {
			"First Line of Comment",
			"Second Line",
			"Third Line",
		}
		repo.pr_id = PR_ID
		local response = requests.send_request_to_add_comment(nil, text)
		local body = vim.fn.json_decode(response.body)
		local expected_comment = "First Line of Comment  \nSecond Line  \nThird Line"
		comment_id = tostring(body["id"])
		assert.are.same(201, response.status)
		assert.are.same(expected_comment, body.content.raw)
	end)
	it("update comment", function()
		local text = { "First Line", "Third Line" }
		assert.are.same("string", type(comment_id))
		repo.pr_id = PR_ID
		local response = requests.send_request_to_update_comment(comment_id, text)
		local body = vim.fn.json_decode(response.body)
		local expected_comment = "First Line  \nThird Line"
		assert.are.same(200, response.status)
		assert.are.same(expected_comment, body.content.raw)
	end)
	it("reply to a comment", function()
		local text = "Reply (Test)"
		repo.pr_id = PR_ID
		local response = requests.send_request_to_add_comment(comment_id, text)
		local body = vim.fn.json_decode(response.body)
		assert.are.same(201, response.status)
		assert.are.same("Reply (Test)", body.content.raw)
		assert.are.same(comment_id, tostring(body.parent.id))
		response = requests.send_request_to_delete_comment(tostring(body.id))
		assert.are.same(204, response.status)
	end)
	it("delete comment", function()
		repo.pr_id = PR_ID
		local response = requests.send_request_to_delete_comment(comment_id)
		assert.are.same(204, response.status)
	end)
	it("new_comment(Single Line)", function()
		repo.pr_id = PR_ID
		local text = "Single Line"
		local response = requests.send_request_to_add_comment(nil, text)
		local body = vim.fn.json_decode(response.body)
		local expected_comment = "Single Line"
		assert.are.same(201, response.status)
		assert.are.same(expected_comment, body.content.raw)
		response = requests.send_request_to_delete_comment(body["id"])
		assert.are.same(204, response.status)
	end)
	it("get all comments", function()
		repo.pr_id = PR_ID
		local values, status = requests.request_comments_table(PR_ID)
		assert.are.same("table", type(values))
		assert.are.same(200, status)
	end)
end)
