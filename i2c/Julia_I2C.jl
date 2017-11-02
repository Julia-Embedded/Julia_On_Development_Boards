#******************************************************************************************
#This is a wrapper library for the i2c-dev.h functions. In the C programming world, you
#just include this into your program and you have access to the i2c functions. (They're
#all static inline and completely defined in the i2c-dev.h file. This is unlike most
#.h files that just have function prototypes.)
#
#I had to first created a new C file from the i2c-dev.h file (it's found in
#./usr/include/linux/i2c-dev.h). I called mine i2c-dev_rev.c, but you can call it anything
#that you want. I then stripped out all of the "static inline" that prefix each function.
#This should all be done on your particular development board. 
#
#I compile it using:
#
#gcc -c -Wall -fPIC i2c-dev_rev.c
#
#and then I make it a shared library that Julia can use.
#
#gcc -shared -o libi2c-dev.so i2c-dev_rev.o
#
#This gives you libi2c-dev.so - your shared library. I have left it in my julia/bin 
#directory until I can figure out a better way to deploy it. This module will also live
#in your julia/bin directory. With this module included in a Julia program, 
#you should now have access to doing i2c communications from Julia.
#
#Note: These routines all have function parameters that match the C functions and return
#what the C functions return. So, you have to be very careful with the types you pass.
#They are usually UInt8, UInt16, or Int32 for single values. The buffer is usually 
#defined as: buffer = Vector{UInt8}(34). This matches the largest variable type used
#in the C code (which is part of a union) - __u8 block[I2C_SMBUS_BLOCK_MAX + 2]; 
#(size is 34 bytes).
#
#I have included an i2c_init() function that you can pass your device (i.e. /dev/i2c-0),
#your device address, and the slave address. This will open your device and return you
#a file descriptor that is needed for all the function calls in this module.
#******************************************************************************************
module Julia_I2C

export i2c_init, i2c_smbus_write_quick, 
		i2c_smbus_read_byte, i2c_smbus_write_byte,
		i2c_smbus_read_byte_data, i2c_smbus_write_byte_data, 
		i2c_smbus_read_word_data, i2c_smbus_write_word_data,
		i2c_smbus_process_call,
		i2c_smbus_read_block_data, i2c_smbus_write_block_data,
		i2c_smbus_read_i2c_block_data, i2c_smbus_write_i2c_block_data,
		i2c_smbus_block_process_call

const I2CLIBRARY 				= "/home/julia-user/julia-0.6.0/bin/libi2c-dev.so"
const I2C_SMBUS_I2C_BLOCK_MAX	= 32

#macro I2CLIBRARY
#	return :("/home/julia-user/julia-0.6.0/bin/libi2c-dev.so")
#end

function i2c_init(filename::String, addr::UInt8, slave_addr::UInt16)
	file = open(filename,"r+")
	fileDes = Base.Libc.fd(file)
	if (fileDes < 0)
		error("Failed to open the bus.")
		# ERROR HANDLING; you can check errno to see what went wrong 
		return
	end
	ret = ccall((:ioctl, "libc"), Int, (Cint, Cint, Cint...), fileDes, slave_addr, addr) 
    if (ret < 0)
		error("Failed to acquire bus access and/or talk to slave.")
            # ERROR HANDLING; you can check errno to see what went wrong 
	end
    return fileDes
end



function i2c_smbus_write_quick(file::Int32, value::UInt8)
	return ccall((:i2c_smbus_write_quick, I2CLIBRARY), Int32, (Int32, UInt8), file, value)
end

function i2c_smbus_read_byte(file::Int32)
	return ccall((:i2c_smbus_read_byte, I2CLIBRARY), Int32, (Int32, ), file)
end

function i2c_smbus_write_byte(file::Int32, value::UInt8)
	return ccall((:i2c_smbus_write_byte, I2CLIBRARY), Int32, (Int32, UInt8), file, value)
end

function i2c_smbus_read_byte_data(file::Int32, command::UInt8)
	return ccall((:i2c_smbus_read_byte_data, I2CLIBRARY), Int32, (Int32, UInt8), file, command)
end

function i2c_smbus_write_byte_data(file::Int32, command::UInt8, value::UInt8)
	return ccall((:i2c_smbus_write_byte_data, I2CLIBRARY), Int32, (Int32, UInt8, UInt8), file, command, value)
end

function i2c_smbus_read_word_data(file::Int32, command::UInt8)
	return ccall((:i2c_smbus_read_word_data, I2CLIBRARY), Int32, (Int32, UInt8), file, command)
end

function i2c_smbus_write_word_data(file::Int32, command::UInt8, value::UInt16)
	return ccall((:i2c_smbus_write_word_data, I2CLIBRARY), Int32, (Int32, UInt8, UInt16), file, command, value)
end

function i2c_smbus_process_call(file::Int32, command::UInt8, value::UInt16)
	return ccall((:i2c_smbus_process_call, I2CLIBRARY), Int32, (Int32, UInt8, UInt16), file, command, value)
end

function i2c_smbus_read_block_data(file::Int32, command::UInt8, values::Vector{UInt8})
	return ccall((:i2c_smbus_read_block_data, I2CLIBRARY), Int32, (Int32, UInt8, Ptr{Void}), file, command, values)
end

function i2c_smbus_write_block_data(file::Int32, command::UInt8, length::UInt8, values::Vector{UInt8})
	return ccall((:i2c_smbus_write_block_data, I2CLIBRARY), Int32, (Int32, UInt8, UInt8, Ptr{Void}), file, command, length, values)
end

function i2c_smbus_read_i2c_block_data(file::Int32, command::UInt8, length::UInt8, values::Vector{UInt8})
	return ccall((:i2c_smbus_read_i2c_block_data, I2CLIBRARY), Int32, (Int32, UInt8, UInt8, Ptr{Void}), file, command, length, values)
end

function i2c_smbus_write_i2c_block_data(file::Int32, command::UInt8, length::UInt8, values::Vector{UInt8})
	return ccall((:i2c_smbus_write_i2c_block_data, I2CLIBRARY), Int32, (Int32, UInt8, UInt8, Ptr{Void}), file, command, length, values)
end

function i2c_smbus_block_process_call(file::Int32, command::UInt8, length::UInt8, values::Vector{UInt8})
	return ccall((:i2c_smbus_block_process_call, I2CLIBRARY), Int32, (Int32, UInt8, UInt8, Ptr{Void}), file, command, length, values)
end

end
