%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Ross_Asiri_ADCP_processing.m
%
% (formerly Ross_Deploy2_ADCP_processing.m)
%
% Process RDI 300kHz ADCP data from ROSS deployments on Aug 2015 ASIRI cruise.
%
% For 1st deployment, ADCP was deployed in ROSS with beam 2 facing
% forward/port, which I think means beam 3 was facing back/port
%
% From RDI manual: "internal compass is mounted so that when the X-Y plane is level, the
% compass measures the orientation of the Y-axis relative to magnetic
% north" - Y axis is aligned with beam 3.
%
% 08/27/15 - A.Pickering - apickering@coas.oregonstate.edu
% 09/06/15 - AP - Added Deploy3 info. Also realized heading offset for
% mounting should be +135 instead of -135?
% 09/09/15 - AP - fix bug with heading/uross/vross when heading is close to
% 0 or 360.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

saveplots=1
savedata=1
makerawplots=0

%~ choose which deployment/file to process
%name='Deploy1' ; time_offset=0;
%name='Deploy2'; time_offset=0;
%name='Deploy3' ; time_offset=-13/86400 ;
%name='Deploy4' ; time_offset=-16/86400 ;
name='Deploy5' ; time_offset=-16/86400 ;
%name='Deploy6'; time_offset=-22/86400 ;

BaseDir=fullfile('/Volumes/scienceparty_share/ROSS/',name)
FigDir=fullfile(BaseDir,'figures')

% load GPS data
disp('Loading gps data')
gpsfile=fullfile(BaseDir,'gps',['GPSLOG_' name '.mat'])
load(gpsfile)

% load ADCP data (in beam coordinates)
disp('Loading ADCP data (beam coordinates')
adcpfile=fullfile(BaseDir,'adcp','mat',[name '_beam.mat'])
load(adcpfile)

%% Check if time-offset is correct by comparing ADCP and gps heading at sharp changes
% %figure out time offset
% time_offset=-22/86400 ;

figure(1);clf
plot(gps.dnum,gps.Heading,'.-')
hold on
h2=adcp.heading+135;
ib=find(h2>360);h2(ib)=h2(ib)-360;
plot(adcp.mtime+time_offset,h2,'.-')
grid on

%%
% add time offset (determined from comparing adcp and gps heading)
adcp.mtime=adcp.mtime+time_offset;

%% throw out some bad data

ib=find(squeeze(adcp.corr(:,1,:))<30);
adcp.east_vel(ib)=nan;

ib=find(squeeze(adcp.corr(:,2,:))<30);
adcp.north_vel(ib)=nan;


%%
% Plot pitch/roll/heading

close all

figure(1);clf
agutwocolumn(1)
wysiwyg
m=5;
n=1;
ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.05, n,m);

axes(ax(1))
plot(adcp.mtime,adcp.heading)
datetick('x')
grid on
SubplotLetterMW('heading')
title(['Ross RDI adcp ' name ])

axes(ax(2))
plot(adcp.mtime,adcp.pitch)
ylim(25*[-1 1])
datetick('x')
grid on
gridxy
SubplotLetterMW('pitch')

axes(ax(3))
plot(adcp.mtime,adcp.roll)
datetick('x')
ylim(25*[-1 1])
grid on
gridxy
SubplotLetterMW('roll')

axes(ax(4))
plot(gps.dnum,gps.Speed*0.514)
ylim([0 5])
datetick('x')
ylabel('m/s')
grid on
gridxy
SubplotLetterMW('gps speed')

axes(ax(5))
%plot(gps.dnum,gps.declat)
[AX,H1,H2]=plotyy(gps.dnum,gps.declat,gps.dnum,gps.declon)
H1.LineWidth=2;H2.LineWidth=2;
AX(1).YLabel.String='lat';
AX(2).YLabel.String='lon';
datetick('x')
grid on
ylabel('Lat')
xlabel(['Time on ' datestr(floor(nanmin(gps.dnum)))])

linkaxes(ax,'x')

if saveplots==1
    print(fullfile(FigDir,['ross_' name '_HdPitchRollSpd']),'-dpng')
