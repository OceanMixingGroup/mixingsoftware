function [cordepth,correction_area] = carter(lat,lon,uncdepth);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Function to apply Carter table correction to echosounder
% data that was collected assuming sound speed = 1500 m/s.
%
% Inputs are (latitude, longitude, uncorrected depth)
% Inputs should have South and East = -ve
% Inputs can be row or column arrays, but not matrices (function is
% designed for single-beam echosounder data)
%
% Uses lookup tables BOUNDARY2.DAT and CORRECTN2.DAT
%
% Outputs are corrected depth, and Carter correction area
% (Note that function returns correction_area = NaN if no correction
% is applied because input depth is <200m)
%
% Author: Mike Meredith, British Antarctic Survey, Dec 2005
%
% Stuck in ice onboard RRS James Clark Ross, off Adelaide Island, 
%   Antarctic Peninsula
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CHECK INPUTS

if nargin ~= 3
   error('Error: Must pass 3 parameters ')
end %if

% CHECK input dimensions and verify consistent
[mlat,nlat] = size(lat);
[mlon,nlon] = size(lon);
[mdepth,ndepth] = size(uncdepth);
  
if (mlat~=1 & nlat~=1) | (mlon~=1 & nlon~=1) | (mdepth~=1 & ndepth~=1)
    error('Error: must pass arrays not matrices');
end

% CHECK THAT INPUTS HAVE SAME LENGTH
slat = length(lat);
slon = length(lon);
sdepth = length(uncdepth);
if (slat~=slon) | (slat~=sdepth) | (slon~=sdepth)
   error('Error: inputs must have same lengths')
end %if

% open files containing area definitions and corrections
fid = fopen('BOUNDARY2.DAT');
fid2 = fopen('CORRECTN2.DAT');

%% main loop

for ii = 1:slat;
% Check that lats and lons are reasonable
if lat(ii)<-90 | lat(ii)>90 | lon(ii) < -180 | lon(ii) > 180;
    error('Error: Navigation out of range')
end; %if

% Check that inputs are not NaNs, and depth is in range of tables (will
% return NaN in first case, and will leave depth uncorrected in second)

if isnan(lat(ii)) ~= 1 & isnan(lon(ii)) ~= 1 & isnan(uncdepth(ii)) ~= 1 & uncdepth(ii) > 200;

% round down lat and lon
lat_use = floor(lat(ii));
lon_use = floor(lon(ii));

lat_file = 999;

% scan through file until find line with appropriate latitude
while lat_file ~= lat_use;

a = fgetl(fid);
b = str2num(a);

num_records = b(4);

if num_records <=9;
    a1 = fgetl(fid); b1 = str2num(a1);
    lon_file = b1(4:2:end);
    area = b1(5:2:end);
elseif num_records > 9 & num_records <= 18;
    a1 = fgetl(fid); b1 = str2num(a1);
    a2 = fgetl(fid); b2 = str2num(a2);
    lon_file = [b1(4:2:end) b2(4:2:end)];
    area = [b1(5:2:end) b2(5:2:end)]; 
elseif num_records > 18 & num_records <= 27;
    a1 = fgetl(fid); b1 = str2num(a1);
    a2 = fgetl(fid); b2 = str2num(a2);
    a3 = fgetl(fid); b3 = str2num(a3);
    lon_file = [b1(4:2:end) b2(4:2:end) b3(4:2:end)];
    area = [b1(5:2:end) b2(5:2:end) b3(5:2:end)]; 
elseif num_records > 27 & num_records <= 36;
    a1 = fgetl(fid); b1 = str2num(a1);
    a2 = fgetl(fid); b2 = str2num(a2);
    a3 = fgetl(fid); b3 = str2num(a3);
    a4 = fgetl(fid); b4 = str2num(a4);
    lon_file = [b1(4:2:end) b2(4:2:end) b3(4:2:end) b4(4:2:end)];
    area = [b1(5:2:end) b2(5:2:end) b3(5:2:end) b4(5:2:end)]; 
else;
    a1 = fgetl(fid); b1 = str2num(a1);
    a2 = fgetl(fid); b2 = str2num(a2);
    a3 = fgetl(fid); b3 = str2num(a3);
    a4 = fgetl(fid); b4 = str2num(a4);
    a5 = fgetl(fid); b5 = str2num(a5);
    lon_file = [b1(4:2:end) b2(4:2:end) b3(4:2:end) b4(4:2:end) b5(4:2:end)];
    area = [b1(5:2:end) b2(5:2:end) b3(5:2:end) b4(5:2:end) b5(5:2:end)];
end; % if num_records

lat_file = b(2);
end; % while


% now scan through longitudes to find correction area

for i = 1:length(lon_file)-1;
    if lon_use >= lon_file(i) & lon_use < lon_file(i+1);
        correction_area(ii) = area(i);
    elseif lon_use > lon_file(end);
        correction_area(ii) = area(end); % if is on last record in group
    end;
end;

frewind(fid);

% now read corrections table to find corrected depth

area_file = 999;

% scan through file until find line with appropriate latitude
while area_file ~= correction_area(ii);

a = fgetl(fid2);
b = str2num(a);

area_file = b(2);
num_records = b(4);

if num_records <=12;
    a1 = fgetl(fid2); b1 = str2num(a1);
    data = b1(4:end);
elseif num_records > 12 & num_records <= 24;
    a1 = fgetl(fid2); b1 = str2num(a1);
    a2 = fgetl(fid2); b2 = str2num(a2);
    data = [b1(4:end) b2(4:end)]; 
