--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2008 Jo-Philipp Wich <xm@leipzig.freifunk.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

local require = require
local pairs = pairs
local print = print
local pcall = pcall
local table = table

module "luci.controller.rpc"

function index()
	local function authenticator(validator, accs)
		local auth = luci.http.formvalue("auth", true)
		auth = luci.http.getcookie("auth");  -- 直接从cookie读取数据，request的url不需要带auth = "asdjhdkshdssfgjsgsjgfs"
		if auth then -- if authentication token was given
			local sdat = luci.sauth.read(auth)
			if sdat then -- if given token is valid
				if sdat.user and luci.util.contains(accs, sdat.user) then
					return sdat.user, auth
				end
			end
		end
		luci.http.status(403, "Forbidden")
	end

	local rpc = node("rpc")
	rpc.sysauth = "root"
	rpc.sysauth_authenticator = authenticator
	rpc.notemplate = true

	entry({"rpc", "uci"}, call("rpc_uci"))
	entry({"rpc", "fs"}, call("rpc_fs"))
	entry({"rpc", "sys"}, call("rpc_sys"))
	entry({"rpc", "ipkg"}, call("rpc_ipkg"))
	entry({"rpc", "auth"}, call("rpc_auth")).sysauth = false
	entry({"rpc", "brxy"}, call("brxy_config"))
	entry({"rpc", "test"}, call("brxy_test")).sysauth = false
end

function brxy_test()

 local jsonrpc = require "luci.jsonrpc"
  local sauth   = require "luci.sauth"
  local http    = require "luci.http"
  local sys     = require "luci.sys"
  local ltn12   = require "luci.ltn12"
  local util    = require "luci.util"
  local nixio   = require "nixio"
  local server = {}
  
  server.test = function(...)
    local name = "sky"
    nixio.syslog("info","rpc test method name="+name)
    return name
  end

  http.prepare_content("application/json")
  ltn12.pump.all(jsonrpc.handle(server, http.source()), http.write)
  
end

function brxy_config()

 local jsonrpc = require "luci.jsonrpc"
  local sauth   = require "luci.sauth"
  local http    = require "luci.http"
  local sys     = require "luci.sys"
  local ltn12   = require "luci.ltn12"
  local util    = require "luci.util"
  local brxyutil =require "luci.tools.brxyutil"
  
  local server = {}
  

  
  server.aioConfig = function(deviceName,deviceActiveCode,baudRate,checkSum,dataBits,stopBits,
  projectorOn,projectorOnFlag,projectorOff,projectorOffFlag,projectorChannel,projectorChannelFlag,
  lampUsedFlag,lampUsed,projectorOpenDelay,projectorCoolingDelay,
  isAutoStartUp,volumeTotal,volumeHigh,volumeLow)  
   
      local re = brxyutil.saveAIO(deviceName,deviceActiveCode,baudRate,checkSum,dataBits,stopBits,
      projectorOn,projectorOnFlag,projectorOff,projectorOffFlag,projectorChannel,projectorChannelFlag,
      lampUsedFlag,lampUsed,projectorOpenDelay,projectorCoolingDelay,isAutoStartUp,volumeTotal,volumeHigh,volumeLow)
      return {re=re}
  end
  
  server.geInternetOfThingsFromDB = function()
    local data = brxyutil.geInternetOfThingsFromDB()
     --util.dumptable(data,10)
    return data
  end
  
  server.saveIOT=function(deviceType,deviceID,deviceStatus,deviceName)
      -- 保存到数据库
      local re = brxyutil.addInternetOfThingsToDB(deviceType,deviceID,deviceStatus,deviceName)
      return {deviceType= deviceType,deviceID =deviceID,deviceStatus=deviceStatus,deviceName=deviceName,re=re}
  end
  
  server.deleteIOT=function(number)
      -- 保存到数据库
      local re = brxyutil.deleteInternetOfThingsFromDB(number)
      return {number= number,re=re}
  end

  http.prepare_content("application/json")
  ltn12.pump.all(jsonrpc.handle(server, http.source()), http.write)
  
end

function rpc_auth()
	local jsonrpc = require "luci.jsonrpc"
	local sauth   = require "luci.sauth"
	local http    = require "luci.http"
	local sys     = require "luci.sys"
	local ltn12   = require "luci.ltn12"
	local util    = require "luci.util"

	local loginstat

	local server = {}
	server.challenge = function(user, pass)
		local sid, token, secret

		if sys.user.checkpasswd(user, pass) then
			sid = sys.uniqueid(16)
			token = sys.uniqueid(16)
			secret = sys.uniqueid(16)

			http.header("Set-Cookie", "auth=" .. sid.."; path=/")
			sauth.reap()
			sauth.write(sid, {
				user=user,
				token=token,
				secret=secret
			})
		end

		return sid and {sid=sid, token=token, secret=secret}
	end

	server.login = function(...)
		local challenge = server.challenge(...)
		return challenge and challenge.sid
	end

	http.prepare_content("application/json")
	ltn12.pump.all(jsonrpc.handle(server, http.source()), http.write)
end

function rpc_uci()
	if not pcall(require, "luci.model.uci") then
		luci.http.status(404, "Not Found")
		return nil
	end
	local uci     = require "luci.jsonrpcbind.uci"
	local jsonrpc = require "luci.jsonrpc"
	local http    = require "luci.http"
	local ltn12   = require "luci.ltn12"

	http.prepare_content("application/json")
	ltn12.pump.all(jsonrpc.handle(uci, http.source()), http.write)
end

function rpc_fs()
	local util    = require "luci.util"
	local io      = require "io"
	local fs2     = util.clone(require "nixio.fs")
	local jsonrpc = require "luci.jsonrpc"
	local http    = require "luci.http"
	local ltn12   = require "luci.ltn12"

	function fs2.readfile(filename)
		local stat, mime = pcall(require, "mime")
		if not stat then
			error("Base64 support not available. Please install LuaSocket.")
		end

		local fp = io.open(filename)
		if not fp then
			return nil
		end

		local output = {}
		local sink = ltn12.sink.table(output)
		local source = ltn12.source.chain(ltn12.source.file(fp), mime.encode("base64"))
		return ltn12.pump.all(source, sink) and table.concat(output)
	end

	function fs2.writefile(filename, data)
		local stat, mime = pcall(require, "mime")
		if not stat then
			error("Base64 support not available. Please install LuaSocket.")
		end

		local  file = io.open(filename, "w")
		local  sink = file and ltn12.sink.chain(mime.decode("base64"), ltn12.sink.file(file))
		return sink and ltn12.pump.all(ltn12.source.string(data), sink) or false
	end

	http.prepare_content("application/json")
	ltn12.pump.all(jsonrpc.handle(fs2, http.source()), http.write)
end

function rpc_sys()
	local sys     = require "luci.sys"
	local jsonrpc = require "luci.jsonrpc"
	local http    = require "luci.http"
	local ltn12   = require "luci.ltn12"

	http.prepare_content("application/json")
	ltn12.pump.all(jsonrpc.handle(sys, http.source()), http.write)
end

function rpc_ipkg()
	if not pcall(require, "luci.model.ipkg") then
		luci.http.status(404, "Not Found")
		return nil
	end
	local ipkg    = require "luci.model.ipkg"
	local jsonrpc = require "luci.jsonrpc"
	local http    = require "luci.http"
	local ltn12   = require "luci.ltn12"

	http.prepare_content("application/json")
	ltn12.pump.all(jsonrpc.handle(ipkg, http.source()), http.write)
end
