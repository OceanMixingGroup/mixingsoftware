% backup_chameleon_timer_oceanus.m
% previously timer_chambackup.m
%
% notes by sjw, January 2014
%
% This code saves the chameleon data in a second location so it is backed
% up in multiple places. 
%
% It backs up all but the LAST file in the raw folder. This is because
% don't want to copy a file that is in the process of being written.
% 
% *** Just be sure to manually copy over the final file when chameleon
% profiling is finished!!!!
%
% This should be running as the data is being processed because the
% cham-processing code should look to the the COPIED files rather than the
% ones that are being directly written by the chameleon.
%
% Use the command get(tcb) to check if the timer is still running.

% load pathnames from set_chameleon
set_chameleon_oceanus
dataprefix=cruise_id;

% directory in which the Chameleon data is stored...
% frompath = '\\poplar\ttp10\Chameleon\data\';
frompath = path_writeraw;

% directory where the Chameleon data is backed up to...
topath = path_raw;



% time increment (seconds) to backup Chameleon
polltime=60; 
tcb=timer('TimerFcn','run_chambackup_oceanus(frompath,topath,dataprefix,polltime)',...
    'Period',polltime,'executionmode','fixedrate','busymode','queue');
STARTTIME=now+1/86400;
startat(tcb,STARTTIME);
% delete(timerfind(tcb));clear tcb