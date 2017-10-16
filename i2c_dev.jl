@everywhere module i2c_dev


export i2c_init, 
		i2c_smbus_access, i2c_smbus_write_quick,
		i2c_smbus_read_byte, i2c_smbus_write_byte,
		i2c_smbus_read_byte_data, i2c_smbus_write_byte_data,
		i2c_smbus_read_word_data, i2c_smbus_write_word_data,
		i2c_smbus_process_call,
		i2c_smbus_read_block_data, i2c_smbus_write_block_data,
		i2c_smbus_read_i2c_block_data, i2c_smbus_write_i2c_block_data,
		i2c_smbus_block_process_call
		


#*****************************************************************************
# This is basically a Julia re-write of the i2c-dev.h file used to do i2c
# communication development in C/C++. The i2c-dev.h is found on most Linux 
# systems at /usr/include/linux/i2c-dev.h. The following is from the
# original header file. Almost all of the const comments are the original
# comments from the original i2c-dev.h file. i2c-dev uses the ioctl function
# to do all of the work. ioctl is found in th libc library of Linux. Here's
# a link: 
#   https://www.gnu.org/software/libc/manual/html_node/Function-Index.html
#
# libc offers a tremendous amount of system fuctionality.
#*****************************************************************************
#
#    i2c-dev.h - i2c-bus driver, char device interface
#
#    Copyright (C) 1995-97 Simon G. Vogl
#    Copyright (C) 1998-99 Frodo Looijaard <frodol@dds.nl>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#    MA 02110-1301 USA.
#
#*****************************************************************************
##ifndef _LINUX_I2C_DEV_H
##define _LINUX_I2C_DEV_H

##include <linux/types.h>
##include <sys/ioctl.h>
##include <stddef.h>


# -- i2c.h -- 


#*****************************************************************************
# I2C Message - used for pure i2c transaction, also from /dev interface
#*****************************************************************************
const 	I2C_M_TEN			=	0x10	# we have a ten bit chip address	
const	I2C_M_RD			=	0x01
const	I2C_M_NOSTART		=	0x4000
const	I2C_M_REV_DIR_ADDR	=	0x2000
const	I2C_M_IGNORE_NAK	=	0x1000
const	I2C_M_NO_RD_ACK		=	0x0800

struct i2c_msg 
	addr::UInt16	# slave address			
	flags::UInt16
	len::Int16		# msg length
	buf::Cstring	# pointer to msg data
end

#*****************************************************************************
# To determine what functionality is present 
#*****************************************************************************
const	I2C_FUNC_I2C					=	0x00000001
const 	I2C_FUNC_10BIT_ADDR				=	0x00000002
const 	I2C_FUNC_PROTOCOL_MANGLING		=	0x00000004 # I2C_M_{REV_DIR_ADDR,NOSTART,..} 
const 	I2C_FUNC_SMBUS_PEC				=	0x00000008
const 	I2C_FUNC_SMBUS_BLOCK_PROC_CALL	=	0x00008000 # SMBus 2.0 
const 	I2C_FUNC_SMBUS_QUICK			=	0x00010000
const 	I2C_FUNC_SMBUS_READ_BYTE		=	0x00020000
const 	I2C_FUNC_SMBUS_WRITE_BYTE		=	0x00040000
const 	I2C_FUNC_SMBUS_READ_BYTE_DATA	=	0x00080000
const 	I2C_FUNC_SMBUS_WRITE_BYTE_DATA	=	0x00100000
const 	I2C_FUNC_SMBUS_READ_WORD_DATA	=	0x00200000
const 	I2C_FUNC_SMBUS_WRITE_WORD_DATA	=	0x00400000
const 	I2C_FUNC_SMBUS_PROC_CALL		=	0x00800000
const 	I2C_FUNC_SMBUS_READ_BLOCK_DATA	=	0x01000000
const 	I2C_FUNC_SMBUS_WRITE_BLOCK_DATA =	0x02000000
const 	I2C_FUNC_SMBUS_READ_I2C_BLOCK	=	0x04000000 # I2C-like block xfer  
const 	I2C_FUNC_SMBUS_WRITE_I2C_BLOCK	=	0x08000000 # w/ 1-byte reg. addr. 

