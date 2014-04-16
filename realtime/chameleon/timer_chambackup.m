% timer_chambackup.m
%
frompath = '\\poplar\ttp10\Chameleon\data\';
% directory in which the Chameleon data is stored...
topath = '\\graf-zeppelin\data2\ttp10\data\chameleon\';
% directory where the Chameleon data is backed up to...
dataprefix='ttp10';
% time increment (seconds) to backup Chameleon
polltime=60; 
tcb=timer('TimerFcn','run_chambackup(frompath,topath,dataprefix,polltime)',...
    'Period',polltime,'executionmode','fixedrate','busymode','queue');
STARTTIME=now+1/86400;
startat(tcb,STARTTIME);
% delete(timerfind(tcb));clear tcb