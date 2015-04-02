--[[


             操作lsqlite3数据库方法


    author：xiaobing





]]--

module("luci.tools.brxyutil", package.seeall)
require "lsqlite3"
local fs = require "nixio.fs"
local table = require "table"
local nixio = require "nixio"


local db = sqlite3.open("/usr/share/brxydata/brxydata.db")




function getMAC()
local db = sqlite3.open("/usr/share/brxydata/brxydata.db")
  local number,MAC
  for row in db:nrows("SELECT * FROM MAC where number = 1") do
    --print(row.number, row.MAC) --显示更新前的number和Code_RTC的数据
    number = row.number
    MAC = row.MAC
  end
  --for a in db:nrows('SELECT * FROM MAC') do table.print(a) end
  db:close()
  nixio.syslog("debug","query device MAC from DB MAC="..MAC)
  return MAC
end



function getIP()
  local ntm = require "luci.model.network".init()
  local wan = ntm:get_wannet()
  local wan6 = ntm:get_wan6net()
  local ip
  if wan then
    ip = wan:ipaddr()
  end
  if wan6 then
    ip = wan6:ip6addr()
  end
  nixio.syslog("debug","query device ip from openWRT network ip="..ip)
  return ip
end

-- 获得串口配置信息
function getSerial()
local db = sqlite3.open("/usr/share/brxydata/brxydata.db")
  local number,baudRate,checkSum,dataBits,stopBits
  for row in db:nrows("SELECT * FROM projector_Serial where number = 1") do
    number = row.number
    baudRate = row.Baud_Rate
    checkSum = row.Checksum
    dataBits = row.Data_Bits
    stopBits = row.Stop_Bits
  end
  db:close()
  nixio.syslog("debug","getSerial from DB number="..number.." baudRate="..baudRate.." checkSum="..checkSum.." dataBits="..dataBits.." stopBits="..stopBits)
  return {baudRate=baudRate,checkSum=checkSum,dataBits=dataBits,stopBits=stopBits}
end

-- 获得音量配置信息
function getSound()
local db = sqlite3.open("/usr/share/brxydata/brxydata.db")
  local number,treble,totalVolume,bass
  for row in db:nrows("SELECT * FROM Sound where number = 1") do
    number = row.number
    treble = row.Treble
    totalVolume = row.total_volume
    bass = row.Bass

  end
  db:close()
  nixio.syslog("debug","getSound from DB number="..number.." treble="..treble.." bass="..bass.." treble="..treble)
  return {treble=treble,totalVolume=totalVolume,bass=bass}
end

function getOperationCode()
local db = sqlite3.open("/usr/share/brxydata/brxydata.db")
  local projectorOn,projectorOnFlag,projectorOff,projectorOffFlag,projectorChannel,projectorChannelFlag
  for row in db:nrows("SELECT * FROM Operation_Code where number = 1") do
    projectorOn = row.Code_Projector_On
    projectorOnFlag = row.Projector_On_Flag
    projectorOff = row.Code_Projector_Off
    projectorOffFlag = row.Projector_Off_Flag
    projectorChannel = row.Code_Projector_Channel
    projectorChannelFlag = row.Projector_Channel_Flag
  end
  db:close()
  nixio.syslog("debug","query device getOperationCode from DB Operation_Code projectorOn="..projectorOn.." projectorOnFlag="..projectorOnFlag)
  nixio.syslog("debug","query device getOperationCode from DB Operation_Code projectorOff="..projectorOff.." projectorOffFlag="..projectorOffFlag)
  nixio.syslog("debug","query device getOperationCode from DB Operation_Code projectorChannel="..projectorChannel.." projectorChannelFlag="..projectorChannelFlag)
  return {projectorOn=projectorOn,
  projectorOnFlag=projectorOnFlag,
  projectorOff=projectorOff,
  projectorOffFlag=projectorOffFlag,
  projectorChannel=projectorChannel,
  projectorChannelFlag=projectorChannelFlag}
