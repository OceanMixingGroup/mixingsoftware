%~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% process_pole_Aug2015_ASIRI.m
%
% Process 5-beam adcp data on the side-mount pole for ASIRI cruise.
%
% Original code was designed to check for new files and add them to the
% ones already processed. We are onlly getting a file every few days so I
% am just processing each file by itself. Also NOTE the ADCP alignment was
% different when put back on the pole between the 1st/2nd or 2nd/3rd
% segments, so we will have to compute a different heading offset for each
% of those files...
%
%
% Original by Jen MacKinnon for cruise 1, modifed for Aug 2015 cruise on
% R/V Revelle by A. Pickering 08/28/15.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

%dir_data='/Volumes/scienceparty_share/sidepole/raw'
dir_data='/Volumes/Andy8GB/sidepole' % load locally since it takes so long, don't want to bog down science share

% *** NOTE - change heading offset below for different files ***

% load a file, in beam coordinates

%fname=fullfile(dir_data,'ASIRI_2Hz_deployment_20150824T043756.pd0');lab'1stFile'= % 1st file
%fname=fullfile(dir_data,'ASIRI 2Hz deployment 20150828T043335.pd0');lab='2ndFile' % 2nd file
%fname=fullfile(dir_data,'ASIRI 2Hz deployment 20150829T123832.pd0');lab='3rdFile' % 3rd file (ends 09/04 11:00 IST)
fname=fullfile(dir_data,'ASIRI_3rdFile000.000');lab='3rdFile_0' % 3rd file (ends 09/04 11:00 IST)


%  read data into mat
[adcp]=rdradcpJmkFast_5beam([fname]);

% there are some funny things with the time vector, fix here
iii=find(diff(adcp.time)==0);
ttemp=adcp.time; ttemp(iii+1)=ttemp(iii)+.5/24/3600;
Adatenum=ttemp+datenum(2000,1,1,0,0,0)-1;
Adatenum5=Adatenum+.25/24/3600; %vertical beam is offset by .25 second from janus: they alternate

clear A

% smaller subset for debugging;
%idt=isin(Adatenum,[datenum(2015,8,26,9,0,0) datenum(2015,8,26,18,0,0)]);
%A.info='Smaller subset of first file saved for debugging purposes'

% or for entire time
idt=1:length(Adatenum);

A.datenum=Adatenum(idt);
A.vel=adcp.vel(:,:,idt);
A.cor=adcp.cor(:,:,idt);
A.int=adcp.int(:,:,idt);
A.pgood=adcp.pgood(:,:,idt);
A.pitch=adcp.pitch(idt);
A.roll=adcp.roll(idt);
A.depths=adcp.depths;

%save('/Volumes/scienceparty_share/sidepole/mat/small_debug.mat','A')
%disp('saving a smaller subset file to mat')
%save('/Volumes/Andy8GB/sidepole/small_debug.mat','A')

A.w5=adcp.vel5/1e3; %% add NEGATIVE SIGN FOR UPWARD LOOKING ACDP
A.depths=adcp.depths;
A.u=NaN*A.w5; A.v=A.u; A.w=A.u; A.uerr=A.u;

%%
%save([fname(1:end-4) '_beam.mat'],'A','-v7.3')

%~~ optional: start debugging from here
% clear all; close all
% %load('/Volumes/scienceparty_share/sidepole/mat/small_debug.mat')
% load('/Volumes/Andy8GB/sidepole/small_debug.mat')

makeplots=0

if makeplots==1
    % plot beam velocities
    
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
    ezpc(A.datenum,A.depths,squeeze(A.vel(3,:,:))/1e3)
    caxis(2*[-1 1])
    colorbar
    datetick('x')
    SubplotLetterMW('bm3')
    
    subplot(414)
    ezpc(A.datenum,A.depths,squeeze(A.vel(4,:,:))/1e3)
    caxis(2*[-1 1])
    colorbar
    datetick('x')
    SubplotLetterMW('bm4')
    
    
    %
    % %% plot beam intensities
    %
    
    close all
    figure(1);clf
    agutwocolumn(1)
    wysiwyg
    
    subplot(411)
    ezpc(A.datenum,A.depths,squeeze(A.int(1,:,:)))
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
    
    
    % %% plot beam correlations
    %
    
    close all
    figure(1);clf
    agutwocolumn(1)
    wysiwyg
    
    subplot(411)
    ezpc(A.datenum,A.depths,squeeze(A.cor(1,:,:)))
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
    
    % *** pgood is all zeros?
    
    % %% plotpgood
    %
    
    close all
    figure(1);clf
    agutwocolumn(1)
    wysiwyg
    
    subplot(411)
    ezpc(A.datenum,A.depths,squeeze(A.pgood(1,:,:)))
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
    
end % makeplots


% load in navigation data from ship (more reliable than the internal
% sensors in the instrument itself). this is a file created by
% 'asiri_read_running_nav.m' and it outputs a structure "N".
disp('loading nav data')
load('/Volumes/scienceparty_share/data/nav_tot.mat')


