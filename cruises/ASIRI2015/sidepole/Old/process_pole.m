%~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% process_pole.m
%
% Process 5-beam adcp data on the side-mount pole for ASIRI cruise.
%
% Original by Jen MacKinnon for cruise 1, modifed for Aug 2015 cruise on
% R/V Revelle by A. Pickering 08/28/15.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

%dir_data='/Volumes/scienceparty_share/sidepole/raw'

dir_data='/Volumes/Andy8GB/sidepole' % load locally since it takes so long, don't want to bog down science share
%files=dir(fullfile(dir_data,'*ASIRI_2Hz'));
%

% *** NOTE - change heading offset below for different files ***

fname=fullfile(dir_data,'ASIRI_2Hz_deployment_20150824T043756.pd0') % 1st file
%fname=fullfile(dir_data,'ASIRI 2Hz deployment 20150828T043335.pd0') % 2nd file
%
Atot.u0=[]; Atot.v0=[]; Atot.w0=[]; Atot.dnum=[];
%
%
%
%for ifile=1:length(files)

% load a file, in beam coordinates
%dir0='/Users/jen/projects/asiri/cruise1/data/sidemount/';
%dir0='/Users/jen/projects/asiri/cruise1/data/emily/sidemount/raw/';

%fname=files(ifile).name;
%disp(fname)

%  modified by jen to read in 5 beams instead of 4

[adcp]=rdradcpJmkFast_5beam([fname]);
%[adcp]=rdradcpJmkFast_5beam([dir0 fname]);


%% save a smaller subset 'A' here for debugging purposes... AP

% there are some funny things with the time vector, fix here
iii=find(diff(adcp.time)==0);
ttemp=adcp.time; ttemp(iii+1)=ttemp(iii)+.5/24/3600;
Adatenum=ttemp+datenum(2000,1,1,0,0,0)-1;
Adatenum5=Adatenum+.25/24/3600; %vertical beam is offset by .25 second from janus: they alternate
%A.yday=A.datenum-datenum(2013,1,1,0,0,0);
%

clear A
idt=isin(Adatenum,[datenum(2015,8,26,9,0,0) datenum(2015,8,26,18,0,0)]);
A.datenum=Adatenum(idt);
A.vel=adcp.vel(:,:,idt);
A.cor=adcp.cor(:,:,idt);
A.int=adcp.int(:,:,idt);
A.pgood=adcp.pgood(:,:,idt);
A.pitch=adcp.pitch(idt);
A.roll=adcp.roll(idt);
A.depths=adcp.depths;

A.info='Smaller subset of first file saved for debugging purposes'
%
%save('/Volumes/scienceparty_share/sidepole/mat/small_debug.mat','A')
disp('saving a smaller subset file to mat')
save('/Volumes/Andy8GB/sidepole/small_debug.mat','A')
%%

% save mat file here in case it crashes (takes a LONG time to read the file
% to mat since it is so big)

%save([fname(1:end-4) '.mat'],'adcp','-v7.3')

% make a smaller subset structre
A.w5=adcp.vel5/1e3; %% add NEGATIVE SIGN FOR UPWARD LOOKING ACDP
A.depths=adcp.depths;
A.u=NaN*A.w5; A.v=A.u; A.w=A.u; A.uerr=A.u;


% there are some funny things with the time vector, fix here
iii=find(diff(adcp.time)==0);
ttemp=adcp.time; ttemp(iii+1)=ttemp(iii)+.5/24/3600;
A.datenum=ttemp+datenum(2000,1,1,0,0,0)-1;
A.datenum5=A.datenum+.25/24/3600; %vertical beam is offset by .25 second from janus: they alternate
A.yday=A.datenum-datenum(2013,1,1,0,0,0);
%
A.bmvel=adcp.vel;

%
%save([fname(1:end-4) '_beam.mat'],'A','-v7.3')

%% start debugging from here

clear all; close all
%load('/Volumes/scienceparty_share/sidepole/mat/small_debug.mat')
load('/Volumes/Andy8GB/sidepole/small_debug.mat')

%% plot beam velocities

close all
figure(1);clf
agutwocolumn(1)
wysiwyg

