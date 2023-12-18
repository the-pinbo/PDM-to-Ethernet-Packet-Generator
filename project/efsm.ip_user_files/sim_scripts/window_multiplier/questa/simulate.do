onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib window_multiplier_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {window_multiplier.udo}

run -all

quit -force
