local repo_remote = vim.fn.system("git remote -v")
local M = {
	workspace = vim.env.WORKSPACE or string.match(repo_remote, ":(%S+)/"),
	reposlug = vim.env.REPOSLUG or string.match(repo_remote, "/(%S+).git"),
	app_password = vim.env.APP_PASSWORD,
	username = vim.env.USER_NAME,
	tabnr = nil,
}
bitbucket_api = "https://api.bitbucket.org/2.0/repositories"
M.base_request_url = bitbucket_api .. "/" .. M.workspace .. "/" .. M.reposlug .. "/"

return M
