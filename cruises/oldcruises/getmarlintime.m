function starttime = getmarlinstarttime(yr,ydayoffset);
% function time = getmarlintime(year,ydayoffset);
%
% Assumes that there is a global variable head from which to get
% head.time and head.saildata.  The argument year is necessary
% because it is not supplied by the Marlin data stream....
  
  
if nargin<0
  error('You must specify a year.');
end;
if nargin<1
  ydayoffset=0;
end;

% get the "precise" time from the saildata string.  
hr = str2num(head.saildata(1:2));
mint = str2num(head.saildata(3:4));
sec = str2num(head.saildata(5:10));

% get the yearday  
day=str2num(head.starttime(15:17))-1; % the saildata is off by one day...
start_time=datenum(yr,1,1,hr,mint,sec)+day;
