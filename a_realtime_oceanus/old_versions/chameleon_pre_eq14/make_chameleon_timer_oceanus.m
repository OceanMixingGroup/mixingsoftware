% make_chameleon_timer.m
%
% comments added by sjw, January 2014
%
% ****************************************************
% This code processes the raw chemeleon data. It uses a timer, so new files
% are processed and added to the summary files as they appear.
%
% If you need to stop this code from running. The timer object is named
% "tmc," so simply type the command: stop(tmc)
% ****************************************************



% initialize the workspace
clear all; close all; 

% set_chameleon sets the path to the raw chameleon data (path_raw), to the 
% processed chameleon data (path_cham), and the summary file of all of the
% chameleon saved so far. Also input cruise_id, start_file, and max depth.
set_chameleon_oceanus;

% creates a structure "cham". Calls a number of functions that ask where
% the data is saved and what datafile to start with. Note that if you have
% already processed files #1-10, you don't have to start at 11, start at 1
% again and the code knows what has already been processed. It will also
% ask for a maximum number of depth bins. Make sure this is deeper than the
% deepest profile depth.
initialize_summary_file_oceanus;



% create a figure with the button "Stop Chameleon" that can be pressed to
% stop the chameleon processing timer.
figure(1);
temp=get(0,'ScreenSize');
% set the position for this figure (may want to change these settings if it
% is an awkward size on your screen)
posi=[0 0 temp(3)/3.5 temp(4)/6]; 
set(gcf,'position',posi)
clf
fig.h(1)=uicontrol('units','normalized','position',[0 0 1 1],...
    'string','Stop Chameleon','fontunits','normalized','fontsize',0.2,...
    'callback','delete(timerfind(tmc));clear tmc');


% start the timer which runs process_file_oceanus to 
tmc=timer('TimerFcn','process_file_oceanus',...
    'Period',10,'executionmode','fixedrate','busymode','queue');
STARTTIME=now+1/86400;
startat(tmc,STARTTIME);
% delete(timerfind(tmc));clear tmc