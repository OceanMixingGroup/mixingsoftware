% plot_bio
%
mn='sep';
dy='16';
fnum='12172637';
fname = (['c:\work\data\analysis\tx01\raw\biosonics\',mn,'\day',dy,'\',fnum,'.dt4']);
transducerdepth=4.5;
horizontalsubsample=10;
verticalsubsample=10;
clear pings
pings=fastreadbio(fname,transducerdepth,horizontalsubsample,verticalsubsample);
% find zeros and negative values before computing logs
idl=find(pings.sample <= 0);
pings.sample(idl)=1e-3;

figure(21)
imagesc(pings.datenum,pings.depth,log(pings.sample));
kdatetick
caxis([2 10])

eval(['print -djpeg50 c:\work\data\analysis\tx01\figures\',mn,dy,'\',fnum])
%eval(['print -djpeg50 c:\work\data\analysis\ct01b\figures\',mn,dy,'\',fnum,'_blowup'])