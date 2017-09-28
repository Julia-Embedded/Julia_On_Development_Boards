@everywhere module Machine_GPIO

export export_pin, unexport_pin, setdirection_pin, setvalue_pin, getvalue_pin, 
getvalue_analog_pin, export_pwm_pin, unexport_pwm_pin, setpolarity_pwm_pin,
setduty_cycle_pwm_pin, setenable_pwm_pin, setperiod_pwm_pin, test_pwm,
getvalue_analog_from_serial,checking_mic_sensor_on_arduino, 
checking_motion_sensor, checking_light_sensor, setvalue_analog_to_serial, local_blinkLED

const	constants = Dict{String, Any}(
				"IN" 					=> 	"in",
				"OUT" 					=>	"out",
				"HIGH"					=>	"1",
				"LOW"					=>	"0",
				"PWM_POLARITY_NORMAL"	=>	"0",
				"PWM_POLARITY_INVERSED"	=>	"1",
				"PWM_ENABLE"	 		=>	"1",
				"PWM_DISABLE"	 		=>	"0",
				"PWM_MODE"				=> 	Dict("BALANCE" => "pwm-bal", "MARK-SPACE" => "pwm-ms"),
				"PWM_CLOCK"				=>	Dict("START" => 2, "END" => 4095),
				"PWM_RANGE"				=>	Dict("START" => 0, "END" => 4096),
				"PWM_DUTY_CYCLE"		=>	Dict("START" => 0, "END" => 1023)
			)



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
#To use PWM on Raspbery Pi see 
#
#We are using WiringPi's gpio command line feature (see: http://wiringpi.com/).
#It comes preinstalled on the latest versions of Raspbian and works without
#needing root permissions.
#
#*************************************************************************************************
type RPIGPIO <: MachineGPIO
    name::String
    handle::Int
    node::String
    path::String
    digital_pin::Dict{String, Int}
    pwm_pin::Dict{String, Int}		
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
			),
			Dict(
				#left pins
				"PIN18" => 	18,
				#right pins
				"PIN19" => 	19
			)
		)
	end
end

function export_pwm_pin(gpio::RPIGPIO, pin::Int)
	flag = pin in values(gpio.pwm_pin)
	if (!flag)
		error("This is not a valid pwm pin defined for " * gpio.name)
		return
	end
	temp = string(pin)
	str = `gpio -g mode $temp pwm`
	run(str)
end

function unexport_pwm_pin(gpio::RPIGPIO, pin::Int)
	flag = pin in values(gpio.pwm_pin)
	if (!flag)
		error("This is not a valid pwm pin defined for " * gpio.name)
		return
	end
	temp = string(pin)
	str = `gpio unexport $temp`
	run(str)
end

function setduty_cycle_pwm_pin(gpio::RPIGPIO, pin::Int, duty_cycle::Int)
	flag = pin in values(gpio.pwm_pin)
	if (!flag)
		error("This is not a valid pwm pin defined for " * gpio.name)
		return
	end
	if (duty_cycle < constants["PWM_DUTY_CYCLE"]["START"] && duty_cycle > constants["PWM_DUTY_CYCLE"]["START"])
		error("Duty cycle must be between " * string(constants["PWM_DUTY_CYCLE"]["START"]) 
				* " and " * string(constants["PWM_DUTY_CYCLE"]["END"]))
		return
	end

	temp1 = string(pin)
	temp2 = string(duty_cycle)
	str = `gpio -g pwm $temp1 $temp2`
	run(str)
end

function setmode_pwm(gpio::RPIGPIO, mode::String) 
	flag = mode in(values(constants["PWM_MODE"]))
	if (!flag)
		error("PWM mode is not correct")
		return
	end
	run(`gpio $mode`)
end

function setclock_pwm(gpio::RPIGPIO, range::Int) 
	if (range < constants["PWM_CLOCK"]["START"] && range > constants["PWM_CLOCK"]["END"])
		error("PWM clock range must be between " * string(constants["PWM_CLOCK"]["START"])
				* " and " * string(constants["PWM_CLOCK"]["END"]))
		return
	end
	temp = string(range)
	run(`gpio pwmc $range`)
end

function setrange_pwm(gpio::RPIGPIO, range::Int) 
	if (range < constants["PWM_RANGE"]["START"] && range > constants["PWM_RANGE"]["END"])
		error("PWM range must be between " * string(constants["PWM_RANGE"]["START"]) 
			* " and " * string(constants["PWM_RANGE"]["END"]))
		return
	end
	temp = string(range)
	run(`gpio pwmr $range`)