end
%
%%
if makerawplots==1
    
%% plot beam velocity

close all

cl=0.5*[-1 1];
yl=[0 100];

figure(1);clf
agutwocolumn(1)
wysiwyg

subplot(511)
plot(adcp.mtime,adcp.heading)
cb=colorbar;killcolorbar(cb)
datetick('x')

subplot(512)
ezpc(adcp.mtime,cfg.ranges,adcp.east_vel)
caxis(cl)
colorbar
ylim(yl)
title('Beam Velocities')
SubplotLetterMW('Bm1')
datetick('x')

subplot(513)
ezpc(adcp.mtime,cfg.ranges,adcp.north_vel)
caxis(cl)
colorbar
ylim(yl)
SubplotLetterMW('Bm2')
datetick('x')

subplot(514)
ezpc(adcp.mtime,cfg.ranges,adcp.vert_vel)
caxis(cl)
colorbar
ylim(yl)
SubplotLetterMW('Bm3')
datetick('x')

subplot(515)
ezpc(adcp.mtime,cfg.ranges,adcp.error_vel)
caxis(cl)
colorbar
ylim(yl)
SubplotLetterMW('Bm4')
xlabel(['Time on ' datestr(floor(adcp.mtime(1)))])
datetick('x')

colormap(bluered)

if saveplots==1
    print(fullfile(FigDir,['ross_' name '_BeamVels']),'-dpng')
end

%pause(3)
%%
close all
% Plot beam correlations

cl=0.75*[-1 1];
yl=[0 100];

figure(1);clf
agutwocolumn(1)
wysiwyg

subplot(411)
ezpc(adcp.mtime,cfg.ranges,squeeze(adcp.corr(:,1,:)))
colorbar
ylim(yl)
ylabel('range')
title('Beam correlations')
SubplotLetterMW('Bm1')
datetick('x')
%
subplot(412)
ezpc(adcp.mtime,cfg.ranges,squeeze(adcp.corr(:,2,:)))
colorbar
ylim(yl)
ylabel('range')
SubplotLetterMW('Bm2')
datetick('x')

subplot(413)
ezpc(adcp.mtime,cfg.ranges,squeeze(adcp.corr(:,3,:)))
colorbar
ylim(yl)
ylabel('range')
SubplotLetterMW('Bm3')
datetick('x')

subplot(414)
ezpc(adcp.mtime,cfg.ranges,squeeze(adcp.corr(:,4,:)))
colorbar
ylim(yl)
ylabel('range')
SubplotLetterMW('Bm4')
xlabel(['Time on ' datestr(floor(adcp.mtime(1)))])

datetick('x')
%%
if saveplots==1
    print(fullfile(FigDir,['ross_' name '_corr']),'-dpng')
end

pause(3)
%%

close all
% Plot beam echo intensity

cl=0.75*[-1 1];
yl=[0 100];

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

if saveplots==1
    print(fullfile(FigDir,['ross_' name '_echointens']),'-dpng')
end

pause(3)

end

%% compute the boat velocity from gps data

[uross,vross]=degtrue2kl(gps.Heading,gps.Speed*0.5144);
uross=uross(:)';
vross=vross(:)';

%% add lat/lon from gps to adcp structure

clear idg1 t1 lat1
%idg=find(diffs(gps.dnum)~=0 ) ;%

[Y,I]=sort(gps.dnum);
t1=gps.dnum(I);
lat1=gps.declat(I);
lon1=gps.declon(I);
ur=uross(I);
vr=vross(I);

%%
idg=find(diffs(t1)~=0);
adcp.lat=interp1(t1(idg),lat1(idg),adcp.mtime);
adcp.lon=interp1(t1(idg),lon1(idg),adcp.mtime);
adcp.uross=interp1(t1(idg),ur(idg),adcp.mtime);
adcp.vross=interp1(t1(idg),vr(idg),adcp.mtime);

figure(11);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.03, 1,3);

axes(ax(1))
plot(adcp.mtime,adcp.heading)
hold on
grid on
datetick('x')
SubplotLetterMW('Heading')

