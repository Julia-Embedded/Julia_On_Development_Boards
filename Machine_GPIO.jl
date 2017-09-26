@everywhere module Machine_GPIO

export export_pin, unexport_pin, setdirection_pin, setvalue_pin, getvalue_pin, 
getvalue_analog_pin, getvalue_analog_from_serial,checking_mic_sensor_on_arduino, 
checking_motion_sensor, checking_light_sensor, setvalue_analog_to_serial, local_blinkLED

const	IN		= 	"in"
const	OUT		=	"out"
const	HIGH	=	1
const	LOW		=	0

abstract type AbstractGPIO end

abstract type MachineGPIO <: AbstractGPIO end

type XXXGPIO <: AbstractGPIO
    name::String
    handle::Int
end

#*************************************************************************************************
#
#Raspberry Pi
#
#*************************************************************************************************
type RPIGPIO <: MachineGPIO
    name::String
    handle::Int
    node::String
    path::String
    pin::Dict{String, Int}
    function RPIGPIO()
		new("Raspberry Pi", 1, "julia-user@NODE-RPI3", "/home/julia-user/julia-0.6.0/bin/",
			Dict(
				#left pins (left)
				"PIN03" => 	2,
				"PIN05" => 	3,
				"PIN07" => 	4,
				"PIN11" => 	17,
				"PIN13" => 	27,
				"PIN15" => 	22,
				"PIN19" => 	10,
				"PIN21" => 	9,
				"PIN23" => 	11,

				#left pins (right)
				"PIN29" => 	5,
				"PIN31" => 	6,
				"PIN33" => 	13,
				"PIN35" => 	19,
				"PIN37" => 	26,

				#right pins (left)
				"PIN08" => 	14,
				"PIN10" => 	15,
				"PIN12" => 	18,
				"PIN16" => 	23,
				"PIN18" => 	24,
				"PIN22" => 	25,
				"PIN24" => 	8,
				"PIN26" => 	7,

				#right pins (right)
				"PIN32" => 	12,
				"PIN36" => 	16,
				"PIN38" => 	20,
				"PIN40" => 	21
			)
		)
	end
end

#*************************************************************************************************
#
#Beaglebone Black
#
#*************************************************************************************************
#Notes about GPIO setup for Beaglebone Black.
#
#Beaglebone black GPIO permissions
#
#sudo groupadd gpio
#
#sudo usermod -aG gpio user-name
#
#We need to create a udev rule in order to change the /sys/class/gpio path from root:root access, 
#to root:gpio( our target group ) access. To make things even more complicated. When we export a gpio pin, 
#this creates a new file path( structure ) that also has root:root access rights by default. As if that 
#were not enough of a “problem”. Things get even more complex in that we have 4 GPIO banks to contend with 
#and no idea which GPIO may need to be exported and when.
#
#sudo nano /etc/udev/rules.d/99-gpio.rules
#
#SUBSYSTEM=="gpio*", PROGRAM="/bin/sh -c 'chown -R root:gpio /sys/class/gpio; chmod -R 770 /sys/class/gpio; chown -R root:gpio /sys/devices/platform/ocp/4????000.gpio/gpio/; chmod -R 770 /sys/devices/platform/ocp/4????000.gpio/gpio/'"
#
#After this we need to reboot in order for the changes to take place.
#
#sudo reboot
#
#To enable ADC (4.x kernel):
#
#sudo nano /boot/uEnv.txt
#
#add (or uncomment):
#
#cape_enable=bone_capemgr.enable_partno=BB-ADC
#
#sudo reboot
#
type BBBGPIO <: MachineGPIO
    name::String
    handle::Int
    node::String
    path::String
    pin::Dict{String, Int}
    function BBBGPIO()
		new("Beaglebone Black", 1, "julia-user@NODE-BBB", "/home/julia-user/julia-0.6.0/bin/",
			Dict(
				#P9 - left pins
				"P9_PIN13" => 	31,
				"P9_PIN11" => 	30,
				"P9_PIN15" => 	48,
				"P9_PIN17" =>	04,
				"P9_PIN21" => 	03,
				"P9_PIN23" => 	49,
				"P9_PIN25" => 	117,
				"P9_PIN27" => 	125,
				"P9_PIN33" => 	4,
				"P9_PIN35" => 	6,
				"P9_PIN37" => 	2,
				"P9_PIN39" => 	0,

				#P9 - right pins
				"P9_PIN12" => 	60,
				"P9_PIN14" => 	40,
				"P9_PIN16" => 	51,
				"P9_PIN18" => 	05,
				"P9_PIN22" => 	02,
				"P9_PIN24" => 	15,
				"P9_PIN26" => 	14,
				"P9_PIN30" => 	122,
				"P9_PIN36" => 	5,
				"P9_PIN38" => 	3,
				"P9_PIN40" => 	1,
				"P9_PIN42" => 	07,

				#P8 - left pins
				"P8_PIN07" => 	66,
				"P8_PIN09" => 	69,
				"P8_PIN11" => 	45,
				"P8_PIN13" => 	23,
				"P8_PIN15" => 	47,
				"P8_PIN17" => 	27,
				"P8_PIN19" => 	22,

				#P8 - right pins
				"P8_PIN08" => 	67,
				"P8_PIN10" => 	68,
				"P8_PIN12" => 	44,
				"P8_PIN14" => 	26,
				"P8_PIN16" => 	46,
				"P8_PIN18" => 	65,
				"P8_PIN26" => 	61
			)
		)
	end
