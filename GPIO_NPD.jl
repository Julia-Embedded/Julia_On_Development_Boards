module GPIO_NPD

include("Machine_Consts.jl")
include("GPIO_Common.jl")

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
    i2c_pin::Dict{String, Int}
    function NPDGPIO()
			new("", 0, "", "", Dict(), Dict(), Dict())
	end
end

function export_pwm_pin(pin::Int)
	temp = string(pin)
	str = `gpio -g mode $temp pwm`
	run(str)
end

function unexport_pwm_pin(pin::Int)
	temp = string(pin)
	str = `gpio unexport $temp`
	run(str)
end

function setduty_cycle_pwm_pin(pin::Int, duty_cycle::Int)
	temp1 = string(pin)
	temp2 = string(duty_cycle)
	str = `gpio -g pwm $temp1 $temp2`
	run(str)
end

function setmode_pwm(mode::String) 
	run(`gpio $mode`)
end

function setclock_pwm(range::Int) 
	temp = string(range)
	run(`gpio pwmc $range`)
end

function setrange_pwm(range::Int) 
	temp = string(range)
	run(`gpio pwmr $range`)
end

function test_pwm(gpio::MachineGPIO)
	#Pin RX on the Debug UART has PWM output, but you have to set it to be the right 
	#frequency output. Servo's want 50 Hz frequency output.
	#
	#For the Nano Pi PWM module, the PWM Frequency in 
	#Hz = 24,000,000 Hz / pwmClock / pwmRange
	#
	#If pwmClock is 240 and pwmRange is 2000 we'll get the PWM frequency = 50 Hz 
	#

	npd = gpio

	#Set pin 5 (Debug RX) to be a PWM output
	export_pwm_pin(npd.pwm_pin["DBG_RX"])

	#Set the PWM to mark-space
	setmode_pwm(GPIO_Common.constants["PWM_MODE"]["MARK-SPACE"])

	#set PWM clock to 240
	setclock_pwm(240)

	#set PWM range to 2000
	setrange_pwm(2000)

	#Now you can set the servo to all the way 
	#to the left (1.0 milliseconds) with
	setduty_cycle_pwm_pin(npd.pwm_pin["DBG_RX"], 100)
	sleep(1)

	#Set the servo to the middle (1.5 ms) with
	setduty_cycle_pwm_pin(npd.pwm_pin["DBG_RX"], 150)
	sleep(1)

	#And all the way to the right (2.0ms) with
	setduty_cycle_pwm_pin(npd.pwm_pin["DBG_RX"], 250)
	sleep(1)

	#Servos often 'respond' to a wider range than 1.0-2.0 milliseconds 
	#so try it with ranges of 50 (0.5ms) to 250 (2.5ms)
	#
	#Of course you can try any number between 50 and 250! 
	#so you get a range of about 200 positions

	unexport_pwm_pin(npd.pwm_pin["DBG_RX"])
end


end
