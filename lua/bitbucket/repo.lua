local M = {}
local repo_remote = vim.fn.system("git remote -v")
M.workspace = vim.env.WORKSPACE or string.match(repo_remote, ":(%S+)/")
M.reposlug = vim.env.REPOSLUG or string.match(repo_remote, "/(%S+).git")
M.app_password = vim.env.APP_PASSWORD
M.username = vim.env.USER_NAME
return M
