function temp = freq2temp(freq,tcal)
%function temp = freq2temp(freq,cfg) calculates  temperature given
%frequency and  temperature calibration structure tcal
%

%D. Rudnick 01/06/05

logf0f = log(tcal.f0 ./ freq);

temp = (1 ./ (tcal.ghij(1) + logf0f .* (tcal.ghij(2) + logf0f .* (tcal.ghij(3) + logf0f .* tcal.ghij(4))))) - 273.15;
