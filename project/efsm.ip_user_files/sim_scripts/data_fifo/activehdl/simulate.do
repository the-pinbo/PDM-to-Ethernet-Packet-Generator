onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+data_fifo -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.data_fifo xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure

do {data_fifo.udo}

run -all

endsim

quit -force
