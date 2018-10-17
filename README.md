# A simple IoT temperature, humidity and pressure sensor for NodeMCU / Lua and submitting measurements by [RESTful API](https://en.wikipedia.org/wiki/Representational_state_transfer).

To use the code, copy init.default.lua to init.lua, and nodevars.default.lua to nodevars.lua and customise the latter to suit your needs.

Enter your own APIKEY etc as appropriate.

The deep sleep function used depends on an external connection which you must make for it to work properly: connect a SB or germainium diode anode to RST, cathode to GPIO16 (D0).

See project described at https://owenduffy.net/blog/?p=13517.

Tested on:
NodeMCU custom build by frightanic.com
        branch: master
        commit: c708828bbe853764b9de58fb8113a70f5a24002d
        SSL: true
        modules: adc,bme280,encoder,file,gpio,http,i2c,mqtt,net,node,tmr,uart,wifi,tls
 build created on 2018-10-14 09:22
 powered by Lua 5.1.4 on SDK 2.2.1(6ab97e9)



