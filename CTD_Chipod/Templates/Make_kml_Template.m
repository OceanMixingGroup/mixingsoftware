%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Make_kml_Template.m
%
% Writes a kml file with CTD cast locations for CTD-chipod cruises.
%
%----------------
% 09/16/16 - A.Pickering - andypicke@gmail.com
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; clc ; close all

%***
project='Template'

addpath(fullfile('/Users/Andy/Cruises_Research/ChiPod/',project,'mfiles'))

eval(['Load_chipod_paths_' project ])
%
load(fullfile(BaseDir,'Data','proc_info'))
%
kmlwrite(fullfile(BaseDir,'Data',[project 'kml']),proc_info.lat,proc_info.lon,'color','r')

%%