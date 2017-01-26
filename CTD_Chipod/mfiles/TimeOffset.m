function delt=TimeOffset(t1,x1,t2,x2);
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function delt=TimeOffset(t1,x1,t2,x2);
%
% Part of CTD-chipod processing
%
% Finds the time offset (in units of t1/t2 between two time series using
% the xcovariance.
% Interpolates onto t2, offset needs to be subtracted from t1.  %%%
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

h = fdesign.bandpass('N,F3dB1,F3dB2',6,0.1,1,1./nanmean(diff(t1*86400)));
d = design(h,'butter');
y1 = filtfilt(d.sosMatrix,d.ScaleValues,x1);

clear h d
h = fdesign.bandpass('N,F3dB1,F3dB2',6,0.1,1,1./nanmean(diff(t2*86400)));
d = design(h,'butter');
y2 = filtfilt(d.sosMatrix,d.ScaleValues,x2);
%
y1=interp1(t1,y1,t2);
    
xx=y1(~isnan(y1+y2)); xx=xx-nanmean(xx);
yy=y2(~isnan(y1+y2)); yy=yy-nanmean(yy);
    
%%% Time Offset %%%
[C,lag]=xcov(xx',yy',round(600./nanmean(diff(t2*86400))),'unbiased');
lag=lag(C==max(C));
    
delt=lag*nanmean(diff(t2));

%%
