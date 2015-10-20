%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%
% For 1st deployment, ADCP was deployed in ROSS with beam 2 facing
% forward/port, which I think means beam 3 was facing forward/starboard. I
% think that normal RDI conventions have beam 3 forward?
%
% From RDI manual: "internal compass is mounted so that when the X-Y plane is level, the
% compass measures the orientation of the Y-axis relative to magnetic
% north" - Y axis is aligned with beam 3. So the offset should be about
% 45deg?
%
% 08/26/15 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

% load GPS data
load('/Volumes/scienceparty_share/ROSS/Deploy1/gps/GPSLOG95')

% load ADCP data
load('/Volumes/scienceparty_share/ROSS/Deploy1/adcp/Deploy1_beam.mat')

%% Plot pitch/roll/heading

figure(1);clf
agutwocolumn(1)
wysiwyg
m=3
n=1

subplot(m,n,1)
plot(adcp.mtime,adcp.heading)
datetick('x')
grid on
SubplotLetterMW('heading')
title('Ross RDI adcp deploy1')

subplot(m,n,2)
plot(adcp.mtime,adcp.pitch)
datetick('x')
grid on
SubplotLetterMW('pitch')

subplot(m,n,3)
plot(adcp.mtime,adcp.roll)
datetick('x')
grid on
SubplotLetterMW('roll')

% save plot
print('/Volumes/scienceparty_share/ROSS/Deploy1/figures/ross_deploy1_HdPitchRoll','-dpng')
%%

% plot beam velocity

cl=0.75*[-1 1]
yl=[0 100]

figure(1);clf
agutwocolumn(1)
wysiwyg

subplot(411)
ezpc(adcp.mtime,cfg.ranges,adcp.east_vel)
caxis(cl)
colorbar
ylim(yl)
title('Beam Velocities')
SubplotLetterMW('Bm1')
datetick('x')

subplot(412)
ezpc(adcp.mtime,cfg.ranges,adcp.north_vel)
caxis(cl)
colorbar
ylim(yl)
SubplotLetterMW('Bm2')
datetick('x')

subplot(413)
ezpc(adcp.mtime,cfg.ranges,adcp.vert_vel)
caxis(cl)
colorbar
ylim(yl)
SubplotLetterMW('Bm3')
datetick('x')

subplot(414)
ezpc(adcp.mtime,cfg.ranges,adcp.error_vel)
caxis(cl)
colorbar
ylim(yl)
SubplotLetterMW('Bm4')
xlabel(['Time on ' datestr(floor(adcp.mtime(1)))])
datetick('x')

% save plot
print('/Volumes/scienceparty_share/ROSS/Deploy1/figures/ross_deploy1_BeamVels','-dpng')


%% Plot beam correlations

cl=0.75*[-1 1]
yl=[0 100]

figure(1);clf
agutwocolumn(1)
wysiwyg

subplot(411)
ezpc(adcp.mtime,cfg.ranges,squeeze(adcp.corr(:,1,:)))
%caxis(cl)
colorbar
ylim(yl)
ylabel('range')
title('Beam correlations')
SubplotLetterMW('Bm1')
datetick('x')
%
subplot(412)
ezpc(adcp.mtime,cfg.ranges,squeeze(adcp.corr(:,2,:)))
%caxis(cl)
colorbar
ylim(yl)
ylabel('range')
SubplotLetterMW('Bm2')
datetick('x')

subplot(413)
ezpc(adcp.mtime,cfg.ranges,squeeze(adcp.corr(:,3,:)))
%caxis(cl)
colorbar
ylim(yl)
ylabel('range')
SubplotLetterMW('Bm3')
datetick('x')

subplot(414)
ezpc(adcp.mtime,cfg.ranges,squeeze(adcp.corr(:,4,:)))
%caxis(cl)
colorbar
ylim(yl)
ylabel('range')
SubplotLetterMW('Bm4')
xlabel(['Time on ' datestr(floor(adcp.mtime(1)))])

datetick('x')

%% save plot
print('/Volumes/scienceparty_share/ROSS/Deploy1/figures/ross_deploy1_corr','-dpng')

%% Plot beam echo intensity

cl=0.75*[-1 1]
yl=[0 100]

figure(1);clf
agutwocolumn(1)
wysiwyg

subplot(411)
ezpc(adcp.mtime,cfg.ranges,log10(squeeze(adcp.intens(:,1,:))))
%caxis(cl)
colorbar
ylim(yl)
ylabel('range')
title('log10 Beam Intensity')
SubplotLetterMW('Bm1')
datetick('x')
%
subplot(412)
ezpc(adcp.mtime,cfg.ranges,log10(squeeze(adcp.intens(:,2,:))))
%caxis(cl)
colorbar
ylim(yl)
ylabel('range')
SubplotLetterMW('Bm2')
datetick('x')

