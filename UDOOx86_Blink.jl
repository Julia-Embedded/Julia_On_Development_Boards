u86Proc = addprocs(["julia-user@NODE-UDOOX86"],dir="/home/julia-user/julia-0.6.0/bin/")

include("GPIO_U86.jl")

import GPIO_U86
using GPIO_U86

u86 = GPIO_U86.U86GPIO()

initialize(u86, "UDOOx86.xml")

LEDPin = u86.digital_pin["CN12_PIN45"]

remotecall_fetch(GPIO_Common.blinkLED, u86Proc[1], LEDPin)
