# Julia_On_Development_Boards
Using the Julia language with a Raspberry Pi, Beaglebone Black, UDOOx86, and NanoPi Duo

Julia is a high-level, high-performance dynamic programming language for numerical computing. It provides a sophisticated compiler, distributed parallel execution, numerical accuracy, and an extensive mathematical function library. (see https://julialang.org/)

This is a work in progress. I wanted to take advantage of Julia's distributed parallel execution by using it with different small, inexpensive development boards. Some of my ideas are being able to remotely control the GPIO pins on these different development boards from the Julia language. 

I have 5 computers on a Beowulf cluster (passwordless ssh): a Dell Optiplex 755, a Raspberry Pi 3, a Beaglebone Black, a UDOOX86, and a NanoPi Duo. The Dell Optiplex 755 acts as the master node with the development boards acting as slave nodes. I want to be able to read and write to GPIO pins from the master node. A scenario would be to have each development board connected to different sensors. The boards might trigger an LED or something when a threshold is reached and report it to the master node. Of course, the world is wide open with applications.

See the videos for a demonstration: 

https://photos.app.goo.gl/0j8f1OwTQFWWTD052, https://photos.app.goo.gl/EI4JTKJqKwtJOWzk2 

The videos are a bit dated. I've streamlined the code quite a bit more.


Each board uses the module file GPIO_Device.jl. There is also a module called GPIO_Common.jl, which contains routines that can easily be used for any board. This GPIO_Common module uses Julia @everywhere macro and this macro allows the routines to be used on any node on the cluster. Using GPIOs is now part of the Linux file system. So, GPIO_Common just uses that fact that any of the development boards that are running Linux can take advantage of the sysfs GPIO (see http://elinux.org/GPIO). So, this idea should work for any development board that has GPIOs and is running some flavor of Linux. I am also running a 32-bit version of Julia on every node because it was the lowest common denominator and all versions of Julia on the cluster must be the same 32-bit or 64-bit version. Each board also has a corresponding .xml file. This allows the user to define pins and other things with regards to that particular board. You will see the use of the .xml files in the examples below. The .xml files allows an instance object to be initialised with values from the .xml file.

Here's an example of using Julia to blink an LED on a remote development board. In this example, I have an LED attached
to the NanoPi Duo board on pin 5. In this example, the whole function blink_LED is being done remotely on the development board. The "blinkLED" routine can be found in GPIO_Common.jl.

```
#Connect to the NanoPi Duo node
npdProc = addprocs(["julia-user@NODE-NANOPIDUO"],dir="/home/julia-user/julia-0.6.0/bin/")

include("GPIO_Device.jl")

import GPIO_Device
using GPIO_Device

#make an instance of the NPDGPIO object.
npd = GPIO_Device.DeviceGPIO()

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

include("GPIO_Device.jl")

import GPIO_Device
using GPIO_Device

#make an instance of the RPIGPIO object.
rpi = GPIO_Device.DeviceGPIO()

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

include("GPIO_Device.jl")

import GPIO_Device
using GPIO_Device

#make an instance of the BBBGPIO object.
bbb = GPIO_Device.DeviceGPIO()

initialize(bbb, "BBB.xml")

LEDPin = bbb.digital_pin["P9_PIN12"]

#do a remote call to Beaglebone Black node and start the blink_LED function 
#passing it the bbb instance and the pin we want to blink
remotecall_fetch(GPIO_Common.blinkLED, bbbProc[1], LEDPin)
```

Here's an example of doing pulse width modulation on the NanoPi Duo. Notice, that I pass a MachineID to the remote function call (along with the pwm pin). The pwm routines work differently on the Raspberry Pi and NanoPi (for the moment) than they do on the Beaglebone Black. They should all use the sysfs, but both Pis have fixes that need to be made for PWM to work from user space. So, the MachineID helps to determine how the pwm calls should be processed (sysfs on the BBB or WiringPI's GPIO utility on the Pis). You can find the "test_pwm" routine in the GPIO_NPD.jl file.

```
npdProc = addprocs(["julia-user@NODE-NANOPIDUO"],dir="/home/julia-user/julia-0.6.0/bin/")

include("GPIO_Device.jl")

import GPIO_Device

using GPIO_Device

npd = GPIO_Device.DeviceGPIO()

initialize(npd, "NANOPIDUO.xml")

PWMPin = npd.pwm_pin["DBG_RX"]

MachineID = npd.id

remotecall_fetch(test_pwm, npdProc[1], MachineID, PWMPin)
```




