local Popup = require("nui.popup")
local M = {}

M.center_popup = Popup({
    position = "50%",
    size = {
      width = "80%",
      height = "60%",
    },
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
      text = {
        top = "Request Content",
        top_align = "center",
      },
    },
  })

function M.dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. M.dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function M.create_vertial_split()
  vim.cmd('vsplit')
  local active_window = vim.api.nvim_get_current_win()
  local buffer_number = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_win_set_buf(active_window, buffer_number)
  return buffer_number
end

function M.concate_tables(first, second)
  for i=1,#second do
      first[#first+1] = second[i]
  end
  return first
end

return M
