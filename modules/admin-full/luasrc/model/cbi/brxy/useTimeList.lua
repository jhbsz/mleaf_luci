--[[
  brxy aio
  
  author:xiaobing
  data:2015.03.16

]]--




local brxyutil =require "luci.tools.brxyutil"
local data = brxyutil.getUseTimeListFromDB()

require("luci.sys")
require("luci.util")
f = SimpleForm("unitmachine", translate("use time list"), translate("use time list detail"))
f.reset  = translate("Cancel")
f.submit = translate("synchronization")


--[[
local data= {
  {startTime = "9:00",   endTime   = "13:00", repeatRule = "周一|周二|周三|周四|周五"},
  {startTime = "14:20",  endTime   = "19:30", repeatRule = "周一|周二|周三|周四|周五"},
  {startTime = "6:30",   endTime   = "22:00", repeatRule = "周一|周二|周三|周四|周五"},
  {startTime = "6:00",   endTime   = "22:00", repeatRule = "周五"}
}
]]--



t = f:section(Table, data)
t:option(DummyValue, "startTime", translate("start time"))
t:option(DummyValue, "endTime", translate("end time"))
t:option(DummyValue, "repeatRule", translate("repeat rule"))


--[[  自定义按钮
sync = f:field(Button,"syn")
sync.title="同步"
sync.inputstyle = "apply"
sync.write = function(self, section)
  f.message = "同步"
end
cancel_syn = f:field(Button,"cancel_syn","取消","desc")
]]--


-- 外层 系统submit的send按钮触发事件
function f.handle(self, state, data)
  --[[
  表单状态  
  FORM_NODATA  =  0
  FORM_PROCEED =  0
  FORM_VALID   =  1
  FORM_DONE  =  1
  FORM_INVALID = -1
  FORM_CHANGED =  2
  FORM_SKIP    =  4
  ]]--
  

  
  -- 从云平台同步数据
  if state == FORM_VALID then
    f.message = "从云平台同步数据 handle state="..state  
    -- TODO 从云平台同步数据
  end
  
  return true
end 

return f