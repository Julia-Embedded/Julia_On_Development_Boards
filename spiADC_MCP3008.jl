include("spidev_h.jl")
include("spidev.jl")

import spidev
using spidev

function combineValues(upper::UInt8, lower::UInt8)
    return (Int16(upper) << 8) | Int16(lower)
end


println("Starting RPi SPI ADC Example")

spi = spidev.SPIDevice(0,0)

print("ret = spidev.spi_setSpeed(spi, 1000000): ")
ret = spidev.spi_setSpeed(spi, 1000000)      # Have access to SPI Device object
println(ret)

print("ret = spidev.spi_setMode(spi, SPI_MODE_0): ")
ret = spidev.spi_setMode(spi, SPI_MODE_0)
println(ret)

print("ret = spidev.spi_setBitsPerWord(spi, 8): ")
ret = spidev.spi_setBitsPerWord(spi, 8)
println(ret)

ret = spidev.spi_open(spi)

print("ret = spidev.spi_open(spi): ")
println(ret)

println("The SPI ADC is setup")

send = Array{UInt8, 1}(3)
receive = Array{UInt8, 1}(3)
send[1] = 0b00000001 # The Start Bit followed
# Set the SGL/Diff and D mode -- e.g., 1000 means single ended CH0 value
send[2] = 0b10000000 # The MSB is the Single/Diff bit and it is followed by 000 for CH0
send[3] = 0          # This byte doesn't need to be set, just for a clear display

spidev.spi_transfer(spi, send, receive, 3)

println("Response bytes are " * string(receive[2]) * "," * string(receive[3]))

# Use the 8-bits of the second value and the two LSBs of the first value
value = combineValues(receive[2] & 0b00000011, receive[3])
println("This is the value " * string(value) * " out of 1024.")
println("End of ERPi SPI ADC Example")

spidev.spi_close(spi)
