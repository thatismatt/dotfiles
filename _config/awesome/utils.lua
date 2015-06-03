local naughty = require("naughty")

utils = {}

utils.log = function (msg)
   naughty.notify({ text = msg })
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
   table.foreach(tbl, function (k, v) ks[#ks + 1] = k end)
   table.sort(ks)
   return ks
end

utils.intr = function (tbl)
   local lines = utils.map(
      utils.keys(tbl),
      function (k) return k .. "\t" .. tostring(tbl[k]) end)
   return table.concat(lines, "\n")
end

return utils
