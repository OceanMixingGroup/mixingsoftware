% make_ctd_oceanus
%
% This code reads in the raw CTD data and converts it to a .mat file using
% the function read_ctd_oceanus.
%
% Note: before this is run, you must use SeaBird's software Sea-Save to
% create a .cnv file from the .hex file that is saved by the ship's
% computer in ttwo.
%
% Orignially written by Sasha Perlin
% Updated and commented by Sally Warner, January 2014


clear all; fclose all;% close all;

%%%% 
% change the profile number each time you want to analyze a ctd cast
profile=5;
%%%%

% manually move the raw files from the ship's server to my computer and
% write the path of that directory here
% datapath='e:\work\Alaska12\ctd\raw\';
% datapath = '~/ganges/work/aperlin/Alaska12/current/ctd/raw/';
datapath = '/Volumes/ttwo_cruises/current/ctd/';

d=dir([datapath '*' sprintf('%02d',profile) '.cnv']);
fname=[datapath d.name]; 
ctd=read_ctd_oceanus(fname);
bad=find(ctd.depth<0);
ctd.depth(bad)=NaN;
% save(['e:\work\Alaska12\ctd\mat\' sprintf('CTD%02d',profile)],'ctd')
% save(['~/work/RESEARCH/shipboard_realtime_data/Alaska12/ctd/mat/' ...
%     sprintf('CTD%02d',profile)],'ctd')

save(['~/data/yq14/ctd/mat/' sprintf('CTD%02d',profile)],'ctd')