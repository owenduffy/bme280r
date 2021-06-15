-- Remember to connect GPIO16 (D0) and RST for deep sleep function,
-- better though a SB diode anode to RST cathode to GPIO16 (D0).

print("bme280r")

--# Settings #
dofile("nodevars.lua")
--# END settings #

function get_sensor_Data()
  temperature,pressure,humidity,qnh=s:read(altitude)
  temperature=string.format("%.1f",temperature)
  humidity=string.format("%.1f",humidity)
  qnh=string.format("%.1f",qnh)
  print("Temperature: "..temperature.." deg C")
  print("Humidity: "..humidity.."%")
  print("QNH: "..qnh.." hPa")
end

function swf()
--  print("wifi_SSID: "..wifi_SSID)
--  print("wifi_password: "..wifi_password)
  wifi.eventmon.register(wifi.eventmon.STA_GOT_IP,cbsrest)
  wifi.setmode(wifi.STATION) 
  wifi.setphymode(wifi_signal_mode)
  if client_ip ~= "" then
    wifi.sta.setip({ip=client_ip,netmask=client_netmask,gateway=client_gateway})
  end
  wifi.sta.sethostname(wifi_hostname)
  wifi.sta.config({ssid=wifi_SSID,pwd=wifi_password})
  print("swf done...")
end

function cbsrest()
  print(tmr.now())
  print("wifi.sta.status()",wifi.sta.status())
  if wifi.sta.status() ~= 5 then
    print("No Wifi connection...")
  else
    print("WiFi connected...")
  end
  get_sensor_Data()
  req,body=httpreq(1)
  if(body=="") then
    http.get(req,nil,cbhttpdone)
  else
    http.post(req,nil,body,cbhttpdone)
  end
  print("cbsrest done...")
end

function cbhttpdone(code,data)
  if (code<0) then
    print("HTTP request failed")
  else
    print(code,data)
  end
  rtmr=tmr.create()
  rtmr:alarm(500,tmr.ALARM_SINGLE,cbslp)
end

function cbslp()
  print(tmr.now())
  node.dsleep(meas_period*1000000-tmr.now()+8100,2)             
end

print("app starting...")
temperature = 0
humidity = 0
qnh=0
t1=tmr.create()
i2c.setup(0,pin_sda,pin_scl,i2c.SLOW)
s=require('bme280').setup(0,nil,nil,nil,nil,nil,BME280_FORCED_MODE)
--print(s)
if s==nil then
  print("Failed BME280 setup.")
  cbslp()
else
  swf()
end
-- Watchdog loop, will force deep sleep if the operation somehow takes to long
tmr.create():alarm(30000,1,function() node.dsleep(meas_period*1000000) end)
