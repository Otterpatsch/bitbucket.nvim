local general = require("bitbucket.actions.general")
local repo = require("bitbucket.repo")

describe("api general", function()
	local pr_id = "2"
	it("curl", function()
		local curl = require("plenary").curl
		local request_url = repo.base_request_url
		print(request_url)
		local response = curl.get(request_url, {
			accept = "application/json",
			auth = repo.username .. ":" .. repo.app_password,
		})
		assert.are.same(200, response.status)
	end)
	it("get pullrequests by commithash", function()
		local pullrequest_id, status = general.get_pullrequest_by_commit("3400495")
		assert.are.same(pr_id, pullrequest_id)
		assert.are.same(200, status)
	end)
	it("get summary of pullrequest", function()
		repo.pr_id = pr_id
		local got = general.get_pullrequest_summary()
		local expected = {
			title = "Tests/branch for tests",
			state = "OPEN",
			author = "Ott Otterson",
			closed_by = false,
		}
		assert.are.same(expected.title, got.title)
		assert.are.same(expected.state, got.state)
		assert.are.same(expected.author, got.author)
		assert.are.same(expected.closed_by, got.closed_by)
	end)
end)