subplot(411)
ezpc(A.datenum,A.depths,squeeze(A.vel(1,:,:))/1e3)
caxis(2*[-1 1])
colorbar
datetick('x')
SubplotLetterMW('bm1')

subplot(412)
ezpc(A.datenum,A.depths,squeeze(A.vel(2,:,:))/1e3)
caxis(2*[-1 1])
colorbar
datetick('x')
SubplotLetterMW('bm2')

subplot(413)
%ezpc(A.datenum,adcp.depths,squeeze(adcp.vel(3,:,:))/1e3)
ezpc(A.datenum,A.depths,squeeze(A.vel(3,:,:))/1e3)
caxis(2*[-1 1])
colorbar
datetick('x')
SubplotLetterMW('bm3')

subplot(414)
%ezpc(A.datenum,adcp.depths,squeeze(adcp.vel(4,:,:))/1e3)
ezpc(A.datenum,A.depths,squeeze(A.vel(4,:,:))/1e3)
caxis(2*[-1 1])
colorbar
datetick('x')
SubplotLetterMW('bm4')


%% 
% %% plot beam intensities
% 

close all
figure(1);clf
agutwocolumn(1)
wysiwyg

subplot(411)
ezpc(A.datenum,A.depths,squeeze(A.int(1,:,:)))
%caxis(2*[-1 1])
colorbar
datetick('x')
SubplotLetterMW('bm1')
title('beam intensity')

subplot(412)
ezpc(A.datenum,A.depths,squeeze(A.int(2,:,:)))
colorbar
datetick('x')
SubplotLetterMW('bm2')

subplot(413)
ezpc(A.datenum,A.depths,squeeze(A.int(3,:,:)))
colorbar
datetick('x')
SubplotLetterMW('bm3')

subplot(414)
ezpc(A.datenum,A.depths,squeeze(A.int(4,:,:)))
colorbar
datetick('x')
SubplotLetterMW('bm4')

%%

% %% plot beam correlations
% 

close all
figure(1);clf
agutwocolumn(1)
wysiwyg

subplot(411)
ezpc(A.datenum,A.depths,squeeze(A.cor(1,:,:)))
%caxis(2*[-1 1])
colorbar
datetick('x')
SubplotLetterMW('bm1')
title('beam correlations')

subplot(412)
ezpc(A.datenum,A.depths,squeeze(A.cor(2,:,:)))
colorbar
datetick('x')
SubplotLetterMW('bm2')

subplot(413)
ezpc(A.datenum,A.depths,squeeze(A.cor(3,:,:)))
colorbar
datetick('x')
SubplotLetterMW('bm3')

subplot(414)
ezpc(A.datenum,A.depths,squeeze(A.cor(4,:,:)))
colorbar
datetick('x')
SubplotLetterMW('bm4')

%% *** pgood is all zeros?

% %% plotpgood
% 

close all
figure(1);clf
agutwocolumn(1)
wysiwyg

subplot(411)
ezpc(A.datenum,A.depths,squeeze(A.pgood(1,:,:)))
%caxis(2*[-1 1])
colorbar
datetick('x')
SubplotLetterMW('bm1')
title('beam % good')

subplot(412)
ezpc(A.datenum,A.depths,squeeze(A.pgood(2,:,:)))
colorbar
datetick('x')
SubplotLetterMW('bm2')

subplot(413)
ezpc(A.datenum,A.depths,squeeze(A.pgood(3,:,:)))
colorbar
datetick('x')
SubplotLetterMW('bm3')

subplot(414)
ezpc(A.datenum,A.depths,squeeze(A.pgood(4,:,:)))
colorbar
datetick('x')
SubplotLetterMW('bm4')

