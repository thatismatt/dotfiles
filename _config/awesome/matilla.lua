---------------------------------------------------------------------------
-- MATILLA - MAtt's TILing LAyout
-- @author Matt Lee
-- @copyright Matt Lee
---------------------------------------------------------------------------

local ipairs = ipairs
local math   = math
local tag    = require("awful.tag")
local utils  = require("utils")

local matilla = {}

local function geometry_create (remaining, proportion, direction)
   local other_direction = ({ height = "width", width = "height"})[direction]
   return {
      [direction] = remaining[direction] * proportion,
      [other_direction] = remaining[other_direction],
      x = remaining.x,
      y = remaining.y
   }
end

local function geometry_add_border (geometry, border)
   return {
      width = geometry.width - (2 * border),
      height = geometry.height - (2 * border),
      x = geometry.x,
      y = geometry.y
   }
end

local function geometry_remove_border (geometry, border)
   return {
      width = geometry.width + (2 * border),
      height = geometry.height + (2 * border),
      x = geometry.x,
      y = geometry.y
   }
end

local function client_set_geometry (client, geometry)
   return geometry_remove_border(
      client:geometry(geometry_add_border(geometry, client.border_width)),
      client.border_width)
end

-- param: {
--  workarea = { y = 28, x = 0, height = 1747, width = 3200 }
--  screen = 1,
--  geometry = { y = 0, x = 0, height = 1800, width = 3200 },
--  clients = { 1 = window/client: 0x1849238 ... }
-- }
local function tile(param)
   local t = param.tag or tag.selected(param.screen)

   local clients = param.clients
   local master_proportion = tag.getmwfact(t)
   if (#clients == 1) then
      master_proportion = 1
   end

   utils.log(
      utils.dump(utils.map(clients, function (c) return c.size_hints end)))

   -- master client
   local master_geometry = client_set_geometry(
      clients[1],
      geometry_create(param.workarea, master_proportion, "width"))

   local remaining = param.workarea
   remaining.width = remaining.width - master_geometry.width
   remaining.x = remaining.x + master_geometry.width

   -- other clients
   for k, client in pairs(utils.tail(clients)) do
      local proportion = 1 / (#clients - k)

      local geometry = client_set_geometry(client, geometry_create(remaining, proportion, "height"))

      remaining.height = remaining.height - geometry.height
      remaining.y = remaining.y + geometry.height
   end
end

matilla.name = "matilla"
matilla.arrange = tile

return matilla
