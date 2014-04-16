function [yday,t0] = datenum2yday(daten,year);
% function yday = datenum2yday(datein);
% 
%  Get the yday.  0.5 => noon Jan 1.
%
%  yday = datenum2yday(datein,year) references the date to year.
%
if nargin<2
  year=[];
end;
if isempty(year)
  year = str2num(datestr(daten(1),10));
end;

t0 = datenum(year,1,1,0,0,0);
yday = daten-t0;
  
