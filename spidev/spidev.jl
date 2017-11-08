module spidev

include("spidev_h.jl")

export shift_bytes_into_ulong, shift_ulong_into_bytes,
        spi_open, spi_close,
        spi_setMode, spi_setSpeed,
        spi_setBitsPerWord, spi_transfer,
        spi_readRegister, spi_readRegisters,
        spi_write, spi_write,
        spi_writeRegister, spi_debugDumpRegisters
    


mutable struct SPIDevice
    bus::UInt8
    device::UInt8
    file::Int
    filename::String
    mode::UInt8
    bits::UInt8
    speed::UInt32
    delay::UInt16
    SPIDevice() = new()
    SPIDevice(bus, device) = new(
                                bus, 
                                device, 
                                0, 
                                "/dev/spidev" * string(bus) * "." * string(device),
                                3,
                                8,
                                488000,
                                0)
end


function shift_bytes_into_ulong(bytes::Array{UInt8,1}, length::Int32)
    u = UInt64(bytes[1])

    for i = 2:length
        u <<= 8    
        u |= bytes[i] 
    end

    return u
end



function shift_ulong_into_bytes(ul::UInt64)
    bytes = Array{UInt8, 1}(8)
    bytes[1] = (ul & 0xff00000000000000) >> 56
    bytes[2] = (ul & 0x00ff000000000000) >> 48
    bytes[3] = (ul & 0x0000ff0000000000) >> 40
    bytes[4] = (ul & 0x000000ff00000000) >> 32
    bytes[5] = (ul & 0x00000000ff000000) >> 24
    bytes[6] = (ul & 0x0000000000ff0000) >> 16
    bytes[7] = (ul & 0x000000000000ff00) >> 8
    bytes[8] = (ul & 0x00000000000000ff)

    return bytes
end


function spi_open(spi::SPIDevice)
    #cout << "Opening the file: " << filename.c_str() << endl;
    O_RDWR = 0x0002             # open for reading and writing
    fd = ccall((:open, "libc"), Cint, (Cstring, Cint), spi.filename, O_RDWR)
    if (fd < 0)
       error("SPI: Can't open device.")
       return fd
    end

    spi.file = fd

    return 0
end

function spi_setMode(spi::SPIDevice, mode::UInt8)
    tempMode = mode


     # Set SPI_POL and SPI_PHA 
     ret = ccall((:ioctl, "libc"), Int, (Cint, Cuint, Ref{Cuchar}...), spi.file, SPI_IOC_WR_MODE, tempMode) 
     if (ret < 0)
        error("SPI (SPI_IOC_WR_MODE): Can't set SPI mode.")
        return -1
     end
     spi.mode = tempMode
    
     ret = ccall((:ioctl, "libc"), Int, (Cint, Cuint, Ref{Cuchar}...), spi.file, SPI_IOC_RD_MODE, tempMode) 
     if (ret < 0)
        error("SPI (SPI_IOC_RD_MODE): Can't get SPI mode.")
         return -1
     end
     spi.mode = tempMode
     mode = tempMode

     return 0
end

function spi_setSpeed(spi::SPIDevice, speed::UInt32)
    tempSpeed = speed
    
    # Set SPI speed
    ret = ccall((:ioctl, "libc"), Int, (Cint, Cuint, Ref{Cuint}...), spi.file, SPI_IOC_WR_MAX_SPEED_HZ, tempSpeed) 
    if (ret < 0)
        error("SPI (SPI_IOC_WR_MAX_SPEED_HZ): Can't set max speed HZ")
        return -1
    end
    spi.speed = tempSpeed

   
    ret = ccall((:ioctl, "libc"), Int, (Cint, Cuint, Ref{Cuint}...), spi.file, SPI_IOC_RD_MAX_SPEED_HZ, tempSpeed) 
    if (ret < 0) 
        error("SPI (SPI_IOC_RD_MAX_SPEED_HZ): Can't get max speed HZ.")
        return -1
    end
    spi.speed = tempSpeed
    speed = tempSpeed

   
	return 0
end

