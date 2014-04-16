function process_tao_data(datadir,var)
% process_tao_data.m
% var is variable name 
% could be either 'adcp','bp','cur','d','met','rad',
% 'rain','lw','s' or 't'
% 'met' data includes wind, airt, sst & rel. humidity data
% so it is not necessary to download these files separately from TAO web
% site

d=dir([datadir var '*.ascii']);
for i=1:length(d)
    eval(['read_tao_' var '([datadir d(i).name]);']);
    eval(['make_one_array_' var '([datadir d(i).name(1:end-6) ''.mat'']);']);
end
