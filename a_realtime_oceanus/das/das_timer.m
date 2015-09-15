% das_timer

waittime = 5*60;
dastm = timer('TimerFcn','real_time_das',...
    'Period',waittime,'executionmode','fixedrate','busymode','queue');
starttimeprocess=now+1/86400;
startat(dastm,starttimeprocess);


