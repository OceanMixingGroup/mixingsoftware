%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% process_pipestring.m
%
% Process pipestring ADCP data for Aug 2015 ASIRI cruise.
%
% *Need to run loadsaveENR.m and asiri_read_running_nav.m first*
%
% Loads nav and ADCP mat files, transforms to earth coordinates, removes
% ship velocity, does ~1min averaging. Final data saved in structure 'P'
%
% Started with script from 2014 cruise, which I got from Emily Shroyer.
%
%----------
% History
%-----------------------------------
% 08/25/2015 - A. Pickering - Modifying for Aug 2015 cruise
% 09/12/2015 - AP - Added constant time offset to ADCP data (estimated by
%           lining up ADCP heading with ship heading). In next round, should find
%           offset for each file, as it probably drifts over time.
% 09/13/2015 - AP - Use a varying time-offset
% 09/19/2015 - AP - beam-to-earth now done already for each file in
% loadsaveENR .
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

% save 1min data at end
savedata=1

% option to estimate heading offset; if not specify head_offset
est_head_offset=0; head_offset=85.5

%%% Set Path to mat files
dir0='/Volumes/scienceparty_share/pipestring/mat/';

% get list of mat files (beam velocity), made in loadsaveENR.m
files = dir([dir0 '*beam.mat']);
%
%%% initialize variables
A=struct()
A.dnum=[];
A.pitch=[];
A.roll=[];
A.heading=[];
A.vel1=[];
A.vel2=[]
%
%%% load in all the adcp data

% file 1 has different # of bins? just skip it
for ifile=2:length(files)
    %
    fname_beam=files(ifile).name
    fname_earth=[fname_beam(1:end-8) 'earth.mat']
    clear adcp xadcp nadcp
    if exist(fullfile(dir0,fname_beam),'file')==2 & exist(fullfile(dir0,fname_earth),'file')==2
        
        disp(['loading ' fname_beam])
        load(fullfile(dir0,fname_beam))
        
        disp(['loading ' fname_earth])
        load(fullfile(dir0,fname_earth))
        %
        disp(['File spans ' datestr(nanmin(adcp.mtime)) ' to ' datestr(nanmax(adcp.mtime))])
        
        A.dnum=[A.dnum adcp.mtime];
        A.ranges=adcp.config.ranges;
        A.heading=[A.heading xadcp.heading];
        A.pitch=[A.pitch xadcp.pitch];
        A.roll=[A.roll xadcp.roll];
        A.vel1=[A.vel1 nadcp.vel1]; % *rotated velocity*
        A.vel2=[A.vel2 nadcp.vel2]; % *rotated velocity*
        A.Info='head/pitch/roll from ship nav';
        
    end
end
%%

% fix any bad values in time vector
% adcp.dnum(adcp.dnum<datenum(2015,0,0))=nan;
% ind=1:length(adcp.dnum);
% adcp.dnum=interp1(ind(~isnan(adcp.dnum)),adcp.dnum(~isnan(adcp.dnum)),ind,'linear','extrap');

%%
%%% load in nav data
load('/Volumes/scienceparty_share/data/nav_tot.mat')

%%%  calculate ship velocity
dydt=diff(N.lat)*111.18e3./(diff(N.dnum_ll)*24*3600);
dxdt=diff(N.lon)*111.18e3./(diff(N.dnum_ll)*24*3600).*cos(N.lat(1:end-1)*pi/180);
uship=interp1(N.dnum_ll(1:end-1)+diff(N.dnum_ll)/2,dxdt,A.dnum);
vship=interp1(N.dnum_ll(1:end-1)+diff(N.dnum_ll)/2,dydt,A.dnum);

%
% plot ship velocity to check we are reading it right...
figure(1);clf

subplot(211)
plot(A.dnum,uship)
ylim(3*[-1 1])
grid on
datetick('x')
gridxy
title('u ship')

