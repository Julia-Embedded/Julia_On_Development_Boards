#*****************************************************************************
#This is example is based on Jatin Kataria's mma8451.py code. Since, this was
#just to test the Julia_I2C.jl wrapper module, I didn't break my program into
#functions the way Jatin did. I basically stripped out what he was doing by 
#default and translated that to the file you see here.
#*****************************************************************************
const HIGH_RES_PRECISION = 14
const LOW_RES_PRECISION = 8
const DEACTIVATE = 0x0
const ACTIVATE = 0x1
const EARTH_GRAVITY_MS2 = 9.80665

const BW_RATE_800HZ = 0x0
const BW_RATE_400HZ = 0x1
const BW_RATE_200HZ = 0x2
const BW_RATE_100HZ = 0x3
const BW_RATE_50HZ = 0x4
const BW_RATE_12_5HZ = 0x5
const BW_RATE_6_25HZ = 0x6
const BW_RATE_1_56HZ = 0x7   # frequency for Low power

const RANGE_2G = 0x00
const RANGE_4G = 0x01
const RANGE_8G = 0x02

const DEFAULT_ADDRESS = 0x1d
const MMA8451_REG_OUT_X_MSB = 0x01
const MA8451_REG_SYSMOD = 0x0B
const MA8451_REG_WHOAMI = 0x0D
const MMA8451_REG_XYZ_DATA_CFG = 0x0E
const MMA8451_REG_F_SETUP = 0x9
const MMA8451_REG_PL_STATUS = 0x10
const MMA8451_REG_PL_CFG = 0x11
const MMA8451_REG_CTRL_REG1 = 0x2A
const MMA8451_REG_CTRL_REG2 = 0x2B
const MMA8451_REG_CTRL_REG4 = 0x2D
const MMA8451_REG_CTRL_REG5 = 0x2E
const MMA8451_RESET = 0x40

const ORIENTATION_ON = 0x40
const MAX_BLOCK_LEN = 32

const I2C_SLAVE = 0x0703
const I2C_SMBUS = 0x0720
const I2C_SMBUS_WRITE = 0
const I2C_SMBUS_READ = 1
const I2C_SMBUS_BYTE_DATA = 2
const I2C_SMBUS_BLOCK_DATA = 5
const I2C_SMBUS_I2C_BLOCK_DATA = 8
const I2C_SMBUS_PROC_CALL = 4

const DATA_RATE_BIT_MASK = 0xc7
const MODS_LOW_POWER = 3

const REDUCED_NOIDE_MODE = 0
const REDUCED_NOIDE_MODE = 0
const OVERSAMPLING_MODE = 1

const ACCEL_ADDR	=	0x1D

#***********************************************************
#Include the wrapper module for i2c-dev functions.
#***********************************************************
include("Julia_I2C.jl")

import Julia_I2C
using Julia_I2C

#***********************************************************
#This is the buffer we will use to get values from the
#i2c device. This maps to the C i2c-dev.h code's
#__u8 block[I2C_SMBUS_BLOCK_MAX + 2] which is part of a 
#union that stores various values. 
#***********************************************************
buffer = Vector{UInt8}(Julia_I2C.I2C_SMBUS_I2C_BLOCK_MAX + 2)
zeros(buffer)

#***********************************************************
#Get the file handle to your i2c device
#***********************************************************
fd = Julia_I2C.i2c_init("/dev/i2c-0", ACCEL_ADDR, I2C_SLAVE)

#***********************************************************
#device id should be 0x1a (or 26 in decimal)
#***********************************************************
device_id = Julia_I2C.i2c_smbus_read_byte_data(fd, MA8451_REG_WHOAMI)
if (device_id != 26)
	error("The device id is not correct. You got " * string(device_id))
	return
end

#***********************************************************
#reset sensor
#***********************************************************
while(true)
	ret = Julia_I2C.i2c_smbus_read_byte_data(fd, MMA8451_REG_CTRL_REG2)
	if (ret == 0)
		break
	end
end
sleep(1)

#***********************************************************
#set resolution
#***********************************************************
Julia_I2C.i2c_smbus_write_byte_data(fd, MMA8451_REG_CTRL_REG2, 0x2)

#***********************************************************
# data ready int1
#***********************************************************
Julia_I2C.i2c_smbus_write_byte_data(fd, MMA8451_REG_CTRL_REG4, 0x1)
Julia_I2C.i2c_smbus_write_byte_data(fd, MMA8451_REG_CTRL_REG5, 0x1)

#***********************************************************
# turn on orientation
#***********************************************************
Julia_I2C.i2c_smbus_write_byte_data(fd, MMA8451_REG_PL_CFG, ORIENTATION_ON)

#***********************************************************
# activate at max rate, low noise mode
#***********************************************************
Julia_I2C.i2c_smbus_write_byte_data(fd, MMA8451_REG_CTRL_REG1, 0x4 | ACTIVATE)

#***********************************************************
#set range for the sensor
#***********************************************************
sensor_range = RANGE_4G & 0x3

#***********************************************************
# first standby
#***********************************************************
reg1 = 0x0
reg1 = Julia_I2C.i2c_smbus_read_byte_data(fd, MMA8451_REG_CTRL_REG1)


