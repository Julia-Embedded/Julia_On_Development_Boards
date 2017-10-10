module GPIO_BBB

export export_pwm_pin, unexport_pwm_pin, setpolarity_pwm_pin,
		setperiod_pwm_pin, setduty_cycle_pwm_pin, setenable_pwm_pin,
		checking_light_sensor

include("Machine_Consts.jl")
include("GPIO_Common.jl")

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
		new("", 0, "", "", Dict(), Dict(), Dict())
		
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

function export_pwm_pin(pin::Int)
	setval_str = "/sys/class/pwm/pwmchip0/export"
	f = open(setval_str, "w")
    write(f, string(pin)) 
	close(f)
end

function unexport_pwm_pin(pin::Int)
	setval_str = "/sys/class/pwm/pwmchip0/unexport"
	f = open(setval_str, "w")
    write(f, string(pin)) 
	close(f)
end


function setpolarity_pwm_pin(pin::Int, polarity::Int)
	setval_str = "/sys/class/pwm/pwmchip0/pwm" * string(pin) * "/polarity"
	f = open(setval_str, "w")
    write(f, polarity) 
	close(f)
end

function setperiod_pwm_pin(pin::Int, period::Int)
	setval_str = "/sys/class/pwm/pwmchip0/pwm" * string(pin) * "/period"
	f = open(setval_str, "w")
    write(f, period) 
	close(f)
end

function setduty_cycle_pwm_pin(pin::Int, duty_cycle::Int)
	setval_str = "/sys/class/pwm/pwmchip0/pwm" * string(pin) * "/duty_cycle"
	f = open(setval_str, "w")
    write(f, string(duty_cycle)) 
	close(f)
end

function setenable_pwm_pin(pin::Int, enable::Int)
	setval_str = "/sys/class/pwm/pwmchip0/pwm" * string(pin) * "/enable"
	f = open(setval_str, "w")
    write(f, string(enable)) 
	close(f)
end


function checking_light_sensor(pinLED::Int, pinSensor::Int)
    an::String = "0"
    value::Int = 0
    prv::String = ""

    export_pin(pinLED)
    sleep(1)
    setdirection_pin(pinLED, constants["OUT"])

    while (true)
        an = getvalue_analog_pin(pinSensor)  
        #println("an: ", an)
        value = parse(Int, an)
        sleep(1)
        if value >= 3000
            prv = "BBB"
            for n = 1:5
                setvalue_pin(pinLED, constants["HIGH"])
                sleep(.5)
                setvalue_pin(pinLED, constants["LOW"])
                sleep(.5)
            end
            break
        end
    end
    unexport_pin(pinLED)
    sleep(1)

    return prv
end


end