subplot(212)
plot(A.dnum,vship)
ylim(3*[-1 1])
title('v ship')
grid on
datetick('x')
gridxy
xlabel(['Time on ' datestr(floor(A.dnum(1)))])

%% testing to find heading offset = difference between instrument and ship


if est_head_offset==1
    %
    clear uv theta
    uv=nanmean(A.vel1(1:15,:))+1i*nanmean(A.vel2(1:15,:));
    theta=[0:1:360];
    
    % compare absolute adcp velocity over upper 30m to ship velocity? if
    % ship is moving these should be about equal? (AP)
    for ith=1:length(theta)
        test1(ith)=nanmean(abs((uv*exp(1i*pi*theta(ith)/180)+(uship+1i*vship))).^2);
    end
    
    %
    figure(2);clf
    plot(theta,test1)
    hold on
    [val,I]=nanmin(test1)
    plot(theta(I),test1(I),'o')
    %    theta(I)
    head_offset=theta(I)
    
else
    disp(['Using head offset of ' num2str(head_offset) ' deg '])
end

%% Fix depth:
% depth up to this point is RANGE! (d'oh! why did this take me so long to realize!)
%A.z=A0.z*cos(20*pi/180); % 20 deg = beam angle
A.z=A.ranges*cos(20*pi/180);

%%% add depth offset for depth of instrument!
mount_depth=4;  %%% Need to check!!!
A.z=A.z+mount_depth;
%A0.z=A0.z+dz;

%%
% conclusion for Aug 2015 cruise - head_offset~=85.5?

clear uv u0 v0
uv=A.vel1+1i*A.vel2;
u0=real(uv*exp(1i*pi*head_offset/180));
v0=imag(uv*exp(1i*pi*head_offset/180));

clear nadcp

% add ship velocity to get absolute water velcoity
A.u=u0+repmat(uship',1,size(A.z,1))';
A.v=v0+repmat(vship',1,size(A.z,1))';

%%

% figure(3);clf
%
% subplot(211)
% ezpc(A.dnum,A.z,A.u)
% caxis(0.6*[-1 1])
% datetick('x')
% colorbar
%
% subplot(212)
% ezpc(A.dnum,A.z,A.v)
% caxis(0.6*[-1 1])
% colorbar
%%

% i'm missing smooth2a (AP)
% flag=find(smooth2a(squeeze(nanmean(adcp.corr,2)),3,11)<95);
% A.u(flag)=nan;
% A.v(flag)=nan;

% data only good for the first 60 m or so down
% A.u=A.u(1:26,:); A.v=A.v(1:26,:);
% A.z=adcp.z(1:26);

%%% smooth a bit in time
a=1; b=ones(1,60)/60;
Af.dnum=nanmin(A.dnum):1/60/24:nanmax(A.dnum);
Af.z=A.z;
Af.u=NaN*ones(length(A.z),length(Af.dnum)); Af.v=Af.u; Af.corr=Af.u;
%
ig=find(diff(A.dnum)>0);
%corr=nanmean(adcp.corr,2);
for iz=1:length(A.z);
    Af.u(iz,:)=interp1(A.dnum(ig),nanfilt(b,a,despike(A.u(iz,ig))),Af.dnum);
    Af.v(iz,:)=interp1(A.dnum(ig),nanfilt(b,a,despike(A.v(iz,ig))),Af.dnum);
    %Af.corr(iz,:)=interp1(A.dnum(ig),nanfilt(b,a,despike(corr(iz,ig))),Af.dnum);
end


%%
%flag=find(Af.corr<95 | abs(Af.u)>.75 | abs(Af.v)>.75);
% edit out data with low correlation
%flag=find(Af.corr<95 | abs(Af.u)>1.5 | abs(Af.v)>1.5 ) ;% AP 08/25/15 ;
flag=find( abs(Af.u)>1.5 | abs(Af.v)>1.5 ) ;% AP 08/25/15 ;

Af.u(flag)=nan;
Af.v(flag)=nan;


%% data below 60m is bad
ibz=find(A.z>60);
Af.u(ibz,:)=nan;
Af.v(ibz,:)=nan;
%%
close all
figure(4);clf

subplot(211)
ezpc(Af.dnum,Af.z,Af.u)
caxis(0.6*[-1 1])
datetick('x')
colorbar

subplot(212)
ezpc(Af.dnum,Af.z,Af.v)
caxis(0.6*[-1 1])
datetick('x')
colorbar

addpath('/Volumes/scienceparty_share/mfiles/shared/cbrewer/cbrewer/')
%cmap=cbrewer('div','RdBu',15);
%colormap(flipud(cmap))
colormap(bluered)
%%
screenheadings=0
if screenheadings==1
    %%% doesn't do well when ship changing heading
    % blank out a bit on either side of quick heading changes
    a=1; b=ones(1,60)/60;
    ig=find(diff(A.dnum)>0);
    headf=interp1(A.dnum(ig),nanfilt(b,a,xadcp.heading(ig)),Af.dnum);
    ib=find(abs(diff(headf/mean(diff(Af.dnum))/24/3600))>0.15);
    ibad=3; % # minutes on either side to blank out
    for iib=1:length(ib)
        inan=(ib(iib)-ibad):(ib(iib)+ibad);
        Af.u(:,inan)=NaN; Af.v(:,inan)=NaN;
    end
    Af.u=Af.u(:,1:length(Af.dnum));
    Af.v=Af.v(:,1:length(Af.dnum));
    %
    % % AP 08/27/15 - comment out below. interp through big gaps doesn't work
    % well, just leave bad data nanned out for now
    % % now interpolate back in
    % for iz=1:length(Af.z)
    %     ig=find(~isnan(Af.u(iz,:)));
    %     if ~isempty(ig) & length(ig)>1
    %         Af.u(iz,:)=interp1(Af.dnum(ig),Af.u(iz,ig),Af.dnum);
    %         Af.v(iz,:)=interp1(Af.dnum(ig),Af.v(iz,ig),Af.dnum);
    %     end
    % end
    
end

%% Nan some bad periods manually

% period when ship was going at full speed and data is bad
%idb=isin(Af.dnum,[datenum(2015,8,27,13,42,0) datenum(2015,8,28,2,53,0)]);
%Af.u(:,idb)=nan;
%Af.v(:,idb)=nan;
%%
%%% change variable names for silly reasons
A0=A;clear A
%A=Af;
P=Af; clear Af
%%% change variable name again, cuz why not?
% here I'm using "P" for pipestring data, "V" for the sentinel V data, "H"
% for the HDSS data, and "S" for the shipboard adcp files, so I can load
% them all in together and not have them all have the same variable name
%P=A;

%% AP - add lat and lon to adcp
clear idg
idg=find( diff(N.dnum_ll)>0);%~=0 & diff(N.dnum_ll))~=0;
P.lat=interp1(N.dnum_ll(idg+1),N.lat(idg+1),P.dnum);
P.lon=interp1(N.dnum_ll(idg+1),N.lon(idg+1),P.dnum);

%% also save ship shpeed

%P.pitch=xadcp.pitch;
%P.roll=xadcp.roll;
P.uship=uship;
P.vship=vship;

P.timeoffsetInfo=['Time offsets applied to adcp time']
P.MakeInfo=['Made ' datestr(now) 'w/ process_pipestring.m']
P.HeadInfo=['Heading offset of ' num2str(head_offset) ' deg used']
P.Note='Preliminary processing - use with caution. Think heading offset is mostly right (compares ok to 150kHz & HDSS). Still working on fixing some bad data where ship changes headings quickly. Contact apickering@coas.oregonstate.edu'
P.mfiles={'asiri_read_running_nav.m' 'FindPipestringTimeOffset_Asiri15.m' 'loadsaveENR.m' 'process_pipestring.m'}
if savedata==1
    dir1='/Volumes/scienceparty_share/data/'
    save([dir1 'pipestring_1min.mat'],'P')
end

%%