end

#*************************************************************************************************
#
#UDOO x86
#
#*************************************************************************************************
#Warning! Warning: UDOO X86 Pins controlled by the main Braswell processor 
#are 1.8V only compliant. Providing higher voltages, like 3.3V or 5V, 
#could irreversibly damage the board. In order to properly work with an 
#input voltage different from 1.8V use a bidirectional level shifter. 

type U86GPIO <: MachineGPIO
    name::String
    handle::Int
    node::String
    path::String
     pin::Dict{String, Int}
    function U86GPIO()
		new("UDOO X86", 1, "julia-user@NODE-UDOOX86", "/home/julia-user/julia-0.6.0/bin/",
			Dict(
				#Braswell - left pins (outside)

				"CN12_PIN46" =>		330,
				"CN12_PIN45" => 	333,
				"CN12_PIN44" => 	336,
				"CN12_PIN43" => 	329,
				"CN12_PIN42" => 	332,
				"CN12_PIN41" => 	326,
				"CN12_PIN40" => 	408,
				"CN14_PIN37" => 	497,
				"CN14_PIN36" => 	499,

				#Braswell - right pins (outside)
				"CN13_PIN30" => 	466,
				"CN13_PIN29" => 	350,
				"CN13_PIN28" => 	347,
				"CN13_PIN27" => 	349,
				"CN13_PIN26" => 	344,
				"CN13_PIN25" => 	451,
				"CN13_PIN24" => 	346
			)
		)
	end
end


#*************************************************************************************************
#
#NanoPi Duo
#
#*************************************************************************************************
#Notes about GPIO setup for NanoPi Duo.
#
#NanoPi Duo GPIO permissions
#
#sudo groupadd gpio
#
#sudo usermod -aG gpio user-name
#
#We need to create a udev rule in order to change the /sys/class/gpio path from root:root access, 
#to root:gpio( our target group ) access. To make things even more complicated. When we export a gpio pin, 
#this creates a new file path( structure ) that also has root:root access rights by default. As if that 
#were not enough of a “problem”. Things get even more complex in that we have 4 GPIO banks to contend with 
#and no idea which GPIO may need to be exported and when.
#
#sudo nano /etc/udev/rules.d/99-gpio.rules
#
#SUBSYSTEM=="gpio", KERNEL=="gpiochip*", ACTION=="add", PROGRAM="/bin/sh -c 'chown root:gpio /sys/class/gpio/export /sys/class/gpio/unexport ; chmod 220 /sys/class/gpio/export /sys/class/gpio/unexport'"
#SUBSYSTEM=="gpio", KERNEL=="gpio*", ACTION=="add", PROGRAM="/bin/sh -c 'chown root:gpio /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value ; chmod 660 /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value'"
#After this we need to reboot in order for the changes to take place.
#
#sudo reboot
#
type NPDGPIO <: MachineGPIO
    name::String
    handle::Int
    node::String
    path::String
    pin::Dict{String, Int}
    function NPDGPIO()
		new("NanoPi Duo", 1, "julia-user@NODE-NANOPIDUO", "/home/julia-user/julia-0.6.0/bin/",
			Dict(
				#left side
				"PIN03" =>	12,
				"PIN05" =>	11,
				"PIN11" =>	15,
				"PIN13" =>	16,
				"PIN15" =>	14,

				#right side
				"PIN16" =>	13
			)
		)
	end
end



function export_pin(gpio::MachineGPIO, pin::Int)
	flag = pin in values(gpio.pin)
	if (!flag)
		error("This is not a valid pin defined for " * gpio.name)
		return
	end
    export_str = "/sys/class/gpio/export"
    f = open(export_str,"w")
    write(f, string(pin))
    close(f)
end

function unexport_pin(gpio::MachineGPIO, pin::Int)
	flag = pin in values(gpio.pin)
	if (!flag)
		error("This is not a valid pin defined for " * gpio.name)
		return
	end
    unexport_str = "/sys/class/gpio/unexport"
    f = open(unexport_str, "w")
    write(f, string(pin))
    close(f)
end

function setdirection_pin(gpio::MachineGPIO, pin::Int, dir::String)
	flag = pin in values(gpio.pin)
	if (!flag)
		error("This is not a valid pin defined for " * gpio.name)
		return
	end
	if (dir == IN || dir == OUT)
	else
		error("Valid direction is " * IN * " or " * OUT)
		return
	end
    setdir_str = "/sys/class/gpio/gpio" * string(pin) * "/direction"
    f = open(setdir_str, "w")
    write(f, dir) 
    close(f)
