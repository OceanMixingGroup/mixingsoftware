%~~~~~~~~~~~~~~~~~~~~~~~~~
%
% SetPathsAsiri_AP.m
%
% Set paths for post-cruise ASIRI processing, for Andy's computer.
%
% For post-cruise processing, m-files are being copied form
% scienceparty_share to a github repository. All m-files are being modified
% with more general paths so that only this file needs to be changed
% depending on where data is archived.
%
%
%
%-------------
% 10/20/15 - AP - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~
%%

% Path for *data* on scienceparty_share ; eventually this data will be
% archived on tbd server(s). This can be modified to point to the copy of
% data that you are working with. All paths in m-files should be made
% relative to this.
SciencePath='/Volumes/Midge/ExtraBackup/scienceshare_092015/'

% Path for *m-files* (github repo) that you cloned to your computer. Going
% forward, any standard processing ('raw' to 'processed') of cruise data
% should be done using files from this repository so we have a standard,documented set of codes.
MfilePath='/Users/Andy/Cruises_Research/mixingsoftware/cruises/ASIRI2015/mfiles/'


%%