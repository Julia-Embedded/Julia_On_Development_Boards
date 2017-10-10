module GPIO_RPI

export test_pwm

include("GPIO_Consts.jl")
include("GPIO_Common.jl")



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
	id::String
    name::String
    handle::Int
    node::String
    path::String
    digital_pin::Dict{String, Int}
    pwm_pin::Dict{String, Int}		
    function RPIGPIO()
		new("", "", 0, "", "", Dict(), Dict())
    end
end


@everywhere function test_pwm(id::String, pin::Int)
	#Pin #18 has PWM output, but you have to set it to be the right 
	#frequency output. Servo's want 50 Hz frequency output.
	#
	#For the Raspberry Pi PWM module, the PWM Frequency in 
	#Hz = 19,200,000 Hz / pwmClock / pwmRange
	#
	#If pwmClock is 192 and pwmRange is 2000 we'll get the PWM frequency = 50 Hz 
	#

	#Set pin 18 to be a PWM output
	GPIO_Common.export_pwm_pin(id, pin)

	#Set the PWM to mark-space
	GPIO_Common.setmode_pwm(id, GPIO_Common.constants["PWM_MODE"]["MARK-SPACE"])

	#set PWM clock to 192
	GPIO_Common.setclock_pwm(id, 192)

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



end
