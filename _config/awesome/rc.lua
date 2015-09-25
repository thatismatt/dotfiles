---------------------------------
-- thatismatt's awesome config --
---------------------------------

gears       = require("gears")
awful       = require("awful")
awful.rules = require("awful.rules")
              require("awful.autofocus")
wibox       = require("wibox")
beautiful   = require("beautiful")
naughty     = require("naughty")
menubar     = require("menubar")

prime       = require("prime")
utils       = require("utils")
agate       = require("agate")
mpd         = require("mpd")

-- {{{ Error handling
-- Handle runtime errors after startup
do
   local in_error = false
   awesome.connect_signal(
      "debug::error",
      function (err)
         -- Make sure we don't go into an endless error loop
         if in_error then return end
         in_error = true

         naughty.notify({ preset = naughty.config.presets.critical,
                          title = "Oops, an error happened!",
                          text = err })
         in_error = false
      end
   )
end
-- }}}

-- {{{ Prime - extra commands
prime.add_commands({
      d = {
         name = "dump",
         handle = utils.dump
      },
      l = {
         name = "log",
         handle = function (v)
            utils.log(tostring(v))
            return "LOGGED"
         end
      }
})
prime.default_command_id = "d"
-- }}}

-- {{{ Variable definitions
beautiful.init("/home/matt/.config/awesome/theme.lua")

terminal = "x-terminal-emulator"
emacs = "emacsclient -c -a="

modkey = "Mod4"
altkey = "Mod1"

local bindings = {};

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts = {
   awful.layout.suit.tile,
   awful.layout.suit.tile.left,
   awful.layout.suit.tile.bottom,
   -- awful.layout.suit.tile.top,
   -- awful.layout.suit.fair,
   -- awful.layout.suit.fair.horizontal,
   -- awful.layout.suit.spiral,
   awful.layout.suit.spiral.dwindle,
   awful.layout.suit.max,
   -- awful.layout.suit.max.fullscreen,
   awful.layout.suit.magnifier,
   awful.layout.suit.floating
}
layouts.max = awful.layout.suit.max
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
   for s = 1, screen.count() do
      gears.wallpaper.maximized(beautiful.wallpaper, s, true)
   end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = { by_screen = {} }
tags.count = 4 -- per screen
for s = 1, screen.count() do
   local names = utils.range((s - 1) * tags.count + 1, tags.count * s)
   tags.by_screen[s] = awful.tag(names, s, layouts[1])
   for k, v in pairs(names) do
      tags[v] = tags.by_screen[s][k]
   end
end
-- }}}

