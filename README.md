# Julia_On_Development_Boards
Using the Julia language with a Raspberry Pi, Beaglebone Black, UDOOx86, and NanoPi Duo

Julia is a high-level, high-performance dynamic programming language for numerical computing. It provides a sophisticated compiler, distributed parallel execution, numerical accuracy, and an extensive mathematical function library. (see https://julialang.org/)

This is a work in progress. I wanted to take advantage of Julia's distributed parallel execution by using it with different small, inexpensive development boards. Some of my ideas are being able to remotely control the GPIO pins on these different development boards from the Julia language. 

I have 5 computers on a Beowulf cluster (passwordless ssh): a Dell Optiplex 755, a Raspberry Pi 3, a Beaglebone Black, a UDOOX86, and a NanoPi Duo. The Dell Optiplex 755 acts as the master node with the development boards acting as slave nodes. I want to be able to read and write to GPIO pins from the master node. A scenario would be to have each development board connected to different sensors. The boards might trigger an LED or something when a threshold is reached and report it to the master node. Of course, the world is wide open with applications.

See the videos for a demonstration: 

https://photos.app.goo.gl/0j8f1OwTQFWWTD052, https://photos.app.goo.gl/EI4JTKJqKwtJOWzk2 

The videos are a bit dated. I've streamlined the code quite a bit more.


The main Julia file that I am using, now, is Machine_GPIO.jl. It keeps all of the code in one file. Machine_GPIO is a module that can be used on any of the nodes on the cluster. This is done via the Julia macro @everywhere. This macro basically takes the code and makes it available to any processes. Using GPIOs is now part of the Linux file system. So, Machine_GPIO just uses that fact that any of the development boards that are running Linux can take advantage of the sysfs GPIO (see http://elinux.org/GPIO). So, this idea should work for any development board that has GPIOs and is running some flavor of Linux. I am also running a 32-bit version of Julia on every node because it was the lowest common denominator and all versions of Julia on the cluster must be the same 32-bit or 64-bit version. See the Machine_GPIO.jl file for specific instructions that may need to be followed to ensure that permissions are correctly set for the specific board.

Here's an example of using Julia to blink an LED on a remote development board. In this example, I have an LED attached
to the NanoPi Duo board on pin 5. In this example, the whole function blink_LED is being done remotely on the development board.

```
#Connect to the NanoPi Duo node
npdProc = addprocs(["julia-user@NODE-NANOPIDUO"],dir="/home/julia-user/julia-0.6.0/bin/")

include("GPIO_NPD.jl")

import GPIO_NPD
using GPIO_NPD

#make an instance of the NPDGPIO object.
npd = GPIO_NPD.NPDGPIO()

initialize(npd, "NANOPIDUO.xml")

LEDPin = npd.digital_pin["PIN12"]

#do a remote call to NanoPi Duo node and start the blink_LED function 
#passing it the npd instance and the pin we want to blink
remotecall_fetch(GPIO_Common.blinkLED, npdProc[1], LEDPin)
```

So, to make this work on the Raspberry Pi means changing very little code.

```
#Connect to the Raspberry Pi node
rpiProc = addprocs(["julia-user@NODE-RPI3"],dir="/home/julia-user/julia-0.6.0/bin/")

include("GPIO_RPI.jl")

import GPIO_RPI
using GPIO_RPI

#make an instance of the RPIGPIO object.
rpi = GPIO_RPI.RPIGPIO()

initialize(rpi, "RPI3.xml")

LEDPin = rpi.digital_pin["PIN07"]

#do a remote call to Raspberry Pi node and start the blink_LED function 
#passing it the rpi instance and the pin we want to blink
remotecall_fetch(GPIO_Common.blinkLED, rpiProc[1], LEDPin)
```

And, here is the same code with little change blinking an LED on the Beaglebone Black (note - we needed to use
a different pin).

```
#Connect to the Beaglebone Black node
bbbProc = addprocs(["julia-user@NODE-BBB"],dir="/home/julia-user/julia-0.6.0/bin/")

include("GPIO_BBB.jl")

import GPIO_BBB
using GPIO_BBB

#make an instance of the BBBGPIO object.
bbb = GPIO_BBB.BBBGPIO()

initialize(bbb, "BBB.xml")

LEDPin = bbb.digital_pin["P9_PIN12"]

#do a remote call to Beaglebone Black node and start the blink_LED function 
#passing it the bbb instance and the pin we want to blink
remotecall_fetch(GPIO_Common.blinkLED, bbbProc[1], LEDPin)
```




