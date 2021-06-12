--copy to init.lua and edit cfgdefs below
--the values correspond to cfgvars
cfgdefs={
"",
"",
"4",
"3",
"60",
"0",
"",
"",
""
}
--no need for changes below here
cfgvars={
"wifi_SSID",
"wifi_password",
"pin_scl",
"pin_sda",
"meas_period",
"altitude",
"rest_url",
"rest_body",
"apikey"
}

function httpreq(opt) 
  if opt==1 then
    req=rest_url.."?api_key="..apikey.."&field1="..temperature.."&field2="..humidity.."&field3="..qnh
    body=""
    print("req:"..req.."\nbody:"..body)
    return req,body
  end
end

print("\n\nHold Pin00 low for 1s to stop boot.")
print("\n\nHold Pin00 low for 5s for config mode.")
tmr.delay(1000000)
if gpio.read(3) == 0 then
  print("Release to stop boot...")
  tmr.delay(4000000)
  if gpio.read(3) == 0 then
    print("Release now (wifi cfg)...")
    print("Starting wifi config mode...")
    dofile("wifi_setup.lua")
    return
  else
    print("...boot stopped")
    return
    end
  end

print("Starting...")
if pcall(function ()
    print("Open config")
--    dofile("config.lc")
    dofile("config.lua")
    end) then
  dofile("app.lua")
else
  print("Starting wifi config mode...")
  dofile("wifi_setup.lua")
end
