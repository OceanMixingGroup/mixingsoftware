%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% GPS velocity during deploy4 looks odd, i'm going to compute speed from
% differentating lat/lon and see how that compares.
%
% 
%
% 09/09/15 - A. Pickering
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

saveplots=0

%name='Deploy1' ; time_offset=0;
%name='Deploy2'; time_offset=0;
%name='Deploy3' ; time_offset=-13/86400 ;
name='Deploy4' ; time_offset=-16/86400 ;

%BaseDir=fullfile('/Users/Andy/Cruises_Research/Asiri/ROSSlocal/ROSS/',name)
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

%%

adcp.mtime=adcp.mtime+time_offset;

%%


idg=find(diff(gps.dnum)~=0);%gps.dnum(idb)=nan;
% interpolate gps to adcp time
adcp.lat=interp1(gps.dnum(idg),gps.declat(idg),adcp.mtime);
adcp.lon=interp1(gps.dnum(idg),gps.declon(idg),adcp.mtime);
%adcp.headgps=interp1(gps.dnum(idg),gps.Heading(idg),adcp.mtime);
%adcp.speedgps=interp1(gps.dnum(idg),gps.Speed(idg),adcp.mtime);

%[uross2,vross2]=degtrue2kl(adcp.headgps,adcp.speedgps*0.5144);

[uross,vross]=degtrue2kl(gps.Heading,gps.Speed*0.5144);
uross=uross(:)';
vross=vross(:)';

adcp.uross=interp1(gps.dnum(idg),uross(idg),adcp.mtime);
adcp.vross=interp1(gps.dnum(idg),vross(idg),adcp.mtime);

figure(1);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.015, 1,5);

axes(ax(1))
plot(gps.dnum,gps.declat)
hold on
plot(adcp.mtime,adcp.lat,'.')
SubplotLetterMW('lat')

axes(ax(2))
plot(gps.dnum,gps.Speed*0.5144)
hold on
ylim([0 3])
SubplotLetterMW('speed')
ylabel('m/s')

axes(ax(3))
plot(gps.dnum,gps.Heading,'.')
hold on
plot(adcp.mtime,adcp.heading,'.')
SubplotLetterMW('\Theta')
grid on

% uross and vross the way i've been computing it
axes(ax(4))
plot(gps.dnum,uross,'.')
ylim(3*[-1 1])
hold on
plot(adcp.mtime,adcp.uross,'.')
gridxy
grid on
SubplotLetterMW('uross')

axes(ax(5))
plot(gps.dnum,vross,'.')
ylim(3*[-1 1])
hold on
plot(adcp.mtime,adcp.vross,'.')
gridxy
grid on
SubplotLetterMW('vross')

linkaxes(ax,'x')

%% compute speed from d/lat d/lon and compare

%%%  ship velocity, to subtract
dydt=diff(gps.declat)*111.18e3./(diff(gps.dnum)*24*3600);
dxdt=diff(gps.declon)*111.18e3./(diff(gps.dnum)*24*3600).*cos(gps.declat(1:end-1)*pi/180);

dydt=[dydt ;nan];
dxdt=[dxdt ;nan];
%%
%uship=interp1(N.dnum_ll(1:end-1)+diff(N.dnum_ll)/2,dxdt,adcp.time);
%vship=interp1(N.dnum_ll(1:end-1)+diff(N.dnum_ll)/2,dydt,adcp.time);

figure(2);clf
% plot(gps.dnum,uross)
% hold on
% plot(gps.dnum,dxdt)

plot(gps.dnum,vross)
hold on
plot(gps.dnum,dydt)

%%