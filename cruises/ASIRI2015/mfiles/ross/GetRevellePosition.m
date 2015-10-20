function [time lat lon]=GetRevellePosition
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Get recent Revelle position from the Met data
%
%
% 08/24/15 - A.Pickering 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

load('/Volumes/scienceparty_share/data/combined_met.mat')

lat=data.lon(end);
lon=data.lat(end);
time=data.dnum(end);

disp(['Ship position at ' datestr(time) ' is ' num2str(lon) ' E ,' num2str(lat) ' N'])

%%