const 	I2C_FUNC_SMBUS_BYTE 			= 	(I2C_FUNC_SMBUS_READ_BYTE | I2C_FUNC_SMBUS_WRITE_BYTE)
const 	I2C_FUNC_SMBUS_BYTE_DATA 		=	(I2C_FUNC_SMBUS_READ_BYTE_DATA | I2C_FUNC_SMBUS_WRITE_BYTE_DATA)
const 	I2C_FUNC_SMBUS_WORD_DATA 		=	(I2C_FUNC_SMBUS_READ_WORD_DATA | I2C_FUNC_SMBUS_WRITE_WORD_DATA)
const 	I2C_FUNC_SMBUS_BLOCK_DATA 		=	(I2C_FUNC_SMBUS_READ_BLOCK_DATA | I2C_FUNC_SMBUS_WRITE_BLOCK_DATA)
const 	I2C_FUNC_SMBUS_I2C_BLOCK 		=	(I2C_FUNC_SMBUS_READ_I2C_BLOCK | I2C_FUNC_SMBUS_WRITE_I2C_BLOCK)

#*****************************************************************************
# Old name, for compatibility 
#*****************************************************************************
const 	I2C_FUNC_SMBUS_HWPEC_CALC		=	I2C_FUNC_SMBUS_PEC

#*****************************************************************************
#  Data for SMBus Messages
#***************************************************************************** 
const 	I2C_SMBUS_BLOCK_MAX				=	32	# As specified in SMBus standard 
const 	I2C_SMBUS_I2C_BLOCK_MAX			=	32	# Not specified but we use same structure 

#***************************************************************************** 
# This was originally a union of several fields. This was suggested by
# a Julia forum member who helped with the few key data structures and
# the ccall parameter layout. This allows you to get a byte, word, or 
# block of data much as the union provides in the original.
# The data can still be accessed as:
#      byte - data[1], word - data[1], block - data[1-n]
#***************************************************************************** 
mutable struct i2c_smbus_data
    block::NTuple{(I2C_SMBUS_BLOCK_MAX + 1) ÷ 2 + 1, UInt16}
end

#*****************************************************************************
# smbus_access read or write markers 
#*****************************************************************************
const 	I2C_SMBUS_READ					=	1
const 	I2C_SMBUS_WRITE					=	0

#*****************************************************************************
# SMBus transaction types (size parameter in the above functions)
#   Note: these no longer correspond to the (arbitrary) PIIX4 internal codes! 
#*****************************************************************************
const 	I2C_SMBUS_QUICK					=   0
const 	I2C_SMBUS_BYTE		    		=	1
const 	I2C_SMBUS_BYTE_DATA	    		=	2
const 	I2C_SMBUS_WORD_DATA	    		=	3
const 	I2C_SMBUS_PROC_CALL	    		=	4
const 	I2C_SMBUS_BLOCK_DATA	    	=	5
const 	I2C_SMBUS_I2C_BLOCK_BROKEN  	=	6
const 	I2C_SMBUS_BLOCK_PROC_CALL   	=	7		# SMBus 2.0 
const 	I2C_SMBUS_I2C_BLOCK_DATA    	=	8

#*****************************************************************************
# /dev/i2c-X ioctl commands.  The ioctl's parameter is always an
#*****************************************************************************
# * unsigned long, except for:
# *	- I2C_FUNCS, takes pointer to an unsigned long
# *	- I2C_RDWR, takes pointer to struct i2c_rdwr_ioctl_data
# *	- I2C_SMBUS, takes pointer to struct i2c_smbus_ioctl_data
# 
#*****************************************************************************
const 	I2C_RETRIES						=	0x0701	# number of times a device address should
													#be polled when not acknowledging 
const 	I2C_TIMEOUT						=	0x0702	# set timeout in units of 10 ms 

#*****************************************************************************
# NOTE: Slave address is 7 or 10 bits, but 10-bit addresses
# * are NOT supported! (due to code brokenness)
#***************************************************************************** 
const 	I2C_SLAVE						=	0x0703	# Use this slave address 
const 	I2C_SLAVE_FORCE					=	0x0706	# Use this slave address, even if it
													# is already in use by a driver! 
