local discussion_sign_name = "bitbucket_discussion"
local discussion_helper_sign_start = "bitbucket_discussion_helper_start"
local discussion_helper_sign_mid = "bitbucket_discussion_helper_mid"
local discussion_helper_sign_end = "bitbucket_discussion_helper_end"
local diagnostics_namespace = vim.api.nvim_create_namespace(discussion_sign_name)

M = {}

local function define_sign_icon()
	vim.fn.sign_define(discussion_sign_name, {
		text = "💬",
	})
end

function M.place_sign_comment(sign_id, buffer_name, line_number)
	define_sign_icon()
	vim.fn.sign_place(sign_id, discussion_sign_name, discussion_sign_name, buffer_name, { lnum = line_number })
end

return M
