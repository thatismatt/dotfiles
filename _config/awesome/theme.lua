--------------------------------
-- thatismatt's awesome theme --
--------------------------------

-- load the default theme to use it as the base for this custom theme
local success, theme = pcall(function () return dofile("/usr/share/awesome/themes/default/theme.lua") end)

theme.font          = "Liberation Sans 12"

theme.fg_normal     = "#aaaaaa"
theme.bg_normal     = "#222222"

theme.fg_focus      = "#dddddd"
theme.bg_focus      = "#555555"

theme.fg_urgent     = "#dddddd"
theme.bg_urgent     = "#ff0000"

theme.fg_minimize   = "#dddddd"
theme.bg_minimize   = "#444444"

theme.border_width  = "2"
theme.border_normal = "#444444"
theme.border_focus  = "#3333dd"
theme.border_marked = "#ff0000"

-- There are other variable sets overriding the default one when defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]

-- theme.menu_submenu_icon = "/usr/share/awesome/themes/default/submenu.png"
theme.menu_height = "24"
theme.menu_width  = "150"

theme.wallpaper = "/home/matt/Pictures/wallpaper"

theme.awesome_icon = "/home/matt/.config/awesome/awesome_icon.png"

-- theme.tasklist_plain_task_name = true

return theme
