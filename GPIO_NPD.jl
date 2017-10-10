module GPIO_NPD

include("GPIO_Consts.jl")
include("GPIO_Common.jl")

export export_pin, unexport_pin, setdirection_pin, 
		getvalue_pin, setvalue_pin, setMode, digitalRead, digitalWrite,
		export_pwm_pin, unexport_pwm_pin, setduty_cycle_pwm_pin,
		setmode_pwm, setclock_pwm, setrange_pwm, test_pwm

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
	id::String
    name::String
    handle::Int
    node::String
    path::String
    digital_pin::Dict{String, Int}
    pwm_pin::Dict{String, Int}
    i2c_pin::Dict{String, Int}
    function NPDGPIO()
			new("", "", 0, "", "", Dict(), Dict(), Dict())
	end
end


@everywhere function test_pwm(id::String, pin::Int)
	#Pin RX on the Debug UART has PWM output, but you have to set it to be the right 
	#frequency output. Servo's want 50 Hz frequency output.
	#
	#For the Nano Pi PWM module, the PWM Frequency in 
	#Hz = 24,000,000 Hz / pwmClock / pwmRange
	#
	#If pwmClock is 240 and pwmRange is 2000 we'll get the PWM frequency = 50 Hz 
	#


	#Set pin 5 (Debug RX) to be a PWM output
	GPIO_Common.export_pwm_pin(id, pin)

	#Set the PWM to mark-space
	GPIO_Common.setmode_pwm(id, GPIO_Common.constants["PWM_MODE"]["MARK-SPACE"])

	#set PWM clock to 240
	GPIO_Common.setclock_pwm(id, 240)

	#set PWM range to 2000
	GPIO_Common.setrange_pwm(id, 2000)

	#Now you can set the servo to all the way 
	#to the left (1.0 milliseconds) with
	GPIO_Common.setduty_cycle_pwm_pin(id, pin, 100)
	sleep(1)

	#Set the servo to the middle (1.5 ms) with
	GPIO_Common.setduty_cycle_pwm_pin(id, pin, 150)
	sleep(1)

	#And all the way to the right (2.0ms) with
	GPIO_Common.setduty_cycle_pwm_pin(id, pin, 250)
	sleep(1)

	#Servos often 'respond' to a wider range than 1.0-2.0 milliseconds 
	#so try it with ranges of 50 (0.5ms) to 250 (2.5ms)
	#
	#Of course you can try any number between 50 and 250! 
	#so you get a range of about 200 positions

	GPIO_Common.unexport_pwm_pin(id, pin)
end

end
