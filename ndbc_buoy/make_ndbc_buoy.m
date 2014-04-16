% make_ndbc_buoy.m
% define input parameters of the data: path, year, station #
dpath='C:\work\ndbc_buoy\data\ney_jersey\';
year=2007;
station_id='44009';
%% read and process the data
met=read_NDBCbuoy_meteo([dpath station_id '\'],station_id,year);
wind=read_NDBCbuoy_wind([dpath station_id '\'],station_id,year);
% spwvdens=read_NDBCbuoy_spwvdens(dpath,station_number,year);
% spwvdir=read_NDBCbuoy_spwvdir(dpath,station_number,year);
%% save mat files
save([[dpath station_id '\'] 'ndbc' station_id '_' num2str(year)],...
'met','wind');
% save([[dpath station_id '\'] 'ndbc' station_id '_' num2str(year)],...
% 'met','wind','spwvdens','spwvdir');
