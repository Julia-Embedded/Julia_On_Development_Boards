@everywhere module GPIO_RPI

macro gpio(gpio_str, gpio_nbr)
	quote
		const $(esc(gpio_str)) = string($((esc(gpio_nbr))))
    end
end

include("GPIO_Common.jl")

export gpio, export_pin, unexport_pin, setdirection_pin, 
getvalue_pin, setvalue_pin, setMode, digitalRead, digitalWrite, 
checking_motion_sensor

const	IN		= 	"in"
const	OUT		=	"out"
const	HIGH	=	"1"
const	LOW		=	"0"

#left pins
@gpio 	PIN03 	2
@gpio 	PIN05 	3
@gpio 	PIN07 	4
@gpio 	PIN11 	17
@gpio 	PIN13 	27
@gpio 	PIN15 	22
@gpio 	PIN19 	10
@gpio 	PIN21 	9
@gpio 	PIN23 	11

#left pins RPi 2 =>
@gpio 	PIN29 	5
@gpio 	PIN31 	6
@gpio 	PIN33 	13
@gpio 	PIN35 	19
@gpio 	PIN37 	26

#right pins
@gpio 	PIN08 	14
@gpio 	PIN10 	15
@gpio 	PIN12 	18
@gpio 	PIN16 	23
@gpio 	PIN18 	24
@gpio 	PIN22 	25
@gpio 	PIN24 	8
@gpio 	PIN26 	7

#right pins RPi 2 =>
@gpio 	PIN32 	12
@gpio 	PIN36 	16
@gpio 	PIN38 	20
@gpio 	PIN40 	21


function checking_motion_sensor(pinLED::String, pinSensor::String)
    ret::String = "0"
    prv::String = ""

    export_pin(pinLED)
    sleep(1)
    setdirection_pin(pinLED, "out")

    export_pin(pinSensor)
    sleep(1)
    setdirection_pin(pinSensor, "in")

    while (true)
        ret = getvalue_pin(pinSensor)  
        sleep(1)
        if ret == "1"
            prv = "rpi"
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
    unexport_pin(pinSensor)
    sleep(1)

    return prv
end

end
