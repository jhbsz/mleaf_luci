--[[
LuCI - Lua Configuration Interface

一体机配置

$Id$
]]--


 --获得 一体机 串口控制 的实例
local brxyutil =require "luci.tools.brxyutil"
local data = brxyutil.getData()
 


f = SimpleForm("unitmachine", translate("brxy aio"), translate("brxy aio detail"))
f.reset  = translate("Revert") --  false不显示重置表单按钮          --translate("form reset")  -- 显示reset按钮，并改变显示文字
f.submit = translate("Save &#38; Apply")
f.brxy = true  -- brxy 禁用F5的标志,js增加刷新按钮



 


  --serialBaudRate.rmempty = true  -- Removes this option from the configuration file when the user enters an empty value 
  
  -- 设备IP
  deviceIp = f:field(DummyValue,"deviceIp","IP")
  deviceIp.rmempty = false
--function deviceIp.cfgvalue()
--  return fs.readfile("/etc/unitmachine.deviceIp") or ""
--end

  deviceName = f:field(Value,"deviceName","设备名称")
  deviceName.rmempty = false
  
  deviceMac = f:field(DummyValue,"deviceName","设备序列号")
  deviceMac.rmempty = false
  
  activeCode = f:field(Value,"activeCode","设备激活码")
  activeCode.rmempty = false
  
-- 波特率
  baudRate = f:field(ListValue, "baudRate", translate("baudRate"))
  baudRate:value("82", "300")
  baudRate:value("83", "600")
  baudRate:value("84", "1200")
  baudRate:value("85", "2400")
  baudRate:value("86", "4800")
  baudRate:value("87", "9600")
  baudRate:value("88", "14400")
  baudRate:value("89", "19200")
  baudRate:value("90", "38400")
  baudRate:value("92", "57600")
  baudRate:value("93", "115200") 

  -- 校验位  EVEN，ODD，NONE
  checkSum = f:field(ListValue, "checkSum" ,translate("checkSum"))
  checkSum:value("NONE", translate("No parity"))
  checkSum:value("ODD", translate("Odd parity"))
  checkSum:value("EVEN", translate("Even parity"))  
  
  -- 数据位可选：为十进制数“8，9” 意义分别为：8位数据，9位数据 dataBits
  dataBits = f:field(ListValue, "dataBits" ,translate("dataBits"))
  dataBits:value("8", translate("8bit"))
  dataBits:value("9", translate("9bit"))
  
  
  -- 停止位的值：为十进制数“1，2，3，4”意义分别为：0.5位停止位，1位停止位，1.5位停止位，2位停止位。，LUCI中需中文显示  stopBits
  stopBits = f:field(ListValue, "stopBits" ,translate("stopBits"))
  stopBits:value("1", translate("0.5位停止位"))
  stopBits:value("2", translate("1位停止位"))
  stopBits:value("3", translate("1.5位停止位"))  
  stopBits:value("4", translate("2位停止位")) 
  
  
--   投影仪开机码
projectionOn= f:field(Value,"projectionOn",translate("projectionOn"),translate("projectionOn 16 hexadecimal code"))
projectionOn.rmempty = false
projectionOn.validate = function(self, value, section) 
  
    if value == nil then
      return nil , translate("projectionOn can not be null")
    else
      result = f.myvalidate(value)
      if result then  
        return value
      else    
        return nil , translate("projectionOn must use 16 hexadecimal")
      end        
    end
end

-- 投影仪开机码测试
projectionOnFlag = f:field(Flag, "projectionOnFlag" ,translate("projectionOnFlag"))
projectionOnTest = f:field(Button, "projectionOnTest" ,translate("projectionOnTest"))
function projectionOnTest.write(self,section)
  -- TODO 调用方法查询开机码是否正确
  f.message = "调用方法查询开机码是否正确"
end


--  投影仪关机码
projectionOff=f:field(Value,"projectionOff",translate("projectionOff"),translate("projectionOff 16 hexadecimal code"))
projectionOff.rmempty = false
projectionOff.validate = function(self, value, section)
    if value == nil then
      return nil , translate("projectionOff can not be null")
    else
      result = f.myvalidate(value)
      if result then  
        return value
      else    
        return nil , translate("projectionOff must use 16 hexadecimal")
      end       
    end
end

-- 投影仪关机码测试
projectionOffFlag = f:field(Flag, "projectionOffFlag" ,translate("projectionOffFlag"))
projectionOffTest = f:field(Button, "projectionOffTest" ,translate("projectionOffTest"))
function projectionOffTest.write(self,section)
  -- TODO 调用方法查询关机码是否正确
  f.message = "调用方法查询关机码是否正确"
end