end

function test_pwm(gpio::RPIGPIO)
	#Pin #18 has PWM output, but you have to set it to be the right 
	#frequency output. Servo's want 50 Hz frequency output.
	#
	#For the Raspberry Pi PWM module, the PWM Frequency in 
	#Hz = 19,200,000 Hz / pwmClock / pwmRange
	#
	#If pwmClock is 192 and pwmRange is 2000 we'll get the PWM frequency = 50 Hz 
	#

	rpi = gpio

	#Set pin 18 to be a PWM output
	export_pwm_pin(rpi, rpi.pwm_pin["PIN18"])

	#Set the PWM to mark-space
	setmode_pwm(rpi, constants["PWM_MODE"]["MARK-SPACE"])

	#set PWM clock to 192
	setclock_pwm(rpi, 192)

	#set PWM range to 2000
	setrange_pwm(rpi, 2000)

	#Now you can set the servo to all the way 
	#to the left (1.0 milliseconds) with
	setduty_cycle_pwm_pin(rpi, rpi.pwm_pin["PIN18"], 100)
	sleep(1)

	#Set the servo to the middle (1.5 ms) with
	setduty_cycle_pwm_pin(rpi, rpi.pwm_pin["PIN18"], 150)
	sleep(1)

	#And all the way to the right (2.0ms) with
	setduty_cycle_pwm_pin(rpi, rpi.pwm_pin["PIN18"], 250)
	sleep(1)

	#Servos often 'respond' to a wider range than 1.0-2.0 milliseconds 
	#so try it with ranges of 50 (0.5ms) to 250 (2.5ms)
	#
	#Of course you can try any number between 50 and 250! 
	#so you get a range of about 200 positions

	unexport_pwm_pin(rpi, rpi.pwm_pin["PIN18"])
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
#optargs=quiet bone_capemgr.enable_partno=BB-ADC,BB-PWM1
#
#sudo reboot
#
type BBBGPIO <: MachineGPIO
    name::String
    handle::Int
    node::String
    path::String
    digital_pin::Dict{String, Int}
    analog_pin::Dict{String, Int}
    pwm_pin::Dict{String, Int}
    function BBBGPIO()
		new("Beaglebone Black", 1, "julia-user@NODE-BBB", "/home/julia-user/julia-0.6.0/bin/",
			Dict(
				#P9 - left pins
				"P9_PIN11" => 	30,
				"P9_PIN13" => 	31,
				"P9_PIN15" => 	48,
				"P9_PIN17" =>	04,
				"P9_PIN21" => 	03,
				"P9_PIN23" => 	49,
				"P9_PIN25" => 	117,
				"P9_PIN27" => 	125,
				"P9_PIN29" => 	121,
				"P9_PIN31" => 	120,
				"P9_PIN41" => 	20,				
				#P9 - right pins
				"P9_PIN12" => 	60,
				"P9_PIN14" => 	0,		#PWM1A
				"P9_PIN16" => 	1,		#PWM1B
				"P9_PIN18" => 	05,
				"P9_PIN22" => 	02,
				"P9_PIN24" => 	15,
				"P9_PIN26" => 	14,
				"P9_PIN30" => 	122,
				"P9_PIN42" => 	07,

				#P8 - left pins
				"P8_PIN03" => 	38,
				"P8_PIN05" => 	34,
				"P8_PIN07" => 	66,
				"P8_PIN09" => 	69,
				"P8_PIN11" => 	45,
				"P8_PIN13" => 	23,
				"P8_PIN15" => 	47,
				"P8_PIN17" => 	27,
				"P8_PIN19" => 	22,
				"P8_PIN21" => 	62,
				"P8_PIN23" => 	36,
				"P8_PIN25" => 	32,
				"P8_PIN27" => 	86,
				"P8_PIN29" => 	87,
				"P8_PIN31" => 	10,
				"P8_PIN33" => 	09,
				"P8_PIN35" => 	08,
				"P8_PIN37" => 	78,
				"P8_PIN39" => 	76,
				"P8_PIN41" => 	74,
				"P8_PIN43" => 	72,
				"P8_PIN45" => 	70,
				
				#P8 - right pins
				"P8_PIN04" => 	39,
				"P8_PIN06" => 	35,
				"P8_PIN08" => 	67,
				"P8_PIN10" => 	68,
				"P8_PIN12" => 	44,
				"P8_PIN14" => 	26,
				"P8_PIN16" => 	46,
				"P8_PIN18" => 	65,
				"P8_PIN20" => 	63,
				"P8_PIN22" => 	37,
				"P8_PIN24" => 	33,
				"P8_PIN26" => 	61,
				"P8_PIN28" => 	88,
				"P8_PIN30" => 	89,
				"P8_PIN32" => 	11,
				"P8_PIN34" => 	81,
				"P8_PIN36" => 	80,
				"P8_PIN38" => 	79,
				"P8_PIN40" => 	77,
				"P8_PIN42" => 	75,
				"P8_PIN44" => 	73,
				"P8_PIN46" => 	71
			),
			Dict(
				#P9 - left side
				"P9_PIN33" => 	4,
				"P9_PIN35" => 	6,
				"P9_PIN37" => 	2,
				"P9_PIN39" => 	0,
				
				#P9 - right side
				"P9_PIN36" => 	5,
				"P9_PIN38" => 	3,
				"P9_PIN40" => 	1
			),
			Dict(
				#P9 - right side
				"P9_PIN14" => 	0,
				"P9_PIN16" => 	1
			)
		)
	end
