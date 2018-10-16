-- Remember to connect GPIO16 (D0) and RST for deep sleep function,
-- better though a SB diode anode to RST cathode to GPIO16 (D0).

--# Settings #
dofile("nodevars.lua")
--# END settings #

function get_sensor_Data()
  sens_status=bme280.setup(1,1,1,1)
  if sens_status~=2 then
     print("Failed BME280 setup.")
  else
    repeat
      temperature,pressure,humidity,qnh=bme280.read(altitude)
      --temperature=bme280.temp()
    until temperature~=nil and humidity~=nil and pressure~=nil
--    repeat
--      humidity=bme280.humi()
--    until humidity~=nil
    temperature=string.format("%.1f",temperature/100)
    humidity=string.format("%.1f",humidity/1000)
    qnh=string.format("%.1f",qnh/1000)
    print("Temperature: "..temperature.." deg C")
    print("Humidity: "..humidity.."%")
  end
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
  tmr.alarm(0,500,tmr.ALARM_SINGLE,cbslp)
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
sda,scl=3,4   --D3,D4 GPIO00,GPIO02?
i2c.setup(0,sda,scl,i2c.SLOW) -- call i2c.setup() only once
swf()
-- Watchdog loop, will force deep sleep if the operation somehow takes to long
tmr.create():alarm(30000,1,function() node.dsleep(meas_period*1000000) end)
