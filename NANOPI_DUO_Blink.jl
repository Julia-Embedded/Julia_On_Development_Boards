npdProc = addprocs(["julia-user@NODE-NANOPIDUO"],dir="/home/julia-user/julia-0.6.0/bin/")

include("Machine_GPIO.jl")

import Machine_GPIO

using Machine_GPIO

npd = Machine_GPIO.NPDGPIO()


remotecall_fetch(export_pin, npdProc[1], npd, npd.pin["PIN05"])

remotecall_fetch(setdirection_pin, npdProc[1], npd, npd.pin["PIN05"], Machine_GPIO.OUT)

for n = 1:10
	remotecall_fetch(setvalue_pin, npdProc[1], npd, npd.pin["PIN05"], Machine_GPIO.HIGH)
	sleep(.5)
	remotecall_fetch(setvalue_pin, npdProc[1], npd, npd.pin["PIN05"], Machine_GPIO.LOW)
	sleep(.5)
end

remotecall_fetch(unexport_pin, npdProc[1], npd, npd.pin["PIN05"])
