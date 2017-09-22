npdProc = addprocs(["julia-user@NODE-NANOPIDUO"],dir="/home/julia-user/julia-0.6.0/bin/")

include("GPIO_NPD.jl")

import GPIO_NPD

using GPIO_NPD

remotecall_fetch(export_pin, npdProc[1], GPIO_NPD.PIN05)

remotecall_fetch(setdirection_pin, npdProc[1], GPIO_NPD.PIN05, GPIO_NPD.OUT)

for n = 1:10
	remotecall_fetch(setvalue_pin, npdProc[1], GPIO_NPD.PIN05, GPIO_NPD.HIGH)
	sleep(.5)
	remotecall_fetch(setvalue_pin, npdProc[1], GPIO_NPD.PIN05, GPIO_NPD.LOW)
	sleep(.5)
end

remotecall_fetch(unexport_pin, npdProc[1], GPIO_NPD.PIN05)
