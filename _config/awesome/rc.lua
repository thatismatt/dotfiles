-- Standard awesome library
gears = require("gears")
awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
wibox = require("wibox")
-- Theme handling library
beautiful = require("beautiful")
-- Notification library
naughty = require("naughty")
menubar = require("menubar")

utils = require("utils")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
   naughty.notify({ preset = naughty.config.presets.critical,
                    title = "Oops, there were errors during startup!",
                    text = awesome.startup_errors })
end

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

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/matt/.config/awesome/theme.lua")

terminal = "x-terminal-emulator"
emacs = "emacsclient -c -a="

modkey = "Mod4"
altkey = "Mod1"

local bindings = {};

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts = {
   awful.layout.suit.tile,
   -- awful.layout.suit.tile.left,
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
tags = {}
for s = 1, screen.count() do
   -- Each screen has its own tag table.
   tags[s] = awful.tag({ 1, 2, 3, 4 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "Manual",  terminal .. " -e man awesome" },
   { "Restart", awesome.restart },
   { "Quit",    awesome.quit }
}

mymainmenu = awful.menu({
      items = {
         { "Awesome",      myawesomemenu,   beautiful.awesome_icon },
         { "Emacs",        emacs,           "/usr/share/icons/Faenza/apps/32/emacs.png" },
         { "Firefox",      "firefox",       "/usr/share/icons/Faenza/apps/32/firefox.png" },
         { "Chrome",       "google-chrome", "/usr/share/icons/Faenza/apps/32/google-chrome.png" },
         { "Thunar",       "thunar",        "/usr/share/icons/Faenza/apps/32/thunar.png" },
         { "LXAppearance", "lxappearance",  "/usr/share/icons/Faenza/categories/32/preferences-desktop.png" },
         { "Terminal",     terminal,        "/usr/share/icons/Faenza/apps/32/xterm.png" },
         { "Quit",         awesome.quit }
}})

mylauncher = awful.widget.launcher({
      image = beautiful.awesome_icon,
      menu = mymainmenu
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Utils
function focus_raise (idx)
   return function ()
      awful.client.focus.byidx(idx)
      if client.focus then client.focus:raise() end
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

function previous_client ()
   awful.client.focus.history.previous()
   if client.focus then
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
   left_layout:add(mylauncher)
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

-- Wifi signal
local wifi = {}
wifi.widget = wibox.widget.textbox()
wifi.update = function ()
   local strength = awful.util.pread("awk 'NR==3 {printf \"%.1f%%\\n\",($3/70)*100}' /proc/net/wireless")
   wifi.widget:set_text(" Wifi: " .. strength)
end
wifi.timer = timer({ timeout = 2 })
wifi.timer:connect_signal("timeout", wifi.update)
wifi.timer:start()
wifi.update()

-- Bandwidth
local bandwidth = {}
bandwidth.widget = wibox.widget.textbox()
bandwidth.interface = "wlan0"
bandwidth.previous = { rx = 0, tx = 0 }
bandwidth.update = function ()
   local current_rx = tonumber(io.lines("/sys/class/net/" .. bandwidth.interface .. "/statistics/rx_bytes")())
   local current_tx = tonumber(io.lines("/sys/class/net/" .. bandwidth.interface .. "/statistics/tx_bytes")())
   local rx = current_rx - bandwidth.previous.rx
   local tx = current_tx - bandwidth.previous.tx
   if bandwidth.previous.rx == 0 then
      rx = 0
      tx = 0
   end
   bandwidth.previous = { rx = current_rx, tx = current_tx }
   -- 131072 = 1024 * 1024 / 8
   bandwidth.widget:set_text(
      " Down: " .. string.format("%.2f", rx / 131072) ..
         " Up: " .. string.format("%.2f", tx / 131072))
end
bandwidth.update()
bandwidth.timer = timer({ timeout = 1 })
bandwidth.timer:connect_signal("timeout", bandwidth.update)
bandwidth.timer:start()

local bottom_widgets_layout = wibox.layout.fixed.horizontal()
bottom_widgets_layout:add(wifi.widget)
bottom_widgets_layout:add(bandwidth.widget)

mypromptbox = awful.widget.prompt()

mypromptbox.lua = function ()
   awful.prompt.run(
      { prompt = "Lua: " },
      mypromptbox.widget,
      awful.util.eval,
      nil,
      awful.util.getdir("cache") .. "/history_eval"
   )
end

local bottom_layout = wibox.layout.align.horizontal()
bottom_layout:set_left(mypromptbox)
bottom_layout:set_middle(bottom_widgets_layout)
-- layout:set_right()

bottom_wibox:set_widget(bottom_layout)
-- }}}

