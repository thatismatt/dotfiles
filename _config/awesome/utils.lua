local naughty = require("naughty")

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

utils.map_values = function (tbl, f)
   local r = {}
   for k, v in pairs(tbl) do
      r[k] = f(v)
   end
   return r
end

utils.keys = function (tbl)
   local ks = {}
   -- NOTE: tostring(k) required for sorting
   table.foreach(tbl, function (k, v) ks[#ks + 1] = tostring(k) end)
   table.sort(ks)
   return ks
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