-- 显示通道
projectionChannel=f:field(Value,"projectionChannel",translate("projectionChannel"),translate("projectionChannel 16 hexadecimal code"))
projectionChannel.rmempty = false
projectionChannel.validate = function(self, value, section) 
    if value == nil then
      return nil , translate("projectionChannel can not be null")
    else
      result = f.myvalidate(value)
      if result then  
        return value
      else    
        return nil , translate("projectionChannel must use 16 hexadecimal")
      end       
    end
end

-- 显示通道测试
projectionChannelFlag = f:field(Flag, "projectionChannelFlag" ,translate("projectionChannelFlag"))
projectionChannelTest = f:field(Button, "projectionChannelTest" ,translate("projectionChannelTest"))
function projectionChannelTest.write(self,section)
  -- TODO 调用方法查询显示通道是否正确
  f.message = "调用方法查询显示通道是否正确"
end


-- 投影灯使用寿命查询码
lampUsed=f:field(Value,"lampUsed",translate("lampUsed"),translate("lampUsed 16 hexadecimal code"))
lampUsed.rmempty = false
lampUsed.validate = function(self, value, section) 
    if value == nil then
      return nil , translate("lampUsed can not be null")
    else
      result = f.myvalidate(value)
      if result then  
        return value
      else    
        return nil , translate("lampUsed must use 16 hexadecimal")
      end       
    end
end

-- 开机启动延时  关机散热时间
projectorOpenDelay = f:field(ListValue, "projectorOpenDelay",translate("projectorOpenDelay"))
for  i=0,10 do
  j = i*0.5
  projectorOpenDelay:value(i,j) 
end;
projectorCoolingDelay=f:field(ListValue, "projectorCoolingDelay", translate("projectorCoolingDelay"))
for  i=0,20 do
  j = i*0.5 
  projectorCoolingDelay:value(i,j)
end;


--[[ 电脑自动开机
isAutoOpenComputer = f:field(ListValue, "isAutoOpenComputer" ,translate("isAutoOpenComputer"))
isAutoOpenComputer:value(1,translate("Auto Open Computer")) 
isAutoOpenComputer:value(0,translate("not Auto Open Computer")) 
]]--
-- 电脑自动开机
isAutoStartUp = f:field(Flag, "isAutoStartUp" ,translate("isAutoStartUp"))




-- 音量
volumeTotal = f:field(ListValue,"volumeTotal",translate("volumeTotal"))
for  i=1,8 do
  volumeTotal:value(i,i) 
end;

 --  高音  低音
volumeHight =f:field(ListValue,"volumeHight",translate("volumeHight"))
volumeLow= f:field(ListValue,"volumeLow",translate("volumeLow"))
for  i=1,15 do
  volumeHight:value(i,i) 
  volumeLow:value(i,i) 
end;
 




--[[
refresh = f:field(Button, "refresh", translate("read repeat"))
function refresh.write(self, s)  
  luci.http.redirect(luci.dispatcher.build_url("admin", "unitmachine"))
end
]]--


-- 公共验证16进制方法
function f.myvalidate(value)
  len = string.len(value)
  for i=1,len do
    s = string.sub(value,i,i)   
    if string.lower(s) > "f" or string.lower(s) < "0" then     
    return false 
    end
  end
  return true
end
     

--test = f:field(Value,"test","测试输出")

-- 把查询结果赋值到页面
function f.initValue()
  deviceIp.default = data.deviceIp
  deviceName.default = data.deviceName
  deviceMac.default = data.deviceMac
  activeCode.default = data.activeCode
  baudRate.default = data.baudRate
  checkSum.default = data.checkSum
  dataBits.default = data.dataBits
  stopBits.default = data.stopBits
  projectionOn.default  = data.projectionOn
  projectionOff.default = data.projectionOff
  projectionChannel.default = data.projectionChannel
  projectionOnFlag.default = data.projectionOnFlag
  projectionOffFlag.default = data.projectionOffFlag
  projectionChannelFlag.default = data.projectionChannelFlag
  lampUsed.default = data.lampUsed
  projectorOpenDelay.default = data.projectorOpenDelay
  projectorCoolingDelay.default = data.projectorCoolingDelay
  isAutoStartUp.default = data.isAutoStartUp
  volumeTotal.default = data.volumeTotal
  volumeHight.default = data.volumeHight
  volumeLow.default =data.volumeLow
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
  
  --f.errmessage = translate("serialBaudRate")
   -- print(state)
  if state == FORM_NODATA  or state == FORM_PROCEED then
    -- 初始化 读取串口获取值
    f.initValue()
    return true
  end
  
  -- 存入数据库
  if state == FORM_VALID then
    f.message = "存数据库 handle state="..state  
    -- TODO 存数据库
  end
  
  return true
end 





return f
