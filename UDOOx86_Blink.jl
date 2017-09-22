u86Proc = addprocs(["julia-user@NODE-UDOOX86"],dir="/home/julia-user/julia-0.6.0/bin/")

include("GPIO_U86.jl")

import GPIO_U86

using GPIO_U86

remotecall_fetch(export_pin, u86Proc[1], GPIO_U86.CN12_PIN46)

remotecall_fetch(setdirection_pin, u86Proc[1], GPIO_U86.CN12_PIN46, GPIO_U86.OUT)

for n = 1:10
	remotecall_fetch(setvalue_pin, u86Proc[1], GPIO_U86.CN12_PIN46, GPIO_U86.HIGH)
	sleep(.5)
	remotecall_fetch(setvalue_pin, u86Proc[1], GPIO_U86.CN12_PIN46, GPIO_U86.LOW)
	sleep(.5)
end

remotecall_fetch(unexport_pin, u86Proc[1], GPIO_U86.CN12_PIN46)
