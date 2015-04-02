--[[
LuCI - Lua Configuration Interface

一体机配置

$Id$
]]--


 --获得 一体机 串口控制 的实例
 
 local configInfoLib=require "luci.brxyaioserial.module.ConfigInfo"
 local brxyaioserialLib=require "luci.brxyaioserial"
 local brxyaioserialInstance = brxyaioserialLib.aioserial.new(configInfoLib.ConfigInfo.new())

local i,v,q


f = SimpleForm("unitmachine", translate("brxy aio"), translate("brxy aio detail"))
f.reset  = false --不显示重置表单按钮          --translate("form reset")  -- 显示reset按钮
f.submit = translate("form submit")
f.brxy = true  -- brxy 禁用F5的标志,js增加刷新按钮


--返回按钮
--f.redirect = luci.dispatcher.build_url("admin/unitmachine")




  --serialBaudRate.rmempty = true  -- Removes this option from the configuration file when the user enters an empty value 
  
-- 波特率
  serialBaudRate = f:field(ListValue, "serialBaudRate", translate("serialBaudRate"))
  serialBaudRate:value("82", "300")
  serialBaudRate:value("83", "600")
  serialBaudRate:value("84", "1200")
  serialBaudRate:value("85", "2400")
  serialBaudRate:value("86", "4800")
  serialBaudRate:value("87", "9600")
  serialBaudRate:value("88", "14400")
  serialBaudRate:value("89", "19200")
  serialBaudRate:value("90", "38400")
  serialBaudRate:value("92", "57600")
  serialBaudRate:value("93", "115200") 

-- 校验位
serialParity = f:field(ListValue, "serialParity" ,translate("serialParity"))
  serialParity:value("0", translate("No parity"))
  serialParity:value("1", translate("Odd parity"))
  serialParity:value("2", translate("Even parity"))  
  
--   投影仪开机码
projectorOpenCode= f:field(Value,"projectorOpenCode",translate("projectorOpenCode"),translate("projectorOpenCode 16 hexadecimal code"))
projectorOpenCode.rmempty = false
projectorOpenCode.validate = function(self, value, section) 
  
    if value == nil then
      return nil , translate("projectorOpenCode not null")
    else
      result = f.myvalidate(value)
      if result then  
        return value
      else    
        return nil , translate("projectorOpenCode must use 16 hexadecimal")
      end        
    end
end

--  投影仪关机码
projectorCloseCode=f:field(Value,"projectorCloseCode",translate("projectorCloseCode"),translate("projectorCloseCode 16 hexadecimal code"))
projectorCloseCode.rmempty = false
projectorCloseCode.validate = function(self, value, section)
    if value == nil then
      return nil , translate("projectorCloseCode not null")
    else
      result = f.myvalidate(value)
      if result then  
        return value
      else    
        return nil , translate("projectorCloseCode must use 16 hexadecimal")
      end       
    end
end

-- 显示通道
projectorComputerCode=f:field(Value,"projectorComputerCode",translate("projectorComputerCode"),translate("projectorComputerCode 16 hexadecimal code"))
projectorComputerCode.rmempty = false
projectorComputerCode.validate = function(self, value, section) 
    if value == nil then
      return nil , translate("projectorComputerCode not null")
    else
      result = f.myvalidate(value)
      if result then  
        return value
      else    
        return nil , translate("projectorComputerCode must use 16 hexadecimal")
      end       
    end
end

-- 开机启动延时  关机散热时间
--[[
projectorOpenDelay = f:field(ListValue, "projectorOpenDelay", "开机启动延时","0-10共11个级别分别代表0 0.5 1 1.5 ... 5分钟")
projectorCoolingDelay=f:field(ListValue, "projectorCoolingDelay", "关机散热时间","0-10共11个级别分别代表0 0.5 1 1.5 ... 5分钟")
for  i=0,10 do
  projectorOpenDelay:value(i,i)
  projectorCoolingDelay:value(i,i)
end;
]]--

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


-- 电脑自动开机
isAutoOpenComputer = f:field(ListValue, "isAutoOpenComputer" ,translate("isAutoOpenComputer"))
isAutoOpenComputer:value(1,translate("Auto Open Computer")) 
isAutoOpenComputer:value(0,translate("not Auto Open Computer")) 

-- 话筒信道
micChannel = f:field(ListValue, "micChannel" ,translate("micChannel"))
for  i=1,99 do
  micChannel:value(i,i) 
end;

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
 
-- 混音
volumeMix= f:field(ListValue,"volumeMix",translate("volumeMix"))
for  i=1,128 do
  volumeMix:value(i,i) 
end; 

