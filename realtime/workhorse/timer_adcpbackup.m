% timer_adcpbackup.m
%
% directory in which the ADCP data is stored...
frompath = '\\dirigible\work\st10\';
% directory where the ADCP data is backed up to...
topath = 'c:\work\st10\';
dataprefix='st10';
% time increment (seconds) to backup ADCP
polltime=3600; 
tab=timer('TimerFcn','run_adcpbackup(frompath,topath,dataprefix,polltime)',...
    'Period',polltime,'executionmode','fixedrate','busymode','queue');
STARTTIME=now+1/86400;
startat(tab,STARTTIME);
% delete(timerfind(tab));clear tab