axes(ax(2))
plot(gps.dnum,gps.Speed*0.5144)
ylabel('m/s')
datetick('x')
%legend('uross','vross')
SubplotLetterMW('speed')
grid on
gridxy

axes(ax(3))
plot(adcp.mtime,adcp.uross,adcp.mtime,adcp.vross)
ylabel('m/s')
datetick('x')
legend('uross','vross')
grid on
gridxy
xlabel(['Time on ' datestr(floor(adcp.mtime(1)))])

linkaxes(ax,'x')

%% now transform velocity to earth coordinates

addpath('/Volumes/scienceparty_share/ROSS/mfiles/')

xadcp = adcp;
disp('transforming from beam to earth coordinates')
nadcp=beam2earth_workhorse(xadcp);

% compute actual depth (range up to this point)
% **need to add blank distance?
%A0.z=A0.z*cos(20*pi/180); % 20 deg = beam angle
adcp.z=cfg.ranges*cos(20*pi/180);

%% plot the transformed earth velocities (boat velocity still in them)

figure(1);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.015, 1,5);

cl=1.5*[-1 1]
yl=[0 70]

axes(ax(1))
plot(adcp.mtime,adcp.uross)
hold on
plot(adcp.mtime,adcp.vross)
cb=colorbar;killcolorbar(cb)
grid on
gridxy
datetick('x')
xlim([nanmin(adcp.mtime) nanmax(adcp.mtime)])
title(['ROSS ' name])
legend('uross','vross','location','best')

axes(ax(2))
ezpc(adcp.mtime,adcp.z,nadcp.vel1)
caxis(cl)
colorbar
datetick('x')
xlim([nanmin(adcp.mtime) nanmax(adcp.mtime)])
ylim(yl)
SubplotLetterMW('u')
ylabel('depth [m]')

axes(ax(3))
ezpc(adcp.mtime,adcp.z,nadcp.vel2)
caxis(cl)
colorbar
datetick('x')
xlim([nanmin(adcp.mtime) nanmax(adcp.mtime)])
ylim(yl)
SubplotLetterMW('v')
ylabel('depth [m]')

axes(ax(4))
ezpc(adcp.mtime,adcp.z,nadcp.vel3)
caxis(cl)
colorbar
datetick('x')
xlim([nanmin(adcp.mtime) nanmax(adcp.mtime)])
ylim(yl)
SubplotLetterMW('w')
ylabel('depth [m]')

axes(ax(5))
ezpc(adcp.mtime,adcp.z,nadcp.vel4)
caxis(cl)
datetick('x')
xlim([nanmin(adcp.mtime) nanmax(adcp.mtime)])
ylim(yl)
colorbar
SubplotLetterMW('err')
ylabel('depth [m]')
xlabel(['Time on ' datestr(floor(adcp.mtime(1)))])

colormap(bluered)

linkaxes(ax,'x')

%%

if strcmp(name,'Deploy4')
idb=find(adcp.mtime<datenum(2015,9,7,14,1,0) | adcp.mtime>datenum(2015,9,8,8,39,5) );
nadcp.vel1(:,idb)=nan;
nadcp.vel2(:,idb)=nan;
end


if strcmp(name,'Deploy5')
idb=find(adcp.mtime<datenum(2015,9,10,3,12,53) | adcp.mtime>datenum(2015,9,10,8,26,54) );
nadcp.vel1(:,idb)=nan;
nadcp.vel2(:,idb)=nan;
end


%% determine heading correction similar to pipestring by assuming
% that mean velocity over upper 20m is equal to boat speed


nadcp.uv=nanmean(nadcp.vel1(1:15,:))+1i*nanmean(nadcp.vel2(1:15,:));
theta=[0:1:360];

% compare absolute adcp velocity over upper 30m to ship velocity? if
% ship is moving these should be about equal? (AP)
for ith=1:length(theta)

    test1(ith)=nanmean( abs( ( nadcp.uv*exp(1i*pi*theta(ith)/180) + (adcp.uross+1i*adcp.vross) )).^2);