Julia_I2C.i2c_smbus_write_byte_data(fd, MMA8451_REG_CTRL_REG1, DEACTIVATE)
Julia_I2C.i2c_smbus_write_byte_data(fd, MMA8451_REG_XYZ_DATA_CFG, sensor_range)        
Julia_I2C.i2c_smbus_write_byte_data(fd, MMA8451_REG_CTRL_REG1, UInt8(reg1) | ACTIVATE)                

#***********************************************************
# set the data rate for the sensor. 
#***********************************************************
data_rate = BW_RATE_400HZ
current = Julia_I2C.i2c_smbus_read_byte_data(fd, MMA8451_REG_CTRL_REG1)        

#***********************************************************
# deactivate
#***********************************************************
Julia_I2C.i2c_smbus_write_byte_data(fd, MMA8451_REG_CTRL_REG1, DEACTIVATE)        

current = UInt8(current)
current = current & DATA_RATE_BIT_MASK
current = current | (data_rate << 3)
Julia_I2C.i2c_smbus_write_byte_data(fd, MMA8451_REG_CTRL_REG1, current | ACTIVATE)        

#***********************************************************
#Start reading the x,y,z values from the mma8451
#***********************************************************
while(true)
	#***********************************************************
	#def _validate axes readings
	#make sure F_READ and F_MODE are disabled.
	#***********************************************************
	f_read = Julia_I2C.i2c_smbus_read_byte_data(fd, MMA8451_REG_CTRL_REG1) & 2

	f_mode = Julia_I2C.i2c_smbus_read_byte_data(fd, MMA8451_REG_F_SETUP) & 0xC0

	#***********************************************************
	#Read the buffer from the mma8451
	#***********************************************************
	read_bytes = Julia_I2C.i2c_smbus_read_i2c_block_data(fd, MMA8451_REG_OUT_X_MSB, 0x6, buffer)  
	if (read_bytes < 0)
		error("Problem reading data.")
		break
	end
	
	#***********************************************************
	#debug information
	#***********************************************************
	print("read_bytes: ")
	println(read_bytes)  
	
	for n = 1:read_bytes    
		println("raw: " * string(buffer[n]))
	end
	
	#***********************************************************
	#This initially bit me and took a while to figure out why I
	#kept getting the wrong values.	Each element of the buffer
	#is an unsigned 8-bit integer. It has no place to go when
	#you shift 8 bits left.
	#***********************************************************

	
	#***********************************************************
	#x = ((buffer[1] << 8) | buffer[2]) >> 2  gave wrong value
	#***********************************************************
	
	#***********************************************************
	#Corrected with new variable type cast to 16-bits
	#***********************************************************
	temp = UInt16(buffer[1]) 

	x = ((temp << 8) | buffer[2]) >> 2
	
	
	
	#***********************************************************
	#y = ((buffer[3] << 8) | buffer[4]) >> 2  gave wrong value
	#***********************************************************
	
	#***********************************************************
	#Corrected with new variable type cast to 16-bits
	#***********************************************************
	temp = UInt16(buffer[3])
	y = ((temp << 8) | buffer[4]) >> 2

	#***********************************************************
	#z = ((buffer[5] << 8) | buffer[6]) >> 2  gave wrong value
	#***********************************************************
	
	#***********************************************************
	#Corrected with new variable type cast to 16-bits
	#***********************************************************
	temp = UInt16(buffer[5]) 
	z = ((temp << 8) | buffer[6]) >> 2
	
	#***********************************************************
	#more debug information
	#***********************************************************
	println("************************************************************")
	orientation = Julia_I2C.i2c_smbus_read_byte_data(fd, MMA8451_REG_PL_STATUS) & 0x7
	print("Position = ")
	println(orientation)
	print("x: ")
	println(x)
	print("y: ")
	println(y)
	print("z: ")
	println(z)
	println("************************************************************")
	
	precision = HIGH_RES_PRECISION

	max_val = 2 ^ (precision - 1) - 1
	signed_max = 2 ^ precision
	
	print("max_val: ")
	println(max_val)
	print("signed_max: ")
	println(signed_max)

	#***********************************************************
	#This wasn't used based on values, but it was in the python
	#program.
	#***********************************************************
	#x = x - signed_max if x > max_val else 0  - python
	#
	#if x > max_val
	#	x = x - signed_max
	#else
	#	x = 0
	#end
	#
	#y = y - signed_max if y > max_val else 0  - python
	#
	#if y > max_val
	#	y = y - signed_max
	#else
	#	y = 0
	#end
	#
	#z = z - signed_max if z > max_val else 0  - python
	#if x > max_val
	#	z = z - signed_max
	#else
	#	z = 0
	#end
	   
	x = round((float(x)) / (2048 / EARTH_GRAVITY_MS2), 3)
	y = round((float(y)) / (2048 / EARTH_GRAVITY_MS2), 3)
	z = round((float(z)) / (2048 / EARTH_GRAVITY_MS2), 3)
	
	#orientation = Julia_I2C.i2c_smbus_read_byte_data(fd, MMA8451_REG_PL_STATUS) & 0x7
	
	println("*****************************************************")
	print("Position = ")
	println(orientation)
	print("x: ")
	println(x)
	print("y: ")
	println(y)
	print("z: ")
	println(z)	
	println("*****************************************************")
	
	sleep(0.5)
end
