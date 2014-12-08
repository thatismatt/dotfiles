------------------------------------------------------------
-- Global State

local _options = {
   font = "Liberation Mono",
   cpu_bands = {
      x = 0,
      y = 350,
      width = 500,
      num_samples = 100
   },
   cpu_bars = {
      x = 0,
      y = 460,
      width = 500
   },
   clock = {
      x = 0,
      y = 440
   },
   battery = {
      x = 0,
      y = 600
   },
   todo = {
      x = 0,
      y = 720
   }
}

local _cc, _data = nil, nil

------------------------------------------------------------
-- Main

function conky_main()
   if conky_window == nil then return end
   _data = _data or Data:new(_options)
   if (_data:updates() > 5) then
      _cc = _cc or CairoContext:new(conky_window)
      draw(_cc, _data, _options)
   end
end

------------------------------------------------------------
-- Draw

function draw(cc, data, options)
   cc:rgba(1, 1, 1, 0.3)
   machine(cc, data, options)
   clock(cc, data, options)
   cpu_bars(cc, data, options)
   cpu_bands(cc, data, options)
   battery(cc, data, options)
   todo(cc, data, options)
end

------------------------------------------------------------
-- Utils

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k, v in pairs(o) do
         s = s .. k .. ' = ' .. dump(v) .. ', '
      end
      return s .. '}'
   else
      return tostring(o)
   end
end

function pp(o)
   print(dump(o))
end

------------------------------------------------------------
-- Data

Data = {}

function Data:new(options)
   local bands = {}
   -- pad the bands table
   for i = 1, options.cpu_bands.num_samples do
      table.insert(bands, { 0, 0, 0, 0 })
   end
   d = {
      _options = options,
      distro = conky_parse("${exec echo `lsb_release -si` `lsb_release -sr`}"),
      nodename = conky_parse("${nodename}"),
      _cpu_bands = bands
   }
   setmetatable(d, self)
   self.__index = self
   return d
end

function Data:updates()
   return tonumber(conky_parse("${updates}"))
end

function Data:cpus()
   local cpus = {}
   for c = 0, 7 do
      table.insert(cpus, tonumber(conky_parse('${cpu cpu' .. c .. '}')))
   end
   return cpus
end

function Data:cpu_bands()
   local cpus = self:cpus()
   if #cpus > 0 then
      table.sort(cpus)
      local bands = { cpus[1], cpus[3], cpus[6], cpus[8] }
      table.insert(self._cpu_bands, bands)
      table.remove(self._cpu_bands, 1)
   end
   return self._cpu_bands
end

function Data:battery_perc()
   local battery = conky_parse("${battery_percent BAT1}")
   return battery
end

function Data:battery_state()
   local battery = conky_parse("${battery BAT1}")
   return battery
end

------------------------------------------------------------
-- Widgets

function machine(cc, data, options)
   local name_size, distro_size = 140, 28
   cc:text(0, name_size, data.nodename, options.font, name_size)
   cc:text(50, name_size + distro_size, data.distro, options.font, distro_size)
end

function clock(cc, data, options)
   local time, day, month, year, day_of_week = os.date("%H:%M"), os.date("%d"), os.date("%b"), os.date("%Y"), os.date("%a")
   local x, y = options.clock.x, options.clock.y
   local time_size = 150
   local date_y = 120
   cc:text(48,  220,          time,        options.font, 70)

   -- Clock Bars
   local hour, minute, second = os.date("%H"), os.date("%M"), os.date("%S")
   cc:rgba(1, 1, 1, 0.1)
   cc:rect(300, 150, 200, 20)
   cc:rect(300, 175, 200, 20)
   cc:rect(300, 200, 200, 20)
   cc:rgba(1, 1, 1, 0.3)
   cc:rect(300, 150, 200 * hour / 24, 20)
   cc:rect(300, 175, 200 * minute / 60, 20)
   cc:rect(300, 200, 200 * second / 60, 20)

   --cc:text(300, date_y + 103, day,         options.font, 100) -- TODO: right align - text extent?
   --cc:text(420, date_y + 58,  day_of_week, options.font, 34)
   --cc:text(420, date_y + 85,  month,       options.font, 34)
   --cc:text(420, date_y + 108, year,        options.font, 25)
end

function cpu_bars(cc, data, options)
   local cpus = data:cpus()
   local h, gap = 100, 5
   local w = (options.cpu_bars.width + gap) / #cpus - gap
   for k, v in pairs(cpus) do
      local x = (k - 1) * (w + gap) + options.cpu_bars.x
      local y = options.cpu_bars.y
      cc:rgba(1, 1, 1, 0.1)
      cc:rect(x, y - h, w, h)
      cc:rgba(1, 1, 1, 0.3)
      cc:rect(x, y - v, w, v)
      -- cc:text(x + 5, y + 15, v, options.font, 18)
   end
end

function cpu_bands(cc, data, options)
   local bands = data:cpu_bands()
   local num_samples = options.cpu_bands.num_samples
   if #bands < 5 then
      return
   end
   local poly_inner, poly_outer = {}, {}
   local y, w, sz = options.cpu_bands.y, options.cpu_bands.width / (num_samples - 1), 2 * num_samples + 1
   for t, b in pairs(bands) do
      local x = options.cpu_bands.x + (t - 1) * w
      poly_outer[t]      = { x = x, y = y - b[1] }
      poly_outer[sz - t] = { x = x, y = y - b[4] }
      poly_inner[t]      = { x = x, y = y - b[2] }
      poly_inner[sz - t] = { x = x, y = y - b[3] }
   end
   cc:rgba(1, 1, 1, 0.05)
   cc:rect(options.cpu_bands.x, y - 100, options.cpu_bands.width, 100)
   cc:rgba(1, 1, 1, 0.1)
   cc:poly(poly_outer)
   cc:poly(poly_inner)
   cc:rgba(1, 1, 1, 0.3)
end

function battery(cc, data, options)
   local x, y = options.battery.x, options.battery.y
   cc:text(x, y, "Battery: " .. data:battery_state(), options.font, 24)
end

function todo(cc, data, options)
   local filename = os.getenv("HOME") .. "/notes/todo.org"
   local l, x, y = 0, options.todo.x, options.todo.y
   for line in io.lines(filename) do
      l = l + 1
      cc:text(x, y + l * 18, line, options.font, 18)
   end
end
