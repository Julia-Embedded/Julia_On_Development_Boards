rpiProc = addprocs(["julia-user@NODE-RPI3"],dir="/home/julia-user/julia-0.6.0/bin/")

include("Machine_GPIO.jl")

import Machine_GPIO

using Machine_GPIO

rpi = Machine_GPIO.RPIGPIO()


remotecall_fetch(export_pin, rpiProc[1], rpi, rpi.pin["PIN05"])

remotecall_fetch(setdirection_pin, rpiProc[1], rpi, rpi.pin["PIN05"], Machine_GPIO.OUT)

for n = 1:10
	remotecall_fetch(setvalue_pin, rpiProc[1], rpi, rpi.pin["PIN05"], Machine_GPIO.HIGH)
	sleep(.5)
	remotecall_fetch(setvalue_pin, rpiProc[1], rpi, rpi.pin["PIN05"], Machine_GPIO.LOW)
	sleep(.5)
end

remotecall_fetch(unexport_pin, rpiProc[1], rpi, rpi.pin["PIN05"])
