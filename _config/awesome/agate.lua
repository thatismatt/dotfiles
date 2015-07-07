--------------------------------------
--              AGATE               --
-- awesome global alt tab extension --
--------------------------------------

local awful = require("awful")
local cairo = require("lgi").cairo
local wibox = require("wibox")
local gears = require("gears")
local utils = require("utils")
local ipairs = ipairs
local pairs = pairs
local type = type
local math = math
local table = table
local screen = screen
local mouse = mouse
local client = client
local keygrabber = keygrabber
local timer = timer

module("agate")

local focus = { stack = {} }

focus.delete = function (c)
    for k, v in ipairs(focus.stack) do
        if v == c then
            table.remove(focus.stack, k)
            break
        end
    end
end

focus.add = function (c)
   focus.delete(c)
   table.insert(focus.stack, 1, c)
end

client.connect_signal("focus", focus.add)
client.connect_signal("unmanage", focus.delete)

captures = {}
captures.size = 500

captures.add = function (c)
   local cg = c:geometry()
   local source_size = math.max(cg.width, cg.height)

   local scale = captures.size / source_size

   local geometry = { width = cg.width * scale, height = cg.height * scale }

   local surface = cairo.ImageSurface(cairo.Format.RGB24, geometry.width, geometry.height)
   local cc = cairo.Context(surface)

   cc:scale(scale, scale)

   cc:set_source_surface(gears.surface(c.content), 0, 0)
   cc:paint()
   captures[c] = {
      surface = surface,
      geometry = geometry
   }
end

captures.delete = function (c) captures[c] = nil end

client.connect_signal("unfocus", captures.add)
client.connect_signal("unmanage", captures.delete)

local overlay = wibox({})
overlay.border_width = 3
overlay.ontop = true
overlay.visible = false
overlay.opacity = 0.8
local thumbnails = {}

-- overlay size as protion of screen
local height_portion = 0.5
local width_portion = 0.8
local active_border_width = 5
local thumbnail = {}

thumbnail.fit = function (t, width, height)
   return t.geometry.width, t.geometry.height
end

thumbnail.draw = function (t, wbox, cr, width, height)
   local active = thumbnails[thumbnails.active_index] == t
   local thumbnail_factor = 0.7
   if active then
      thumbnail_factor = 0.9
   end

   -- TODO: make configurable
   -- TODO: use pango?
   cr:select_font_face("sans", "italic", "normal")
   cr:set_font_face(cr:get_font_face())
   cr:set_source_rgba(1, 1, 1, 1)
   cr:set_font_size(12)

   local text = t.client.name
   local text_extents = cr:text_extents(text)
   -- TODO: fade out wide text (gradient source?)
   local text_x = 30
   cr:move_to(text_x, height - 16)
   cr:show_text(text)

   -- TODO: right align
   cr:move_to(3 * width / 4, height - 32)
   -- TODO: optionally show t.client.screen
   local tags = table.concat(utils.map(t.client:tags(), function (t) return t.name end), ", ")
   cr:show_text("[" .. tags .. "]")

   if active then
      cr:set_font_size(16)
   end
   cr:move_to(text_x, height - 32)
   cr:show_text(t.client.class)

   local cg = captures[t.client] and captures[t.client].geometry
   if t.client:isvisible() or not cg then
      cg = t.client:geometry()
   end

   local target_size = math.min(width, height) * thumbnail_factor
   local source_size = math.max(cg.width, cg.height)
   local scale = target_size / source_size
   local tx = (width - (cg.width * scale)) / 2
   local ty = (height - (cg.height * scale)) / 2

   cr:translate(tx, ty)
   cr:scale(scale, scale)

   if active then
      cr:set_source_rgba(1, 0, 1, 1)
   else
      cr:set_source_rgba(0.5, 0.5, 0.5, 1)
   end
   local scaled_width = active_border_width / scale
   cr:rectangle(-scaled_width, -scaled_width,
                cg.width + 2 * scaled_width, cg.height + 2 * scaled_width)
   cr:fill()

   if t.client:isvisible() then
      cr:set_source_surface(gears.surface(t.client.content), 0, 0)
   elseif captures[t.client] then
      cr:set_source_surface(gears.surface(captures[t.client].surface), 0, 0)
   else
      -- offscreen and never been focussed, so we fallback to a grey box
      cr:set_source_rgba(0.3, 0.3, 0.3, 1)
   end
   cr:rectangle(0, 0, cg.width, cg.height)
   cr:fill()
end

thumbnail.new = function (client, geometry)
   local ret = wibox.widget.base.make_widget()
   for k, v in pairs(thumbnail) do
      if type(v) == "function" then
         ret[k] = v
      end
   end
   ret.client = client
   ret.geometry = geometry
   return ret
end

local function open ()
   overlay:set_bg("#000000")

   local sg = screen[mouse.screen].geometry
   local h = sg.height * height_portion
   local w = sg.width * width_portion
   overlay:geometry({
         x = sg.x + (sg.width - w) / 2,
         width = w,
         y = sg.y + (sg.height - h) / 2,
         height = h
   })

   -- TODO: add all other windows, that currently are in the focus stack
   -- i.e. cs should be the union of client.get() & focus.stack
   local cs = utils.union(focus.stack, client.get())

   local thumbnail_geometry = { width = w / #cs, height = h }

   local layout = wibox.layout.fixed.horizontal()
   overlay:set_widget(layout)

   thumbnails = {}
   thumbnails.active_index = 1

   for k, c in pairs(cs) do
      local t = thumbnail.new(c, thumbnail_geometry)
      layout:add(t)
      table.insert(thumbnails, t)
      if c == client.focus then
         thumbnails.active_index = #thumbnails + 1
      end
   end

   -- this async call ensures the overlay re-renders before becoming visible
   utils.async(function () overlay.visible = true end)
end

local function close ()
   overlay.visible = false
end

local keys = {}
keys.exit = {
   ["Alt_L"] = true,
   ["Meta_L"] = true,
   ["Escape"] = true
}
keys.right = {
   ["Tab"] = true,
   ["Right"] = true,
   ["Down"] = true
}
keys.left = {
   ["ISO_Left_Tab"] = true,
   ["Left"] = true,
   ["Up"] = true
}

local function cycle (direction)
   local old_index = thumbnails.active_index
   thumbnails.active_index =
      math.mod(direction + thumbnails.active_index - 1 + #thumbnails,
               #thumbnails) + 1
   thumbnails[old_index]:emit_signal("widget::updated")
   thumbnails[thumbnails.active_index]:emit_signal("widget::updated")
end

local function switch ()
   open()
   keygrabber.run(
      function (mod, key, event)
         if keys.exit[key] and event == "release" then
            close()
            keygrabber.stop()
            if key ~= "Escape" then
               local chosen_client = thumbnails[thumbnails.active_index].client
               awful.client.jumpto(chosen_client)
            end
         elseif keys.right[key] and event == "press" then cycle(1)
      	 elseif keys.left[key] and event == "press" then cycle(-1)
         end
      end
   )
end

-- TODO: allow mouse click - left click to choose and right click to mark

-- TODO: highlight focussed thumbnail

-- TODO: highlight minimized thumbnails

-- TODO: highlight marked thumbnails

-- TODO: multiple rows of thumbnails when there are lots

-- TODO: make configurable - font, colours, sizes etc.

-- TODO: Add cycle through marked only clients

return {
   switch = switch,
   keys = keys
}