%%
% close all
% figure(1);clf
% agutwocolumn(1)
% wysiwyg
% 
% subplot(411)
% ezpc(A.datenum,adcp.depths,squeeze(adcp.int(1,:,:))/1e3)
% %caxis(2*[-1 1])
% colorbar
% datetick('x')
% 
% subplot(412)
% ezpc(A.datenum,adcp.depths,squeeze(adcp.int(2,:,:))/1e3)
% %caxis(2*[-1 1])
% colorbar
% datetick('x')
% 
% subplot(413)
% ezpc(A.datenum,adcp.depths,squeeze(adcp.int(3,:,:))/1e3)
% %caxis(2*[-1 1])
% colorbar
% datetick('x')
% 
% subplot(414)
% ezpc(A.datenum,adcp.depths,squeeze(adcp.int(4,:,:))/1e3)
% %caxis(2*[-1 1])
% colorbar
% datetick('x')
% 
% %%
% print('/Volumes/scienceparty_share/sidepole/figures/deploy2_int.png','-dpng')
% %%
% close all
% figure(1);clf
% ezpc(A.datenum,adcp.depths,squeeze(adcp.cor(1,:,:)))
% colorbar
% datetick('x')

%%
% load in navigation data from ship ** more reliable than the internal
% sensors in the instrument itself. this is a file created by
% 'asiri_read_nav.m' and it outputs a structure "N".
%load('/Users/jen/projects/asiri/cruise1/data/nav/nav_total.mat')
disp('loading nav data')
load('/Volumes/scienceparty_share/data/nav_tot.mat')

%%

clear xadcp nadcp
% try using the beam2earth_workhorse code, modified for 5 beams
xadcp.east_vel = squeeze(A.vel(1,:,:))/1e3;
xadcp.north_vel = squeeze(A.vel(2,:,:))/1e3;
xadcp.vert_vel = squeeze(A.vel(3,:,:))/1e3;
xadcp.error_vel = squeeze(A.vel(4,:,:))/1e3;
ttemp=N.dnum_hpr; ig=find(diff(ttemp)>0); ig=ig(1:end-1)+1;

%
xadcp.heading=interp1(ttemp(ig),N.head(ig),A.datenum);
xadcp.time=A.datenum;

xadcp.pitch=A.pitch;


%xadcp.pitch=A.pitch+645.36; % ** where does this come from??

xadcp.roll=A.roll;
xadcp.config.orientation='down';
%%
xadcp.pitch=A.pitch+655.36; % ** where does this come from??
xadcp.roll=A.roll+655.36; % ** where does this come from??
%%
figure(1);clf
ezpc(xadcp.time,A.depths,xadcp.east_vel)
caxis(2*[-1 1])
datetick('x')
%%
figure(1);clf
plot(xadcp.time,xadcp.roll)
hold on
plot(xadcp.time,xadcp.pitch)
%%

disp('Transforming to earth coordinates')
%
nadcp=beam2earth_sentinel5(xadcp);
%nadcp=beam2earth_workhorse(xadcp);
%%
close all
figure(1)
ezpc(A.datenum,A.depths,nadcp.vel3)
%ezpc(A.datenum,A.depths,xadcp.east_vel)
colorbar
caxis(2*[-1 1])
datetick('x')
%%
% try using the beam2earth_workhorse code, modified for 5 beams
xadcp.east_vel = squeeze(adcp.vel(1,:,:));
xadcp.north_vel = squeeze(adcp.vel(2,:,:));
xadcp.vert_vel = squeeze(adcp.vel(3,:,:));
xadcp.error_vel = squeeze(adcp.vel(4,:,:));
ttemp=N.dnum_hpr; ig=find(diff(ttemp)>0); ig=ig(1:end-1)+1;

%
xadcp.heading=interp1(ttemp(ig),N.head(ig),A.datenum);
xadcp.time=A.datenum;

%xadcp.pitch=adcp.pitch+655.36; % original from Jen
xadcp.pitch=adcp.pitch+645.36; % ** where does this come from??

xadcp.roll=adcp.roll;
xadcp.config.orientation='down';
disp('Transforming to earth coordinates')
nadcp=beam2earth_sentinel5(xadcp);
%
%addpath('/Volumes/scienceparty_share/mfiles/pipestring/')
%nadcp=beam2earth_workhorse(xadcp);
%%
% add this file to big structure

