%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% FindPipestringTimeOffset_Asiri15.m
%
% Find time offset for 300kHz pipestring ADCP on Aug 2015 Revelle ASIRI
% cruise.
%
% Results in a linear fit to time-offset, which is save in
% time_offset_fit.mat and used to calculate time offset for each file
% in loadsaveENR.m
%
%---------------
% 09/19/15 - A.Pickering - apickering@coas.oregonstate.edu
% 10/21/15 - AP - Update paths for post-cruise processing
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

% load nav data with ship heading and time (the 'true' values)
%load('/Volumes/scienceparty_share/data/nav_tot.mat')
load(fullfile(SciencePath,'data','nav_tot.mat'))

%
%datadir='/Volumes/scienceparty_share/pipestring/mat/'
datadir=fullfile(SciencePath,'pipestring','mat')
Flist=dir(datadir)

tm=nan*ones(1,length(Flist));
time_off=nan*ones(1,length(Flist));
% loop though each file and compute time offset
for ifile=3:length(Flist)
    %
    clear adcp
    load(fullfile(datadir,Flist(ifile).name))
        
    clear D1 D2 id
    D1=datetime(N.dnum_hpr,'ConvertFrom','datenum');
    D2=datetime(adcp.mtime,'ConvertFrom','datenum');
    id=isin(N.dnum_hpr,[nanmin(adcp.mtime)-0/24 nanmax(adcp.mtime)+0/24]);
    
    t1=N.dnum_hpr(id);
    x1=N.head(id);
    ip=find(x1<0);x1(ip)=x1(ip)+360;
    
    t2=adcp.mtime;
    x2=adcp.heading;
    ip=find(x2<0);x2(ip)=x2(ip)+360;
    
    % fcut=200*24;
    % x1low=MyLowpass(t1,x1,4,fcut);
    % x2low=MyLowpass(t2,x2,4,fcut);
    
    %h1r=(N.head(id) )*pi/180;
    %h1r=(x1low-nanmean(x1low) )*pi/180;
    h1r=(N.head(id)-nanmean(N.head(id)) )*pi/180;
    h1ru=unwrap(h1r);
    
    %h2r=( adcp.heading ) *pi/180;
    %h2r=(x2low-nanmean(x2low))*pi/180;
    h2r=( adcp.heading-nanmean(adcp.heading) ) *pi/180;
    h2ru=unwrap(h2r);
    %
    % figure(23);clf
    % plot(D1(id),h1ru)
    % hold on
    % plot(D1(id),h1r)
    % plot(D2,h2r,D2,h2ru)
    
    % q1=MyLowpass(t1,h1ru,4,fcut);
    % q2=MyLowpass(t2,h2ru,4,fcut);
    
    % figure(24);clf
    % plot(D1(id),h1ru-nanmean(h1ru))
    % hold on
    % %plot(D1(id),h1r-nanmean(h1r))
    % %plot(D2,h2r)
    % plot(D2,h2ru-nanmean(h2ru))
    
    %delt3=TimeOffset_ap(N.dnum_hpr(id),h1ru,adcp.mtime,h2ru)
    try
        delt3=TimeOffset_ap(N.dnum_hpr(id),h1ru,adcp.mtime,h2ru);
        %delt3*86400;
        time_off(ifile)=delt3*86400;
    catch
    end
    
    tm(ifile)=nanmean(t2);
    
end

%% TimeOffset_ap works for most files, but there are some where it doesn't. 
% I eliminate outliers and fit to the obvious linear trend in offsets.

tm(tm<datenum(2015,8,15))=nan;
dt=diffs(time_off);
ib=find(abs(dt)>3);
hold on
%inds=1:ifile;

figure(2);clf
ax1=subplot(211)
plot(tm,time_off)
hold on
t2=time_off;t2(ib)=nan;
ib2=find(dt==0);
t2(ib2)=nan;
plot(tm,t2,'o')

ig=find(~isnan(t2));

% fit time offsets as a linear function of ADCP time
P=polyfit(tm(ig),t2(ig),1);
Y=polyval(P,tm);
plot(tm,Y,'m')
ylim([-700 500])
datetick('x')

ax2=subplot(212)
plot(tm,dt,'.')
hold on
plot(tm(ib),dt(ib),'o')
datetick('x')

linkaxes([ax1 ax2],'x')

%%

%save('/Volumes/scienceparty_share/pipestring/time_offset_fit','P')
save(fullfile(SciencePath,'pipestring','time_offset_fit'),'P')

%%