elseif num_records > 24 & num_records <= 36;
    a1 = fgetl(fid2); b1 = str2num(a1);
    a2 = fgetl(fid2); b2 = str2num(a2);
    a3 = fgetl(fid2); b3 = str2num(a3);
    data = [b1(4:end) b2(4:end) b3(4:end)]; 
elseif num_records > 36 & num_records <= 48;
    a1 = fgetl(fid2); b1 = str2num(a1);
    a2 = fgetl(fid2); b2 = str2num(a2);
    a3 = fgetl(fid2); b3 = str2num(a3);
    a4 = fgetl(fid2); b4 = str2num(a4);
    data = [b1(4:end) b2(4:end) b3(4:end) b4(4:end)]; 
elseif num_records > 48 & num_records <= 60;
    a1 = fgetl(fid2); b1 = str2num(a1);
    a2 = fgetl(fid2); b2 = str2num(a2);
    a3 = fgetl(fid2); b3 = str2num(a3);
    a4 = fgetl(fid2); b4 = str2num(a4);
    a5 = fgetl(fid2); b5 = str2num(a5);
    data = [b1(4:end) b2(4:end) b3(4:end) b4(4:end) b5(4:end)]; 
elseif num_records > 60 & num_records <= 72;
    a1 = fgetl(fid2); b1 = str2num(a1);
    a2 = fgetl(fid2); b2 = str2num(a2);
    a3 = fgetl(fid2); b3 = str2num(a3);
    a4 = fgetl(fid2); b4 = str2num(a4);
    a5 = fgetl(fid2); b5 = str2num(a5);
    a6 = fgetl(fid2); b6 = str2num(a6);
    data = [b1(4:end) b2(4:end) b3(4:end) b4(4:end) b5(4:end) b6(4:end)]; 
elseif num_records > 72 & num_records <= 84;
    a1 = fgetl(fid2); b1 = str2num(a1);
    a2 = fgetl(fid2); b2 = str2num(a2);
    a3 = fgetl(fid2); b3 = str2num(a3);
    a4 = fgetl(fid2); b4 = str2num(a4);
    a5 = fgetl(fid2); b5 = str2num(a5);
    a6 = fgetl(fid2); b6 = str2num(a6);
    a7 = fgetl(fid2); b7 = str2num(a7);
    data = [b1(4:end) b2(4:end) b3(4:end) b4(4:end) b5(4:end) b6(4:end) b7(4:end)];
elseif num_records > 84 & num_records <= 96;
    a1 = fgetl(fid2); b1 = str2num(a1);
    a2 = fgetl(fid2); b2 = str2num(a2);
    a3 = fgetl(fid2); b3 = str2num(a3);
    a4 = fgetl(fid2); b4 = str2num(a4);
    a5 = fgetl(fid2); b5 = str2num(a5);
    a6 = fgetl(fid2); b6 = str2num(a6);
    a7 = fgetl(fid2); b7 = str2num(a7);
    a8 = fgetl(fid2); b8 = str2num(a8);
    data = [b1(4:end) b2(4:end) b3(4:end) b4(4:end) b5(4:end) b6(4:end) b7(4:end) b8(4:end)];
elseif num_records > 96 & num_records <= 108;
    a1 = fgetl(fid2); b1 = str2num(a1);
    a2 = fgetl(fid2); b2 = str2num(a2);
    a3 = fgetl(fid2); b3 = str2num(a3);
    a4 = fgetl(fid2); b4 = str2num(a4);
    a5 = fgetl(fid2); b5 = str2num(a5);
    a6 = fgetl(fid2); b6 = str2num(a6);
    a7 = fgetl(fid2); b7 = str2num(a7);
    a8 = fgetl(fid2); b8 = str2num(a8);
    a9 = fgetl(fid2); b9 = str2num(a9);
    data = [b1(4:end) b2(4:end) b3(4:end) b4(4:end) b5(4:end) b6(4:end) b7(4:end) b8(4:end) b9(4:end)];
else;  % for num_records > 108
    a1 = fgetl(fid2); b1 = str2num(a1);
    a2 = fgetl(fid2); b2 = str2num(a2);
    a3 = fgetl(fid2); b3 = str2num(a3);
    a4 = fgetl(fid2); b4 = str2num(a4);
    a5 = fgetl(fid2); b5 = str2num(a5);
    a6 = fgetl(fid2); b6 = str2num(a6);
    a7 = fgetl(fid2); b7 = str2num(a7);
    a8 = fgetl(fid2); b8 = str2num(a8);
    a9 = fgetl(fid2); b9 = str2num(a9);
    a10 = fgetl(fid2); b10 = str2num(a10);
    data = [b1(4:end) b2(4:end) b3(4:end) b4(4:end) b5(4:end) b6(4:end) b7(4:end) b8(4:end) b9(4:end) b10(4:end)];
end; % if num_records

end; % while

uncdepth_file = 200:100:10000;
uncdepth_file = uncdepth_file(1:length(data));

for i = 1:length(data)-1;
    if uncdepth(ii) >= uncdepth_file(i) & uncdepth(ii) < uncdepth_file(i+1);
        cordepth_high = data(i+1);
        cordepth_low = data(i);
        uncdepth_low = uncdepth_file(i);
    end;
end;

% now linearly interpolate to find corrected depth

offset = uncdepth(ii) - uncdepth_low;
cordepth(ii) = cordepth_low + ((cordepth_high-cordepth_low)*offset)./100;

frewind(fid2);

else;  % (if one of inputs is NaN or depth < 200)
    
cordepth(ii) = uncdepth(ii); 
correction_area(ii) = NaN;

end; %(if one of inputs is NaN or depth < 200)

end; % ii, main loop

fclose(fid);
fclose(fid2);

return;
