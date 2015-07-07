---------------------------------------------------------------------------
-- Awesome Prime - An improved remote repl for Awesome WM
-- @author Matt Lee
-- @copyright 2015 Matt Lee
-- Based on awful.remote, by Julien Danjou
---------------------------------------------------------------------------

local dbus     = dbus
                 require("awful.dbus")
local error    = error
local ipairs   = ipairs
local load     = loadstring or load -- v5.1 - loadstring, v5.2 - load
local pairs    = pairs
local string   = string
local table    = table
local tostring = tostring
local type     = type

module("prime")

local prime = {}

prime.commands = {
   r = {
      name = "raw return",
      handle = tostring
   },
   t = {
      name = "type",
      handle = function (v)
         return tostring(type(v))
      end
   },
   h = {
      name = "help",
      response = function ()
         local help = { "--- Awesome Prime ---", "An improved remote repl for Awesome WM", "Commands:" }
         for id, c in pairs(prime.commands) do
            table.insert(help, "  :" .. id .. " - " .. c.name)
         end
         return table.concat(help, "\n")
      end
   }
}

function prime.add_commands (cmds)
   for id, c in pairs(cmds) do
      -- TODO: test for overwriting builtin commands
      prime.commands[id] = c
   end
end

function parse_request (request)
   if request == "" then
      return
   end
   local command_id, code = string.match(request, "^:([a-z]?) ?(.*)$")
   if command_id then
      if command_id == "" then
         command_id = "d"
      end
      code = "return " .. code
   else
      command_id = "r"
      code = request
   end
   return command_id, code
end

function process_request (command, code)
   if command.response then
      return command.response()
   else
      local f, e = load(code)
      if f then
         local results = { f() }
         local responses = {}
         for _, v in ipairs(results) do
            table.insert(responses, command.handle(v))
         end
         return table.concat(responses, "\n")
      else
         return tostring(e or "unknown error")
      end
   end
end

function initialise ()
   dbus.connect_signal(
      "org.naquadah.awesome.awful.Prime",
      function (data, request)
         if data.member == "Eval" then
            local command_id, code = parse_request(request)
            if not command_id then
               return
            end
            local command = prime.commands[command_id]
            local response = "Unknown command: " .. command_id
            if command then
               response = process_request(command, code)
            end
            -- add newlines that are removed in awesome-prime shell script
            return "s", "\n" .. response .. "\n"
         end
      end
   )
end

if dbus then
   initialise()
else
   error("prime: unable to connect to dbus")
end

return prime