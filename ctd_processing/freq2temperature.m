  function temp = freq2temperature(f, tcal)
% function temp = freq2temperature(f, tcal) 
% calculates temperature given frequency and calibration structure tcal

f = log(tcal.f0./f);
temp = 1./(tcal.ghij(1) + f.*tcal.ghij(2) + f.^2.*tcal.ghij(3) + f.^3.*tcal.ghij(4)) - 273.15;
