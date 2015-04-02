

require("luci.sys")
require("luci.util")
local nixio = require "nixio"
local table = require "table"

m = Map("unitmachine", translate("internet of things config page"))  -- internetofthings
m.reset  = false --不显示重置表单按钮          --translate("form reset")  -- 显示reset按钮
m.submit = false

local brxyutil =require "luci.tools.brxyutil"
local data = brxyutil.geInternetOfThingsFromDB()

s = m:section(TypedSection, "Internet_Of_Things", translate("Device list"))
--s = m:section(Table, data)
s.addremove = true
-- s.extedit = true
--s.sortable = true
s.anonymous = true
s.template = "cbi/tblsection"

--[[
number = s:option(DummyValue, "number", translate("number"))
number.datatype = "string"
number.rmempty  = true
]]--

deviceType = s:option(ListValue, "Device_Type", translate("device type"))
deviceType:value("Light Control One",translate("Light Control One"))
deviceType:value("Light Control Two",translate("Light Control Two"))
deviceType:value("Light Control Three",translate("Light Control Three"))
deviceType:value("Light Control Four",translate("Light Control Four"))
deviceType:value("Temperature humidity Light",translate("Temperature humidity Light"))  
deviceType:value("RFID","RFID")
deviceType.datatype = "string"
deviceType.rmempty  = true

deviceId = s:option(Value, "Device_ID", translate("device ID"))
deviceId.datatype = "macaddr"
deviceId.rmempty  = true

deviceStatus = s:option(ListValue, "Device_Status", translate("device status"))
deviceStatus:value("OFF","OFF")
deviceStatus:value("ON","ON")
deviceStatus.datatype = "string"
deviceStatus.rmempty  = true

deviceName = s:option(Value, "Device_Name", translate("device name"))
deviceName.datatype = "string"
deviceName.rmempty  = true

  

local apply = luci.http.formvalue("cbi.apply")
if apply then
  -- TODO  写入数据库
   --luci.http.redirect(luci.dispatcher.build_url("admin/unitmachine/old eg")) 
    nixio.syslog("debug","internetOfThings submit  changes") 
      local uci = luci.model.uci.cursor()
      local changes = uci:changes()
    luci.util.dumptable(changes,10)
     nixio.syslog("debug","internetOfThings submit map") 
     luci.util.dumptable(m,10)
   --for k,v in pairs(s.data) do
    --nixio.syslog("debug","k="..k.." Device_ID="..v[k].Device_ID)
     
  -- end
  
end




return m