%~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% process_pole_Aug2015_ASIRI_v2.m
%
% Process RDI Sentinel 500kHz adcp data on the side-mount pole for ASIRI cruise.
%
% Files from Sentinel were very large (2GB) and I was having trouble
% loading them/processing in Matlab. So I split them into ~100mb files with
% BBsplit; this is a modified processing script to read all those smaller
% files and combine into one big structure.
%
% We still need to process some of the deployments separately because the
% ADCP was mounted differently and heading offset is different...
%
% 09/04/15 - A. Pickering - apickering@coas.oregonstate.edu
% 09/05/15 - AP - Computer getting bogged down and crashing when I try to
% do beam to earth transform for entire file. Instead I will do transform
% for each split file and combine.
%~~~~~~~~~~~~~
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

cd('/Volumes/scienceparty_share/mfiles/sidepole/')

% =1 to estimate heading offset by comparing to ship speed
est_head_offset=1 ;% head_offset=255

% root directory for data 
dir_data='/Volumes/scienceparty_share/sidepole/raw'
%dir_data='/Volumes/Andy8GB/sidepole/' %
%dir_data='/Volumes/Andy8GB/sidepole/File3' %
%dir_data='/Volumes/Midge/ExtraBackup/scienceshare_090815/sidepole/raw/'
%dir_data='/Volumes/ASIRI2015/ASIRI2015/scienceshare_backup/09_11_2015/sidepole/raw' 
%dir_data='/Volumes/ASIRI2015/ASIRI2015/'

% filenames
fnameshort='ASIRI_2Hz_deployment_20150824T043756.pd0';lab='File1';
%fnameshort='ASIRI 2Hz deployment 20150828T043335.pd0';lab='File2';
%fnameshort='ASIRI 2Hz deployment 20150829T123832.pd0';lab='File3';
%fnameshort='ASIRI 2Hz deployment 20150904T053350.pd0';lab='File4'
%fnameshort='ASIRI 2Hz deployment 20150908T141555.pd0';lab='File5'; head_offset=255
%fnameshort='ASIRI 2Hz deployment 20150911T223729.pd0';lab='File6'; head_offset=255

% list of split files (~50mb each)
Flist=dir(fullfile(dir_data,[fnameshort(1:end-4) '_split*'])) % some have capital 'S' in split
%
% make an empty structure for combined data
Atot=struct();
Atot.dnum=[];
Atot.pitch=[];
Atot.roll=[];
Atot.heading=[];
% beam vels
% Atot.vel1=[];
% Atot.vel2=[];
% Atot.vel3=[];
% Atot.vel4=[];
% total earth vel (w/ ship motion)
Atot.u0=[];
Atot.v0=[];

% load in navigation data from ship (more reliable than the internal
% sensors in the instrument itself). this is a file created by
% 'asiri_read_running_nav.m' and it outputs a structure "N".
disp('loading nav data')
load('/Volumes/scienceparty_share/data/nav_tot.mat')
ttemp_nav=N.dnum_hpr; ig=find(diff(ttemp_nav)>0); ig=ig(1:end-1)+1;

