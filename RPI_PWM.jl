rpiProc = addprocs(["julia-user@NODE-RPI3"],dir="/home/julia-user/julia-0.6.0/bin/")

include("GPIO_Device.jl")

import GPIO_Device

using GPIO_Device

rpi = GPIO_Device.DeviceGPIO()

initialize(rpi, "RPI3.xml")

PWMPin = rpi.pwm_pin["PIN18"]

MachineID = rpi.id

remotecall_fetch(test_pwm, rpiProc[1], MachineID, PWMPin)
