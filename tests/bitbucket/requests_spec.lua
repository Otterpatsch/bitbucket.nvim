require("diffview").setup()
local requests = require("bitbucket.requests")

describe("api", function()
	it("new_comment", function()
		local response = requests.new_comment(nil, 1, "First Line of Comment\nSecond Line\nThird Line")
		assert.are.same(response.status, 201)
	end)
end)