const 	I2C_TENBIT						=	0x0704	# 0 for 7 bit addrs, != 0 for 10 bit 

const 	I2C_FUNCS						=	0x0705	# Get the adapter functionality mask 

const 	I2C_RDWR						=	0x0707	# Combined R/W transfer (one STOP only) 

const 	I2C_PEC							=	0x0708	# != 0 to use PEC with SMBus 
const 	I2C_SMBUS						=	0x0720	# SMBus transfer 

#*****************************************************************************
# This is the structure as used in the I2C_SMBUS ioctl call 
#
#Note: This structure was also changed from the original. It contained a
#      union to i2c_smbus_data. The data can still be accessed as:
#      byte - data[1], word - data[1], block - data[1-n]
#*****************************************************************************
mutable struct i2c_smbus_ioctl_data
	read_write::UInt8
	command::UInt8
	size::UInt32
	data::i2c_smbus_data
end

#*****************************************************************************
# This is the structure as used in the I2C_RDWR ioctl call 
#*****************************************************************************
struct i2c_rdwr_ioctl_data 
	msgs::Vector{i2c_msg}		# pointers to i2c_msgs 
	nmsgs::UInt32			# number of i2c_msgs 
end

const	I2C_RDRW_IOCTL_MAX_MSGS				=	42


#*****************************************************************************
# I added this function as an easy way of getting a file handle necessary
# to use all of the i2c-dev functions. This was not in the original
# i2c-dev.h. 
#*****************************************************************************
function i2c_init(filename::String, addr::UInt8, slave_addr::UInt16)
	file = open(filename,"r+")
	filehandle = Base.Libc.fd(file)
	if (filehandle < 0)
		error("Failed to open the bus.")
		# ERROR HANDLING; you can check errno to see what went wrong 
		return
	end
	ret = ccall((:ioctl, "libc"), Int, (Cint, Cint, Cint...), filehandle, slave_addr, addr) 
    if (ret < 0)
		error("Failed to acquire bus access and/or talk to slave.")
            # ERROR HANDLING; you can check errno to see what went wrong 
	end
    return filehandle
end


#*****************************************************************************
# This is the work horse of the entire i2c-dev. All of the other functions
# call this one - simpy passing different parameters.
#*****************************************************************************
function i2c_smbus_access(file::Int32, read_write::UInt8, command::UInt8,
                                     size::Int32, data::i2c_smbus_data)
	args = i2c_smbus_ioctl_data(read_write, command, size, data)

	ret = ccall((:ioctl, "libc"), Int32, (Cint, Cint, Ref{i2c_smbus_ioctl_data}), file, I2C_SMBUS, args)
	return ret
end


function i2c_smbus_write_quick(file::Int32, value::UInt8)
	ret = i2c_smbus_access(file, value, 0, I2C_SMBUS_QUICK, NULL)
	return ret
end

function i2c_smbus_read_byte(file::Int32)
	data = i2c_smbus_data((0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))
	
	ret = i2c_smbus_access(file, UInt8(I2C_SMBUS_READ), 0, I2C_SMBUS_BYTE, data)
	if (ret < 0)
		return ret
	else
		return 0x0FF & data[1]
	end
end

function i2c_smbus_write_byte(file::Int32, value::UInt8)
	ret = i2c_smbus_access(file, I2C_SMBUS_WRITE, value, I2C_SMBUS_BYTE, NULL)
	return ret
end

function i2c_smbus_read_byte_data(file::Int32, command::UInt8)
	data = i2c_smbus_data((0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))
		
	ret = i2c_smbus_access(file, UInt8(I2C_SMBUS_READ), command, I2C_SMBUS_BYTE_DATA, data)
	if (ret < 0)
		return ret
	else
		return 0xFF & data.block[1]
	end
end

function i2c_smbus_write_byte_data(file::Int32, command::UInt8, value::UInt8)
	data = i2c_smbus_data((value,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))

	ret = i2c_smbus_access(file, UInt8(I2C_SMBUS_WRITE), command, I2C_SMBUS_BYTE_DATA, data)
	return ret
end