subplot(413)
ezpc(adcp.mtime,cfg.ranges,log10(squeeze(adcp.intens(:,3,:))))
%caxis(cl)
colorbar
ylim(yl)
ylabel('range')
SubplotLetterMW('Bm3')
datetick('x')

subplot(414)
ezpc(adcp.mtime,cfg.ranges,log10(squeeze(adcp.intens(:,4,:))))
%caxis(cl)
colorbar
ylim(yl)
ylabel('range')
SubplotLetterMW('Bm4')
xlabel(['Time on ' datestr(floor(adcp.mtime(1)))])

datetick('x')

% save plot
print('/Volumes/scienceparty_share/ROSS/Deploy1/figures/ross_deploy1_echointens','-dpng')

%% add lat/lon from gps

idg=find(diff(gps.dnum)~=0);%gps.dnum(idb)=nan;
% interpolate gps to adcp time
adcp.lat=interp1(gps.dnum(idg),gps.declat(idg),adcp.mtime)
adcp.lon=interp1(gps.dnum(idg),gps.declon(idg),adcp.mtime)
adcp.headgps=interp1(gps.dnum(idg),gps.Heading(idg),adcp.mtime)
adcp.speedgps=interp1(gps.dnum(idg),gps.Speed(idg),adcp.mtime)

%% compare adcp heading to gps heading (get heading offset?)

% ** adcp compass is 180 off (mounted backwards?)?

figure(1);clf
plot(adcp.mtime,adcp.heading-135)
hold on
plot(gps.dnum,gps.Heading,'.')


%% transform to earth coordinates

addpath /Volumes/scienceparty_share/ROSS/

% correct for mounting alignment
head2=adcp.heading-145;

xadcp = adcp;
% xadcp.east_vel = xadcp.v1;
% xadcp.north_vel = xadcp.v2;
% xadcp.vert_vel = xadcp.v3;
% xadcp.error_vel = xadcp.v4;
%ttemp=N.dnum_hpr; ig=find(diff(ttemp)>0); ig=ig(1:end-1)+1;
xadcp.heading=head2;%nterp1(ttemp(ig),N.head(ig),xadcp.time);
%xadcp.pitch=interp1(ttemp(ig),N.pitch(ig),xadcp.time);
%xadcp.roll=interp1(ttemp(ig),N.roll(ig),xadcp.time);

nadcp=beam2earth_workhorse(xadcp);

%% compute boat velocity

[uross,vross]=degtrue2kl(adcp.headgps,adcp.speedgps*0.5144);
uross=uross(:)';
vross=vross(:)';
figure
plot(adcp.mtime,uross,adcp.mtime,vross)
ylabel('m/s')
datetick('x')
%% need to determine heading correction similar to pipestring by assuming
% that mean velocity over upper 20m is equal to boat speed


  nadcp.uv=nanmean(nadcp.vel1(1:15,:))+1i*nanmean(nadcp.vel2(1:15,:));
    theta=[0:0.5:360];
    
%
    % compare absolute adcp velocity over upper 30m to ship velocity? if
    % ship is moving these should be about equal? (AP)
    for ith=1:length(theta)
        test1(ith)=nanmean(abs((nadcp.uv*exp(1i*pi*theta(ith)/180)+(uross+1i*vross))).^2);
    end
    
    figure(1);clf
    plot(theta,test1)
    
    [val,I]=nanmin(test1)
    hold on
    plot(theta(I),test1(I),'o')
    theta(I)
    
    %% corect
%    head_offset=85.5; % Aug 2015 cruise
head_offset=2.5 % from above
uv=nadcp.vel1+1i*nadcp.vel2;
u0=real(uv*exp(1i*pi*head_offset/180));
v0=imag(uv*exp(1i*pi*head_offset/180));