for a=7%1:5%length(Flist)

    clear fname adcp
    fname=fullfile(dir_data,Flist(a).name)
    
    % check if mat file of beam velocity data already exists
    clear fname_beam_mat
    fname_beam_mat=fullfile('/Volumes/scienceparty_share/sidepole/mat/',[Flist(a).name '_beam.mat'])
    if exist(fname_beam_mat,'file')
        disp('file already exists, loading')
        load(fname_beam_mat)    
    else
        disp('no mat exists, loading file')
    % not processed yet, read data into mat
    clear adcp
    [adcp]=rdradcpJmkFast_5beam([fname]);
    
    % fix dnum in adcp
    clear iii ttemp Adatenum
    iii=find(diff(adcp.time)==0);
    ttemp=adcp.time; ttemp(iii+1)=ttemp(iii)+.5/24/3600;
    Adatenum=ttemp+datenum(2000,1,1,0,0,0)-1;
    adcp.dnum=Adatenum;
    % not using beam 5 for now...
    %Adatenum5=Adatenum+.25/24/3600; %vertical beam is offset by .25 second from janus: they alternate
    %Atot.dnum=Adatenum;

    % save mat file here so we don't have to reload in future?
    save(fname_beam_mat,'adcp')
    end
    
    % check if mat file with Earth vels exists
    % the beam-to-earth transform takes a lot of time/memory, sometimes
    % bogs down if I wait until the end to transform all at once. INstead,
    % do each smaller file one at a time.
    clear xadcp nadcp
    clear fname_earth_mat
    fname_earth_mat=fullfile('/Volumes/scienceparty_share/sidepole/mat/',[Flist(a).name '_earth.mat'])
    if exist(fname_earth_mat,'file')
        disp('Earth vel file already exists, loading')
        load(fname_earth_mat)    
    else
        disp('no rotated mat exists, transforming to earth')

    clear xadcp nadcp
    xadcp.east_vel =  squeeze(adcp.vel(1,:,:))/1e3;
    xadcp.north_vel = squeeze(adcp.vel(2,:,:))/1e3;
    xadcp.vert_vel = squeeze(adcp.vel(3,:,:))/1e3;
    xadcp.error_vel = squeeze(adcp.vel(4,:,:))/1e3;
    
    % NOTE we use ship heading, not ADCP compass
    xadcp.heading=interp1(ttemp_nav(ig),N.head(ig),adcp.dnum);
    xadcp.dnum=adcp.dnum;
    
    % when read into mat, pitch and roll for Sentinel have some weird offset. If I have
    % time, should figure out how to read these in correctly
    % ** should use ship pitch and roll here also?
    xadcp.pitch=adcp.pitch+655.36; %
    xadcp.roll =adcp.roll+655.36; %
    xadcp.config.orientation='down';
    disp('Transforming to earth coordinates')
    nadcp=beam2earth_sentinel5(xadcp);
    
    save(fname_earth_mat,'xadcp','nadcp')
    
    end % rotated mat file exists
    
    % add data to combined structure
    Atot.dnum   =[Atot.dnum    adcp.dnum];
    Atot.pitch  =[Atot.pitch   xadcp.pitch];
    Atot.roll   =[Atot.roll    xadcp.roll];
    Atot.heading=[Atot.heading xadcp.heading];
    
    % use u0,v0 because ship velocity not removed yet
    Atot.u0=[Atot.u0 nadcp.vel1];
    Atot.v0=[Atot.v0 nadcp.vel2];

    % not saving beam velocities right now..
    %     Atot.vel1=[Atot.vel1 squeeze(adcp.vel(1,:,:))];
    %     Atot.vel2=[Atot.vel2 squeeze(adcp.vel(2,:,:))];
    %     Atot.vel3=[Atot.vel3 squeeze(adcp.vel(3,:,:))];
    %     Atot.vel4=[Atot.vel4 squeeze(adcp.vel(4,:,:))];
    
end % loop through files

% depths (actually range along beams.. converted to real depth later)
Atot.z=adcp.depths;

% swittch to A for no reason
A=Atot;clear Atot
A.u=nan*ones(size(A.u0));
A.v=A.u;

clear adcp nadcp xadcp%

makeplots=0

if makeplots==1
    % plot beam velocities
    
    close all
    figure(1);clf
    agutwocolumn(1)
    wysiwyg
    
    subplot(411)
    ezpc(A.dnum,A.z,squeeze(A.vel(1,:,:))/1e3)
    caxis(2*[-1 1])
    colorbar
    datetick('x')
    SubplotLetterMW('bm1')
    
    subplot(412)
    ezpc(A.dnum,A.z,squeeze(A.vel(2,:,:))/1e3)
    caxis(2*[-1 1])
    colorbar
    datetick('x')
    SubplotLetterMW('bm2')
    
    subplot(413)
    ezpc(A.dnum,A.z,squeeze(A.vel(3,:,:))/1e3)
    caxis(2*[-1 1])
    colorbar
    datetick('x')
    SubplotLetterMW('bm3')
    
    subplot(414)
    ezpc(A.dnum,A.z,squeeze(A.vel(4,:,:))/1e3)
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
    ezpc(A.dnum,A.z,squeeze(A.int(1,:,:)))
    colorbar
    datetick('x')
    SubplotLetterMW('bm1')
    title('beam intensity')
    
    subplot(412)
    ezpc(A.dnum,A.z,squeeze(A.int(2,:,:)))
    colorbar
    datetick('x')
    SubplotLetterMW('bm2')
    
    subplot(413)
    ezpc(A.dnum,A.z,squeeze(A.int(3,:,:)))
    colorbar
    datetick('x')
    SubplotLetterMW('bm3')
    
    subplot(414)
    ezpc(A.dnum,A.z,squeeze(A.int(4,:,:)))
    colorbar
    datetick('x')
    SubplotLetterMW('bm4')
    
    
    %% %% plot beam correlations
    %
    
    close all
    figure(1);clf
    agutwocolumn(1)
    wysiwyg
    
    subplot(411)
    ezpc(A.dnum,A.z,squeeze(A.cor(1,:,:)))
    colorbar
    datetick('x')
    SubplotLetterMW('bm1')
    title('beam correlations')
    
    subplot(412)
    ezpc(A.dnum,A.z,squeeze(A.cor(2,:,:)))
    colorbar
    datetick('x')
    SubplotLetterMW('bm2')
    
    subplot(413)
    ezpc(A.dnum,A.z,squeeze(A.cor(3,:,:)))
    colorbar
    datetick('x')
    SubplotLetterMW('bm3')
    
    subplot(414)
    ezpc(A.dnum,A.z,squeeze(A.cor(4,:,:)))
    colorbar
    datetick('x')
    SubplotLetterMW('bm4')
    
    % *** pgood is all zeros?
    
    % %% plotpgood
    
    close all
    figure(1);clf
    agutwocolumn(1)
    wysiwyg
    
    subplot(411)
    ezpc(A.dnum,A.z,squeeze(A.pgood(1,:,:)))
    colorbar
    datetick('x')
    SubplotLetterMW('bm1')
    title('beam % good')
    
    subplot(412)
    ezpc(A.dnum,A.z,squeeze(A.pgood(2,:,:)))
    colorbar
    datetick('x')
    SubplotLetterMW('bm2')
    
    subplot(413)
    ezpc(A.dnum,A.z,squeeze(A.pgood(3,:,:)))
    colorbar
    datetick('x')
    SubplotLetterMW('bm3')
    
    subplot(414)
    ezpc(A.dnum,A.z,squeeze(A.pgood(4,:,:)))
    colorbar
    datetick('x')
    SubplotLetterMW('bm4')
    