function spi_setBitsPerWord(spi::SPIDevice, bits::UInt8)
    tempBits = bits
    
    ret = ccall((:ioctl, "libc"), Int, (Cint, Cuint, Ref{Cuchar}...), spi.file, SPI_IOC_WR_BITS_PER_WORD, tempBits) 
    if (ret < 0) 
        error("SPI: Can't set bits per word.")
        return -1
    end
    spi.bits = tempBits

    ret = ccall((:ioctl, "libc"), Int, (Cint, Cuint, Ref{Cuchar}...), spi.file, SPI_IOC_RD_BITS_PER_WORD, tempBits) 
    if (ret < 0) 
        error("SPI: Can't set bits per word.")
        return -1
    end
    spi.bits = tempBits
    bits = tempBits

	return 0
end


function spi_close(spi::SPIDevice) 

   ret = ccall((:close, "libc"), Cint, (Cint,), spi.file)

    return ret
end

#********************************************************************************
# Generic method to transfer data to and from the SPI device. It is used by the
# following methods to read and write registers.
# @param send The array of data to send to the SPI device
# @param receive The array of data to receive from the SPI device
# @param length The length of the array to send
# @return -1 on failure
#********************************************************************************
function spi_transfer(spi::SPIDevice, send::Array{UInt8,1}, receive::Array{UInt8,1}, len::Int32)
    transfer = spi_ioc_transfer()
 
    #see <linux/spi/spidev.h> for details!
    transfer.tx_buf = pointer(send)
    transfer.rx_buf = pointer(receive)
    transfer.len = len #number of bytes in vector
    transfer.speed_hz = spi.speed
    transfer.delay_usecs = spi.delay
    transfer.bits_per_word = spi.bits
    transfer.pad = 0

    ret = ccall((:ioctl, "libc"), Cint, (Cint, Clong, Ref{spi_ioc_transfer}), spi.file, SPI_IOC_MESSAGE(1), transfer) 
    
    if (ret < 0) 
        error("SPI: Transfer SPI_IOC_MESSAGE Failed")
        return -1
    end


    return ret
end

function spi_readRegister(spi::SPIDevice, registerAddress::UInt64)
    send = Array{UInt8, 1}(2)
    receive = Array{UInt8, 1}(2)
    zeros(send)

    send[1] = UInt8(0x80 + registerAddress)
    
	spi_transfer(spi, send, receive, 2)
        
    println("The value that was received is: " * string(receive[2]))

	return receive[2]
end

function spi_readRegisters(spi::SPIDevice, number::UInt32, fromAddress::UInt32)
    data = Array{UInt8}(number)
	
    send = Array{UInt8, 1}(number + 1)
    receive = Array{UInt8, 1}(number + 1)
    zeros(send)
	send[1] =  UInt8(0x80 + 0x40 + fromAddress) #set read bit and MB bit

	data = spi_transfer(spi, send, receive, number+1)
	
	return data
end

function spi_write(spi::SPIDevice, value::UInt8)
    null_return = 0x00
    
	println(value)
    spi_transfer(spi, value, null_return, 1)
    
	return 0
end

function spi_write(spi::SPIDevice, value::Array{UInt8,1}, length::Int32)
	null_return = 0x00
    spi_transfer(spi, value, null_return, length)
    
	return 0
end

function spi_writeRegister(spi::SPIDevice, registerAddress::UInt32, value::UInt8)
    send = Array{UInt8, 1}(2)
    receive = Array{UInt8, 1}(2)
    zeros(receive)

    send[1] = UInt8(registerAddress)
	send[2] = value
	println("The value that was written is: " * string(send[2]))
    spi_transfer(spi, send, receive, 2)
    
	return 0
end


function spi_debugDumpRegisters(spi::SPIDevice, number::UInt32)
	println("SPI Mode: " * string(spi.mode))
	println("Bits per word: " * string(spi.bits))
	println("Max speed: " * string(spi.speed))
	println("Dumping Registers for Debug Purposes:")
    
    registers = spi_readRegisters(spi, number)
	for i=1:number
		print(hex(registers[i]))
        if (i % 16 == 15) 
            println()
        end
    end
	println(string(dec))
end

end
