module GPIO_Device

export test_pwm

include("GPIO_Consts.jl")
include("GPIO_Common.jl")


type DeviceGPIO <: MachineGPIO
	id::String
    name::String
    handle::Int
    node::String
    path::String
    digital_pin::Dict{String, Int}
    analog_pin::Dict{String, Int}		
    pwm_pin::Dict{String, Int}		
    i2c_devices::Vector{String}
    spi_devices::Vector{String}
    function DeviceGPIO()
		new("", "", 0, "", "", Dict(), Dict(), Dict(),[],[])
    end
end

end