-- 开机秘钥
scheduleCode= f:field(Value,"scheduleCode",translate("scheduleCode"),translate("10 bit 16 hexadecimal scheduleCode")) 
--scheduleCode.datatype = "aio16num(10)"  --长度10位16进制
scheduleCode.rmempty = false

scheduleCode.validate = function(self, value, section)
  
  if value == nil then
    return nil , translate("scheduleCode not null")
  else
    len = string.len(value)
    if len == 10 then   
      for i=1,10 do
        s = string.sub(value,i,i)     
        if string.lower(s) > "f" or string.lower(s) < "0" then     
        return nil , translate("scheduleCode must use 16 hexadecimal")
        end
      end
      return value
    else
      return nil,translate("scheduleCode must 10 bit")
    end
  end
  
end

--[[
refresh = f:field(Button, "refresh", translate("read repeat"))
function refresh.write(self, s)  
  luci.http.redirect(luci.dispatcher.build_url("admin", "unitmachine"))
end
]]--


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

function f.initValue()
  
   local status,result =  brxyaioserialInstance.refreshConfigInfo()  
    
   if status then
    f.message = translate("Read the serial success")
    -- success, process result
      serialBaudRate.default = result.getSerialBaudRate()   
      serialParity.default = result.getSerialParity()  
      projectorOpenCode.default = result.getProjectorOpenCode()
      projectorCloseCode.default = result.getProjectorCloseCode()
      projectorComputerCode.default = result.getProjectorComputer()
      projectorOpenDelay.default = result.getProjectorOpenDelay()
      projectorCoolingDelay.default = result.getProjectorCoolingDelay()
      
      --isAutoOpenComputer.default = result.getAutoOpenComputer() 
      if result.getAutoOpenComputer() ==0 then
       isAutoOpenComputer.default = 0
      else
      isAutoOpenComputer.default = 1
      end
      
      micChannel.default = result.getMicChannel()
      
      volumeTotal.default = result.getVolumeHigh()
      volumeLow.default = result.getVolumeLow()
      volumeHight.default = result.getVolumeHigh()
      volumeMix.default = result.getVolumeMix()
      
      scheduleCode.default = result.getProjectorSchoolCode()
   else
    -- failed, the result is the failed message
     f.message = result
   end
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
   
  if state == FORM_NODATA  or state == FORM_PROCEED then
    -- 初始化 读取串口获取值
    f.initValue()
  return true
  
  end
  
  if state == FORM_VALID then
    f.errmessage = "handle state="..state  
    local flag = true
    local msg = ""  
    
    -- 设置串口信息
    local status, result = brxyaioserialInstance.updateSerialConfigSetting(data.serialBaudRate,data.serialParity)
    if status then 
    else
      msg = msg..result
      f.message = msg   
    end
    flag = status
    
    
    -- 设置 声音音量
    if flag then
      local status, result = brxyaioserialInstance.updateSoundVolumeSetting(data.volumeHight,data.volumeLow,data.volumeTotal,data.volumeMix)
      if status then 
      else
        msg = msg..result
        f.message = msg   
      end
      flag = status
    end
   
    
     -- 打开投影仪
     if flag then
      local status, result = brxyaioserialInstance.openProjector(data.projectorOpenCode)
      if status then 
      else
        msg = msg..result
        f.message = msg      
      end
      flag = status
     end
    
    
     -- 关闭投影仪
    if flag then
      local status, result = brxyaioserialInstance.closeProjector(data.projectorCloseCode)
      if status then 
      else
        msg = msg..result
        f.message = msg   
      end
      flag = status
    end
    
    
    -- 显示通道设置
    if flag then
      local status, result = brxyaioserialInstance.updateProjectorComputerSetting(data.projectorComputerCode)
      if status then 
      else
        msg = msg..result
        f.message = msg   
        end
      flag = status
    end
  
    
     -- 设置学校代码
     if flag then
      local status, result = brxyaioserialInstance.updateScheduleCode(data.scheduleCode)
      if status then 
      else
        msg = msg..result
        f.message = msg     
      end
      flag = status
    end
  
    
     -- 设置话筒通道
     if flag then
      local status, result = brxyaioserialInstance.updateMicChannelSetting(data.micChannel)
      if status then 
      else
        msg = msg..result
        f.message = msg     
      end
      flag = status
    end
    
    
    -- 自动控制设置
    if flag then
      local status, result = brxyaioserialInstance.updateAutoControlSetting(data.projectorOpenDelay,data.projectorCoolingDelay,data.isAutoOpenComputer)
      if status then 
      else
        msg = msg..result
        f.message = msg   
      end
      flag = status
    end
   
   
   if flag then     
      f.errmessage = translate("Write the serial success")
      --luci.http.redirect(luci.dispatcher.build_url("admin", "unitmachine"))   
    else    
      --f.message = "设置失败"   
    end  
 
  end
  
  return true
end 



return f