end % makeplots

%% calculate ship velocity from it's 5 hz lat/lon, to subtract from measured velocity
% again, this from the read_nav.m file
clear dydt dxdt uship vship
dydt=diff(N.lat)*111.18e3./(diff(N.dnum_ll)*24*3600);
dxdt=diff(N.lon)*111.18e3./(diff(N.dnum_ll)*24*3600).*cos(N.lat(1:end-1)*pi/180);

uship=interp1(N.dnum_ll(1:end-1)+diff(N.dnum_ll)/2,dxdt,A.dnum);
vship=interp1(N.dnum_ll(1:end-1)+diff(N.dnum_ll)/2,dydt,A.dnum);

ib=find(abs(uship)>10 | abs(vship)>10 );uship(ib)=nan;vship(ib)=nan;


%%

close all
figure(1);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.05, 1,4);

ig=isin(N.dnum_hpr,[nanmin(A.dnum) nanmax(A.dnum)]);
axes(ax(1))
plot(N.dnum_hpr(ig),N.head(ig))
grid on
datetick('x')
cb=colorbar;killcolorbar(cb)
ylabel('ship heading')

axes(ax(2))
plot(A.dnum,uship)
hold on
plot(A.dnum,vship)
ylim(3*[-1 1])
legend('uship','vship','orientation','horizontal','location','best')
datetick('x')
cb=colorbar;killcolorbar(cb)
gridxy
grid on

axes(ax(3))
pcolor(A.dnum,A.z,A.u0)
axis ij
shading flat
colorbar
caxis(3*[-1 1])
datetick('x')

axes(ax(4))
pcolor(A.dnum,A.z,A.v0)
axis ij
shading flat
colorbar
caxis(3*[-1 1])
datetick('x')

colormap(bluered)

linkaxes(ax,'x')

%% testing to find heading offset
% this is the heading offset between the instrument and the ship, i.e. beam
% 3 was not quite aligned along-ship determined by comparing adcp heading and ship heading, although the adcp
% heading wanders since it's a compas sitting next to this big metal hull,
% so this value may need some work,but probalby ok for a first pass...
% NOTE if beam3 was aligned forward, heading_offset would be 0

%est_head_offset=0;
if est_head_offset==1
    % this is a simple way of determining approximate heading offset. basically we
    % assume the depth-average adcp speed over the upper 15-30m
    % should be ~= and opposite to the ship's speed. If there are
    % actual strong currents, this won't be true, but on average it is
    % probably approximately right.
    
    clear uv
    % form complex depth-average adcp velocity
    % nadcp.uv=nanmean(nadcp.vel1(1:30,:))/1e3+i*nanmean(nadcp.vel2(1:30,:))/1e3;
    uv=nanmean(A.u0(1:30,:))+i*nanmean(A.v0(1:30,:));
    theta=[1:360]; clear test1
    % go in a circle and plot the sum of adcp and ship speed
    for ith=1:length(theta)
        %test1(ith)=nanmean(abs(despike(uv0*exp(i*pi*theta(ith)/180)+(uship+i*vship))).^2);
        test1(ith)=nanmean(abs(uv*exp(i*pi*theta(ith)/180)+(uship+i*vship)).^2);
    end
    
    % plot the sum versus angle, and find the minimum; this is our
    % heading offset
    figure(1);clf
    plot(theta,test1)
    [val,I]=nanmin(test1)
    hold on
    plot(theta(I),test1(I),'o')
    dth=theta(I) % this is the minimum offset, our heading correction
    %
    
    clear head_offset uv u0 v0
