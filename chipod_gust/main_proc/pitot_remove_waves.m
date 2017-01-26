function [data] =  pitot_remove_waves(data)
%%

dt = diff(data.time(1:2))*3600*24;

%_____________________low pass 100 sec______________________
f_low = dt/30;
data.spd    = qbutter(data.spd,f_low);
data.Pdym   = qbutter(data.Pdym,f_low);
data.V_cal  = qbutter(data.V_cal,f_low);
data.U      = qbutter(data.U,f_low);
data.u      = real(data.U);
data.v      = imag(data.U);