%     
%     figure(32);clf
%     plot(adcp.mtime,abs(nadcp.uv*exp(1i*pi*theta(ith)/180)))
%     hold on
%     plot(adcp.mtime,abs(adcp.uross+1i*adcp.vross))
%     legend('adcp','ross')    
%     title(['theta=' num2str(theta(ith))])
%     ylim([0 5])
%     pause(0.1)
    

end

figure(1);clf
plot(theta,test1)

[val,I]=nanmin(test1)
hold on
plot(theta(I),test1(I),'o')
theta(I)
% 
% %%
% 
% figure(75);clf
% 
% ax1=subplot(311)
% plot(adcp.mtime,adcp.uross)
% hold on
% plot(adcp.mtime,adcp.vross)
% datetick('x')
% grid on
% 
% ax2=subplot(312)
% plot(adcp.mtime,nanmean(nadcp.vel1(1:15,:)))
% hold on
% plot(adcp.mtime,nanmean(nadcp.vel2(1:15,:)))
% datetick('x')
% grid on
% 
% ax3=subplot(313)
% uv=nadcp.vel1+1i*nadcp.vel2;
% head_offset_2=theta(I)
% u0=real(uv*exp(1i*pi*head_offset_2/180));
% v0=imag(uv*exp(1i*pi*head_offset_2/180));
% plot(adcp.mtime,nanmean(u0(1:15,:)))
% hold on
% plot(adcp.mtime,nanmean(v0(1:15,:)))
% grid on
% gridxy
% datetick('x')
% 
% linkaxes([ax1 ax2 ax3])
%%

%% apply heading correction
clear head_offset_2 uv u0 v0
head_offset_2=theta(I) % from above
%head_offset_2=0 % 

uv=nadcp.vel1+1i*nadcp.vel2;
u0=real(uv*exp(1i*pi*head_offset_2/180));
v0=imag(uv*exp(1i*pi*head_offset_2/180));

