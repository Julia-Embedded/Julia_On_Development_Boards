npdProc = addprocs(["julia-user@NODE-NANOPIDUO"],dir="/home/julia-user/julia-0.6.0/bin/")

include("GPIO_NPD.jl")

import GPIO_NPD

using GPIO_NPD

npd = GPIO_NPD.NPDGPIO()

initialize(npd, "NANOPIDUO.xml")

PWMPin = npd.pwm_pin["DBG_RX"]

MachineID = npd.id

remotecall_fetch(test_pwm, npdProc[1], MachineID, PWMPin)