Atot.u0=[Atot.u0,nadcp.vel1/1e3];
Atot.v0=[Atot.v0,nadcp.vel2/1e3];
Atot.dnum=[Atot.dnum,A.datenum(:)'];
Atot.depths=A.depths;

%
%save([fname(1:end-4) '_Atot.mat'],'Atot')

%% AP continues here
Atot=A;
Atot.dnum=A.datenum;
Atot.u0=nadcp.vel1;
Atot.v0=nadcp.vel2;
%%
figure(1);clf
ezpc(Atot.dnum,Atot.depths,Atot.u0)
%plot(Atot.dnum,Atot.u0)
colorbar
caxis(2*[-1 1])
datetick('x')
%
%%  calculate ship velocity from it's 5 hz lat/lon, to subtract from measured velocity
% again, this form the read_nav.m file
clear dydt dxdt uship vship
dydt=diff(N.lat)*111.18e3./(diff(N.dnum_ll)*24*3600);
dxdt=diff(N.lon)*111.18e3./(diff(N.dnum_ll)*24*3600).*cos(N.lat(1:end-1)*pi/180);

uship=interp1(N.dnum_ll(1:end-1)+diff(N.dnum_ll)/2,dxdt,Atot.dnum);
vship=interp1(N.dnum_ll(1:end-1)+diff(N.dnum_ll)/2,dydt,Atot.dnum);

%%

% heading offset

% this is the heading offset between the instrument and the ship, i.e. beam
% 3 was not quite aligned along-ship
% determined by comparing adcp heading and ship heading, although the adcp
% heading wanders since it's a compas sitting next to this big metal hull,
% so this value may need some work,but probalby ok for a first pass...
%head_off=3.52;;
%
% note there is code below (scroll down) for picking out this heading
% offset

clear head_offset uv u0 v0
%head_offset=87% 1st file determined below
%head_offset=62% 1st file determined below
head_offset=243;
%head_offset=237% % 2nd file (re-attached differently)
%head_offset=230% % 2nd file (re-attached differently)
uv=Atot.u0+sqrt(-1)*Atot.v0;
u0=real(uv*exp(i*pi*head_offset/180));
v0=imag(uv*exp(i*pi*head_offset/180));

%% subtract ship movement
Atot.u=u0+repmat(uship',1,length(A.depths))';
Atot.v=v0+repmat(vship',1,length(A.depths))';
%%
%save([fname(1:end-4) '.mat'],'Atot')
%%
close all
figure(2);clf
subplot(211)
ezpc(Atot.dnum,Atot.depths,Atot.u)
datetick('x')
caxis([-1 1])
colorbar

subplot(212)
ezpc(Atot.dnum,Atot.depths,Atot.v)
datetick('x')
caxis([-1 1])
colorbar
%% some basic despiking

addpath('/Volumes/scienceparty_share/mfiles/pipestring/') % for despike.m

ib=find(abs(Atot.u)>5); Atot.u(ib)=NaN;
ib=find(abs(Atot.v)>5); Atot.v(ib)=NaN;

for iz=1:length(A.depths)
    ig=find(~isnan(Atot.u(iz,:)));
    if length(ig)>1e3;
        Atot.u(iz,:)=despike(Atot.u(iz,:),4);
        Atot.v(iz,:)=despike(Atot.v(iz,:),4);
    end
end
%%
close all
figure(3);clf

subplot(211)
ezpc(Atot.dnum,Atot.depths,Atot.u)
datetick('x')
caxis([-1 1])

subplot(212)
ezpc(Atot.dnum,Atot.depths,Atot.v)
datetick('x')
caxis([-1 1])
%% smooth a bit in time - here's a 1-minute averaged data file

a=1; b=ones(1,60)/60;
Af.dnum=Atot.dnum(1):1/60/24:Atot.dnum(end);
Af.u=NaN*ones(length(Atot.depths),length(Af.dnum));Af.v=Af.u;
ig=find(diff(Atot.dnum)>0); ig=ig(2:end-1)+1;
for iz=1:length(Atot.depths);
    Af.u(iz,:)=interp1(Atot.dnum(ig),nanfilt(b,a,despike(Atot.u(iz,ig))),Af.dnum);
    Af.v(iz,:)=interp1(Atot.dnum(ig),nanfilt(b,a,despike(Atot.v(iz,ig))),Af.dnum);
end

Af.depths=Atot.depths;

figure(4);clf
subplot(211)
ezpc(Af.dnum,Atot.depths,Af.u)
datetick('x')
caxis([-1 1])

subplot(212)
ezpc(Af.dnum,Atot.depths,Af.v)
datetick('x')
caxis([-1 1])
%%

figure(5);clf
plot(Atot.dnum,Atot.u(30,:))
hold on
plot(Af.dnum,Af.u(30,:))

%% despike again
for iz=1:length(Af.depths)
    ig=find(~isnan(Af.u(iz,:)));
    if length(ig)>1e2;
        Af.u(iz,:)=despike(Af.u(iz,:),1);
        Af.v(iz,:)=despike(Af.v(iz,:),1);
    end
end
%%
screenheadchanges=0
if screenheadchanges==1
    %% data doesn't do well when ship changes heading quickly
    % blank out a bit of data on either side of quick heading changes
    a=1; b=ones(1,120)/120;
    ttemp=N.dnum_hpr; ig=find(diff(ttemp)>0); ig=ig(1:end-1)+1;
    headf=interp1(N.dnum_hpr(ig),nanfilt(b,a,despike(N.head(ig))),Af.dnum);
    ib=find(abs(diff(headf/mean(diff(Af.dnum))/24/3600))>0.15); % identify "big" heading changes
    ibad=3; % # minutes on either side to blank out of such instances
    for iib=1:length(ib)
        inan=(ib(iib)-ibad):(ib(iib)+ibad);
        Af.u(:,inan)=NaN; Af.v(:,inan)=NaN;
    end
    Af.u=Af.u(:,1:length(Af.dnum));
    Af.v=Af.v(:,1:length(Af.dnum));
    
    % now interpolate back in
    for iz=1:length(Af.z)
        ig=find(~isnan(Af.u(iz,:)));
        Af.u(iz,:)=interp1(Af.dnum(ig),Af.u(iz,ig),Af.dnum);
        Af.v(iz,:)=interp1(Af.dnum(ig),Af.v(iz,ig),Af.dnum);
    end
    
end
%% nan out periods when instrument was turned off :(
% t0=min(Atot.dnum);
% ii1=find(Atot.dnum-t0<2.5);
% ii2=find(Atot.dnum-t0>2.5&Atot.dnum-t0<5);
% ii3=find(Atot.dnum-t0>5&Atot.dnum-t0<7.8);
% ii4=find(Atot.dnum-t0>7.8);
% ioff=find(Af.dnum>max(Atot.dnum(ii1)-.005)&Af.dnum<min(Atot.dnum(ii2)+.005));
% Af.u(:,ioff)=NaN; Af.v(:,ioff)=NaN;
% ioff=find(Af.dnum>max(Atot.dnum(ii2)-.005)&Af.dnum<min(Atot.dnum(ii3)+.005));
% Af.u(:,ioff)=NaN; Af.v(:,ioff)=NaN;
% ioff=find(Af.dnum>max(Atot.dnum(ii3)-.005)&Af.dnum<min(Atot.dnum(ii4)+.005));
% Af.u(:,ioff)=NaN; Af.v(:,ioff)=NaN;


%% change name: i'm usiing V for the sentinal V files, and other files use P for pipesting ADCP, S for shipboard adcp.
V=Af;
V0=Atot;

%%

% ** AP - need to check this for Aug 15  cruise **
%% fix depth
% up to now depth is in RANGE!
% need to correct for 25 deg beam angle AND 15 deg instrument tilt
dth=15+25;
V.z=V.depths*cos(dth*pi/180);
%%
% now correct for transducer location, approx 2 m down - this is determined
% by comparing to shipboard adcp, code for doing this below
V.z=V.z+2;
V0.z=V0.depths*cos(dth*pi/180);
V0.z=V0.z+2;

%%

V.MakeInfo=['Made ' datestr(now) ' w/ process_pole.m']
V.Note='Preliminary processing - use with caution! - contact Andy with ?s'
%save([dir_data 'processed/sentinel_1min.mat'],'V')
save(fullfile('/Volumes/scienceparty_share/data/','sentinel_1min.mat'),'V')

%%
V0.MakeInfo=['Made ' datestr(now) ' w/ process_pole.m']
V0.Note='Preliminary processing - use with caution! - contact Andy with ?s'

%save([dir_data 'processed/sentinel_full.mat'],'V0')
save(fullfile('/Volumes/scienceparty_share/data/','sentinel_full.mat'),'V0')

%% end of main file - below are some other useful testing and plotting things

%%
if domore==1
    %% comparison to sadcp for determining depth offset
    %load('/Users/jen/projects/asiri/cruise1/data/sadcp/nb150_uv.mat')
    
    % pick a nice time period for comparing
    y1=321.55; y2=321.6; dz=4;
    y1=315.557; y2=315.56; dz=4;
    y1=325.72; y2=325.73; dz=4;
    %y1=319.18; y2=319.22;
    y1=324.245; y2=324.27;
    %y1=324.85; y2=324.88;
    
    dz=-2;dz=0; dz=1;
    t0=datenum(2013,1,1,0,0,0);
    ii1=find(Af.dnum-t0>y1&Af.dnum-t0<y2);
    ii2=find(S.datenum-t0>y1&S.datenum-t0<y2);
    ii3=find(H.datenum-t0>y1&H.datenum-t0<y2);
    
    figure(2); clf; fig_setup(0)
    subplot(121)
    plot(nanmean(Af.u(:,ii1),2),Af.z+dz,nanmean(S.u(:,ii2),2),S.z,real(nanmean(H.u(:,ii3),2)),H.z); set(gca,'ylim',[0 100]); axis ij
    subplot(122)
    plot(nanmean(Af.v(:,ii1),2),Af.z+dz,nanmean(S.v(:,ii2),2),S.z,imag(nanmean(H.u(:,ii3),2)),H.z); set(gca,'ylim',[0 100]); axis ij
    
    
    %% testing to find heading offset
    dotesting=0;
    if dotesting
        %%
        nadcp.uv=nanmean(nadcp.vel1(1:30,:))/1e3+i*nanmean(nadcp.vel2(1:30,:))/1e3;
%        nadcp.uv=nanmean(nadcp.vel1(1:30,:))+i*nanmean(nadcp.vel2(1:30,:));
        theta=[1:360]; clear test1
        for ith=1:length(theta)
            %    test1(ith)=nanmean(abs(despike(uv0*exp(i*pi*theta(ith)/180)+(uship+i*vship))).^2);
            test1(ith)=nanmean(abs(nadcp.uv*exp(i*pi*theta(ith)/180)+(uship+i*vship)).^2);
        end
        
        figure(1);clf
        plot(theta,test1)
        [val,I]=nanmin(test1)
        dth=theta(I)
        %%
        
        
        %% plots
        dth=180.1;
        ii=ii2;
        subplot(311)
        plot(Atot.dnum(ii)-t0,real(uv0(ii)*exp(i*pi*dth/180))+uship(ii)); shg
        subplot(312)
        plot(Atot.dnum(ii)-t0,imag(uv0(ii)*exp(i*pi*dth/180))+vship(ii)); shg
        subplot(313)
        plot(Atot.dnum(ii)-t0,[uship(ii);vship(ii)])
        
        %%
        dth=180.2;a=1; b=ones(1,300)/300;
        ii=ii2;
        subplot(311)
        plot(Atot.dnum(ii)-t0,nanfilt(b,a,real(uv0(ii)*exp(i*pi*dth/180))+uship(ii))); shg
        subplot(312)
        plot(Atot.dnum(ii)-t0,nanfilt(b,a,imag(uv0(ii)*exp(i*pi*dth/180))+vship(ii))); shg
        subplot(313)
        plot(Atot.dnum(ii)-t0,[uship(ii);vship(ii)])
        
        %%
        for ii=1:4
            subplot(4,1,ii)
            plot(Atot.dnum-t0,real(uv0*exp(i*pi*th(ii)/180))+uship); set(gca,'ylim',[-1 1]*2);
        end
        shg
        
    end
    
    
end
%% bad data?
% cc=squeeze(adcp.cor(1,:,:));
% ib=find(cc<60);
% A.u(ib)=NaN; A.v(ib)=NaN; A.w(ib)=NaN;




