function out=qv_caltcp(tp,coeff_tp,t,coeff_t,fspd)
% function out=qv_caltp(tp,coeff_tp,irep_tp,t,coeff_t,irep_t,fspd,irep_fspd)
% This function does a polynomial calibration on the
% vector tp with time constant given in coeff_tp, dc time series
% given in t, and polynomial coefficients for t given by coeff_t
if size(t,2)==2
  t=ch(t);
end
if size(tp,2)==2
  tp=ch(tp);
end
ltp=length(tp);
t=makelen(t,ltp);
fspd=makelen(fspd,ltp);
warning off
out=(coeff_t(2)).*tp.*100./(coeff_tp(1)*fspd);
out(find(fspd<5))=NaN;
warning on