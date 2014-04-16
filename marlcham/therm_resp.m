function out=therm_resp(power,freq,fcrit,filter)
% function out=therm_response(power,freq,fcrit)
% this function calculates the thermal response 
% from Rolf Leuck's 1977 paper....
%   fcrit=25;
%out=power.*(1+(freq./fcrit).^2);
% this used to be the following
% tau=0.035;
%out=power.*(1+(2*pi*tau*freq).^2).^2;
%
% 2 feb 2009 modified to use also double-pole filter
% (Cregg and Meagher, 1980)
% out=power.*(1+(freq./fcrit).^2).^2;
% filter==1 for single-pole (default)
% filter==2 for double-pole

% I changed this after doing the thermocouple paper...
if nargin==2
    fcrit=2;
    filter=1;
elseif nargin==3
    filter=1;
end
if length(fcrit)==1
    fcrit=[fcrit ; fcrit];
end
if filter==1
    out=power.*sqrt(1+(freq./fcrit(1)).^2).*sqrt(1+(freq./fcrit(2)).^2);
elseif filter==2
    out=power.*(1+(freq./fcrit(1)).^2).^2;
end
    