end


function getAutomaticControll()
local db = sqlite3.open("/usr/share/brxydata/brxydata.db")
  local projectorOpenDelay,projectorCoolingDelay,isAutoStartUp
  for row in db:nrows("SELECT * FROM Automatic_Control where number = 1") do
    projectorOpenDelay = row.Projector_Open_Delay
    projectorCoolingDelay = row.Projector_Cooling_Delay
    isAutoStartUp = row.Is_Auto_Startup
  end
  db:close()
  nixio.syslog("debug","query device getAutomaticControll from DB Automatic_Control projectorOpenDelay="..projectorOpenDelay.." projectorCoolingDelay="..projectorCoolingDelay.." isAutoStartUp="..isAutoStartUp)
  return {isAutoStartUp=isAutoStartUp,
  projectorOpenDelay=projectorOpenDelay,
  projectorCoolingDelay=projectorCoolingDelay}
end


function getLampUsed()
local db = sqlite3.open("/usr/share/brxydata/brxydata.db")
  local lampUsedFlag,lampUsed
  for row in db:nrows("SELECT * FROM Lamp_Used where number = 1") do
    lampUsedFlag = row.Lamp_Used_Flag
    lampUsed = row.Code_Lamp_Used
  end
  db:close()
  nixio.syslog("debug","query device getLampUsed from DB Lamp_Used lampUsedFlag="..lampUsedFlag.." lampUsed="..lampUsed)
  return {lampUsedFlag=lampUsedFlag,lampUsed=lampUsed}
end



-- TODO AIO data
function getData()
  local serial = getSerial()
  local sound = getSound()
  local operationCode =getOperationCode();
  local automaticControll= getAutomaticControll()
  local lampUsedInfo =getLampUsed()
  local data ={
    deviceIp = getIP(),
    deviceName = "deviceName",
    deviceMac = getMAC(),
    activeCode = "云平台注册设备获取激活码",
    baudRate = serial.baudRate,
    checkSum = serial.checkSum,
    dataBits = serial.dataBits,
    stopBits = serial.stopBits,
    projectorOn  = operationCode.projectorOn,
    projectorOnFlag = operationCode.projectorOnFlag,
    projectorOff = operationCode.projectorOff,
    projectorOffFlag = operationCode.projectorOffFlag,
    projectorChannel = operationCode.projectorChannel,
    projectorChannelFlag = operationCode.projectorChannelFlag,
    lampUsed =lampUsedInfo.lampUsed,
    lampUsedFlag = lampUsedInfo.lampUsedFlag,
    projectorOpenDelay = automaticControll.projectorOpenDelay,
    projectorCoolingDelay = automaticControll.projectorCoolingDelay,
    isAutoStartUp = automaticControll.isAutoStartUp,
    volumeTotal = sound.totalVolume,
    volumeHigh = sound.treble,
    volumeLow =sound.bass
  }
  return data
end

-- 分别调用方法把数据保存到sqlite3
function saveAIO(deviceName,deviceActiveCode,baudRate,checkSum,dataBits,stopBits,projectorOn,projectorOnFlag,projectorOff,projectorOffFlag,projectorChannel,projectorChannelFlag,lampUsedFlag,
  lampUsed,projectorOpenDelay,projectorCoolingDelay,isAutoStartUp,volumeTotal,volumeHigh,volumeLow)
  setSerial(baudRate,checkSum,dataBits,stopBits)
  setSound(volumeTotal,volumeHigh,volumeLow)
  setOperationCode(projectorOn,projectorOnFlag,projectorOff,projectorOffFlag,projectorChannel,projectorChannelFlag)
  setAutomaticControll(isAutoStartUp,projectorOpenDelay,projectorCoolingDelay)
  setLampUsed(lampUsedFlag,lampUsed)
  
  return true
end


