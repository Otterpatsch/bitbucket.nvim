vim.api.nvim_create_user_command("TestComments", function()
  package.loaded.bitbucket = nil
  require("bitbucket").get_comments(116)
end, {})
