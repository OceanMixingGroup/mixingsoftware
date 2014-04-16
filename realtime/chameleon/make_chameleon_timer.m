% save_files.m
clear all; close all; fclose all;
% cd c:\work\eq08\mfiles\chameleon
initialize_summary_file;
n=0;
load nextfile;
figure(1);
temp=get(0,'ScreenSize');
% posi=[0 -52 temp(3)/2 temp(4)-7]; 
posi=[0 0 temp(3)/3.5 temp(4)/6]; 
set(gcf,'position',posi)
clf
fig.h(1)=uicontrol('units','normalized','position',[0 0 1 1],...
    'string','Stop Chameleon','fontunits','normalized','fontsize',0.2,...
    'callback','delete(timerfind(tmc));clear tmc');
tmc=timer('TimerFcn','process_file_timer',...
    'Period',20,'executionmode','fixedrate','busymode','queue');
STARTTIME=now+1/86400;
startat(tmc,STARTTIME);
% delete(timerfind(tmc));clear tmc