module GPIO_U86

export checking_mic_sensor_on_arduino

include("Machine_Consts.jl")
include("GPIO_Common.jl")


#*************************************************************************************************
#
#UDOO x86
#
#*************************************************************************************************
#Warning! Warning: UDOO X86 Pins controlled by the main Braswell processor 
#are 1.8V only compliant. Providing higher voltages, like 3.3V or 5V, 
#could irreversibly damage the board. In order to properly work with an 
#input voltage different from 1.8V use a bidirectional level shifter. 

type U86GPIO <: MachineGPIO
    name::String
    handle::Int
    node::String
    path::String
    digital_pin::Dict{String, Int}
    function U86GPIO()
		new("", 0, "", "", Dict())
	end
end

function getvalue_analog_from_serial(portname::String)
    return readchomp(`./readSerialStream --portname $portname`)
end

function setvalue_analog_to_serial(portname::String, cmd::String)
    return readchomp(`./writeSerialStream --portname $portname --command $cmd`)
end

function checking_mic_sensor_on_arduino(pinLED::Int, portname::String)
    an::String = "0"
    value::Int = 0
    prv::String = ""

    export_pin(pinLED)
    sleep(1)
    setdirection_pin(pinLED, GPIO_Common.constants["OUT"])

    while (true)
        an = getvalue_analog_from_serial(portname)  
        #println("an: ", an)
        value = parse(Int, an)
        sleep(1)
        if value >= 525
            prv = "U86"
            for n = 1:5
                setvalue_pin(pinLED, GPIO_Common.constants["HIGH"])
                sleep(.5)
                setvalue_pin(pinLED, GPIO_Common.constants["LOW"])
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
