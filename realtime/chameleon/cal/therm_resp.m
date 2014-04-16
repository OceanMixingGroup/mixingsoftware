function out=therm_resp(power,freq,fcrit,poles)
% function out=therm_response(power,freq,fcrit,poles)
% this function calculates the thermal response 
% this has been modified from Rolf Leuck's 1977 paper....
% It now lets one enter fcrit as a two element vector, so that
% there can be two cutoff frequencies.  It also allows for the
% number of poles to be specified.  Gregg and Meagher (1980) suggested a
% double pole filter; Lueck et al 1977 suggested a single pole.
% The defaults are fcrit=25Hz, poles=1;
% Another possibility if fcrit=35, poles=2; but these depend on
% profiling speed.  See Nash et al Nov 1999 (Jtech).  

if nargin==2
   fcrit=25;
   poles=1
end
if nargin==3
  poles=1;
end
if length(fcrit)==1
  fcrit=[fcrit ; fcrit];
end
out=power.*(sqrt(1+(freq./fcrit(1)).^2).*sqrt(1+(freq./fcrit(2)).^2)).^poles;

