

@everywhere function export_pin(pin::String)
    export_str = "/sys/class/gpio/export"
    f = open(export_str,"w")
    write(f, pin)
    close(f)
end

@everywhere function unexport_pin(pin::String)
    unexport_str = "/sys/class/gpio/unexport"
    f = open(unexport_str, "w")
    write(f, pin)
    close(f)
end

@everywhere function setdirection_pin(pin::String, dir::String)
    setdir_str = "/sys/class/gpio/gpio" * pin * "/direction"
    f = open(setdir_str, "w")
    write(f, dir) 
    close(f)
end

@everywhere function getvalue_pin(pin::String)
    setval_str = "/sys/class/gpio/gpio" * pin * "/value"
    f = open(setval_str, "r")
    val::String = readline(f) 
    close(f)
    return val
end

@everywhere function setvalue_pin(pin::String, val::String)
    setval_str = "/sys/class/gpio/gpio" * pin * "/value"
    f = open(setval_str, "w")
    write(f, val) 
    close(f)
end


@everywhere function pinMode(pin::String, mode::String)
	export_pin(pin)
	setdirection_pin(mode)
end

@everywhere function digitalWrite(pin::String, value::String)
	setvalue_pin(pin, value)
end

@everywhere function digitalRead(pin::String)
	return getvalue_pin(pin)
end