% add ship velocity to get absolute water velcoity
% A.u=u0+repmat(uship',1,size(adcp.z,1))';
% A.v=v0+repmat(vship',1,size(adcp.z,1))';

    
%% Plot earth velocities


cl=1.5*[-1 1]
yl=[0 100]

figure(1);clf
agutwocolumn(1)
wysiwyg

subplot(411)
ezpc(adcp.mtime,cfg.ranges,nadcp.vel1)
caxis(cl)
colorbar
ylim(yl)
title('Earth Velocities (w/ boat vel)')
SubplotLetterMW('Bm1')

subplot(412)
ezpc(adcp.mtime,cfg.ranges,nadcp.vel2)
caxis(cl)
colorbar
ylim(yl)
SubplotLetterMW('Bm2')
%
subplot(413)
ezpc(adcp.mtime,cfg.ranges,nadcp.vel3)
caxis(cl)
colorbar
ylim(yl)
SubplotLetterMW('Bm3')

subplot(414)
ezpc(adcp.mtime,cfg.ranges,nadcp.vel4)
caxis(cl)
colorbar
ylim(yl)
SubplotLetterMW('Bm4')
xlabel(['Time on ' datestr(floor(adcp.mtime(1)))])

datetick('x')

% save plot
%print('/Volumes/scienceparty_share/ROSS/Deploy1/figures/ross_deploy1_echointens','-dpng')

%% Now try adding boat velocity to get absolute water veloci

uabs=u0+repmat(uross(:)',size(nadcp.vel1,1),1);
vabs=v0+repmat(vross(:)',size(nadcp.vel1,1),1);
% uabs=nadcp.vel1+repmat(uross(:)',size(nadcp.vel1,1),1);
% vabs=nadcp.vel2+repmat(vross(:)',size(nadcp.vel1,1),1);

cl=1*[-1 1]
yl=[0 100]

figure(1);clf
agutwocolumn(1)
wysiwyg

subplot(411)
ezpc(adcp.mtime,cfg.ranges,uabs)
caxis(cl)
colorbar
ylim(yl)
title('Earth Velocities ')
SubplotLetterMW('u')
datetick('x')

subplot(412)
ezpc(adcp.mtime,cfg.ranges,vabs)
caxis(cl)
colorbar
ylim(yl)
SubplotLetterMW('v')
datetick('x')

colormap(bluered)
%
%%
%A0.z=A0.z*cos(20*pi/180); % 20 deg = beam angle
adcp.z=cfg.ranges*cos(20*pi/180);

%%

nc=60 % ~1min
u_sm=conv2(uabs,ones(1,nc)/nc,'same');
v_sm=conv2(vabs,ones(1,nc)/nc,'same');
%
cl=1*[-1 1]
yl=[0 60]
xl=[13.4 14.1]

figure(2);clf
agutwocolumn(1)
wysiwyg

subplot(211)
%ezpc(adcp.lat,cfg.ranges,uabs)
ezpc(adcp.lat,adcp.z,u_sm)
caxis(cl)
colorbar
xlim(xl)
ylim(yl)
title('Ross abs. Velocities ')
ylabel('depth [m]')
SubplotLetterMW('u')
%datetick('x')

subplot(212)
ezpc(adcp.lat,adcp.z,v_sm)
%ezpc(adcp.lat,cfg.ranges,vabs)
caxis(cl)
colorbar
xlim(xl)
ylim(yl)
SubplotLetterMW('v')
ylabel('depth [m]')
%datetick('x')
xlabel('latitude')

colormap(bluered)
%% save plot
print('/Volumes/scienceparty_share/ROSS/Deploy1/figures/ross_deploy1_u_v_vslat','-dpng')
%% now plot shear


cl=0.05*[-1 1]
yl=[0 60]
xl=[13.4 14.1]

dz=nanmean(diff(adcp.z))
uz=-conv2(diffs(uabs),ones(1,nc)/nc,'same')./dz;
vz=-conv2(diffs(vabs),ones(1,nc)/nc,'same')./dz;

figure(2);clf
agutwocolumn(1)
wysiwyg

subplot(211)
%ezpc(adcp.lat,cfg.ranges,uabs)
%ezpc(adcp.lat,adcp.z,diffs(u_sm)/4)
ezpc(adcp.lat,adcp.z,uz)

caxis(cl)
colorbar
xlim(xl)
ylim(yl)
title('Ross Deploy1')
ylabel('depth [m]')
SubplotLetterMW('uz')

subplot(212)
ezpc(adcp.lat,adcp.z,vz)
caxis(cl)
colorbar
xlim(xl)
ylim(yl)
SubplotLetterMW('vz')
ylabel('depth [m]')
%datetick('x')
xlabel('latitude')

colormap(bluered)

%% save plot
print('/Volumes/scienceparty_share/ROSS/Deploy1/figures/ross_deploy1_uz_vz_vslat','-dpng')

%% save a new structure with just the fields we want

vel=struct();
vel.dnum=adcp.mtime;
vel.u=u_sm;
vel.v=v_sm;
vel.z=adcp.z;
vel.uz=uz;
vel.vz=vz;
vel.lat=adcp.lat;
vel.lon=adcp.lon;
vel.heading=adcp.heading;
vel.pitch=adcp.pitch;
vel.roll=adcp.roll;
vel.MakeInfo=['Made ' datestr(now) ' w/ Ross_Deploy1_Analysis.m']
vel.name='Deploy1'
vel.note=['Smoothed over ' num2str(nc) 'sec']

save('/Volumes/scienceparty_share/ROSS/Deploy1/adcp/Deploy1_adcp_proc.mat','vel')
%%