-- {{{ Menu
menu = {}

menu.icon = function (dir, name)
   return string.format("/usr/share/icons/Faenza/%s/32/%s.png", dir, name)
end

menu.awesome = {
   { "Manual",  terminal .. " -e man awesome" },
   { "Restart", awesome.restart },
   { "Quit",    awesome.quit }
}

menu.power = {
   { "Power Off", "systemctl poweroff",  menu.icon("actions", "system-shutdown") },
   { "Suspend",   "systemctl suspend",   menu.icon("apps", "system-suspend") },
   { "Restart",   "systemctl reboot",    menu.icon("apps", "system-restart") }
}

menu.screens = {
   { "Single", "/home/matt/scripts/screen-single.sh" },
   { "Dual",   "/home/matt/scripts/screen-dual.sh" },
   { "Arandr", "arandr"}
}

menu.main = awful.menu({
      { "Awesome",      menu.awesome,    beautiful.awesome_icon },
      { "Terminal",     terminal,        menu.icon("apps", "xterm") },
      { "Thunar",       "thunar",        menu.icon("apps", "thunar") },
      { "Emacs",        emacs,           menu.icon("apps", "emacs") },
      { "Firefox",      "firefox",       menu.icon("apps", "firefox") },
      { "Chrome",       "google-chrome", menu.icon("apps", "google-chrome") },
      { "Gimp",         "gimp",          menu.icon("apps", "gimp") },
      { "LXAppearance", "lxappearance",  menu.icon("categories", "preferences-desktop") },
      { "Screens",      menu.screens,    menu.icon("devices", "monitor") },
      { "Power",        menu.power,      menu.icon("actions", "system-shutdown") }
})

menu.main.toggle_at_corner = function ()
   menu.main:toggle({ coords = { x = 0, y = 0 } })
end

menu.launcher = awful.widget.launcher({
      image = beautiful.awesome_icon,
      menu = menu.main
})

menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Utils
function focus_raise (direction)
   return function ()
      local screen_id = mouse.screen
      local cls = utils.filter(
         utils.flatmap(utils.range(screen.count()), awful.client.visible),
         function (c) return awful.client.focus.filter(c) or c == client.focus end)
      local client_to_focus = nil
      for idx, c in ipairs(cls) do
         if c == client.focus then
            client_to_focus = cls[awful.util.cycle(#cls, idx + direction)]
         end
      end
      if client_to_focus then
         client.focus = client_to_focus
         client.focus:raise()
      end
   end
end

function restore_and_focus ()
   local restored = awful.client.restore(mouse.screen)
   if restored then
      client.focus = restored
   end
end

function cycle_master (direction)
   return function ()
      if client.focus == awful.client.getmaster() then
         awful.client.cycle(direction)
      else
         awful.client.setmaster(client.focus)
      end
      client.focus = awful.client.getmaster()
      client.focus:raise()
   end
end
-- }}}

-- {{{ Wibox
mytextclock = awful.widget.textclock()
mytextclock:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn("gsimplecal") end)))

mywibox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
   awful.button({        }, 1, awful.tag.viewonly),
   awful.button({ modkey }, 1, awful.client.movetotag),
   awful.button({        }, 3, awful.tag.viewtoggle),
   awful.button({ modkey }, 3, awful.client.toggletag),
   awful.button({        }, 4, function (t) awful.tag.viewprev(awful.tag.getscreen(t)) end),
   awful.button({        }, 5, function (t) awful.tag.viewnext(awful.tag.getscreen(t)) end)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
   awful.button({ }, 1, function (c)
         if c == client.focus then
            c.minimized = true
         else
            -- Without this, the following
            -- :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() then
               awful.tag.viewonly(c:tags()[1])
            end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
            c:raise()
         end
   end),
   awful.button({ }, 2, function (c)
         c:kill()
   end),
   awful.button({ }, 3, function ()
         if instance then
            instance:hide()
            instance = nil
         else
            instance = awful.menu.clients({
                  theme = { width = 250 }
            })
         end
   end),
   awful.button({ }, 4, focus_raise(-1)),
   awful.button({ }, 5, focus_raise(1)))

for s = 1, screen.count() do
   -- Layouts widget
   mylayoutbox[s] = awful.widget.layoutbox(s)
   mylayoutbox[s]:buttons(awful.util.table.join(
                             awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                             awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                             awful.button({ }, 4, function () awful.layout.inc(layouts, -1) end),
                             awful.button({ }, 5, function () awful.layout.inc(layouts, 1) end)))

   -- Taglist widget
   mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

   -- Tasklist widget
   mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

   -- Top wibox
   mywibox[s] = awful.wibox({ position = "top", screen = s })

   -- Widgets that are aligned to the left
   local left_layout = wibox.layout.fixed.horizontal()
   left_layout:add(menu.launcher)
   left_layout:add(mytaglist[s])

   -- Widgets that are aligned to the right
   local right_layout = wibox.layout.fixed.horizontal()
   if s == 1 then right_layout:add(wibox.widget.systray()) end
   right_layout:add(mytextclock)
   right_layout:add(mylayoutbox[s])

   -- Now bring it all together (with the tasklist in the middle)
   local layout = wibox.layout.align.horizontal()
   layout:set_left(left_layout)
   layout:set_middle(mytasklist[s])
   layout:set_right(right_layout)

   mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Bottom wibox
bottom_wibox = awful.wibox({ position = "bottom", screen = screen.count(), height = 25 })

function icon_file(...)
   return string.format("/home/matt/Pictures/material-design-icons/%s/1x_web/ic_%s_white_18dp.png", ...)
end

function status_widget (icon_or_fn, update, data)
   local w = data or {}
   w.widget = wibox.widget.textbox()
   function w.widget:fit (w, h) return 60, h end
   local img = wibox.widget.imagebox()
   w.icon = wibox.layout.margin(img, 3, 3, 3, 3)
   w.update = function ()
      local text = update(w)
      w.widget:set_text(text)
      local icon = type(icon_or_fn) == "function" and icon_or_fn(w) or icon_or_fn
      img:set_image(icon)
   end
   w.timer = timer({ timeout = 1 })
   w.timer:connect_signal("timeout", w.update)
   w.timer:start()
   w.update(w)
   return w
end

local wifi = status_widget(
   function (wifi)
      local icon = "signal_wifi_off"
      if wifi.strength > 80 then icon = "signal_wifi_4_bar"
      elseif wifi.strength > 75 then icon = "signal_wifi_3_bar"
      elseif wifi.strength > 50 then icon = "signal_wifi_2_bar"
      elseif wifi.strength > 25 then icon = "signal_wifi_1_bar"
      elseif wifi.strength > 0 then icon = "signal_wifi_0_bar"
      end
      return icon_file("device", icon)
   end,
   function (wifi)
      for line in io.lines("/proc/net/wireless") do
         local match = string.match(line, "^ *" .. wifi.interface .. ": +%d+ +(%d+)")
         wifi.strength = 0
         if match then
            wifi.strength = 100 * tonumber(match) / 70
            return string.format("%.0f%%", wifi.strength)
         end
      end
      return "off"
   end,
   { interface = "wlan0" }
)

function bandwidth_update (bandwidth)
   local current = tonumber(io.lines("/sys/class/net/" .. bandwidth.interface .. "/statistics/" .. bandwidth.direction .. "_bytes")())
   local d = current - bandwidth.previous
   if bandwidth.previous == 0 then
      d = 0
   end
   bandwidth.previous = current
   -- 131072 = 1024 * 1024 / 8
   return string.format("%.2f", d / 131072)
end

local bandwidth_rx = status_widget(
   icon_file("file", "file_download"),
   bandwidth_update,
   { previous = 0, interface = "wlan0", direction = "rx" }
)

local bandwidth_tx = status_widget(
   icon_file("file", "file_upload"),
   bandwidth_update,
   { previous = 0, interface = "wlan0", direction = "tx" }
)

local cpu = status_widget(
   icon_file("action", "settings"),
   function (cpu)
      local user, system, idle = string.match(io.lines("/proc/stat")(), "cpu +(%d+) +%d+ +(%d+) +(%d+)")
      local text = ""
      if cpu.user then
         local total_d = user + system + idle - cpu.user - cpu.system - cpu.idle
         local used_d = user + system - cpu.user - cpu.system
         text = string.format("%.1f%%", 100 * used_d / total_d)
      end
      cpu.user, cpu.system, cpu.idle = user, system, idle
      return text
   end,
   {}
)

local memory = status_widget(
   icon_file("hardware", "memory"),
   function (memory)
      local total, used = string.match(awful.util.pread("free -m"), "Mem: +(%d+) +(%d+)")
      return string.format("%.0f%%", 100 * used / total)
   end
)

local battery = status_widget(
   function (battery)
      local charge = "20"
      if battery.charge > 90 then charge = "90"
      elseif battery.charge > 80 then charge = "80"
      elseif battery.charge > 60 then charge = "60"
      elseif battery.charge > 50 then charge = "50"
      elseif battery.charge > 30 then charge = "30"
      end
      local status = io.lines("/sys/class/power_supply/" .. battery.identifier .. "/status")()
      local status_mapping = {
         Full = "battery_charging_full",
         Discharging = "battery_%s",
         Charging = "battery_charging_%s"
      }
      local icon_fmt = status_mapping[status] or "battery_unknown"
      local icon = string.format(icon_fmt, charge)
      return icon_file("device", icon)
   end,
   function (battery)
      local full = tonumber(io.lines("/sys/class/power_supply/" .. battery.identifier .. "/energy_full")())
      local now = tonumber(io.lines("/sys/class/power_supply/" .. battery.identifier .. "/energy_now")())
      battery.charge = 100 * now / full
      local text = string.format("%.0f%%", battery.charge)
      return text
   end,
   { identifier = "BAT1" }
)

local volume = status_widget(
   icon_file("hardware", "speaker"),
   function (volume)
      local fd = io.popen("amixer -D pulse sget Master")
      local status = fd:read("*all")
      fd:close()
      local on = string.match(status, "%[(o[^%]]*)%]") == "on"
      local text = "mute"
      if on then
         text = string.match(status, "(%d?%d?%d)%%") .. "%"
      end
      return text
   end
)

local bottom_widgets_layout = wibox.layout.fixed.horizontal()
bottom_widgets_layout:add(wifi.icon)
bottom_widgets_layout:add(wifi.widget)
bottom_widgets_layout:add(bandwidth_rx.icon)
bottom_widgets_layout:add(bandwidth_rx.widget)
bottom_widgets_layout:add(bandwidth_tx.icon)
bottom_widgets_layout:add(bandwidth_tx.widget)
bottom_widgets_layout:add(battery.icon)
bottom_widgets_layout:add(battery.widget)
bottom_widgets_layout:add(volume.icon)
bottom_widgets_layout:add(volume.widget)
bottom_widgets_layout:add(cpu.icon)
bottom_widgets_layout:add(cpu.widget)
bottom_widgets_layout:add(memory.icon)
bottom_widgets_layout:add(memory.widget)

local mpd_layout = wibox.layout.fixed.horizontal()

function mpd_button (icon, action)
   local mpd_icon = wibox.widget.imagebox(icon_file("av", icon))
   local mpd_widget = wibox.layout.margin(mpd_icon, 0, 0, 2, 2)
   mpd_widget:buttons(awful.util.table.join(awful.button({ }, 1, action)))
   mpd_layout:add(mpd_widget)
end

mpd_client = mpd.new()
mpd_button("skip_previous", function () mpd_client:command("previous") end)
mpd_button("fast_rewind", function () mpd_client:command("seekcur -30") end)
mpd_button("play_arrow", function () mpd_client:toggle() end)
mpd_button("fast_forward", function () mpd_client:command("seekcur +30") end)
mpd_button("skip_next", function () mpd_client:command("next") end)

local bottom_layout = wibox.layout.align.horizontal()
bottom_layout:set_middle(bottom_widgets_layout)
bottom_layout:set_right(mpd_layout)

bottom_wibox:set_widget(bottom_layout)
-- }}}

