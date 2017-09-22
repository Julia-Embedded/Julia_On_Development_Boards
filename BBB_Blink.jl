bbbProc = addprocs(["julia-user@NODE-BBB"],dir="/home/julia-user/julia-0.6.0/bin/")

include("GPIO_BBB.jl")

import GPIO_BBB

using GPIO_BBB

remotecall_fetch(export_pin, bbbProc[1], GPIO_BBB.P9_PIN15)

remotecall_fetch(setdirection_pin, bbbProc[1], GPIO_BBB.P9_PIN15, GPIO_BBB.OUT)

for n = 1:10
	remotecall_fetch(setvalue_pin, bbbProc[1], GPIO_BBB.P9_PIN15, GPIO_BBB.HIGH)
	sleep(.5)
	remotecall_fetch(setvalue_pin, bbbProc[1], GPIO_BBB.P9_PIN15, GPIO_BBB.LOW)
	sleep(.5)
end

remotecall_fetch(unexport_pin, bbbProc[1], GPIO_BBB.P9_PIN15)
