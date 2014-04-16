% plot_bio_dt
%

%pname = (['\\Ladoga\datad\cruises\tx01\biosonics\']);
pname = (['\\Ladoga\datad\cruises\tx01\biosonics\mat\']);
%start_time=datenum(2001,9,18,5,0,0);
%end_time=datenum(2001,9,18,6,0,0);
start_time=input('enter start time:  ');
end_time=input('enter end time:  ');
time_str=datestr(start_time,0);
%start_time-datenum(2001,1,1,0,0,0);
% make naming strings
mnt=time_str(16:17);
hr=time_str(13:14);
dy=time_str(1:2);
mn=time_str(4:6);

transducerdepth=4.5;
horizontalsubsample=1;
verticalsubsample=1;

figure(23);clf
%plot_bio_times(pname,start_time,end_time,transducerdepth,horizontalsubsample,verticalsubsample);
plot_bio_decimated(pname,start_time,end_time);
title([datestr(start_time),' to ',datestr(end_time)])
set(gca,'ylim',[6 60])
set(gca,'tickdir','out')
caxis([0.5 3.3])
kdatetick2

%eval(['print -djpeg60 c:\work\data\analysis\tx01\figures\',mn,dy,'_',hr,mnt])
%eval(['print -djpeg50 c:\work\data\analysis\ct01b\figures\',mn,dy,'\',fnum,'_blowup'])