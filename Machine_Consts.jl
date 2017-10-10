import LightXML

export initialize, is_digital_pin_configured, is_analog_pin_configured,
		is_pwm_pin_configured, is_i2c_pin_configured

abstract type AbstractGPIO end

abstract type MachineGPIO <: AbstractGPIO end


			
function initialize(gpio::MachineGPIO, filename::String)
	#using LightXML
	xdoc = LightXML.parse_file(filename)

	# get the root element
	xroot = LightXML.root(xdoc)  # an instance of XMLElement
	# print its name
	#println(LightXML.name(xroot))  # this should print: machine_information

	machine = LightXML.get_elements_by_tagname(xroot, "machine")
	mname = LightXML.attribute(machine[1], "name")
	gpio.name = mname
	
	node = LightXML.attribute(machine[1], "node")
	gpio.node = node
	
	bindir = LightXML.attribute(machine[1], "julia-bin")
	gpio.path = bindir
	
	for n in machine
		for o in LightXML.child_elements(n)
			if (LightXML.has_attribute(o, "category") && LightXML.attribute(o, "category") == "digital")
				for p in collect(LightXML.child_elements(o))
					gpio.digital_pin[LightXML.name(p)] = parse(Int32, LightXML.content(p))
				 end
			end
			if (LightXML.has_attribute(o, "category") && LightXML.attribute(o, "category") == "analog")
				for p in collect(LightXML.child_elements(o))
					gpio.analog_pin[LightXML.name(p)] = parse(Int32, LightXML.content(p))
				 end
			end			
			if (LightXML.has_attribute(o, "category") && LightXML.attribute(o, "category") == "pwm")
				for p in collect(LightXML.child_elements(o))
					gpio.pwm_pin[LightXML.name(p)] = parse(Int32, LightXML.content(p))
				 end
			end
			if (LightXML.has_attribute(o, "category") && LightXML.attribute(o, "category") == "i2c")
				for p in collect(LightXML.child_elements(o))
					gpio.i2c_pin[LightXML.name(p)] = parse(Int32, LightXML.content(p))
				 end
			end			
		end
	end
	

end
		