% Now add boat velocity to get absolute water velocity
clear uabs vabs
uabs=u0+repmat(adcp.uross(:)',size(nadcp.vel1,1),1);
vabs=v0+repmat(adcp.vross(:)',size(nadcp.vel1,1),1);

%

figure(1);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.025, 1,6);

cl=1.5*[-1 1]
yl=[0 70]

axes(ax(1))
[AX,H1,H2]=plotyy(adcp.mtime,adcp.lat,adcp.mtime,adcp.lon)
cb=colorbar;killcolorbar(cb)
H1.LineWidth=2;H2.LineWidth=2;
AX(1).YLabel.String='lat';
AX(2).YLabel.String='lon';
datetick('x')
grid on
title(['ROSS ' name])

axes(ax(2))
plot(adcp.mtime,adcp.uross)
hold on
plot(adcp.mtime,adcp.vross)
cb=colorbar;killcolorbar(cb)
grid on
gridxy
datetick('x')
xlim([nanmin(adcp.mtime) nanmax(adcp.mtime)])
legend('uross','vross','location','best')

axes(ax(3))
ezpc(adcp.mtime,adcp.z,u0)
caxis(cl)
colorbar
datetick('x')
xlim([nanmin(adcp.mtime) nanmax(adcp.mtime)])
ylim(yl)
SubplotLetterMW('u0')
ylabel('depth [m]')

axes(ax(4))
ezpc(adcp.mtime,adcp.z,v0)
caxis(cl)
colorbar
datetick('x')
xlim([nanmin(adcp.mtime) nanmax(adcp.mtime)])
ylim(yl)
SubplotLetterMW('v0')
ylabel('depth [m]')

axes(ax(5))
ezpc(adcp.mtime,adcp.z,uabs)
caxis(cl)
colorbar
datetick('x')
xlim([nanmin(adcp.mtime) nanmax(adcp.mtime)])
ylim(yl)
SubplotLetterMW('u')
ylabel('depth [m]')

axes(ax(6))
ezpc(adcp.mtime,adcp.z,vabs)
caxis(cl)
datetick('x')
xlim([nanmin(adcp.mtime) nanmax(adcp.mtime)])
ylim(yl)
colorbar
SubplotLetterMW('v')
ylabel('depth [m]')
xlabel(['Time on ' datestr(floor(adcp.mtime(1)))])

colormap(bluered)

linkaxes(ax,'x')

if saveplots==1
    print(fullfile(FigDir,['ross_' name '_u0v0_u_v']),'-dpng')
end


%% save a new structure with just the fields we want

vel=struct();
vel.corr=adcp.corr;
vel.dnum=adcp.mtime;
vel.u=uabs;
vel.v=vabs;
vel.z=adcp.z;
vel.lat=adcp.lat;
vel.lon=adcp.lon;
vel.heading=adcp.heading;
vel.uross=adcp.uross;
vel.vross=adcp.vross;
vel.pitch=adcp.pitch;
vel.roll=adcp.roll;
vel.MakeInfo=['Made ' datestr(now) ' w/ Ross_Asiri_ADCP_processing.m'];
vel.name=name;
vel.note=['not smoothed'];
vel.Headinginfo=[' heading correction of ' num2str(head_offset_2) ' applied']
vel.time_offset=time_offset

if strcmp(vel.name,'Deploy3')
    vel.Note2='Pulses in v between 05:00 and 06:00 might be bad data... trying to figure out what happened there'
end

if savedata==1
% save a file with unsmoothed data
disp('saving file with raw (unsmoothed) earth velocities')
save( fullfile(BaseDir,'adcp','mat',[name '_adcp_proc.mat']) ,'vel')
end

%% option to start with above saved file

% clear ; close all
% %load('/Volumes/scienceparty_share/ROSS/Deploy2/adcp/mat/deploy2_adcp_proc.mat')
% load('/Volumes/scienceparty_share/ROSS/Deploy1/adcp/mat/deploy1_adcp_proc.mat')

clear adcp cfg ens

%% now do some editing, cleaning up etc.

%% manually nan out some obviously bad data

if strcmp(vel.name,'Deploy2')
    
    % period at beginning during deployment
    idb0=find(vel.dnum<datenum(2015,8,25,23,44,0) );
    
    % short period where speed/heading changed rapidly
    idb1=isin(vel.dnum,[datenum(2015,8,26,1,12,0) datenum(2015,8,26,1,36,0)]);
    
    % longer period at end where ross was doing doughnuts...
    idb2=find(vel.dnum>datenum(2015,8,26,7,39,0) );
    
    vel.u(:,[idb0 idb1 idb2])=nan;
    %   vel.u(:,[idb0 idb1 idb2])=nan;
    vel.v(:,[idb0 idb1 idb2])=nan;
    %  vel.v(:,[idb0 idb1 idb2])=nan;
end

if strcmp(vel.name,'Deploy3')
    % Ross got off track for a bit (accidentally sent it back to first
    % waypoint)
    idb=isin(vel.dnum,[datenum(2015,9,5,9,43,0) datenum(2015,9,5,9,57,0)]);
    
    % begginng/launch period
    idb0=find(vel.dnum<datenum(2015,9,5,3,0,45));
        
    idb1=isin(vel.dnum,[datenum(2015,9,5,8,14,24) datenum(2015,9,5,8,19,23)]);
    
    idb2=isin(vel.dnum,[datenum(2015,9,5,3,5,0) datenum(2015,9,5,3,9,27)]);
    
    idb4=isin(vel.dnum,[datenum(2015,9,5,8,32,47) datenum(2015,9,5,8,34,29)]);
    
    idb3=find(vel.dnum > datenum(2015,9,5,10,38,15)); % end/recovery
        
    vel.u(:,[idb0 idb idb1 idb2 idb3 idb4])=nan;
    vel.v(:,[idb0 idb idb1 idb2 idb3 idb4])=nan;
    
    %05-Sep-2015 09:56:39
end
%%


figure(1);clf

ax1=subplot(211)
ezpc(vel.dnum,vel.z,vel.u)
caxis(1.5*[-1 1])

ax2=subplot(212)
ezpc(vel.dnum,vel.z,vel.v)
caxis(1.5*[-1 1])

linkaxes([ax1 ax2])
%
%% interpolate through small (in time) gaps



disp('interpolating through small gaps')
maxgap=5; % max gap to interpolate (1sec sampling, so ~=seconds)
u2=nan*ones(size(vel.u));
v2=u2;
for whz=1:length(vel.z)
    u2(whz,:)=FillGaps(vel.u(whz,:),maxgap);
    v2(whz,:)=FillGaps(vel.v(whz,:),maxgap);
end

addpath('/Volumes/scienceparty_share/mfiles/pipestring/')
%despike
u3=nan*ones(size(vel.u));
v3=u3;
for whz=1:length(vel.z)
    [u3(whz,:)]=despike(u2(whz,:));
    [v3(whz,:)]=despike(v2(whz,:));
end

%%
close all

figure(1);clf
agutwocolumn(1)
wysiwyg

ax0=subplot(411);
plot(vel.dnum,vel.uross,vel.dnum,vel.vross)
datetick('x')

ax1=subplot(412);
plot(vel.dnum,vel.lat)
datetick('x')

ax2=subplot(413);
ezpc(vel.dnum,vel.z,u3)
caxis([-1 1])
ylim([0 80])
datetick('x')

ax3=subplot(414);
ezpc(vel.dnum,vel.z,v3)
caxis([-1 1])
ylim([0 80])
datetick('x')

linkaxes([ax0 ax1 ax2 ax3],'x')

colormap(bluered)

vel.u=u3;
vel.v=v3;

if savedata==1
% save a file with unsmoothed but cleaned data
disp('saving file with clean but unsmoothed earth velocities')
save( fullfile(BaseDir,'adcp','mat',[name '_adcp_proc_clean_nosmooth.mat']) ,'vel')
end

%% Now smooth a bit also

clear nc u_sm v_sm
nc=30;
u_sm=conv2(u3,ones(1,nc)/nc,'same');
v_sm=conv2(v3,ones(1,nc)/nc,'same');

%
cl=1*[-1 1];
yl=[0 60];

figure(2);clf
agutwocolumn(1)
wysiwyg

ax1=subplot(211)
ezpc(vel.dnum,vel.z,u_sm)
datetick('x')
caxis(cl)
colorbar
ylim(yl)
title('Ross abs. Velocities ')
ylabel('depth [m]')
SubplotLetterMW('u')

ax2=subplot(212)
ezpc(vel.dnum,vel.z,v_sm)
caxis(cl)
colorbar
ylim(yl)
SubplotLetterMW('v')
ylabel('depth [m]')
datetick('x')
xlabel(['time on ' datestr(floor(vel.dnum(1)))])

colormap(bluered)

linkaxes([ax1 ax2])

%
if saveplots==1
    print(fullfile(FigDir,['ross_' name '_u_v_vstime_clean_30secsmooth']),'-dpng')
end

%% plot vs lat
% 
% %
% cl=1*[-1 1];
% yl=[0 60];
% %xl=[13.4 14.1];
% xl=[nanmin(vel.lat) nanmax(vel.lat)]
% 
% figure(2);clf
% agutwocolumn(1)
% wysiwyg
% 
% ax1=subplot(211);
% ezpc(vel.lat,vel.z,u_sm)
% caxis(cl)
% colorbar
% xlim(xl)
% ylim(yl)
% title('Ross abs. Velocities ')
% ylabel('depth [m]')
% SubplotLetterMW('u');
% 
% ax2=subplot(212);
% ezpc(vel.lat,vel.z,v_sm)
% caxis(cl)
% colorbar
% xlim(xl)
% ylim(yl)
% SubplotLetterMW('v');
% ylabel('depth [m]')
% xlabel('Latitude [^oN]')
% 
% linkaxes([ax1 ax2])
% colormap(bluered)
% 
% if saveplots==1
%     print(fullfile(FigDir,['ross_' name '_u_v_vslat_30sec']),'-dpng')
% end
% 

%% now plot shear


cl=0.05*[-1 1];
yl=[0 60];
%xl=[13.4 14.1];

dz=nanmean(diff(vel.z));
uz=conv2(-diffs(u2),ones(1,nc)/nc,'same')./dz;
vz=conv2(-diffs(v2),ones(1,nc)/nc,'same')./dz;

uz(1,:)=nan;
vz(1,:)=nan;

figure(3);clf
agutwocolumn(1)
wysiwyg

ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.015, 1,2);