clear xadcp nadcp
% try using the beam2earth_workhorse code, modified for 5 beams
xadcp.east_vel = squeeze(A.vel(1,:,:))/1e3;
xadcp.north_vel = squeeze(A.vel(2,:,:))/1e3;
xadcp.vert_vel = squeeze(A.vel(3,:,:))/1e3;
xadcp.error_vel = squeeze(A.vel(4,:,:))/1e3;
ttemp=N.dnum_hpr; ig=find(diff(ttemp)>0); ig=ig(1:end-1)+1;
% note we use ship heading, not ADCP compass
xadcp.heading=interp1(ttemp(ig),N.head(ig),A.datenum);
xadcp.time=A.datenum;
xadcp.pitch=A.pitch;
% when read into mat, pitch and roll have some weird offset. If I have
% time, should figure out how to read in correctly
xadcp.pitch=A.pitch+655.36; %
xadcp.roll =A.roll+655.36; %
xadcp.config.orientation='down';

disp('Transforming to earth coordinates')
%
nadcp=beam2earth_sentinel5(xadcp);
%nadcp=beam2earth_workhorse(xadcp);
%
A.dnum=A.datenum;

% u0,v0 are total velocities (including ship speed)
A.u0=nadcp.vel1;
A.v0=nadcp.vel2;
%
figure(1);clf
pcolor(A.dnum,A.depths,A.u0)
axis ij
shading flat
%plot(A.dnum,A.u0)
colorbar
caxis(2*[-1 1])
datetick('x')
%
%  calculate ship velocity from it's 5 hz lat/lon, to subtract from measured velocity
% again, this from the read_nav.m file
clear dydt dxdt uship vship
dydt=diff(N.lat)*111.18e3./(diff(N.dnum_ll)*24*3600);
dxdt=diff(N.lon)*111.18e3./(diff(N.dnum_ll)*24*3600).*cos(N.lat(1:end-1)*pi/180);

uship=interp1(N.dnum_ll(1:end-1)+diff(N.dnum_ll)/2,dxdt,A.dnum);
vship=interp1(N.dnum_ll(1:end-1)+diff(N.dnum_ll)/2,dydt,A.dnum);

%

% testing to find heading offset
% this is the heading offset between the instrument and the ship, i.e. beam
% 3 was not quite aligned along-ship determined by comparing adcp heading and ship heading, although the adcp
% heading wanders since it's a compas sitting next to this big metal hull,
% so this value may need some work,but probalby ok for a first pass...

% NOTE if beam3 was aligned forward, heading_offset would be 0

dotesting=1;
if dotesting
    %
    % this is a crude way of determining heading offset. basically we
    % assume the depth-average adcp speed over the upper 15-30m
    % should be ~= and opposite to the ship's speed. If there are
    % actual strong currents, this won't be true, but on average it is
    % probably approximately right.
    
    % form complex depth-average adcp velocity
    nadcp.uv=nanmean(nadcp.vel1(1:30,:))/1e3+i*nanmean(nadcp.vel2(1:30,:))/1e3;
    theta=[1:360]; clear test1
    % go in a circle and plot the sum of adcp and ship speed
    for ith=1:length(theta)
        %test1(ith)=nanmean(abs(despike(uv0*exp(i*pi*theta(ith)/180)+(uship+i*vship))).^2);
        test1(ith)=nanmean(abs(nadcp.uv*exp(i*pi*theta(ith)/180)+(uship+i*vship)).^2);
    end
    
    % plot the sum versus angle, and find the minimum; this is our
    % heading offset
    figure(1);clf
    plot(theta,test1)
    [val,I]=nanmin(test1)
    dth=theta(I)
    %
end
%%
clear head_offset uv u0 v0
%head_offset=87% 1st file determined below
%head_offset=62% 1st file determined below
%head_offset=243;
head_offset=dth % use value found above
%head_offset=237% % 2nd file (re-attached differently)
%head_offset=230% % 2nd file (re-attached differently)

% form complex velocity u + iv
uv=A.u0+sqrt(-1)*A.v0;
% rotate by heading offset
u0=real(uv*exp(i*pi*head_offset/180));
v0=imag(uv*exp(i*pi*head_offset/180));

