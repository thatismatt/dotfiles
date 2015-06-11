local naughty = require("naughty")
local awful = require("awful")

local utils = {}

utils.log = function (msg)
   naughty.notify({ text = msg, timeout = 0 })
end

utils.map = function (tbl, f)
   local r = {}
   for k, v in pairs(tbl) do
      r[#r + 1] = f(v)
   end
   return r
end

utils.flatmap = function (tbl, f)
   return utils.concat(utils.map(tbl, f))
end

utils.map_values = function (tbl, f)
   local r = {}
   for k, v in pairs(tbl) do
      r[k] = f(v)
   end
   return r
end

utils.keys = function (tbl)
   local ks = {}
   table.foreach(tbl, function (k, v) ks[#ks + 1] = k end)
   return ks
end

utils.concat = function (tbls)
   local r = {}
   for k, v in pairs(tbls) do
      r = awful.util.table.join(r, v)
   end
   return r
end

utils.range = function (from, to)
   if not to then
      to = from
      from = 1
   end
   local r = {}
   for i = from, to do
      table.insert(r, i)
   end
   return r
end

utils.intr = function (tbl)
   local format_key = function (k)
      local tabs = 2
      if string.len(k) > 7 then
         tabs = 1
      end
      return k .. string.rep("\t", tabs) .. tostring(tbl[k])
   end
   local lines = utils.map(
      utils.keys(tbl),
      format_key)
   return table.concat(lines, "\n")
end

utils.dump = function (o, indent)
   indent = indent or ""
   if type(o) == "table" then
      local s = "{\n"
      for k, v in pairs(o) do
         s = s .. indent .. " " .. tostring(k) .. ' = ' .. utils.dump(v, indent .. " ") .. '\n'
      end
      return s .. indent .. "}"
   else
      return tostring(o)
   end
end

utils.pp = function (o)
   utils.log(utils.dump(o))
end

return utils
