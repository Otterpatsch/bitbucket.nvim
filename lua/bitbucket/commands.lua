vim.api.nvim_create_user_command("TestComments", function()
  package.loaded.bitbucket = nil
  require("bitbucket").get_comments(116)
end, {})
vim.api.nvim_create_user_command("Clear", function()
  package.loaded.bitbucket = nil
  require("bitbucket")
end, {})