%% subtract ship movement (actually add because they have opposite signs)
A.u=u0+repmat(uship',1,length(A.depths))';
A.v=v0+repmat(vship',1,length(A.depths))';

% Plot the absolute velocities
close all
figure(2);clf

subplot(211)
ezpc(A.dnum,A.depths,A.u)
datetick('x')
caxis([-1 1])
colorbar

subplot(212)
ezpc(A.dnum,A.depths,A.v)
datetick('x')
caxis([-1 1])
colorbar

% do some basic despiking

addpath('/Volumes/scienceparty_share/mfiles/pipestring/') % for despike.m

ib=find(abs(A.u)>5); A.u(ib)=NaN;
ib=find(abs(A.v)>5); A.v(ib)=NaN;

for iz=1:length(A.depths)
    ig=find(~isnan(A.u(iz,:)));
    if length(ig)>1e3;
        A.u(iz,:)=despike(A.u(iz,:),4);
        A.v(iz,:)=despike(A.v(iz,:),4);
    end
end
% plot again
close all
figure(3);clf

subplot(211)
ezpc(A.dnum,A.depths,A.u)
datetick('x')
caxis([-1 1])

subplot(212)
ezpc(A.dnum,A.depths,A.v)
datetick('x')
caxis([-1 1])

% smooth a bit in time - here's a 1-minute averaged data file

% 'Af' will be the smoothed/filtered data

a=1; b=ones(1,60)/60;
Af.dnum=A.dnum(1):1/60/24:A.dnum(end);
Af.u=NaN*ones(length(A.depths),length(Af.dnum));Af.v=Af.u;
ig=find(diff(A.dnum)>0); ig=ig(2:end-1)+1;
for iz=1:length(A.depths);
    Af.u(iz,:)=interp1(A.dnum(ig),nanfilt(b,a,despike(A.u(iz,ig))),Af.dnum);
    Af.v(iz,:)=interp1(A.dnum(ig),nanfilt(b,a,despike(A.v(iz,ig))),Af.dnum);
end

Af.depths=A.depths;

% plot the smoothed data
figure(4);clf
subplot(211)
ezpc(Af.dnum,A.depths,Af.u)
datetick('x')
caxis([-1 1])

subplot(212)
ezpc(Af.dnum,A.depths,Af.v)
datetick('x')
caxis([-1 1])


% despike again
for iz=1:length(Af.depths)
    ig=find(~isnan(Af.u(iz,:)));
    if length(ig)>1e2;
        Af.u(iz,:)=despike(Af.u(iz,:),1);
        Af.v(iz,:)=despike(Af.v(iz,:),1);
    end
end

%
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
    
end % screen heading changes

% change name: i'm usiing V for the sentinal V files, and other files use P for pipesting ADCP, S for shipboard adcp.
V=Af;
%V0=Atot;

% ** AP - need to check this for Aug 15  cruise **
% fix depth - up to now depth is in RANGE! (along beams)
% need to correct for 25 deg beam angle AND 15 deg instrument tilt
dth=15+25;
V.z=V.depths*cos(dth*pi/180);
%
% now correct for transducer location, approx 2 m down - this is determined
% by comparing to shipboard adcp, code for doing this below
V.z=V.z+2;
%V0.z=V0.depths*cos(dth*pi/180);
%V0.z=V0.z+2;

%%
V.source=fname;
V.head_offset=head_offset;
V.MakeInfo=['Made ' datestr(now) ' w/ process_pole.m']
V.Note='Preliminary processing - use with caution! - contact Andy with ?s'
%save([dir_data 'processed/sentinel_1min.mat'],'V')
save(fullfile('/Volumes/scienceparty_share/data/',['sentinel_1min_' lab '.mat']),'V')

%%
% V0.MakeInfo=['Made ' datestr(now) ' w/ process_pole.m']
% V0.Note='Preliminary processing - use with caution! - contact Andy with ?s'
%
% %save([dir_data 'processed/sentinel_full.mat'],'V0')
% save(fullfile('/Volumes/scienceparty_share/data/','sentinel_full.mat'),'V0')

%% end of main file - below are some other useful testing and plotting things

domore=0
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
    
    %%
    %
    %         %% plots
    %         dth=180.1;
    %         ii=ii2;
    %         subplot(311)
    %         plot(A.dnum(ii)-t0,real(uv0(ii)*exp(i*pi*dth/180))+uship(ii)); shg
    %         subplot(312)
    %         plot(A.dnum(ii)-t0,imag(uv0(ii)*exp(i*pi*dth/180))+vship(ii)); shg
    %         subplot(313)
    %         plot(A.dnum(ii)-t0,[uship(ii);vship(ii)])
    %
    %         %%
    %         dth=180.2;a=1; b=ones(1,300)/300;
    %         ii=ii2;
    %         subplot(311)
    %         plot(A.dnum(ii)-t0,nanfilt(b,a,real(uv0(ii)*exp(i*pi*dth/180))+uship(ii))); shg
    %         subplot(312)
    %         plot(A.dnum(ii)-t0,nanfilt(b,a,imag(uv0(ii)*exp(i*pi*dth/180))+vship(ii))); shg
    %         subplot(313)
    %         plot(A.dnum(ii)-t0,[uship(ii);vship(ii)])
    %
    %         %%
    %         for ii=1:4
    %             subplot(4,1,ii)
    %             plot(A.dnum-t0,real(uv0*exp(i*pi*th(ii)/180))+uship); set(gca,'ylim',[-1 1]*2);
    %         end
    %         shg
    %
    %     end
    
    
end
%% bad data?
% cc=squeeze(adcp.cor(1,:,:));
% ib=find(cc<60);
% A.u(ib)=NaN; A.v(ib)=NaN; A.w(ib)=NaN;




