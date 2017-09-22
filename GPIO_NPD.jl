#Notes about GPIO setup for NanoPi duo.
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
@everywhere module GPIO_NPD

macro gpio(gpio_str, gpio_nbr)
	quote
		const $(esc(gpio_str)) = string($((esc(gpio_nbr))))
    end
end

include("GPIO_Common.jl")

export getvalue_analog_pin, gpio, export_pin, unexport_pin, setdirection_pin, 
getvalue_pin, setvalue_pin, setMode, digitalRead, digitalWrite, checking_mic_sensor_on_arduino

const	IN		= 	"in"
const	OUT		=	"out"
const	HIGH	=	"1"
const	LOW		=	"0"

#left side
@gpio	PIN03	12
@gpio	PIN05	11
@gpio	PIN11	15
@gpio	PIN13	16
@gpio	PIN15	14

#right side
@gpio	PIN16	13


end
