function [out]=invert_filt(freq,spec,n_order,f_cut)
% invert_filt applies the correction from an n_order butterworth filter with
% cut-off frequency at f_cut usinq data vector spec at frequencies freq.
% This was the routine before february 24, 1998, but I think it is wrong and
% should be replaced by the thing below ref. Horowitz and Hill pg 269.
% out=spec.*sqrt(1+(freq./f_cut).^(2*n_order));
out=spec.*(1+(freq./f_cut).^(2*n_order));