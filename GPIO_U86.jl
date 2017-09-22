#Warning! Warning: UDOO X86 Pins controlled by the main Braswell processor 
#are 1.8V only compliant. Providing higher voltages, like 3.3V or 5V, 
#could irreversibly damage the board. In order to properly work with an 
#input voltage different from 1.8V use a bidirectional level shifter. 

@everywhere module GPIO_U86

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

#Braswell - left pins (outside)

@gpio 	CN12_PIN46 	330
@gpio 	CN12_PIN45 	333
@gpio 	CN12_PIN44 	336
@gpio 	CN12_PIN43 	329
@gpio 	CN12_PIN42 	332
@gpio 	CN12_PIN41 	326
@gpio 	CN12_PIN40 	408
@gpio 	CN14_PIN37 	497
@gpio 	CN14_PIN36 	499

#Braswell - right pins (outside)
@gpio 	CN13_PIN30 	466
@gpio 	CN13_PIN29 	350
@gpio 	CN13_PIN28 	347
@gpio 	CN13_PIN27 	349
@gpio 	CN13_PIN26 	344
@gpio 	CN13_PIN25 	451
@gpio 	CN13_PIN24 	346




end