-- {{{ Mouse bindings
bindings.mouse = awful.util.table.join(
   awful.button({ }, 3, menu.main.toggle_at_corner),
   awful.button({ }, 4, awful.tag.viewprev),
   awful.button({ }, 5, awful.tag.viewnext)
)
-- }}}

-- {{{ Key bindings
bindings.keys = awful.util.table.join(
   awful.key({ modkey            }, "m",      menu.main.toggle_at_corner),
   awful.key({ modkey            }, "Escape", awful.tag.history.restore),
   awful.key({ modkey            }, "Up",     focus_raise(-1)),
   awful.key({ modkey            }, "Down",   focus_raise(1)),
   awful.key({ modkey, "Shift"   }, "Up",     function () awful.client.swap.byidx(-1) end),
   awful.key({ modkey, "Shift"   }, "Down",   function () awful.client.swap.byidx(1) end),
   awful.key({ modkey            }, "Tab",    awful.tag.viewnext),
   awful.key({ modkey, "Shift"   }, "Tab",    awful.tag.viewprev),
   awful.key({ modkey, "Control" }, "Up",     cycle_master(false)),
   awful.key({ modkey, "Control" }, "Down",   cycle_master(true)),
   awful.key({ altkey,           }, "Tab",    agate.switch),
   awful.key({ modkey            }, "o",      function () awful.screen.focus_relative(1) end),
   awful.key({ modkey            }, "p",      menubar.show),
   awful.key({ modkey            }, "u",      awful.client.urgent.jumpto),
   awful.key({ modkey            }, "t",      function () awful.util.spawn(terminal) end),
   awful.key({ modkey            }, "e",      function () awful.util.spawn(emacs) end),
   awful.key({ modkey            }, "f",      function () awful.util.spawn("thunar") end),
   awful.key({ modkey            }, "w",      function () awful.util.spawn("x-www-browser") end),
   awful.key({ modkey            }, "v",      function () awful.util.spawn("pavucontrol") end),
   awful.key({ modkey, "Control" }, "r",      awesome.restart),
   awful.key({ modkey, "Shift"   }, "q",      awesome.quit),
   awful.key({ modkey            }, "Right",  function () awful.tag.incmwfact( 0.05) end),
   awful.key({ modkey            }, "Left",   function () awful.tag.incmwfact(-0.05) end),
   awful.key({ modkey, "Control" }, "Right",  function () awful.tag.incnmaster(1) end),
   awful.key({ modkey, "Control" }, "Left",   function () awful.tag.incnmaster(-1) end),
   awful.key({ modkey, "Shift"   }, "Right",  function () awful.tag.incncol(1) end),
   awful.key({ modkey, "Shift"   }, "Left",   function () awful.tag.incncol(-1) end),
   awful.key({ modkey            }, "space",  function () awful.layout.inc(layouts, 1) end),
   awful.key({ modkey, "Shift"   }, "space",  function () awful.layout.inc(layouts, -1) end),
   awful.key({ modkey, "Control" }, "n",      restore_and_focus)
)

-- Brightness
function brightness_key (action)
   return function () awful.util.spawn("xbacklight " .. action, false) end
end
bindings.brightness = awful.util.table.join(
   awful.key({ }, "XF86MonBrightnessUp",   brightness_key("+10")),
   awful.key({ }, "XF86MonBrightnessDown", brightness_key("-10"))
)

-- Volume keys
function volume_key (action)
   return function () awful.util.spawn("amixer -q -D pulse set Master " .. action, false) end
end
bindings.audio = awful.util.table.join(
   awful.key({ }, "XF86AudioMute",        volume_key("toggle")),
   awful.key({ }, "XF86AudioRaiseVolume", volume_key("5%+")),
   awful.key({ }, "XF86AudioLowerVolume", volume_key("5%-")),
   awful.key({ }, "XF86AudioPlay",        function () mpd_client:toggle() end)
)

function toggle_maximized (c)
   local screen_id = c.screen
   local layout = awful.layout.get(screen_id)
   local layout_new = layout == layouts.max and layouts[1] or layouts.max
   local tag = awful.tag.selected(screen_id)
   awful.layout.set(layout_new, tag)
end

opaque = {}
opaque.clients = {}
opaque.toggle = function (c)
   opaque.clients[c] = not opaque.clients[c] or nil
end

bindings.client = {}
bindings.client.keys = awful.util.table.join(
   awful.key({ altkey            }, "F4",     function (c) c:kill() end),
   awful.key({ modkey, "Shift"   }, "f",      awful.client.floating.toggle),
   awful.key({ modkey            }, "Return", function (c) c:swap(awful.client.getmaster()) end),
   awful.key({ modkey, "Shift"   }, "o",      awful.client.movetoscreen),
   -- awful.key({ modkey, "Shift"   }, "t",      function (c) c.ontop = not c.ontop end),
   awful.key({ modkey, "Shift"   }, "t",      opaque.toggle),
   -- awful.key({ modkey, "Shift"   }, "f",      function (c) c.fullscreen = not c.fullscreen end),
   awful.key({ modkey, "Shift"   }, "n",      function (c) c.minimized = true end),
   awful.key({ modkey, "Shift"   }, "m",      toggle_maximized),
   awful.key({ modkey, "Shift"   }, "k",      awful.client.togglemarked),
   awful.key({ modkey, "Shift"   }, "d",      function (c) debug_client = c end)
)

-- Tag numeric bindings
bindings.tags = utils.flatmap(
   utils.range(tags.count * screen.count()),
   function (i)
      return awful.util.table.join(
         awful.key({ modkey }, i,
            function () awful.tag.viewonly(tags[i]) end),
         awful.key({ modkey, "Control" }, i,
            function () awful.tag.viewtoggle(tags[i]) end),
         awful.key({ modkey, "Shift" }, i,
            function ()
               if client.focus then
                  awful.client.movetotag(tags[i])
               end
            end
         ),
         awful.key({ modkey, "Control", "Shift" }, i,
            function ()
               if client.focus then
                  awful.client.toggletag(tags[i])
               end
            end
         )
      )
   end
)

bindings.client.buttons = awful.util.table.join(
   awful.button({        }, 1, function (c) client.focus = c; c:raise() end),
   awful.button({ modkey }, 1, awful.mouse.client.move),
   awful.button({ modkey }, 3, awful.mouse.client.resize)
)

-- Set Key/Mouse Bindings
root.keys(awful.util.table.join(bindings.keys, bindings.tags, bindings.audio, bindings.brightness))
root.buttons(bindings.mouse)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
   -- All clients will match this rule.
   { rule = { },
     properties = { border_width = beautiful.border_width,
                    border_color = beautiful.border_normal,
                    focus = awful.client.focus.filter,
                    raise = true,
                    keys = bindings.client.keys,
                    buttons = bindings.client.buttons } },
   { rule = { class = "MPlayer" },
     properties = { floating = true } },
   { rule = { class = "pinentry" },
     properties = { floating = true } },
   { rule = { class = "gimp" },
     properties = { floating = true } },
   { rule = { class = "Plugin-container" }, -- flash fullscreen e.g. youtube
     properties = { floating = true } },
   { rule = { name = "Google+ Hangouts is sharing your screen with plus.google.com." },
     properties = { floating = true } },
}
-- }}}

-- {{{ Client decoration
function decorate_client (c)
   c.border_color = beautiful.border_normal
   c.opacity = 0.85
   if opaque.clients[c] then
      c.opacity = 1
   end

   if client.focus == c then
      c.border_color = beautiful.border_focus
      c.opacity = 1
   end

   if awful.client.ismarked(c) then
      c.border_color = beautiful.border_marked
   end
end

client.connect_signal("focus",    decorate_client)
client.connect_signal("unfocus",  decorate_client)
client.connect_signal("marked",   decorate_client)
client.connect_signal("unmarked", decorate_client)
-- }}}
