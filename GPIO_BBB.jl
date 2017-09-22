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



@everywhere module GPIO_BBB

macro gpio(gpio_str, gpio_nbr)
	quote
		const $(esc(gpio_str)) = string($((esc(gpio_nbr))))
    end
end

include("GPIO_Common.jl")

export getvalue_analog_pin, gpio, export_pin, unexport_pin, setdirection_pin, 
getvalue_pin, setvalue_pin, setMode, digitalRead, digitalWrite, checking_motion_sensor

const	IN		= 	"in"
const	OUT		=	"out"
const	HIGH	=	"1"
const	LOW		=	"0"

#P9 - left pins
@gpio 	P9_PIN11 	30
@gpio 	P9_PIN13 	31
@gpio 	P9_PIN15 	48
@gpio 	P9_PIN17 	04
@gpio 	P9_PIN21 	03
@gpio 	P9_PIN23 	49
@gpio 	P9_PIN25 	117
@gpio 	P9_PIN27 	125
@gpio 	P9_PIN33 	4
@gpio 	P9_PIN35 	6
@gpio 	P9_PIN37 	2
@gpio 	P9_PIN39 	0

#P9 - right pins
@gpio 	P9_PIN12 	60
@gpio 	P9_PIN14 	40
@gpio 	P9_PIN16 	51
@gpio 	P9_PIN18 	05
@gpio 	P9_PIN22 	02
@gpio 	P9_PIN24 	15
@gpio 	P9_PIN26 	14
@gpio 	P9_PIN30 	122
@gpio 	P9_PIN36 	5
@gpio 	P9_PIN38 	3
@gpio 	P9_PIN40 	1
@gpio 	P9_PIN42 	07

#P8 - left pins
@gpio 	P8_PIN07 	66
@gpio 	P8_PIN09 	69
@gpio 	P8_PIN11 	45
@gpio 	P8_PIN13 	23
@gpio 	P8_PIN15 	47
@gpio 	P8_PIN17 	27
@gpio 	P8_PIN19 	22

#P8 - right pins
@gpio 	P8_PIN08 	67
@gpio 	P8_PIN10 	68
@gpio 	P8_PIN12 	44
@gpio 	P8_PIN14 	26
@gpio 	P8_PIN16 	46
@gpio 	P8_PIN18 	65
@gpio 	P8_PIN26 	61

function getvalue_analog_pin(pin::String)
	if (searchindex("01234567", pin) != 0) #BBB valid analog pins are 0-7.
		getval_str = "/sys/bus/iio/devices/iio:device0/in_voltage" * pin * "_raw"
		f = open(getval_str, "r")
		val::String = readline(f) 
		close(f)
		return val
	else
		error("Not a valid analog pin number.")
	end
end


function checking_light_sensor(pinLED::String, pinSensor::String)
    an::String = "0"
    value::Int = 0
    prv::String = ""

    export_pin(pinLED)
    sleep(1)
    setdirection_pin(pinLED, "out")

    while (true)
        an = getvalue_analog_pin(pinSensor)  
        #println("an: ", an)
        value = parse(Int, an)
        sleep(1)
        if value >= 3000
            prv = "BBB"
            for n = 1:5
                setvalue_pin(pinLED, "1")
                sleep(.5)
                setvalue_pin(pinLED, "0")
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
