npdProc = addprocs(["julia-user@NODE-NANOPIDUO"],dir="/home/julia-user/julia-0.6.0/bin/")

include("GPIO_Device.jl")

import GPIO_Device
using GPIO_Device

npd = GPIO_Device.DeviceGPIO()

initialize(npd, "NANOPIDUO.xml")

LEDPin = npd.digital_pin["PIN12"]

remotecall_fetch(GPIO_Common.blinkLED, npdProc[1], LEDPin)