end

function getvalue_pin(gpio::MachineGPIO, pin::Int)
	flag = pin in values(gpio.pin)
	if (!flag)
		error("This is not a valid pin defined for " * gpio.name)
		return
	end
    setval_str = "/sys/class/gpio/gpio" * string(pin) * "/value"
    f = open(setval_str, "r")
    val::String = readline(f) 
    close(f)
    return val
end

function setvalue_pin(gpio::MachineGPIO, pin::Int, val::Int)
	flag = pin in values(gpio.pin)
	if (!flag)
		error("This is not a valid pin defined for " * gpio.name)
		return
	end
	if (val == HIGH || val == LOW)
	else
		error("Valid values are " * string(HIGH) * " or " * string(LOW))
		return
	end
    setval_str = "/sys/class/gpio/gpio" * string(pin) * "/value"
    f = open(setval_str, "w")
    write(f, string(val)) 
    close(f)
end

function getvalue_analog_pin(gpio::BBBGPIO, pin::Int)
	flag = pin in values(gpio.pin)
	if (!flag)
		error("This is not a valid pin defined for " * gpio.name)
		return
	end
	if (searchindex("01234567", pin) != 0) #BBB valid analog pins are 0-7.
		getval_str = "/sys/bus/iio/devices/iio:device0/in_voltage" * string(pin) * "_raw"
		f = open(getval_str, "r")
		val::String = readline(f) 
		close(f)
		return val
	else
		error("Not a valid analog pin number.")
	end
end

function getvalue_analog_from_serial(gpio::U86GPIO, portname::String)
    return readchomp(`./readSerialStream --portname $portname`)
end

function setvalue_analog_to_serial(gpio::U86GPIO, portname::String, cmd::String)
    return readchomp(`./writeSerialStream --portname $portname --command $cmd`)
end

function blinkLED(gpio::MachineGPIO, pinLED::Int)

	export_pin(gpio, pinLED)
	
	sleep(1)

	setdirection_pin(gpio, pinLED, OUT)

	sleep(1)
	
	for n = 1:10
		setvalue_pin(gpio, pinLED, HIGH)
		sleep(.5)
		setvalue_pin(gpio, pinLED, LOW)
		sleep(.5)
	end

	unexport_pin(gpio, pinLED)
end

function checking_mic_sensor_on_arduino(u86::U86GPIO, pinLED::Int, portname::String)
    an::String = "0"
    value::Int = 0
    prv::String = ""

    export_pin(u86, pinLED)
    sleep(1)
    setdirection_pin(u86, pinLED, OUT)

    while (true)
        an = getvalue_analog_from_serial(u86, portname)  
        #println("an: ", an)
        value = parse(Int, an)
        sleep(1)
        if value >= 525
            prv = "U86"
            for n = 1:5
                setvalue_pin(u86, pinLED, HIGH)
                sleep(.5)
                setvalue_pin(u86, pinLED, LOW)
                sleep(.5)
            end
            break
        end
    end
    unexport_pin(u86, pinLED)
    sleep(1)

    return prv
end

function checking_motion_sensor(rpi::RPIGPIO, pinLED::Int, pinSensor::Int)
    ret::String = "0"
    prv::String = ""

    export_pin(rpi, pinLED)
    sleep(1)
    setdirection_pin(rpi, pinLED, OUT)

    export_pin(rpi, pinSensor)
    sleep(1)
    setdirection_pin(rpi, pinSensor, IN)

    while (true)
        ret = getvalue_pin(rpi, pinSensor)  
        sleep(1)
        if ret == "1"
            prv = "rpi"
            for n = 1:5
                setvalue_pin(rpi, pinLED, HIGH)
                sleep(.5)
                setvalue_pin(rpi, pinLED, LOW)
                sleep(.5)
            end
            break
        end
    end
    unexport_pin(rpi, pinLED)
    sleep(1)
    unexport_pin(rpi, pinSensor)
    sleep(1)

    return prv
end

function checking_light_sensor(bbb::BBBGPIO, pinLED::Int, pinSensor::Int)
    an::String = "0"
    value::Int = 0
    prv::String = ""

    export_pin(bbb, pinLED)
    sleep(1)
    setdirection_pin(bbb, pinLED, OUT)

    while (true)
        an = getvalue_analog_pin(bbb, pinSensor)  
        #println("an: ", an)
        value = parse(Int, an)
        sleep(1)
        if value >= 3000
            prv = "BBB"
            for n = 1:5
                setvalue_pin(bbb, pinLED, HIGH)
                sleep(.5)
                setvalue_pin(bbb, pinLED, LOW)
                sleep(.5)
            end
            break
        end
    end
    unexport_pin(bbb, pinLED)
    sleep(1)

    return prv
end

end
