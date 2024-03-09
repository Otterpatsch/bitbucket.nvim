local Popup = require("nui.popup")
local Menu = require("nui.menu")
local M = {}

function M.create_popup(titel, width, height)
	return Popup({
		position = "50%",
		relative = "editor",
		size = {
			width = width or 100,
			height = height or 30,
		},
		enter = true,
		focusable = true,
		border = {
			style = "rounded",
			text = {
				top = titel,
				top_align = "center",
			},
		},
	})
end

function M.create_menu(items, on_close, on_submit)
	local lines = {}
	for _, item in ipairs(items) do
		if item.type == "item" then
			table.insert(lines, Menu.item(item.text, item.values))
		elseif item.type == "separator" then
			table.insert(lines, Menu.separator(item.text))
		else
			print("Error")
		end
	end
	return Menu({
		position = "50%",
		size = {
			width = 25,
			height = 5,
		},
		border = {
			style = "single",
			text = {
				top = "Choose",
				top_align = "center",
			},
		},
		win_options = {
			winhighlight = "Normal:Normal,FloatBorder:Normal",
		},
	}, {
		lines = lines,
		max_width = 20,
		keymap = {
			focus_next = { "j", "<Down>", "<Tab>" },
			focus_prev = { "k", "<Up>", "<S-Tab>" },
			close = { "<Esc>", "<C-c>" },
			submit = { "<CR>", "<Space>" },
		},
		on_close = function(item)
			return on_close(item)
		end,
		on_submit = function(item)
			return on_submit(item)
		end,
	})
end

function M.confirm(titel, options)
	return vim.fn.confirm(titel, options)
end

function M.create_vertial_split()
	vim.cmd("vsplit")
	local active_window = vim.api.nvim_get_current_win()
	local buffer_number = vim.api.nvim_create_buf(true, true)
	vim.api.nvim_win_set_buf(active_window, buffer_number)
	return buffer_number
end

--- Function which concatenates two tables together
---@param first table: first table onto which the second is concatenated
---@param second  table: second table which will be added to the first table
---@return table: combined table
function M.concate_tables(first, second)
	for i = 1, #second do
		first[#first + 1] = second[i]
	end
	return first
end

function M.lines_to_raw_text(lines)
	if type(lines) ~= "table" then
		return lines
	end
	return table.concat(lines, "  \n")
end

return M
