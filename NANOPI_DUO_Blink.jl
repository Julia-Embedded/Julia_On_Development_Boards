npdProc = addprocs(["julia-user@NODE-NANOPIDUO"],dir="/home/julia-user/julia-0.6.0/bin/")

include("GPIO_NPD.jl")

import GPIO_NPD
using GPIO_NPD

npd = GPIO_NPD.NPDGPIO()

initialize(npd, "NANOPIDUO.xml")

LEDPin = npd.digital_pin["PIN12"]

remotecall_fetch(GPIO_Common.blinkLED, npdProc[1], LEDPin)
