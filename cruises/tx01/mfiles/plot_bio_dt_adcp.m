% plot_bio_dt
%

figure(23);clf

vel_range=[-.5 .5];
depth_range=[5.5 90];
%pname = (['\\Ladoga\datad\cruises\tx01\biosonics\']);
pname = (['\\Ladoga\datad\cruises\tx01\biosonics\mat\']);
%start_time=datenum(2001,9,18,5,0,0);
%end_time=datenum(2001,9,18,6,0,0);
start_time=input('enter start time:  ');
end_time=input('enter end time:  ');
time_range=[start_time,end_time];
time_str=datestr(start_time,0);
%start_time-datenum(2001,1,1,0,0,0);
% make naming strings
mnt=time_str(16:17);
hr=time_str(13:14);
dy=time_str(1:2);
mn=time_str(4:6);

transducerdepth=4.5;
horizontalsubsample=4;
verticalsubsample=4;

left=.05;
bottom=.1;
width=.85;
height=.6;

pos_rect=[left, bottom, width, height];
hecho=axes('position',pos_rect);

%plot_bio_times(pname,start_time,end_time,transducerdepth,horizontalsubsample,verticalsubsample);
plot_bio_decimated(pname,start_time,end_time);
%pause
set(gca,'ylim',depth_range)
%set(gca,'xlim',time_range)
kdatetick2

% adcp 
time_range=[start_time-datenum(2000,0,0),end_time-datenum(2000,0,0)];

bottom=.75;
height=.2;
pos_rect=[left, bottom, width, height];
hadcp=axes('position',pos_rect);

load \\ladoga\data\cruises\tx01\adcp150\mat\t150014
%load \\ladoga\data\cruises\tx01\adcp300\mat\t300009
% reference velocities
adcp=subtractbt(adcp);
adcp=removebottom(adcp,0.85);
%subplot(211)
pcolor(adcp.time-datenum(2000,0,0),adcp.depth(:,1),adcp.u)
%pcolor(adcp.lon,adcp.depth(:,1),adcp.u)
shading flat
colormap(redblue)
caxis(vel_range)
set(gca,'ylim',depth_range)
set(gca,'xlim',time_range)
axis ij
title([datestr(start_time),' to ',datestr(end_time)])
kdatetick2
%title('300 kHz')

eval(['print -djpeg60 c:\work\data\analysis\tx01\figures\',mn,dy,'_',hr,mnt])
%eval(['print -djpeg50 c:\work\data\analysis\ct01b\figures\',mn,dy,'\',fnum,'_blowup'])