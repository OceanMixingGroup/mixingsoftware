function out=qv_calw(in,coef,spd)
% function OUT=qv_calw(IN,COEFF)
% This function calibrates raw voltages from DC-pitot
% module using sensitivity in header coeff.W(2)
% cgs units 
rho=1.024;%nominal density
if size(in,2)==2
  in=ch(in);
end
sp=1/coef(2);%probe sensitivity [volts/(dyne/cm^2)]
out=in./(2*rho*spd.*sp);
