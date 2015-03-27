function [coef,out]=get_T_calibration(ref_time,ref_T,raw_time,raw_T)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function [coef,out]=get_T_calibration(ref_time,ref_T,raw_time,raw_T)
%
% Calibrate absoulte temperature from chipod using CTD temperature
% timeseries. Part of CTD_Chipod processing software.
%
% Fits a polynomial of form a+ bx + cx^2 + dx^3
%
% INPUT
% ref_time : Reference time
% ref_T    : Reference temperature
% raw_time : Raw time 
% raw_T    : Raw temperature (to be calibrated)
%
% OUTPUT
% coef : Coefficients of polynomial fit
% out  : The fit (ie the 'calibrated' temperature)
%
% Original - J. Nash?
% Commented and cleaned up 26 Mar 2015 - A. Pickering
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

raw_T_star=interp1(raw_time,raw_T,ref_time);

b=regress(ref_T,[ones(size(raw_T_star)) raw_T_star raw_T_star.^2 raw_T_star.^3]);

out=b(1)+raw_T*b(2)+raw_T.^2*b(3)+raw_T.^3*b(4);
coef=[b' 1];

%	plot(ref_time,ref_T,raw_time,out);

%%