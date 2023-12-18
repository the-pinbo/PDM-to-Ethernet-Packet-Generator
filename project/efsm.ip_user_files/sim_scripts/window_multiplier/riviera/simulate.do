onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+window_multiplier -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.window_multiplier xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure

do {window_multiplier.udo}

run -all

endsim

quit -force
