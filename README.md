# Julia_On_Development_Boards
Using the Julia language with a Raspberry Pi, Beaglebone Black, UDOOx86, and NanoPi Duo

Julia is a high-level, high-performance dynamic programming language for numerical computing. It provides a sophisticated compiler, distributed parallel execution, numerical accuracy, and an extensive mathematical function library. (see https://julialang.org/)

This is a work in progress. I wanted to take advantage of Julia's distributed parallel execution by using it with different small, inexpensive development boards. Some of my ideas are being able to remotely control the GPIO pins on these different development boards from the Julia language. 

I have 5 computers on a Beowulf cluster (passwordless ssh): a Dell Optiplex 755, a Raspberry Pi 3, a Beaglebone Black, a UDOOX86, and a NanoPi Duo. The Dell Optiplex 755 acts as the master node with the development boards acting as slave nodes. I want to be able to read and write to GPIO pins from the master node. A scenario would be to have each development board connected to different sensors. The boards might trigger an LED or something when a threshold is reached and report it to the master node. Of course, the world is wide open with applications.

See the videos for a demonstration: 

https://photos.app.goo.gl/0j8f1OwTQFWWTD052, https://photos.app.goo.gl/EI4JTKJqKwtJOWzk2 

The videos are a bit dated. I've streamlined the code quite a bit more.


The main Julia file that I am using, now, is Machine_GPIO.jl. It keeps all of the code in one file.

Here's an example of using Julia to blink an LED on a remote development board. In this example, I have an LED attached
to the NanoPi Duo board on pin 5. In this example, the whole function blink_LED is being done remotely on the development board.

```
#Connect to the NanoPi Duo node
npdProc = addprocs(["julia-user@NODE-NANOPIDUO"],dir="/home/julia-user/julia-0.6.0/bin/")

include("Machine_GPIO.jl")

import Machine_GPIO

using Machine_GPIO

#make an instance of the NPDGPIO object.
npd = Machine_GPIO.NPDGPIO()

#do a remote call to NanoPi Duo node and start the blink_LED function 
#passing it the npd instance and the pin we want to blink
remotecall_fetch(Machine_GPIO.blinkLED, npdProc[1], npd, npd.pin["PIN05"])
```

So, to make this work on the Raspberry Pi means changing very little code.

```
#Connect to the Raspberry Pi node
rpiProc = addprocs(["julia-user@NODE-RPI3"],dir="/home/julia-user/julia-0.6.0/bin/")

include("Machine_GPIO.jl")

import Machine_GPIO

using Machine_GPIO

#make an instance of the RPIGPIO object.
rpi = Machine_GPIO.RPIGPIO()

#do a remote call to Raspberry Pi node and start the blink_LED function 
#passing it the rpi instance and the pin we want to blink
remotecall_fetch(Machine_GPIO.blinkLED, rpiProc[1], rpi, rpi.pin["PIN05"])
```

And, here is the same code with little change blinking an LED on the Beaglebone Black (note - we needed to use
a different pin).

```
#Connect to the Beaglebone Black node
bbbProc = addprocs(["julia-user@NODE-BBB"],dir="/home/julia-user/julia-0.6.0/bin/")

include("Machine_GPIO.jl")

import Machine_GPIO

using Machine_GPIO

#make an instance of the BBBGPIO object.
bbb = Machine_GPIO.BBBGPIO()

#do a remote call to Beaglebone Black node and start the blink_LED function 
#passing it the bbb instance and the pin we want to blink
remotecall_fetch(Machine_GPIO.blinkLED, bbbProc[1], bbb, bbb.pin["P9_PIN15"])
```

This is another blink LED example, but each line is being sent from the master node to the slave node [development
board - back to the NanoPi Duo].

```
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
```


