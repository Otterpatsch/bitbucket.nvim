local general = require("bitbucket.actions.general")
local repo = require("bitbucket.repo")

describe("api general", function()
	it("get pullrequests by commithash", function()
		local pullrequest_id, status = general.get_pullrequest_by_commit("3400495")
		assert.are.same(PR_ID, pullrequest_id)
		assert.are.same(200, status)
	end)
	it("get summary of pullrequest", function()
		repo.pr_id = PR_ID
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