end

function getvalue_analog_pin(gpio::BBBGPIO, pin::Int)
	flag = pin in values(gpio.digital_pin)
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

function export_pwm_pin(gpio::BBBGPIO, pin::Int)
	flag = pin in values(gpio.pwm_pin)
	if (!flag)
		error("This is not a valid pwm pin defined for " * gpio.name)
		return
	end

	setval_str = "/sys/class/pwm/pwmchip0/export"
	f = open(setval_str, "w")
    write(f, string(pin)) 
	close(f)
end

function unexport_pwm_pin(gpio::BBBGPIO, pin::Int)
	flag = pin in values(gpio.pwm_pin)
	if (!flag)
		error("This is not a valid pwm pin defined for " * gpio.name)
		return
	end

	setval_str = "/sys/class/pwm/pwmchip0/unexport"
	f = open(setval_str, "w")
    write(f, string(pin)) 
	close(f)
end


function setpolarity_pwm_pin(gpio::BBBGPIO, pin::Int, polarity::Int)
	flag = pin in values(gpio.pwm_pin)
	if (!flag)
		error("This is not a valid pwm pin defined for " * gpio.name)
		return
	end
	flag = pin in ("0", "1")
	if (!flag)
		error("This is not a valid pwm polarity.")
		return
	end

	setval_str = "/sys/class/pwm/pwmchip0/pwm" * string(pin) * "/polarity"
	f = open(setval_str, "w")
    write(f, polarity) 
	close(f)
end

function setperiod_pwm_pin(gpio::BBBGPIO, pin::Int, period::Int)
	flag = pin in values(gpio.pwm_pin)
	if (!flag)
		error("This is not a valid pwm pin defined for " * gpio.name)
		return
	end

	setval_str = "/sys/class/pwm/pwmchip0/pwm" * string(pin) * "/period"
	f = open(setval_str, "w")
    write(f, period) 
	close(f)
end

function setduty_cycle_pwm_pin(gpio::BBBGPIO, pin::Int, duty_cycle::Int)
	flag = pin in values(gpio.pwm_pin)
	if (!flag)
		error("This is not a valid pwm pin defined for " * gpio.name)
		return
	end

	setval_str = "/sys/class/pwm/pwmchip0/pwm" * string(pin) * "/duty_cycle"
	f = open(setval_str, "w")
    write(f, string(duty_cycle)) 
	close(f)
end

function setenable_pwm_pin(gpio::BBBGPIO, pin::Int, enable::Int)
	flag = pin in values(gpio.pwm_pin)
	if (!flag)
		error("This is not a valid pwm pin defined for " * gpio.name)
		return
	end

	setval_str = "/sys/class/pwm/pwmchip0/pwm" * string(pin) * "/enable"
	f = open(setval_str, "w")
    write(f, string(enable)) 
	close(f)
end


