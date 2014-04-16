function out=calibrate_w(in,coef,spd)
% function OUT=calibrate_w(IN,COEFF)
% This function calibrates raw voltages from DC-pitot
% module using sensitivity in header coeff.W(2)
% cgs units 
rho=1.024;% nominal density
if size(in,2)==2
  in=ch(in);
end
in=in(1:length(in)/length(spd):length(in));
% check to make sure gain is non-zero:
if ~coef(5),coef(5)=1;, end
sp=coef(5)/coef(2);% probe sensitivity [volts/(dyne/cm^2)]
out=in./(2*rho*spd.*sp);
