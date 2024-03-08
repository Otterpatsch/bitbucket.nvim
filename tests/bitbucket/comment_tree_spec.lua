require("diffview").setup()
local repo = require("bitbucket.repo")
local requests = require("bitbucket.actions.comments")
local tree = require("bitbucket.view.tree")
local utils = require("bitbucket.utils")
describe("helper functions", function()
	local node_id = nil
	it("handle_request_new_comment", function()
		local bufnr = utils.create_vertial_split()
		vim.api.nvim_buf_set_lines(bufnr, 1, 2, false, { "abc", "def" })
		repo.pr_id = 1
		local values, status = requests.request_comments_table("1")
		tree.comments_view(values)
		node_id = requests.handle_request_new_comment(bufnr, nil)
		requests.delete_comment(node_id)
	end)
	it("update comment(chose yes)", function()
		utils.confirm = function()
			return 1
		end
		local bufnr = utils.create_vertial_split()
		local lines = { "updated text", "SOme other line" }
		vim.api.nvim_buf_set_lines(bufnr, 0, #lines, false, lines)
		local pr_id = "1"
		local reponse = requests.handle_request_update_comment(bufnr, node_id, pr_id)
		local reponse_body = vim.fn.json_decode(reponse.body)
		assert.are.same("updated text  \nSOme other line", reponse_body.content.raw)
		requests.delete_comment(node_id)
	end)
	it("update comment(chose quit)", function()
		utils.confirm = function()
			return 3
		end
		local bufnr = utils.create_vertial_split()
		local lines = { "updated text", "SOme other line" }
		vim.api.nvim_buf_set_lines(bufnr, 0, #lines, false, lines)
		local pr_id = "1"
		local reponse = requests.handle_request_update_comment(bufnr, node_id, pr_id)
		assert.are.same(false, reponse)
		requests.delete_comment(node_id)
	end)
end)
