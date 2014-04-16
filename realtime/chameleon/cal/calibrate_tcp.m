function out=calibrate_tcp(tcp,coeff_tcp,tc,coeff_tc,fspd)
% function out=qv_caltcp(tcp,coeff_tcp,tc,coeff_tc,fspd)
% This function does a polynomial calibration on the
% vector tcp with time constant given in coeff_tcp, dc time series
% given in tc, and polynomial coefficients for tc given by coeff_tc
if size(tc,2)==2
  tc=ch(tc);
end
if size(tcp,2)==2
  tcp=ch(tcp);
end
if coeff_tcp(1)==0
  coeff_tcp(1)=coeff_tcp(2);
end
ltcp=length(tcp);
tc=makelen(tc,ltcp);
fspd=makelen(fspd,ltcp);
warning off
out=(coeff_tc(2)).*tcp.*100./(coeff_tcp(1)*fspd);
out(find(fspd<5))=NaN;
warning on