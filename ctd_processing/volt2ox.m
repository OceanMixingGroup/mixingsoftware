function ox=volt2ox(v,s,t,p,oxcal)
%function ox=volt2ox(v,s,t,p,oxcal) calculates oxygen concentration in 
%ml/l given volts from sensor, temperature, salinity, and oxygen
%calibration structure oxcal.

%D. Rudnick 07/30/06

ox=(oxcal.soc*(v+oxcal.voffset)).*exp(oxcal.tcor*t).*sw_satO2(s,t).*exp(oxcal.pcor*p);
