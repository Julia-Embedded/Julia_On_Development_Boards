#Connect to the different nodes whose user is julia-user. 
#Of course, the nodes are set up as passwordless SSH.
rpiProc = addprocs(["julia-user@NODE-RPI2"],dir="/home/julia-user/julia-0.6.0/bin/")
bbbProc = addprocs(["julia-user@NODE-BBB"],dir="/home/julia-user/julia-0.6.0/bin/")
udooProc = addprocs(["julia-user@NODE-UDOOX86"],dir="/home/julia-user/julia-0.6.0/bin/")

#These are routines written to manipulate the GPIO
#via the file system on the development boards.
include("Device_GPIO.jl")

#I want to use these.
import Device_GPIO



#The routine takes two parameters. The first is the GPIO
#pin number used to control the LED. The second is the GPIO
#pin number used to control the motion sensor. 
rpi_process = true
bbb_process = true
udoo_process = true
process_return_value = ""

rpi = Device_GPIO.DeviceGPIO()
bbb = Device_GPIO.DeviceGPIO()
u86 = Device_GPIO.DeviceGPIO()

initialize(rpi, "RPI3.xml")
initialize(bbb, "BBB.xml")
initialize(u86, "UDOOx86.xml")

#This loop is sending out routines to the Raspberry Pi,
#Beaglebone Black, and Udoo x86 boards.
#This loop will send the routines to the appropriate nodes
#and then wait for it to get return value from the remotecall.
while(true)
    if (rpi_process)
        rpi_rc = remotecall(GPIO_Common.checking_motion_sensor, rpi.handle, rpi, "17", "27")
        sleep(1)
        rpi_process = false
    end
    if (bbb_process)
        bbb_rc = remotecall(GPIO_Common.checking_light_sensor, bbb.handle, bbb, "60", "1")
        sleep(1)
        bbb_process = false
    end
    if (udoo_process)
        udoo_rc = remotecall(GPIO_Common.checking_mic_sensor_on_arduino, u86.handle, u86, "366", "/dev/ttyACM1")
        sleep(1)
        udoo_process = false
    end

    print(Dates.format(now(), "mm/dd/yyyy"))
    print(" ")
    print(Dates.format(now(), "HH:MM:SS"))
    print(" ")
    println("Watching the sensors on remote machines.")

    if isfile("/tmp/stop")
        println("Program stopped.")
        break
    end
   

    #When the remotecall - Machine_GPIO.checking_motion_sensor gets a
    #return value - let us know by printing a message.
    if isready(rpi_rc)
        remotecall_fetch(GPIO_Common.setvalue_analog_to_serial, u86.handle, u86, "/dev/ttyACM2", "startplasma")
        sleep(2)
        remotecall_fetch(GPIO_Common.setvalue_analog_to_serial, u86.handle, u86, "/dev/ttyACM2", "endplasma")
        print("MOVEMENT DETECTED ON ")
        print(rpi.name)
        println(" SENSOR.")
        rpi_process = true
        process_return_value = fetch(rpi_rc)
        println(process_return_value)
    end
    #When the remotecall - Machine_GPIO.checking_light_sensor gets a
    #return value - let us know by printing a message.
    if isready(bbb_rc)
        print("BRIGHT LIGHT DETECTED ON ")
        print(bbb.name)
        println(" SENSOR.")
        bbb_process = true
        process_return_value = fetch(bbb_rc)
        println(process_return_value)
    end
    #When the remotecall - Machine_GPIO.checking_mic_sensor_on_arduino gets a
    #return value - let us know by printing a message.
    if isready(udoo_rc)
        print("MIC DETECTED LOUD NOISE ON ")
        print(u86.name)
        println(" SENSOR.")
        udoo_process = true
        process_return_value = fetch(udoo_rc)
        println(process_return_value)
    end

    sleep(.25)
end

rmprocs(bbb.handle)
rmprocs(rpi.handle)
rmprocs(u86.handle)

#To initially set up BBB for analog
#echo "BB-ADC" > /sys/devices/platform/bone_capemgr/slots
#I had to put it in a start up script
#sudo nano AnalogStart.sh
#
#(Obviously it doesn't have to be called "AnalogStart".) In this script, do whatever you want to do. Perhaps just run the script you mentioned.
#
#!/bin/bash
#echo "BB-ADC" > /sys/devices/platform/bone_capemgr/slots
#
#Make it executable.
#
#sudo chmod +x AnalogStart.sh
#
#Add it as a cron job
#
#crontab -e
#
#add the line
#@reboot /home/debian/AnalogStart.sh
#
#save and get out of editor



#get an analog value off of BBB analog 1
#ret = remotecall_fetch(getvalue_analog_pin, bbb[1], "1")
#
#On udoo x86
#sudo nano /etc/udev/rules.d/50-local.rules
#
#Paste
#ACTION=="add", ATTRS{idProduct}=="607d", ATTRS{idVendor}=="1d50", DRIVERS=="usb", RUN+="chmod a+rw /dev/ttyACM0"
#Your device id {idProduct}, and your manufacturer id {idVendor} may be different. To check, run
#
#lsusb
#
#And substitute your results into the /etc/udev/rules.d/50-local.rules file you created.
#
#Bus 003 Device 026: ID 1d50:607d OpenMoko, Inc.
#under sudo su
#stty -F /dev/ttyACM0 raw ispeed 115200 ospeed 115200 -ignpar cs8 -cstopb -echo
#read -r line < /dev/ttyACM0
#echo $line









