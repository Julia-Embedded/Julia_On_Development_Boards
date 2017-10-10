module GPIO_RPI

export export_pwm_pin, unexport_pwm_pin, setduty_cycle_pwm_pin,
		setmode_pwm, setclock_pwm, setrange_pwm, test_pwm

include("Machine_Consts.jl")
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
    name::String
    handle::Int
    node::String
    path::String
    digital_pin::Dict{String, Int}
    pwm_pin::Dict{String, Int}		
    function RPIGPIO()
		new("", 0, "", "", Dict(), Dict())
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
	export_pwm_pin(rpi.pwm_pin["PIN18"])

	#Set the PWM to mark-space
	setmode_pwm(constants["PWM_MODE"]["MARK-SPACE"])

	#set PWM clock to 192
	setclock_pwm(192)

	#set PWM range to 2000
	setrange_pwm(2000)

	#Now you can set the servo to all the way 
	#to the left (1.0 milliseconds) with
	setduty_cycle_pwm_pin(rpi.pwm_pin["PIN18"], 100)
	sleep(1)

	#Set the servo to the middle (1.5 ms) with
	setduty_cycle_pwm_pin(rpi.pwm_pin["PIN18"], 150)
	sleep(1)

	#And all the way to the right (2.0ms) with
	setduty_cycle_pwm_pin(rpi.pwm_pin["PIN18"], 250)
	sleep(1)

	#Servos often 'respond' to a wider range than 1.0-2.0 milliseconds 
	#so try it with ranges of 50 (0.5ms) to 250 (2.5ms)
	#
	#Of course you can try any number between 50 and 250! 
	#so you get a range of about 200 positions

	unexport_pwm_pin(rpi.pwm_pin["PIN18"])
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