-- {{{ Mouse bindings
bindings.mouse = awful.util.table.join(
   awful.button({ }, 3, function () mymainmenu:toggle() end),
   awful.button({ }, 4, awful.tag.viewprev),
   awful.button({ }, 5, awful.tag.viewnext)
)
-- }}}

-- {{{ Key bindings
bindings.keys = awful.util.table.join(
   awful.key({ modkey            }, "Escape", awful.tag.history.restore),
   awful.key({ modkey            }, "Up",     focus_raise(-1)),
   awful.key({ modkey            }, "Down",   focus_raise(1)),
   awful.key({ modkey, "Shift"   }, "Up",     function () awful.client.swap.byidx(-1) end),
   awful.key({ modkey, "Shift"   }, "Down",   function () awful.client.swap.byidx(1) end),
   awful.key({ modkey            }, "Tab",    awful.tag.viewnext),
   awful.key({ modkey, "Shift"   }, "Tab",    awful.tag.viewprev),
   awful.key({ modkey, "Control" }, "Up",     cycle_master(false)),
   awful.key({ modkey, "Control" }, "Down",   cycle_master(true)),
   awful.key({ altkey,           }, "Tab",    previous_client),
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
   awful.key({ modkey, "Control" }, "n",      function () awful.client.restore(mouse.screen) end),
   awful.key({ modkey            }, "r",      function () mypromptbox:run() end),
   awful.key({ modkey            }, "x",      mypromptbox.lua)
)

-- Volume keys
function volume_key(action)
   return function () awful.util.spawn("amixer -q -D pulse set Master " .. action) end
end
bindings.volume = awful.util.table.join(
   awful.key({ }, "XF86AudioMute",        volume_key("toggle")),
   awful.key({ }, "XF86AudioRaiseVolume", volume_key("5%+")),
   awful.key({ }, "XF86AudioLowerVolume", volume_key("5%-"))
)

function toggle_maximized (c)
   c.maximized_horizontal = not c.maximized_horizontal
   c.maximized_vertical   = not c.maximized_vertical
end

clientkeys = awful.util.table.join(
   awful.key({ altkey            }, "F4",     function (c) c:kill() end),
   awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle),
   awful.key({ modkey            }, "Return", function (c) c:swap(awful.client.getmaster()) end),
   awful.key({ modkey, "Shift"   }, "o",      awful.client.movetoscreen),
   awful.key({ modkey, "Shift"   }, "t",      function (c) c.ontop = not c.ontop end),
   awful.key({ modkey, "Shift"   }, "f",      function (c) c.fullscreen = not c.fullscreen end),
   awful.key({ modkey, "Shift"   }, "n",      function (c) c.minimized = true end),
   awful.key({ modkey, "Shift"   }, "m",      toggle_maximized),
   awful.key({ modkey, "Shift"   }, "k",      awful.client.togglemarked),
   awful.key({ modkey, "Shift"   }, "d",      function (c) debug_client = c end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, #tags[1] do
   bindings.keys = awful.util.table.join(
      bindings.keys,
      -- View tag only.
      awful.key({ modkey }, "#" .. i + 9,
         function ()
            local screen = mouse.screen
            local tag = awful.tag.gettags(screen)[i]
            if tag then
               awful.tag.viewonly(tag)
            end
         end
      ),
      -- Toggle tag.
      awful.key({ modkey, "Control" }, "#" .. i + 9,
         function ()
            local screen = mouse.screen
            local tag = awful.tag.gettags(screen)[i]
            if tag then
               awful.tag.viewtoggle(tag)
            end
         end
      ),
      -- Move client to tag.
      awful.key({ modkey, "Shift" }, "#" .. i + 9,
         function ()
            if client.focus then
               local tag = awful.tag.gettags(client.focus.screen)[i]
               if tag then
                  awful.client.movetotag(tag)
               end
            end
         end
      ),
      -- Toggle tag.
      awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
         function ()
            if client.focus then
               local tag = awful.tag.gettags(client.focus.screen)[i]
               if tag then
                  awful.client.toggletag(tag)
               end
            end
         end
   ))
end

clientbuttons = awful.util.table.join(
   awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
   awful.button({ modkey }, 1, awful.mouse.client.move),
   awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set Key/Mouse Bindings
root.keys(awful.util.table.join(bindings.keys, bindings.volume))
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
                    keys = clientkeys,
                    buttons = clientbuttons } },
   { rule = { class = "MPlayer" },
     properties = { floating = true } },
   { rule = { class = "pinentry" },
     properties = { floating = true } },
   { rule = { class = "gimp" },
     properties = { floating = true } },
   { rule = { class = "Plugin-container" }, -- flash fullscreen e.g. youtube
     properties = { floating = true } },
   -- Set Firefox to always map on tags number 2 of screen 1.
   -- { rule = { class = "Firefox" },
   --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal(
   "manage",
   function (c, startup)
      -- Enable sloppy focus
      -- c:connect_signal("mouse::enter", function (c)
      --                     if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
      --                     and awful.client.focus.filter(c) then
      --                        client.focus = c
      --                     end
      -- end)

      if not startup then
         -- Set the windows at the slave,
         -- i.e. put it at the end of others instead of setting it master.
         -- awful.client.setslave(c)

         -- Put windows in a smart way, only if they don't set an initial position.
         if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
         end
      end

      local titlebars_enabled = false
      if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
         -- buttons for the titlebar
         local buttons = awful.util.table.join(
            awful.button({ }, 1, function ()
                  client.focus = c
                  c:raise()
                  awful.mouse.client.move(c)
            end),
            awful.button({ }, 3, function ()
                  client.focus = c
                  c:raise()
                  awful.mouse.client.resize(c)
            end)
         )

         -- Widgets that are aligned to the left
         local left_layout = wibox.layout.fixed.horizontal()
         left_layout:add(awful.titlebar.widget.iconwidget(c))
         left_layout:buttons(buttons)

         -- Widgets that are aligned to the right
         local right_layout = wibox.layout.fixed.horizontal()
         right_layout:add(awful.titlebar.widget.floatingbutton(c))
         right_layout:add(awful.titlebar.widget.maximizedbutton(c))
         right_layout:add(awful.titlebar.widget.stickybutton(c))
         right_layout:add(awful.titlebar.widget.ontopbutton(c))
         right_layout:add(awful.titlebar.widget.closebutton(c))

         -- The title goes in the middle
         local middle_layout = wibox.layout.flex.horizontal()
         local title = awful.titlebar.widget.titlewidget(c)
         title:set_align("center")
         middle_layout:add(title)
         middle_layout:buttons(buttons)

         -- Now bring it all together
         local layout = wibox.layout.align.horizontal()
         layout:set_left(left_layout)
         layout:set_right(right_layout)
         layout:set_middle(middle_layout)

         awful.titlebar(c):set_widget(layout)
      end
   end
)

function decorate_client (c)
   if awful.client.ismarked(c) then
      c.border_color = beautiful.border_marked
   elseif client.focus == c then
      c.border_color = beautiful.border_focus
   else
      c.border_color = beautiful.border_normal
   end
end

client.connect_signal("focus",    decorate_client)
client.connect_signal("unfocus",  decorate_client)
client.connect_signal("marked",   decorate_client)
client.connect_signal("unmarked", decorate_client)
-- }}}
