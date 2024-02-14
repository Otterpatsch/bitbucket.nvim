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
local Popup = require("nui.popup")
local Line = require("nui.line")
local Text = require("nui.text")
local Tree = require("nui.tree")


function M.get_pull_requests()
  -- get list of pull requests of PR
  -- Just to show where are PR
  -- and their corresponding branch
end



function M.get_pullrequest_by_commit(commithash)
  -- Get pullrequests by given commit if none is given?
  -- Special chase if commit is present in multiple PRS
  -- Then popup to choose PR
  local commit = commithash or vim.fn.system("git rev-parse --short HEAD"):gsub("%W","")
  local request_url = base_request_url .. "commit/" .. commit .. "/pullrequests"
  local response = curl.get(request_url, {
        accept = "application/json",
        auth = username .. ":" .. app_password
      })
  local decoded_result = vim.fn.json_decode(response.body)
  if #decoded_result["values"] ~= 1 then
    error("two elements: handling yet not implemented")
  else
    return tostring( decoded_result["values"][1]["id"] )
  end
end

-- Function which visualize the overall Pull Request Comments 
-- Comments which are not put on some line of code/are linked to a specific file
function M.get_comments(pr_id)
  pr_id = pr_id or pull_request_id
  local request_url = base_request_url .. "/pullrequests/" .. pr_id .. "/comments"
  local response = curl.get(request_url, {
        accept = "application/json",
        auth = username .. ":" .. app_password
      })
  -- TODO check if key "next" exist if it does curl next page too until no next exist
  local content = vim.fn.json_decode(response.body)
  local values = content["values"]
  local bufnr = utils.create_vertial_slit()
  local tree = Tree({
        bufnr = bufnr,
        get_node_id = function(node)
          -- this is telling NuiTree where we're storing the id
          return node.id
        end,
        prepare_node = function(node)
          -- You can format the text however you want here
          -- Maybe add some colors and styles etc.
          local lines = { Line({Text(node.author .. "  ".. (node.parent_id or ""))})}
          for _, raw_line in ipairs(vim.split(node.text, "\n")) do
            table.insert(lines, Line({ Text("    "..raw_line) }))
          end
          table.insert(lines, Line({ Text("--------------------") }))
          if not node:has_children() then
             table.insert(lines, Line({ Text("--------------------") }))
          end
          return lines
        end,
      })
  local node_by_id = {}

  local function add_node_to_tree(id)
    local node = tree:get_node(id)
    if node then
      return
    end

    node = node_by_id[id]
    if not node then
      return
    end

    local parent_id = node.parent_id
    if parent_id and not tree:get_node(parent_id) then
      -- ensure parent is added before the child
      add_node_to_tree(parent_id)
    end
    tree:add_node(node, parent_id)
  end

  for _, value in ipairs(values) do
    local text = value["content"]["raw"]
    local author = value["user"]["display_name"]
    local id = tostring(value["id"]) -- id needs to be string
    local parent_id = value["parent"] and tostring(value["parent"]["id"]) -- id needs to be string
    local node = Tree.Node({
      text = text,
      author = author,
      id = id,
      parent_id = parent_id,
    }, {})
    node:expand()
    node_by_id[id] = node
  end


  for id in pairs(node_by_id) do
    add_node_to_tree(id)
  end

  tree:render()
end


function M.create_pullrequest()
  -- post method
  request_url = base_request_url .. "pullrequests"
  curl.post()
end

require("bitbucket.commands")
return M