function i2c_smbus_read_word_data(file::Int32, command::UInt8)
	data = i2c_smbus_data((0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))
		
	ret = i2c_smbus_access(file, UInt8(I2C_SMBUS_READ), command, I2C_SMBUS_WORD_DATA, data)
	if (ret < 0)
		return ret
	else
		return 0x0FFFF & data.block[1]
	end
end

function i2c_smbus_write_word_data(file::Int32, command::UInt8, value::UInt16)
	data = i2c_smbus_data((value,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))
		
	ret = i2c_smbus_access(file, UInt8(I2C_SMBUS_WRITE), command, I2C_SMBUS_WORD_DATA, data)	
	return ret
end

function i2c_smbus_process_call(file::Int32, command::UInt8, value::UInt16)
	data = i2c_smbus_data((value,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))
		
	ret = i2c_smbus_access(file, UInt8(I2C_SMBUS_WRITE), command, I2C_SMBUS_PROC_CALL, data)
	if (ret < 0)
		return ret
	else
		temp = data.block[1] 
		word = ((temp << 8) | data.block[2])
		return 0x0FFFF & word
	end
end

#*****************************************************************************
# This function has been changed from the original. In the original the
# "data block" was passed in and changed in the function. We realy didn't
# need to pass a "data block" in because there were no values in the
# "data block" being used by the i2c_smbus_access() routine (because the
# data was being read). So, I give it an empty "data block" and return
# 2 items - the length (like in the original) and the "data block" returned.
#*****************************************************************************
function i2c_smbus_read_block_data(file::Int32, command::UInt8)
	data = i2c_smbus_data((0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))
	
	ret = i2c_smbus_access(file, UInt8(I2C_SMBUS_READ), command, I2C_SMBUS_BLOCK_DATA, data)
	if (ret < 0)
		return ret
	else 
		tmpArray = collect(data.block)
		for i = 2:data.block[1]
			tmpArray[i-1] = data.block[i]
		end
		values = i2c_smbus_data(TmpArray)
		return data.block[1], values
	end
end

#*****************************************************************************
# Returns the number of read bytes 
#*****************************************************************************
#function i2c_smbus_read_block_data(file::Int32, command::UInt8, values::i2c_smbus_data)
#	data = i2c_smbus_data((0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))
#	
#	ret = i2c_smbus_access(file, UInt8(I2C_SMBUS_READ), command, I2C_SMBUS_BLOCK_DATA, data)
#	if (ret < 0)
#		return ret
#	else 
#		tmpArray = collect(data.block)
#		for i = 2:data.block[1]
#			tmpArray[i-1] = data.block[i]
#		end
#		values = i2c_smbus_data(TmpArray)
#		return data.block[1]
#	end
#end

function i2c_smbus_write_block_data(file::Int32, command::UInt8, length::UInt8, values::i2c_smbus_data)
	data = i2c_smbus_data((0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))

	if (length > 32)
		length = 32
	end
	tmpArray = collect(data.block)
	for i = 2:length
		tmpArray[i] = values[i-1]
	end
	tmpArray[1] = length
	data = i2c_smbus_data(TmpArray)
	
	ret = i2c_smbus_access(file, UInt8(I2C_SMBUS_WRITE), command, I2C_SMBUS_BLOCK_DATA, data)
	return ret
end

#*****************************************************************************
# This function has been changed from the original. In the original the
# "data block" was passed in and changed in the function. We realy didn't
# need to pass a "data block" in because there were no values in the
# "data block" being used by the i2c_smbus_access() routine (because the
# data was being read). So, I give it an empty "data block" and return
# 2 items - the length (like in the original) and the "data block" returned.
#*****************************************************************************
function i2c_smbus_read_i2c_block_data(file::Int32, command::UInt8, length::UInt8)
	if (length > 32)
		length = 32
	end
	data = i2c_smbus_data((length,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))

	
	ret = i2c_smbus_access(file, UInt8(I2C_SMBUS_READ), command,
	                     length == 32 ? I2C_SMBUS_I2C_BLOCK_BROKEN :
	                      I2C_SMBUS_I2C_BLOCK_DATA, data)
	if (ret < 0)
		return ret
	else 
		tmpArray = collect(data.block)
		for i = 1:length
			tmpArray[i] = data.block[i]
		end
		values = NTuple{(I2C_SMBUS_BLOCK_MAX + 1) ÷ 2 + 1, UInt16}(tmpArray)

		return length, values
	end
