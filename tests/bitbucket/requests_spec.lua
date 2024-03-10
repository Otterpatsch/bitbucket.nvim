local requests = require("bitbucket.actions.comments")
local general = require("bitbucket.actions.general")

describe("api comments", function()
	local comment_id = nil
	it("new_comment", function()
		local text = {
			"First Line of Comment",
			"Second Line",
			"Third Line",
		}
		local response = requests.send_request_to_add_comment(nil, PR_ID, text)
		local body = vim.fn.json_decode(response.body)
		local expected_comment = "First Line of Comment  \nSecond Line  \nThird Line"
		comment_id = tostring(body["id"])
		assert.are.same(201, response.status)
		assert.are.same(expected_comment, body.content.raw)
	end)
	it("update comment", function()
		local text = { "First Line", "Third Line" }
		assert.are.same("string", type(comment_id))
		local response = requests.send_request_to_update_comment(comment_id, PR_ID, text)
		local body = vim.fn.json_decode(response.body)
		local expected_comment = "First Line  \nThird Line"
		assert.are.same(200, response.status)
		assert.are.same(expected_comment, body.content.raw)
	end)
	it("reply to a comment", function()
		local text = "Reply (Test)"
		local response = requests.send_request_to_add_comment(comment_id, PR_ID, text)
		local body = vim.fn.json_decode(response.body)
		assert.are.same(201, response.status)
		assert.are.same("Reply (Test)", body.content.raw)
		assert.are.same(comment_id, tostring(body.parent.id))
		response = requests.send_request_to_delete_comment(tostring(body.id), PR_ID)
		assert.are.same(204, response.status)
	end)
	it("delete comment", function()
		local response = requests.send_request_to_delete_comment(comment_id, PR_ID)
		assert.are.same(204, response.status)
	end)
	it("new_comment(Single Line)", function()
		local text = "Single Line"
		local response = requests.send_request_to_add_comment(nil, PR_ID, text)
		local body = vim.fn.json_decode(response.body)
		local expected_comment = "Single Line"
		assert.are.same(201, response.status)
		assert.are.same(expected_comment, body.content.raw)
		response = requests.send_request_to_delete_comment(body["id"], PR_ID)
		assert.are.same(204, response.status)
	end)
	it("get all comments", function()
		local values, status = requests.request_comments_table(PR_ID)
		assert.are.same("table", type(values))
		assert.are.same(200, status)
	end)
	it("get pullrequests by commithash", function()
		local pullrequest_id, status = general.get_pullrequest_by_commit("3400495")
		assert.are.same(PR_ID, pullrequest_id)
		assert.are.same(200, status)
	end)
end)
