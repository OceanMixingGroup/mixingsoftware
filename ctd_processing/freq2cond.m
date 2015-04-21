function cond = freq2cond(freq,temp,pres,ccal)
%function cond = freq2cond(freq,temp,press,ccal) calculates conductivity
%given frequency, temperature, pressure and conductivity calibration
%structure ccal.

%D. Rudnick 01/06/05

ff = freq ./ 1000;

cond = (ccal.ghij(1) + ff .* ff .* (ccal.ghij(2) + ff .* (ccal.ghij(3) + ff .* ccal.ghij(4)))) ./ (10 * (1 + ccal.ctpcor(1) .* temp + ccal.ctpcor(2) .* pres));
