@everywhere module GPIO_Common

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

export export_pin, unexport_pin, setdirection_pin, 
		getvalue_pin, setvalue_pin, setMode, digitalRead, digitalWrite,
		export_pwm_pin, unexport_pwm_pin, setduty_cycle_pwm_pin,
		setmode_pwm, setclock_pwm, setrange_pwm, 
		blinkLED

function export_pin(pin::Int)
    export_str = "/sys/class/gpio/export"
    f = open(export_str,"w")
    write(f, string(pin))
    close(f)
end

function unexport_pin(pin::Int)
    unexport_str = "/sys/class/gpio/unexport"
    f = open(unexport_str, "w")
    write(f, string(pin))
    close(f)
end

function setdirection_pin(pin::Int, dir::String)
    setdir_str = "/sys/class/gpio/gpio" * string(pin) * "/direction"
    f = open(setdir_str, "w")
    write(f, dir) 
    close(f)
end

function getvalue_pin(pin::Int)
    setval_str = "/sys/class/gpio/gpio" * string(pin) * "/value"
    f = open(setval_str, "r")
    val::String = readline(f) 
    close(f)
    return val
end

function setvalue_pin(pin::Int, val::String)
    setval_str = "/sys/class/gpio/gpio" * string(pin) * "/value"
    f = open(setval_str, "w")
    write(f, val) 
    close(f)
end

function i2c_read(addr::Int, numBytes::Int)
    i2c_str = "/dev/i2c-0"
    
    f = open(i2c_str, "rw")
    if (f < 0)
		error("Failed to open i2c bus")
		return
    end
    
    buf = read(f, numBytes) 
    if (len(buf) != numBytes)
		error("Failed to read from the i2c bus")
		return
	end
    close(f)
    
    return buf
end

function i2c_write(addr::Int, buf)
    i2c_str = "/dev/i2c-0"
    
    f = open(i2c_str, "rw")
    if (f < 0)
		error("Failed to open i2c bus")
		return
    end
    
    write(f, buf, len(buf)) 

    close(f)
    
    return buf
end

function export_pwm_pin(id::String, pin::Int)
	if (id == "bbb")
		setval_str = "/sys/class/pwm/pwmchip0/export"
		f = open(setval_str, "w")
		write(f, string(pin)) 
		close(f)
	end
	if (id == "rpi3" || id == "npd")
		temp = string(pin)
		str = `gpio -g mode $temp pwm`
		run(str)
	end
end

function unexport_pwm_pin(id::String, pin::Int)
	if (id == "bbb")
		setval_str = "/sys/class/pwm/pwmchip0/unexport"
		f = open(setval_str, "w")
		write(f, string(pin)) 
		close(f)
	end
	if (id == "rpi3" || id == "npd")
		temp = string(pin)
		str = `gpio unexport $temp`
		run(str)
	end
end


function setpolarity_pwm_pin(id::String, pin::Int, polarity::Int)
	if (id == "bbb")
		setval_str = "/sys/class/pwm/pwmchip0/pwm" * string(pin) * "/polarity"
		f = open(setval_str, "w")
		write(f, polarity) 
		close(f)
	end
	if (id == "rpi3" || id == "npd")
	
	end
end

function setperiod_pwm_pin(id::String, pin::Int, period::Int)
	if (id == "bbb")
		setval_str = "/sys/class/pwm/pwmchip0/pwm" * string(pin) * "/period"
		f = open(setval_str, "w")
		write(f, period) 
		close(f)
	end
	if (id == "rpi3" || id == "npd")
	
	end
end

function setduty_cycle_pwm_pin(id::String, pin::Int, duty_cycle::Int)
	if (id == "bbb")
		setval_str = "/sys/class/pwm/pwmchip0/pwm" * string(pin) * "/duty_cycle"
		f = open(setval_str, "w")
		write(f, string(duty_cycle)) 
		close(f)
	end
	if (id == "rpi3" || id == "npd")
		temp1 = string(pin)
		temp2 = string(duty_cycle)
		str = `gpio -g pwm $temp1 $temp2`
		run(str)
	end
end

function setenable_pwm_pin(id::String, pin::Int, enable::Int)
	setval_str = "/sys/class/pwm/pwmchip0/pwm" * string(pin) * "/enable"
	f = open(setval_str, "w")
    write(f, string(enable)) 
	close(f)
	if (id == "rpi3" || id == "npd")
	
	end
end

function setmode_pwm(id::String, mode::String) 
	if (id == "rpi3" || id == "npd")
		run(`gpio $mode`)
	end
end

function setclock_pwm(id::String, range::Int) 
	if (id == "rpi3" || id == "npd")
		temp = string(range)
		run(`gpio pwmc $range`)
	end
end

function setrange_pwm(id::String, range::Int) 
	if (id == "rpi3" || id == "npd")
		temp = string(range)
		run(`gpio pwmr $range`)
	end
end

function blinkLED(pinLED::Int)

	export_pin(pinLED)
	
	sleep(1)

	setdirection_pin(pinLED, constants["OUT"])

	sleep(1)
	
	for n = 1:10
		setvalue_pin(pinLED, constants["HIGH"])
		sleep(.5)
		setvalue_pin(pinLED, constants["LOW"])
		sleep(.5)
	end

	unexport_pin(pinLED)
end	


end