end

#*****************************************************************************
# Returns the number of read bytes 
# Until kernel 2.6.22, the length is hardcoded to 32 bytes. If you
#   ask for less than 32 bytes, your code will only work with kernels
#   2.6.23 and later. 
#*****************************************************************************
#function i2c_smbus_read_i2c_block_data(file::Int32, command::UInt8, length::UInt8, values::i2c_smbus_data)
#
#	if (length > 32)
#		length = 32
#	end
#	data = i2c_smbus_data((length,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))
#
#	
#	ret = i2c_smbus_access(file, UInt8(I2C_SMBUS_READ), command,
#	                     length == 32 ? I2C_SMBUS_I2C_BLOCK_BROKEN :
#	                      I2C_SMBUS_I2C_BLOCK_DATA, data)
#	if (ret < 0)
#		return ret
#	else 
#		tmpArray = collect(data.block)
#		for i = 1:length
#			tmpArray[i] = data.block[i]
#		end
#		values = NTuple{(I2C_SMBUS_BLOCK_MAX + 1) ÷ 2 + 1, UInt16}(tmpArray)
#
#		return length
#	end
#end

function i2c_smbus_write_i2c_block_data(file::Int32, command::UInt8, length::UInt8, values::i2c_smbus_data)
	data = i2c_smbus_data((0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))
	
	if (length > 32)
		length = 32
	end
	tmpArray = collect(data.block)
	for i = 2:length
		tmpArray[i] = values[i-1]
	end
	tmpArray[1] = length
	data = NTuple{(I2C_SMBUS_BLOCK_MAX + 1) ÷ 2 + 1, UInt16}(TmpArray)
	
	ret = i2c_smbus_access(file, UInt8(I2C_SMBUS_WRITE), command, I2C_SMBUS_I2C_BLOCK_BROKEN, data)
	return ret
end

#*****************************************************************************
# This function has been changed from the original. The function returns
# 2 items - the length (like in the original) and the "data block" returned.
#*****************************************************************************
function i2c_smbus_block_process_call(file::Int32, command::UInt8, length::UInt8, values::i2c_smbus_data)
	data = i2c_smbus_data((0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))
	
	if (length > 32)
		length = 32
	end
	
	tmpArray = collect(data.block)
	for i = 2:length
		tmpArray[i] = values[i-1]
	end
	tmpArray[1] = length
	data = NTuple{(I2C_SMBUS_BLOCK_MAX + 1) ÷ 2 + 1, UInt16}(TmpArray)
	ret = i2c_smbus_access(file, UInt8(I2C_SMBUS_WRITE), command, I2C_SMBUS_BLOCK_PROC_CALL, data)
	if (ret < 0)
		return ret
	else 
		tmpArray = collect(data.block)
		for i = 2:data.block[1]
			tmpArray[i-1] = data.block[i]
		end
		values = i2c_smbus_data(TmpArray)
		return data.block[1], values
	end
end

#*****************************************************************************
# Returns the number of read bytes 
#*****************************************************************************
#function i2c_smbus_block_process_call(file::Int32, command::UInt8, length::UInt8, values::i2c_smbus_data)
#	data = i2c_smbus_data((0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))
#	
#	if (length > 32)
#		length = 32
#	end
#	
#	tmpArray = collect(data.block)
#	for i = 2:length
#		tmpArray[i] = values[i-1]
#	end
#	tmpArray[1] = length
#	data = NTuple{(I2C_SMBUS_BLOCK_MAX + 1) ÷ 2 + 1, UInt16}(TmpArray)
#	ret = i2c_smbus_access(file, UInt8(I2C_SMBUS_WRITE), command, I2C_SMBUS_BLOCK_PROC_CALL, data)
#	if (ret < 0)
#		return ret
#	else 
#		tmpArray = collect(data.block)
#		for i = 2:data.block[1]
#			tmpArray[i-1] = data.block[i]
#		end
#		values = NTuple{(I2C_SMBUS_BLOCK_MAX + 1) ÷ 2 + 1, UInt16}(TmpArray)
#		return data.block[1]
#	end
#end

end
