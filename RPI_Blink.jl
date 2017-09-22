rpiProc = addprocs(["julia-user@NODE-RPI3"],dir="/home/julia-user/julia-0.6.0/bin/")

include("GPIO_RPI.jl")

import GPIO_RPI

using GPIO_RPI

remotecall_fetch(export_pin, rpiProc[1], GPIO_RPI.PIN07)

remotecall_fetch(setdirection_pin, rpiProc[1], GPIO_RPI.PIN07, GPIO_RPI.OUT)

for n = 1:10
	remotecall_fetch(setvalue_pin, rpiProc[1], GPIO_RPI.PIN07, GPIO_RPI.HIGH)
	sleep(.5)
	remotecall_fetch(setvalue_pin, rpiProc[1], GPIO_RPI.PIN07, GPIO_RPI.LOW)
	sleep(.5)
end

remotecall_fetch(unexport_pin, rpiProc[1], GPIO_RPI.PIN07)
