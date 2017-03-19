------------------------------------------------------------
-- mpd client - Awesome mpd client using lua socket
-- @author Matt Lee
-- @copyright Matt Lee
------------------------------------------------------------

local socket = require("socket")
local utils = require("utils")
local error = error
local setmetatable = setmetatable
local string = string
local tostring = tostring

module("mpd")

mpd = {}

mpd.hostname = "localhost"
mpd.port = 6600
mpd.timeout = 1000 -- milliseconds
mpd.debug = false

function log (msg)
   if (mpd.debug) then
      utils.log("mpd: " .. tostring(msg))
   end
end

mpd.new = function ()
   local client = {}
   setmetatable(client, { __index = mpd })
   return client
end

function mpd:connect ()
   log("connect")
   self.socket = socket.tcp()
   self.socket:settimeout(mpd.timeout, "t")
   local connected, err = self.socket:connect(mpd.hostname, mpd.port)
   if err then
      log("MPD connect failed: " .. utils.dump(err))
      error("MPD connect failed: " .. utils.dump(err))
      self.connected = false
   else
      local line = self.socket:receive("*l")
      if line:match("^OK MPD") then
         self.connected = true
         local _, _, version = string.find(line, "^OK MPD ([0-9.]+)")
         log("connected: " .. version)
      else
         self.connected = false
         log("not connected: " .. line)
      end
   end
end

function mpd:receive_response ()
   local response = {}
   while true do
      local line, err = self.socket:receive("*l")
      log(utils.dump(line))
      if line then -- occassionally the line is nil, no idea why this happens
         if string.match(line, "^OK$") then
            log(utils.dump(response))
            return response
         end
         local k, v = string.match(line, "^([^:]+):%s(.+)$")
         response[k] = v
      else
         log("Receive error: " .. utils.dump(err))
         return
      end
   end
end

function mpd:command (cmd)
   if not self.connected then
      self:connect()
   end
   self.socket:send(cmd .. "\n")
   local response = self:receive_response()
   if response then
      return response
   else
      self.connected = false
      self.socket:close()
      log("try again: " .. cmd)
      return self:command(cmd)
   end
end

function mpd:toggle ()
   if (self:command("status").state == "play") then
      self:command("pause")
   else
      self:command("play")
   end
end

-- TODO: disconnect: self.socket:close()

return mpd
