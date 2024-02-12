M = {}
local curl = require("plenary").curl
local bitbucket_api = "https://api.bitbucket.org/2.0/repositories/"
local utils = require("bitbucket.utils")
local repo = require("bitbucket.repo")
local workspace = repo.workspace
local reposlug = repo.reposlug
local username = repo.username
local app_password = repo.app_password
local base_request_url = bitbucket_api .. "/" .. workspace .. "/" .. reposlug .. "/"
local pull_request = {}
local pull_request_id

function M.get_pull_requests()
  -- get list of pull requests of PR
  -- Just to show where are PR
  -- and their corresponding branch
end



function M.get_pullrequest_by_commit()
  -- Get pullrequests by given commit if none is given?
  -- Special chase if commit is present in multiple PRS
  -- Then popup to choose PR
  -- commit = commit or utils.get_current_commit()
  local commit = "f43d26e"
  local request_url = base_request_url .. "commit/" .. commit .. "/pullrequests"
  -- request_url = "https://postman-echo.com/get"
  local response = curl.get(request_url, {
        accept = "application/json",
        auth = username .. ":" .. app_password
      })
  local decoded_result = vim.fn.json_decode(response.body)
  if #decoded_result["values"] ~= 1 then
    print("two elements")
  else
    pull_request_id = tostring( decoded_result["values"][1]["id"] )
  end
  local buffer_number = utils.create_vertial_slit()
  vim.api.nvim_buf_set_lines(buffer_number,0,1,false,{tostring( response.status ).."\\n"..tostring(pull_request_id)})
  vim.api.nvim_buf_set_lines(buffer_number,1,1,false,{tostring(pull_request_id)})

end

function M.get_comments(id)
  id = id or pull_request_id
  local request_url = base_request_url .. "/pullrequests/" .. id .. "/comments"
  -- request_url = "https://postman-echo.com/get"
  local response = curl.get(request_url, {
        accept = "application/json",
        auth = username .. ":" .. app_password
      })
  local values = vim.fn.json_decode(response.body)["values"]
  utils.center_popup:mount()
  local empty_line = 0
  local buffer_number = utils.create_vertial_slit()
  for _ ,value in pairs(values) do
    vim.fn.appendbufline(buffer_number,0,{value["user"]["display_name"]})
    vim.fn.appendbufline(buffer_number,1,{value["content"]["raw"]})
    empty_line = empty_line + 2
  end
end

function M.create_pullrequest()
  -- post method
  request_url = base_request_url .. "pullrequests"
  curl.post()
end

return M
