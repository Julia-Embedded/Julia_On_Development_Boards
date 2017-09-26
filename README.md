# Julia_On_Development_Boards
Using the Julia language with a Raspberry Pi, Beaglebone Black, UDOOx86, and NanoPi Duo

This is a work in progress. I am developing some ideas of being able to remotely control the GPIO pins on different development boards from the Julia language. I have 5 computers on a Beowulf cluster: a Dell Optiplex 755, a Raspberry Pi 3, a Beaglebone Black, a UDOOX86, and a NanoPi Duo. The Dell Optiplex 755 acts as the master node with the development boards acting as slave nodes. I want to be able to read and write to GPIO pins from the master node. A scenario would be to have each development board connected to different sensors. The boards might trigger an LED or something when a threshold is reached and report it to the master node. Of course, the world is wide open with applications.

See the videos for a demonstration: https://photos.app.goo.gl/0j8f1OwTQFWWTD052, https://photos.app.goo.gl/EI4JTKJqKwtJOWzk2 

The videos are a bit dated. I've streamlined the code quite a bit more.

The main Julia file that I am using, now, is Machine_GPIO.jl. It keeps all of the code in one file.

Here's an example of using it to blink an LED on a remote development board. In this example, I have an LED attached
to the NanoPi Duo board on pin 5. In this example, the whole function blink_LED is being done on the development board.

npdProc = addprocs(["julia-user@NODE-NANOPIDUO"],dir="/home/julia-user/julia-0.6.0/bin/")

include("Machine_GPIO.jl")

import Machine_GPIO

using Machine_GPIO

npd = Machine_GPIO.NPDGPIO()

remotecall_fetch(Machine_GPIO.blinkLED, npdProc[1], npd, npd.pin["PIN05"])

This example does the same thing as above, but each line is being sent from the master node to the slave node [development
board].

npdProc = addprocs(["julia-user@NODE-NANOPIDUO"],dir="/home/julia-user/julia-0.6.0/bin/")

include("Machine_GPIO.jl")

import Machine_GPIO

using Machine_GPIO

npd = Machine_GPIO.NPDGPIO()

#blink LED
remotecall_fetch(export_pin, npdProc[1], npd, npd.pin["PIN05"])

remotecall_fetch(setdirection_pin, npdProc[1], npd, npd.pin["PIN05"], Machine_GPIO.OUT)

for n = 1:10
	remotecall_fetch(setvalue_pin, npdProc[1], npd, npd.pin["PIN05"], Machine_GPIO.HIGH)
	sleep(.5)
	remotecall_fetch(setvalue_pin, npdProc[1], npd, npd.pin["PIN05"], Machine_GPIO.LOW)
	sleep(.5)
end

remotecall_fetch(unexport_pin, npdProc[1], npd, npd.pin["PIN05"])
