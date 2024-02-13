M = {}
local curl = require("plenary").curl
local NuiTree = require("nui.tree")
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



function M.get_comments(pr_id)
  pr_id = pr_id or pull_request_id
  local request_url = base_request_url .. "/pullrequests/" .. pr_id .. "/comments"
  local response = curl.get(request_url, {
        accept = "application/json",
        auth = username .. ":" .. app_password
      })
  local values = vim.fn.json_decode(response.body)["values"]
  local buffer_number = utils.create_vertial_slit()
  local nodes_by_parent_id = { _root = {} }
  local tree = NuiTree({bufnr=buffer_number})
  for _, value in ipairs(values) do
    local html = value["content"]["html"]
    local author = value["user"]["display_name"]
    local id = value["id"]
    local parent_id = value["parent"] and value["parent"]["id"] or "_root"
    if not nodes_by_parent_id[parent_id] then
      nodes_by_parent_id[parent_id] = {}
    end
    table.insert(nodes_by_parent_id[parent_id], NuiTree.Node({
      text = html,
      author = author,
      id = id,
    }))
  end
  tree:set_nodes(nodes_by_parent_id._root)

  for parent_id, nodes in pairs(nodes_by_parent_id) do
    if parent_id ~= "_root" then
      tree:set_nodes(nodes, ( parent_id ))
    end
  end
  tree:render()
 end

function M.create_pullrequest()
  -- post method
  request_url = base_request_url .. "pullrequests"
  curl.post()
end

return M
