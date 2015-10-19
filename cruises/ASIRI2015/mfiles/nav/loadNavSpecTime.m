function Ntot=loadNavSpecTime(time_range)
%~~~~~~~~~~~~~~~~~~~~~~~~~
%
% N=loadNavSpecTime(time_range)
%
% Load Revelle nav data (pitch,roll,head,lat,lon) for a specified
% time range, for use in ADCP processing (or whatever else you want).
% Originally we were loading the big combined file for entire
% cruise, but as the cruise goes on it is getting too big and slow to load
% every time...
%
% Daily nav files are made with asiri_read_running_nav.m (in pipestring
% processing folder) and saved in /scienceparty_share/nav
%
% INPUT:
% time_range : time range [begin end] in datenum
%
% OUTPUT:
% N : structure with Nav data covering this time range
%
% 09/18/15 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~
%%

% get list of all the daily nav files we have so far

navdir=fullfile(SciencePath,'nav');
Flist=dir([navdir '*.mat']);

Ntot.head=[];
Ntot.pitch=[];
Ntot.roll=[];
Ntot.dnum_hpr=[];
Ntot.dnum_ll=[];
Ntot.lon=[];
Ntot.lat=[];

for ifile=1:length(Flist)
    clear N fname
    fname=Flist(ifile).name;
    id1=strfind(fname,'bho_');
    id2=strfind(fname,'.mat');
    timestamp=fname(id1+4 : id2-1);
    %%
    
    yr=timestamp(1:4);
    month=timestamp(5:6);
    day=timestamp(7:8);
    dnumf=datenum(str2num(yr),str2num(month),str2num(day));
    % each file is 24 hours long
    if (dnumf+1)>=time_range(1) && dnumf<time_range(2)
   fname
        load(fullfile(navdir,fname))
    
%     if 
     Ntot.head=[Ntot.head N.head];
     Ntot.pitch=[Ntot.pitch N.pitch];
     Ntot.roll=[Ntot.roll N.roll];
     Ntot.dnum_hpr=[Ntot.dnum_hpr N.dnum_hpr];
     Ntot.dnum_ll=[Ntot.dnum_ll N.dnum_ll];
     Ntot.lon=[Ntot.lon N.lon];
     Ntot.lat=[Ntot.lat N.lat];
     end
end



%return
%%
