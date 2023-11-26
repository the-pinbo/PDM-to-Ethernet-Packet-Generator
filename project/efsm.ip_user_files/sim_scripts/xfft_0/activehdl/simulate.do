onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+xfft_0 -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.xfft_0 xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure

do {xfft_0.udo}

run -all

endsim

quit -force
