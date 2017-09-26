bbbProc = addprocs(["julia-user@NODE-BBB"],dir="/home/julia-user/julia-0.6.0/bin/")

include("Machine_GPIO.jl")

import Machine_GPIO

using Machine_GPIO

bbb = Machine_GPIO.BBBGPIO()


remotecall_fetch(export_pin, bbbProc[1], bbb, bbb.pin["P9_PIN15"])

remotecall_fetch(setdirection_pin, bbbProc[1], bbb, bbb.pin["P9_PIN15"], Machine_GPIO.OUT)

for n = 1:10
	remotecall_fetch(setvalue_pin, bbbProc[1], bbb, bbb.pin["P9_PIN15"], Machine_GPIO.HIGH)
	sleep(.5)
	remotecall_fetch(setvalue_pin, bbbProc[1], bbb, bbb.pin["P9_PIN15"], Machine_GPIO.LOW)
	sleep(.5)
end

remotecall_fetch(unexport_pin, bbbProc[1], bbb, bbb.pin["P9_PIN15"])
