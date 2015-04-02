--[[
LuCI - Lua Configuration Interface

一体机配置

$Id$
]]--


 --获得 一体机 串口控制 的实例 

 local fs = require "nixio.fs"




f = SimpleForm("unitmachine", translate("brxy aio"), translate("brxy aio detail"))
f.reset  = false --不显示重置表单按钮          --translate("form reset")  -- 显示reset按钮
f.submit = false
f.brxy = false  -- brxy 禁用F5的标志,js增加刷新按钮

-- local internetOfThings = fs.access("/etc/config/unitmachine/Internet_Of_Things") or {}
local internetOfThings = {}

for  i=0,5 do
  internetOfThings[i] = {
      Device_Type    = "Light Control One",
      Device_ID   = "00:01:01:01:01:01",
      Device_Status = "ON",
      Device_Name = "测试输出"
    }
end;

local data, code, msg = fs.readfile("/etc/config/unitmachine/Internet_Of_Things")

s=f:section(Table,data)
s.addremove = true
  deviceType = s:option(ListValue, "Device_Type", translate("deviceType"))
  deviceType:value("Light Control One","灯控开关一路")
  deviceType:value("Light Control Two","灯控开关二路")
  deviceType:value("Light Control Three","灯控开关三路")
  deviceType:value("Light Control Four","灯控开关四路")
  deviceType:value("Temperature humidity Light","温湿度光照")  -- TODO 翻译
  deviceType:value("RFID","RFID")
  deviceType.rmempty  = true
  
  deviceId = s:option(Value, "Device_ID", translate("deviceId"))
  deviceId.rmempty  = true
  
  deviceStatus = s:option(ListValue, "Device_Status", translate("deviceStatus"))
  deviceStatus:value("OFF","OFF")
  deviceStatus:value("ON","ON")
  deviceStatus.rmempty  = true
  
  deviceName = s:option(Value, "Device_Name", translate("deviceName"))
  deviceName.rmempty  = true
  

  test = f:field(Value,"test","测试输出")

 syncBtn = f:field(Button,"Enable_Disable_Time_Flag","同步")
 syncBtn.helptxt  = false
 syncBtn.inputstyle = "reload"
 function syncBtn.write(self,section)
   test.default = "同步"
 end

-- 外层 系统submit的send按钮触发事件
function f.handle(self, state, data)
  --[[]
  表单状态  
  FORM_NODATA  =  0
  FORM_PROCEED =  0
  FORM_VALID   =  1
  FORM_DONE  =  1
  FORM_INVALID = -1
  FORM_CHANGED =  2
  FORM_SKIP    =  4
  ]]--
  
  
  -- local arptable = luci.sys.net.arptable() or {}
  --f.errmessage = translate("serialBaudRate")
  if state == FORM_NODATA  or state == FORM_PROCEED then
    --test.default = internetOfThings
      f.message = internetOfThings
    for i, dataset in ipairs(internetOfThings) do
      deviceType.default = dataset["Device_Type"]
      deviceId.default = dataset["Device_ID"]
      deviceStatus.default = dataset["Device_Status"]
      
    end
  
  end
  
 
  
  return true
end 



return f
