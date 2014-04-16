% DOES NOT WORK !
% make_workhorse_uhdas.m
% read short or long term averaged files using read_workhorse.m
% (read_surveyor.m), translates data to useful format (workhorsetosci.m)
% and saves mat files with adcp data
      % vel1: to EAST
      % vel2: to NORTH
      % vel3: to SURFACE
      % vel4: ERROR velocity
      % time1: computer time
      % time2: ADCP internal clock
      % navfirsttime, navlasttime: GPS time
clear all;
% adcppath
% radcppath
prefix=input('Enter ADCP type (''wh300'' or ''os75'') --> ');
set_workhorse;
trannum=input('Enter daynam --> ');

d=dirs(sprintf('%s%03d_*.raw',workhorsedir,trannum),'fullfile',1);
  
while isempty(d)
   disp('No data... Waiting...')
   for i=1:120
     pause(1)
   end;
   d=dirs(sprintf('%s%03d_*.raw',workhorsedir,trannum),'fullfile',1);
end
sd=dir(sprintf('%s%s*.mat',savedir,prefix));
ff=find(d(1).name=='.',1,'last');
num=d(1).name(ff-5:ff-1);
cfg=[];
clear adcp;
% savename = sprintf('%s/%s%03d%s.mat',savedir,prefix,trannum,type_of_average);
ddd=0;
figure(2);
temp=get(0,'ScreenSize');
% posi=[0 -52 temp(3)/2 temp(4)-7]; 
posi=[temp(3)-temp(3)/3.5 0 temp(3)/3.5 temp(4)/6]; 
set(gcf,'position',posi)
clf
fig.h(1)=uicontrol('units','normalized','position',[0 0 1 1],...
    'string','Stop ADCP','fontunits','normalized','fontsize',0.2,...
    'callback','delete(timerfind(tmu));clear tmu');
fnum=1;
tuc=timer('TimerFcn','run_workhorse_uhdas_timer',...
    'Period',waittime,'executionmode','fixedrate','busymode','queue');
STARTTIME=now+1/86400;
startat(tuc,STARTTIME);
% delete(timerfind(tuc));clear tuc
