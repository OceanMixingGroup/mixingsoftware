%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Make_kml_Template.m
%
%----------------
% 09/16/16 - A.Pickering - andypicke@gmail.com
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; clc ; close all

project='P15S'

addpath(fullfile('/Users/Andy/Cruises_Research/ChiPod/',project,'mfiles'))

eval(['Load_chipod_paths_' project ])
%
load(fullfile(BaseDir,'mfiles','proc_info'))
%
kmlwrite(fullfile(BaseDir,'Data',[project 'kml']),proc_info.lat,proc_info.lon,'color','r')

%%