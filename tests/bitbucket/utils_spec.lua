local utils = require("bitbucket.utils")

describe("utils", function()
	it("concate table", function()
		local first = { 1 }
		local second = { 2, 3 }
		local got = utils.concate_tables(first, second)
		local want = { 1, 2, 3 }
		assert.are.same(want, got)
	end)
end)
