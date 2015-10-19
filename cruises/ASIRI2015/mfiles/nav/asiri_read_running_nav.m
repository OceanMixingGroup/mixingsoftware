%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% asiri_read_running_nav.m
%
% Read R/V Revelle nav data for processing pipestring ADCP on Aug 2015
% ASIRI cruise. Started with script from 2014 cruise, from Emily Shroyer.
%
% 08/25/15 - A. Pickering - Modifying for Aug 2015 cruise
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear all; close all;
inda=1; indb=1;

%%% Set Directories
rootdir=['/Volumes/current_cruise/SerialInstruments/hydrins-navbho/'];
dataout=['/Volumes/scienceparty_share/data/'];
dataout_files=['/Volumes/scienceparty_share/nav/'];

Fnames=dir([rootdir '*.raw']);
Fnames_processed=dir([dataout_files '*.mat']);
%
filenames=[];
for i=1:length(Fnames)-1; % AP 09/11/15 - don't use last file, sometime its not complete and causes errors
    filenames{i}=char(Fnames(i).name(1:end-4));
end

% check which files are already processed
kp=ones(1,length(filenames));
for i=1:length(Fnames_processed);
    filenames_processed=char(Fnames_processed(i).name(1:end-4));
    if sum(strcmp(filenames_processed,filenames))==1;
        kp(i)=0;
    end
end
%%
ind=find(kp==1);
if isempty(ind);
    kp(end)=1;
elseif kp(1)==1
    kp=kp;
else
    kp(ind(1)-1)=1;
end

Fnames=Fnames(kp==1);
disp(['There are ' num2str(length(Fnames)) ' new nav files to process'])

%load([dataout '')
hb=waitbar(0,'Reading nav files');
for ifile=1:length(Fnames)
    waitbar(ifile/length(Fnames),hb)
    %%
    fid=fopen([rootdir Fnames(ifile).name]);
    A=Fnames(ifile).name; disp(['Reading ' A])
    year=str2num(A(16:19));
    month=str2num(A(20:21));
    dday=str2num(A(22:23));
    
    % loop through file
    %year=str2num(filename(1:4));
    %if strcmp(filename(5:7),'dec'); month=12;
    %elseif strcmp(filename(5:1),'nov'); month=11;
    %else; disp(['Bad MONTH!']); return; end
    %day=str2num(filename(8:9));
    %
    % now read the new files line by line
    keepgoing=1;
    whline=1; % save line# for debugging
    while keepgoing
        A=fscanf(fid,'%s',1);
        if isempty(A)
            keepgoing=0; %return
        else
            
            if length(A)>=6 % a few lines have only a few letters, skip these
                B=A(1:6);                
                
                if strcmp(B,'$PHGGA')
                    if length(A)>47
                        hour=str2num(A(8:9));
                        min=str2num(A(10:11));
                        sec=str2num(A(12:16));
                        N.dnum_ll(inda)=datenum(year,month,dday,hour,min,sec);
                        lat1=str2num(A(18:19));
                        lat2=str2num(A(20:30));
                        if numel(lat2)>1;lat2=lat2(1);end % AP 09/11/15
                        try
                        N.lat(inda)=lat1+lat2/60; 
                        catch
                            N.lat(inda)=nan;
                        end
                        hemisphere=A(32); if strcmp(hemisphere,'S'); lat(inda)=-lat(inda); end
                        lon1=str2num(A(34:36));
                        lon2=str2num(A(37:47));
                        if ~isempty(lon2)
                        N.lon(inda)=lon1+lon2/60;
                        end
                        inda=inda+1;
                    end
                elseif strcmp(B,'$PASHR')
                    if length(A)>38
                        hour=str2num(A(8:9));
                        min=str2num(A(10:11));
                        sec=str2num(A(12:17));
                        try
                        N.dnum_hpr(indb)=datenum(year,month,dday,hour,min,sec);
                        catch
                            N.dum_hpr(indb)=nan;
                        end
                        xx=A(19:26);
                        if strcmp(xx(8),'T')
                            N.head(indb)=str2num(A(19:24));
                            N.roll(indb)=str2num(A(28:32));
                            N.pitch(indb)=str2num(A(34:38));
                        elseif strcmp(xx(7),'T')
                            N.head(indb)=str2num(A(19:23));
                            N.roll(indb)=str2num(A(27:31));
                            N.pitch(indb)=str2num(A(33:37));
                        elseif strcmp(xx(6),'T')
                            N.head(indb)=str2num(A(19:22));
                            N.roll(indb)=str2num(A(26:30));
                            N.pitch(indb)=str2num(A(32:36));
                        end
                        indb=indb+1;
                    end
                end
            end % length(A)>6
            
        end
        whline=whline+1; %
    end
    %%
    % save each mat file here in case it crashes
    save([dataout_files  Fnames(ifile).name(1:end-4)],'N')
    clear N
    inda=1; indb=1;
end % ifile
delete(hb)

%% Now load and Cat files together %%%
disp('Loading and combining files')
Fnames=dir([dataout_files '*.mat']);
load([dataout_files Fnames(1).name]);
fnames=fieldnames(N);

N=[];
for i=1:length(fnames);
    eval(['N.' char(fnames(i)) '=[];']);
end

for m=1:length(Fnames);
    tmp=load([dataout_files Fnames(m).name]);
    tmp=tmp.N;
    
    for n=1:length(fnames)
        eval(['N.' char(fnames(n)) '=cat(2,N.' char(fnames(n)) ',tmp.' char(fnames(n)) ');']);
    end
end

%%% Correct Bad Values
ib=find(diff(N.dnum_hpr)>.5);
N.dnum_hpr(ib+1)=N.dnum_hpr(ib+1)-1; % datenum for heading, pitch and roll
ib=find(diff(N.dnum_ll)>.5);
N.dnum_ll(ib+1)=N.dnum_ll(ib+1)-1; % datenum for lat and lon
N.dnum_hpr(1)=N.dnum_hpr(1)-1;
N.dnum_ll(1)=N.dnum_ll(1)-1;


save([dataout  'nav_tot.mat'],'N')


%%