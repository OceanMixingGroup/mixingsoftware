function make_ctd_chipod_folders(basedir,project)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Make empty directory for a CTD-chipod project. If folders already exist,
% will not overwrite.
%
% INPUT
%   - basedir (ex: '/Users/Andy/Cruises_Research/ChiPod/')
%   - project (ex: '26N')
%
% OUTPUT
%   -Makes standard folder structure for CTD-chipod project
%
% Dependencies:
%   ChkMkDir.m
%
%-----------
% 09/12/16 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

fullbase=fullfile( basedir, project)

ChkMkDir( fullfile(fullbase,'Data','proc','chipod') )
ChkMkDir( fullfile(fullbase,'Data','proc','ctd') )

ChkMkDir( fullfile(fullbase,'Data','raw','chipod') )
ChkMkDir( fullfile(fullbase,'Data','raw','ctd') )

ChkMkDir( fullfile(fullbase,'Notes') )
ChkMkDir( fullfile(fullbase,'Figures') )
ChkMkDir( fullfile(fullbase,'mfiles') )

%%