function setSerial(baudRate,checkSum,dataBits,stopBits)
  nixio.syslog("debug","setSerial: baudRate="..baudRate.." checkSum="..checkSum.." dataBits="..dataBits.." stopBits="..stopBits)
  local db = sqlite3.open("/usr/share/brxydata/brxydata.db")
  local stmt = db:prepare[[UPDATE Projector_Serial 
  SET Baud_Rate = :baudRate, 
   Checksum = :checkSum, 
   Data_Bits = :dataBits,
   Stop_Bits = :stopBits 
  where number=1]]
  stmt:bind_names{baudRate=baudRate,checkSum=checkSum,dataBits=dataBits,stopBits=stopBits}
  stmt:step()
  stmt:reset()
  stmt:finalize()
  return true
end

function setSound(volumeTotal,volumeHigh,volumeLow)
  nixio.syslog("debug","setSound: volumeTotal="..volumeTotal.." volumeHigh="..volumeHigh.." volumeLow="..volumeLow)
  local db = sqlite3.open("/usr/share/brxydata/brxydata.db")
  local stmt = db:prepare[[UPDATE Sound 
  SET total_volume= :volumeTotal , 
   Treble= :volumeHigh , 
   Bass= :volumeLow 
  where number=1]]
  stmt:bind_names{volumeTotal=volumeTotal,volumeHigh=volumeHigh,volumeLow=volumeLow}
  stmt:step()
  stmt:reset()
  stmt:finalize()
  return true
end

function setOperationCode(projectorOn,projectorOnFlag,projectorOff,projectorOffFlag,projectorChannel,projectorChannelFlag)
  nixio.syslog("debug","setOperationCode: projectorOn="..projectorOn.." projectorOnFlag="..projectorOnFlag)
  nixio.syslog("debug","setOperationCode: projectorOff="..projectorOff.." projectorOffFlag="..projectorOffFlag)
  nixio.syslog("debug","setOperationCode: projectorChannel="..projectorChannel.." projectorChannelFlag="..projectorChannelFlag)
  local db = sqlite3.open("/usr/share/brxydata/brxydata.db")
  local stmt = db:prepare[[UPDATE Operation_Code 
  SET Code_Projector_On= :projectorOn , 
   Projector_On_Flag= :projectorOnFlag , 
   Code_Projector_Off= :projectorOff , 
   Projector_Off_Flag= :projectorOffFlag, 
   Code_Projector_Channel= :projectorChannel , 
   Projector_Channel_Flag= :projectorChannelFlag  
  where number=1]]
  stmt:bind_names{
  projectorOn=projectorOn,
  projectorOnFlag=projectorOnFlag,
  projectorOff=projectorOff,
  projectorOffFlag=projectorOffFlag,
  projectorChannel=projectorChannel,
  projectorChannelFlag=projectorChannelFlag}
  stmt:step()
  stmt:reset()
  stmt:finalize()
  return true
end

function setAutomaticControll(isAutoStartUp,projectorOpenDelay,projectorCoolingDelay)
  nixio.syslog("debug","setAutomaticControll: isAutoStartUp="..isAutoStartUp.." projectorOpenDelay="..projectorOpenDelay.." projectorCoolingDelay="..projectorCoolingDelay)
  local db = sqlite3.open("/usr/share/brxydata/brxydata.db")
  local stmt = db:prepare[[UPDATE Automatic_Control 
  SET Is_Auto_Startup= :isAutoStartUp , 
   Projector_Open_Delay= :projectorOpenDelay , 
   Projector_Cooling_Delay= :projectorCoolingDelay 
  where number=1]]
  stmt:bind_names{isAutoStartUp=isAutoStartUp,projectorOpenDelay=projectorOpenDelay,projectorCoolingDelay=projectorCoolingDelay}
  stmt:step()
  stmt:reset()
  stmt:finalize()
  return true
end

