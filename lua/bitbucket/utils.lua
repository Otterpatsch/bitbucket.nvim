local Popup = require("nui.popup")
local repo = require("bitbucket.repo")
local curl = require("plenary").curl
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

function M.extract_date(datetime)
  return string.sub(datetime,1,10)
end

function M.extract_time(datetime)
  return string.sub(datetime,12,16)
end

function M.get_comments_table(request_url)
	local response = curl.get(request_url, {
		accept = "application/json",
		auth = repo.username .. ":" .. repo.app_password,
	})
	local content = vim.fn.json_decode(response.body)
	local values = content["values"]
	while content["next"] do
		request_url = content["next"]
		response = curl.get(request_url, {
			accept = "application/json",
			auth = repo.username .. ":" .. repo.app_password,
		})
		content = vim.fn.json_decode(response.body)
		values = M.concate_tables(values, content["values"])
	end
	for index, value in ipairs(values) do
		if value["deleted"] then
			values[index] = nil
		end
	end
	return values
end

function M.dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. M.dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end

function M.create_vertial_split()
	vim.cmd("vsplit")
	local active_window = vim.api.nvim_get_current_win()
	local buffer_number = vim.api.nvim_create_buf(true, true)
	vim.api.nvim_win_set_buf(active_window, buffer_number)
	return buffer_number
end

function M.concate_tables(first, second)
	for i = 1, #second do
		first[#first + 1] = second[i]
	end
	return first
end

return M
