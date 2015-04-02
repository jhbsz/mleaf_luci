--[[

LuCI - Lua Configuration Interface
Copyright 2014-2015 四川博瑞星云科技有限公司 

博瑞星云一体机配置 

$Id$

author:xiaobing
]]--

module("luci.controller.admin.brxy", package.seeall)

function index()

  entry({"admin", "unitmachine"}, alias("admin", "unitmachine", "aio"),translate("brxy"),60).index = true

  --entry({"admin", "unitmachine", "old eg"}, cbi("brxy/oldEg"),"old eg",50)

  --entry({"admin", "unitmachine", "aio"}, cbi("brxy/unitmachine"),translate("AIO Config"),1)

  entry({"admin", "unitmachine", "iot"}, cbi("brxy/internetOfThings"),translate("Internet of things Config"),2)

  entry({"admin", "unitmachine", "utl"},cbi("brxy/useTimeList"),translate("device allow use time"),3)
  
  entry({"admin", "unitmachine", "aiot"}, template("brxy/unitmachine"), translate("AIO Config"),4)
  
  entry({"admin", "unitmachine", "iott"}, template("brxy/internetOfThings"), translate("Internet of things Config"),5)

  
  entry({"admin", "unitmachine", "selfRd"},cbi("brxy/selfRead"),"自己读文件测试",7)

  entry({"admin", "unitmachine", "aioView"}, template("brxy/aioView"), "aioView",8)

  entry({"admin", "unitmachine", "testView"}, template("brxy/unitmachine"), "testView",9)





  --entry({"admin", "unitmachine", "aio"}, template("unitmachine/aioView"), "aio model",90)


  --page = entry({"admin", "unitmachine", "setaio"}, call("setaio"))


  --entry({"admin","unitmachine","dealaio"},cbi("dealaio"),"deal aio",100)

end









