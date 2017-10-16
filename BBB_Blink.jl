bbbProc = addprocs(["julia-user@NODE-BBB"],dir="/home/julia-user/julia-0.6.0/bin/")

include("GPIO_Device.jl")

import GPIO_Device
using GPIO_Device

bbb = GPIO_Device.DeviceGPIO()

initialize(bbb, "BBB.xml")

LEDPin = bbb.digital_pin["P9_PIN12"]

remotecall_fetch(GPIO_Common.blinkLED, bbbProc[1], LEDPin)