function checking_light_sensor(bbb::BBBGPIO, pinLED::Int, pinSensor::Int)
    an::String = "0"
    value::Int = 0
    prv::String = ""

    export_pin(bbb, pinLED)
    sleep(1)
    setdirection_pin(bbb, pinLED, constants["OUT"])

    while (true)
        an = getvalue_analog_pin(bbb, pinSensor)  
        #println("an: ", an)
        value = parse(Int, an)
        sleep(1)
        if value >= 3000
            prv = "BBB"
            for n = 1:5
                setvalue_pin(bbb, pinLED, constants["HIGH"])
                sleep(.5)
                setvalue_pin(bbb, pinLED, constants["LOW"])
                sleep(.5)
            end
            break
        end
    end
    unexport_pin(bbb, pinLED)
    sleep(1)

    return prv
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
    digital_pin::Dict{String, Int}
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

function getvalue_analog_from_serial(gpio::U86GPIO, portname::String)
    return readchomp(`./readSerialStream --portname $portname`)
end

function setvalue_analog_to_serial(gpio::U86GPIO, portname::String, cmd::String)
    return readchomp(`./writeSerialStream --portname $portname --command $cmd`)
end

function checking_mic_sensor_on_arduino(u86::U86GPIO, pinLED::Int, portname::String)
    an::String = "0"
    value::Int = 0
    prv::String = ""

    export_pin(u86, pinLED)
    sleep(1)
    setdirection_pin(u86, pinLED, constants["OUT"])

    while (true)
        an = getvalue_analog_from_serial(u86, portname)  
        #println("an: ", an)
        value = parse(Int, an)
        sleep(1)
        if value >= 525
            prv = "U86"
            for n = 1:5
                setvalue_pin(u86, pinLED, constants["HIGH"])
                sleep(.5)
                setvalue_pin(u86, pinLED, constants["LOW"])
                sleep(.5)
            end
            break
        end
    end
    unexport_pin(u86, pinLED)
    sleep(1)

    return prv
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
#Permissions to use pwm must be set up so a non-root user can use the pwm routines.
#
#sudo nano /etc/udev/rules.d/99-gpio.rules
#
#add these lines:
#
#SUBSYSTEM=="pwm*", PROGRAM="/bin/sh -c '\
#        chown -R root:gpio /sys/class/pwm && chmod -R 770 /sys/class/pwm;\
#        chown -R root:gpio /sys/devices/platform/soc/*.pwm/pwm/pwmchip* && chmod -R 770 /sys/devices/platform/soc/*.pwm/pwm/pwmchip*\
#'"
#
#
#After this we need to reboot in order for the changes to take place.
#
#sudo reboot
type NPDGPIO <: MachineGPIO
    name::String
    handle::Int
    node::String
    path::String
    digital_pin::Dict{String, Int}
    pwm_pin::Dict{String, Int}
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
			),
			Dict(
			)
		)
	end
end



function export_pin(gpio::MachineGPIO, pin::Int)
	flag = pin in values(gpio.digital_pin)
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
	flag = pin in values(gpio.digital_pin)
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
	flag = pin in values("in", "out")
	if (!flag)
		error("This is not a valid pin defined for " * gpio.name)
		return
	end
	flag = dir in ("in", "out")
	if(!flag)
		error("Direction is not a valid constant.")
		return
	end
    setdir_str = "/sys/class/gpio/gpio" * string(pin) * "/direction"
    f = open(setdir_str, "w")
    write(f, dir) 
    close(f)
end

function getvalue_pin(gpio::MachineGPIO, pin::Int)
	flag = pin in values(gpio.digital_pin)
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

function setvalue_pin(gpio::MachineGPIO, pin::Int, val::String)
	flag = pin in values(gpio.digital_pin)
	if (!flag)
		error("This is not a valid pin defined for " * gpio.name)
		return
	end
	flag = val in ("0", "1")
	if (!flag)
		error("Valid values are 0 or 1")
		return
	end
    setval_str = "/sys/class/gpio/gpio" * string(pin) * "/value"
    f = open(setval_str, "w")
    write(f, val) 
    close(f)
end



function blinkLED(gpio::MachineGPIO, pinLED::Int)

	export_pin(gpio, pinLED)
	
	sleep(1)

	setdirection_pin(gpio, pinLED, constants["OUT"])

	sleep(1)
	
	for n = 1:10
		setvalue_pin(gpio, pinLED, constants["HIGH"])
		sleep(.5)
		setvalue_pin(gpio, pinLED, constants["LOW"])
		sleep(.5)
	end

	unexport_pin(gpio, pinLED)
end

end
