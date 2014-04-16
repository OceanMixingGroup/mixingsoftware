% plot_bio
%
mn='sep';
dy='21';
%fnum='00040665';
fnum=input('enter file no.:  ');
fnum=num2str(fnum+1e8);
fname = (['\\Ladoga\datad\cruises\tx01\biosonics\DT2001\',mn,'\day',dy,'\',fnum(2:9),'.dt4']);
%fname = (['\\Pequod\data\\dt\data\dt2001\',mn,'\day',dy,'\',fnum,'.dt4']);
transducerdepth=4.5;
horizontalsubsample=1;
verticalsubsample=1;
clear pings
%pings=read_bio2(fname,transducerdepth,verticalsubsample);
pings=fastreadbio(fname,transducerdepth,horizontalsubsample,verticalsubsample);
%find zeros and negative values before computing logs
idl=find(pings.sample <= 0);
pings.sample(idl)=1e-3;

figure(23);clf
imagesc(pings.datenum,pings.depth,log(pings.sample));
kdatetick
set(gca,'tickdir','out')
caxis([2 8])

%eval(['print -djpeg50 c:\work\data\analysis\tx01\figures\',mn,dy,'\',fnum])
%eval(['print -djpeg50 c:\work\data\analysis\ct01b\figures\',mn,dy,'\',fnum,'_blowup'])