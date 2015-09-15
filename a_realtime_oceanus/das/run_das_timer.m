% run_das_timer.m


dastimer=timer('TimerFcn','run_das',...
    'Period',60*60,'executionmode','fixedrate','busymode','queue');
STARTTIME=now+1/86400;
startat(dastimer,STARTTIME);