axes(ax(1))
ezpc(vel.dnum,vel.z,uz);
caxis(cl)
colorbar
ylim(yl)
title(['Ross ' vel.name])
ylabel('depth [m]')
SubplotLetterMW('du/dz');
datetick('x')

axes(ax(2))
ezpc(vel.dnum,vel.z,vz);
caxis(cl)
colorbar
%xlim(xl)
ylim(yl)
SubplotLetterMW('dv/dz');
ylabel('depth [m]')
datetick('x')
%xlabel('latitude [^oN]')

colormap(bluered)
%
if saveplots==1
    print(fullfile(FigDir,['ross_' name '_uz_vz']),'-dpng')
end

%% save a new modified structure with the smoothed fields

% cut off any velocity below 60m
iz=find(vel.z<60);
vel=rmfield(vel,'corr');
vel.u=u_sm(iz,:);
vel.v=v_sm(iz,:);
vel.z=vel.z(iz);
vel.uz=uz(iz,:);
vel.vz=vz(iz,:);
vel.note=['Smoothed over ' num2str(nc) 'sec']

if savedata==1
disp('saving structure with smoothed vel')
save( fullfile(BaseDir,'adcp','mat',[name '_adcp_proc_smoothed.mat']) ,'vel')
end

%% plot the final smoothed data