function setLampUsed(lampUsedFlag,lampUsed)
  nixio.syslog("debug","setLampUsed: lampUsedFlag="..lampUsedFlag.." lampUsed="..lampUsed)
  local db = sqlite3.open("/usr/share/brxydata/brxydata.db")
  local stmt = db:prepare[[UPDATE Lamp_Used SET Lamp_Used_Flag= :lampUsedFlag ,  Code_Lamp_Used= :lampUsed where number=1]]
  stmt:bind_names{lampUsedFlag=lampUsedFlag,lampUsed=lampUsed}
  stmt:step()
  stmt:reset()
  stmt:finalize()
  return true
end



-- 从数据库读取设备允许使用时间集合
function getUseTimeListFromDB()
local db = sqlite3.open("/usr/share/brxydata/brxydata.db")
  local useTimeListTable = {}
  nixio.syslog("debug","getUseTimeListFromDB()")
  for row in db:nrows("SELECT * FROM Enable_Disable_Time") do
    --print(row.number, row.MAC) --显示更新前的number和Code_RTC的数据
    number = row.number
    nixio.syslog("debug","number="..row.number.." startTime="..row.Start_Time.." endTime="..row.End_Time.." repeatRule="..row.Repeat)
    local rowData = {
      startTime = row.Start_Time,
      endTime = row.End_Time,
      repeatRule = row.Repeat
    }
    table.insert(useTimeListTable,rowData)
    --useTimeListTable[number] = rowData
  end
  db:close()
  -- 日志输出查询结果
  luci.util.dumptable(useTimeListTable,10)
  return useTimeListTable

end

-- 从数据库读取物联网设备集合
function geInternetOfThingsFromDB()
 local db = sqlite3.open("/usr/share/brxydata/brxydata.db")
  local internetOfThingsTable = {}
  nixio.syslog("debug","geInternetOfThingsFromDB()")
  for row in db:nrows("SELECT * FROM Internet_Of_Things") do
    --print(row.number, row.MAC) --显示更新前的number和Code_RTC的数据
    number = row.number
    nixio.syslog("debug","number="..row.number.." Device_Type="..row.Device_Type.." Device_ID="..row.Device_ID.." Device_Status="..row.Device_Status)
    local rowData = {
      number = row.number,
      Device_Type = row.Device_Type,
      Device_ID = row.Device_ID,
      Device_Status = row.Device_Status
    }
    table.insert(internetOfThingsTable,rowData)
    --internetOfThingsTable[number] = rowData   
  end
  db:close()

  
  return internetOfThingsTable

end


--新增数据到IOT
function addInternetOfThingsToDB(deviceType,deviceID,deviceStatus,deviceName)
  nixio.syslog("debug","addInternetOfThingsToDB:".." Device_Type="..deviceType.." Device_ID="..deviceID.." Device_Status="..deviceStatus.."deviceName="..deviceName)
  local db = sqlite3.open("/usr/share/brxydata/brxydata.db")
  local stmt = db:prepare[[INSERT INTO Internet_Of_Things(number,Device_Type,Device_ID,Device_Status) VALUES(NULL,:deviceType,:deviceID,:deviceStatus)]]
  stmt:bind_names{deviceType=deviceType,deviceID=deviceID,deviceStatus=deviceStatus}
  stmt:step()
  stmt:reset()
  stmt:finalize()


--[[
 nixio.syslog("debug","after add Internet_Of_Things")
  for row in db:nrows("SELECT * FROM Internet_Of_Things") do
      nixio.syslog("debug","number="..row.number.." Device_Type="..row.Device_Type.." Device_ID="..row.Device_ID.." Device_Status="..row.Device_Status)
  end
  ]]--
  return true
end



--根据number删除IOT
function deleteInternetOfThingsFromDB(number)
  nixio.syslog("debug","deleteInternetOfThingsFromDB:".." number="..number)
  local db = sqlite3.open("/usr/share/brxydata/brxydata.db")
  local stmt = db:prepare[[DELETE FROM Internet_Of_Things WHERE number = :number]]
  stmt:bind_names{number=number}
  stmt:step()
  stmt:reset()
  stmt:finalize()
  return true
end








