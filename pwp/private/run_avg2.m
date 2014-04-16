%run_avg2(data,N,dim) calculates an N-day running average of hourly data by convolving with a rectangular window.  
%                       The output is of the same length as the input so that the averaged
%                       data can be used with the original time vector and compared against 
%                       other (potentially un-averaged) quantities from the same dataset.
%                       Old version could work around NaNs, but this one can't. 
%                       2003, Tom Farrar, tomf@mit.edu






%Slow old version
%run_avg(data,N) calculates an N-day running average of hourly data.  
%                       The output is of the same length as the input so that the averaged
%                       data can be used with the original time vector and compared against 
%                       other (potentially un-averaged quantities) from the same dataset.
%                       Note that NaNs are put in the first and last N/2 slots, and that NaNs
%                       are acceptable in the input.  This routine is slow, but effective.  
%                       I recommend running it once in a data processing routine rather than
%                       computing the average repeatedly.  Calls nanmean.m.
%
%                       2001, Tom Farrar, tomf@mit.edu

function [swav]=run_avg2(srad,N,dim)


M=N*24;
win=ones(M,1)./M;
[m,n]=size(srad);
if dim==2
  swav=conv2(1,win,srad,'same');
elseif dim==1
  swav=conv2(win,1,srad,'same');
elseif display('run_avg2.m can only operate on 2D arrays!')
  %break
end


