local Popup = require("nui.popup")
local Layout = require("nui.layout")

local title_popup = Popup({
	border = "single",
	enter = true,
	focusable = true,
})
local summary_popup = Popup({
	border = "single",
	focusable = true,
})
local info_popup = Popup({ border = "single", focusable = false })

local layout = Layout(
	{
		position = "50%",
		size = {
			width = 100,
			height = 40,
		},
	},
	Layout.Box({
		Layout.Box(title_popup, { size = "10%" }),
		Layout.Box(summary_popup, { size = "60%" }),
		Layout.Box(info_popup, { size = "30%" }),
	}, { dir = "col" })
)
return {
	layout = layout,
	title_bufnr = title_popup.bufnr,
	summary_bufnr = summary_popup.bufnr,
	info_bufnr = info_popup.bufnr,
}
