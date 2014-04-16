function out=calibrate_tp(tp,coeff_tp,t,coeff_t,fspd)
% function out=calibrate_tp(tp,coeff_tp,t,coeff_t,fspd)
% This function does a polynomial calibration on the
% vector tp with time constant given in coeff_tp, dc time series
% given in t, and polynomial coefficients for t given by coeff_t
% note that fspd must be in cm/s.
if size(t,2)==2
  t=ch(t);
end
if size(tp,2)==2
  tp=ch(tp);
end
ltp=length(tp);
t=makelen(t,ltp);
fspd=makelen(fspd,ltp);
if coeff_tp(2)==0
  coeff_tp(2)=coeff_tp(1);
end
warning off
% add a gain step if coeff(5) is non-zero
if coeff_t(5), t=t/coeff_t(5);, end
if ~coeff_tp(5),coeff_tp(5)=1;,end
out=(coeff_t(2)+2*coeff_t(3)*t+3*coeff_t(4)*t.^2).*tp ... 
    .*100./(coeff_tp(2)*fspd*coeff_tp(5));
out(find(fspd<5))=NaN;
warning on