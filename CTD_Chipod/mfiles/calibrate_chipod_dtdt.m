function out = calibrate_chipod_dtdt(tp, coeff_tp, t, coeff_t)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function out=calibrate_tp(tp,coeff_tp,t,coeff_t)
%
% This function does a polynomial calibration on the
% vector tp with time constant given in coeff_tp, dc time series
% given in t, and polynomial coefficients for t given by coeff_t
%
% INPUT
% tp       : Chipod TP (temperature derivative)
% coeff_tp : Time constant for chipod TP (specified in 'cal' field of chipod data during processing)
% t        : Chipod temperature (T)
% coeff_t  : Fit coefficents for t (from get_T_calibration.m)
%
% OUTPUT
% out      : The calibrated TP
%
%------------------
% Original - J. Nash?
% Commented and cleaned up 11 June 2015 - A. Pickering
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

if size(t,2)==2
    t=ch(t);
end
if size(tp,2)==2
    tp=ch(tp);
end

ltp=length(tp);
t=makelen(t,ltp);
warning off
tp=tp-nanmedian(tp);
out=-(coeff_t(2)+2*coeff_t(3)*t+3*coeff_t(4)*t.^2).*tp ...
    ./coeff_tp;

%out=coeff_t(2).*tp./coeff_tp;

warning on
%%