figure(1);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.025, 1,4);

cl=0.75*[-1 1]
yl=[0 70]

axes(ax(1))
[AX,H1,H2]=plotyy(vel.dnum,vel.lat,vel.dnum,vel.lon)
cb=colorbar;killcolorbar(cb)
H1.LineWidth=2;H2.LineWidth=2;
AX(1).YLabel.String='lat';
AX(2).YLabel.String='lon';
datetick('x')
grid on
title(['ROSS ' name])

axes(ax(2))
plot(vel.dnum,vel.uross)
hold on
plot(vel.dnum,vel.vross)
cb=colorbar;killcolorbar(cb)
grid on
gridxy
datetick('x')
xlim([nanmin(vel.dnum) nanmax(vel.dnum)])
legend('uross','vross','location','best')

axes(ax(3))
ezpc(vel.dnum,vel.z,vel.u)
caxis(cl)
colorbar
datetick('x')
xlim([nanmin(vel.dnum) nanmax(vel.dnum)])
ylim(yl)
SubplotLetterMW('u')
ylabel('depth [m]')

axes(ax(4))
ezpc(vel.dnum,vel.z,vel.v)
caxis(cl)
colorbar
datetick('x')
xlim([nanmin(vel.dnum) nanmax(vel.dnum)])
ylim(yl)
SubplotLetterMW('v')
ylabel('depth [m]')

% axes(ax(5))
% ezpc(adcp.mtime,adcp.z,uabs)
% caxis(cl)
% colorbar
% datetick('x')
% xlim([nanmin(adcp.mtime) nanmax(adcp.mtime)])
% ylim(yl)
% SubplotLetterMW('u')
% ylabel('depth [m]')
% 
% axes(ax(6))
% ezpc(adcp.mtime,adcp.z,vabs)
% caxis(cl)
% datetick('x')
% xlim([nanmin(adcp.mtime) nanmax(adcp.mtime)])
% ylim(yl)
% colorbar
% SubplotLetterMW('v')
% ylabel('depth [m]')
xlabel(['Time on ' datestr(floor(vel.dnum(1)))])

colormap(bluered)

linkaxes(ax,'x')

if saveplots==1
    print(fullfile(FigDir,['ross_' name '_FinalSmoothed_uv']),'-dpng')
end
%%