head_offset=dth % use value found above

else
   % use head_offset given at beginning 
   disp(['using heading offset of ' num2str(head_offset) 'deg'])
end
%%

%clear head_offset uv u0 v0

% form complex velocity u + iv
uv=A.u0+sqrt(-1)*A.v0;
% rotate by heading offset
u0=real(uv*exp(i*pi*head_offset/180));
v0=imag(uv*exp(i*pi*head_offset/180));

%% subtract ship movement (actually add because they have opposite signs)
A.u=u0+repmat(uship',1,length(A.z))';
A.v=v0+repmat(vship',1,length(A.z))';

% plot the data
close all
figure(1);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.05, 1,6);

ig=isin(N.dnum_hpr,[nanmin(A.dnum) nanmax(A.dnum)]);
axes(ax(1))
plot(N.dnum_hpr(ig),N.head(ig))
grid on
datetick('x')
cb=colorbar;killcolorbar(cb)

axes(ax(2))
plot(A.dnum,uship)
hold on
plot(A.dnum,vship)
ylim(3*[-1 1])
legend('uship','vship')
datetick('x')
cb=colorbar;killcolorbar(cb)
gridxy
grid on

axes(ax(3))
pcolor(A.dnum,A.z,u0)
axis ij
shading flat
colorbar
caxis(3*[-1 1])
datetick('x')

axes(ax(4))
pcolor(A.dnum,A.z,v0)
axis ij
shading flat
colorbar
caxis(3*[-1 1])
datetick('x')

axes(ax(5))
pcolor(A.dnum,A.z,A.u)
axis ij
shading flat
colorbar
caxis(1*[-1 1])
datetick('x')

axes(ax(6))
pcolor(A.dnum,A.z,A.v)
axis ij
shading flat
colorbar
caxis(1*[-1 1])
datetick('x')

colormap(bluered)

linkaxes(ax,'x')

%% do some basic despiking

addpath('/Volumes/scienceparty_share/mfiles/pipestring/') % for despike.m

ib=find(abs(A.u)>5); A.u(ib)=NaN;
ib=find(abs(A.v)>5); A.v(ib)=NaN;

for iz=1:length(A.z)
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
ezpc(A.dnum,A.z,A.u)
datetick('x')
caxis([-1 1])

subplot(212)
ezpc(A.dnum,A.z,A.v)
datetick('x')
caxis([-1 1])

% smooth a bit in time - here's a 1-minute averaged data file

% 'Af' will be the smoothed/filtered data

a=1; b=ones(1,60)/60;
Af.dnum=A.dnum(1):1/60/24:A.dnum(end);
Af.u=NaN*ones(length(A.z),length(Af.dnum));Af.v=Af.u;
ig=find(diff(A.dnum)>0); ig=ig(2:end-1)+1;
for iz=1:length(A.z);
    Af.u(iz,:)=interp1(A.dnum(ig),nanfilt(b,a,despike(A.u(iz,ig))),Af.dnum);
    Af.v(iz,:)=interp1(A.dnum(ig),nanfilt(b,a,despike(A.v(iz,ig))),Af.dnum);
end

Af.z=A.z;

% plot the smoothed data
figure(4);clf
subplot(211)
ezpc(Af.dnum,A.z,Af.u)
datetick('x')
caxis([-1 1])

subplot(212)
ezpc(Af.dnum,A.z,Af.v)
datetick('x')
caxis([-1 1])


% despike again
for iz=1:length(Af.z)
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

% ** AP - need to check this for Aug 15  cruise **
% fix depth - up to now depth is in RANGE! (along beams)
% need to correct for 25 deg beam angle AND 15 deg instrument tilt
dth=15+25;
V.z=V.z*cos(dth*pi/180);
%V=rmfield(V,'depths')
%
% now correct for transducer location, approx 2 m down - this is determined
% by comparing to shipboard adcp, code for doing this below
V.z=V.z+2;

%%
ig=find(diff(N.dnum_ll)>0); ig=ig(1:end-1)+1;
V.lon=interp1(N.dnum_ll(ig),N.lon(ig),V.dnum);
V.lat=interp1(N.dnum_ll(ig),N.lat(ig),V.dnum);
%%
V.source=fnameshort;
V.head_offset=head_offset;
V.MakeInfo=['Made ' datestr(now) ' w/ process_pole_Aug2015_ASIRI_v2.m']
V.Note='Preliminary processing - use with caution! - contact Andy with ?s'
%save([dir_data 'processed/sentinel_1min.mat'],'V')
save(fullfile('/Volumes/scienceparty_share/sidepole/mat/',['sentinel_1min_' lab '.mat']),'V')

%clear ; close all
%%