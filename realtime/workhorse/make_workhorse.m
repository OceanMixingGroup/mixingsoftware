% make_workhorse.m
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
prefix=input('Enter prefix --> ');
set_workhorse;
trannum=input('Enter number of ADCP transect --> ');

d=dir(sprintf('%s%s%03d_*.%s',workhorsedir,prefix,trannum,type_of_average));
  
while isempty(d)
   disp('No data... Waiting...')
   for i=1:120
     pause(1)
   end;
   d=dir(sprintf('%s%s%03d_*.%s',workhorsedir,prefix,trannum,type_of_average));
end
sd=dir(sprintf('%s%s*.mat',savedir,prefix));
num=0;
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
    'callback','kill_script=1');
kill_script=0;

while kill_script==0
  d=dir(sprintf('%s%s%03d_*.%s',workhorsedir,prefix,trannum,type_of_average));
  fname = sprintf('%s%s%03d_%06d.%s',workhorsedir,prefix,trannum,num,type_of_average);
  dd=dir(fname);
  if dd.bytes>ddd
    ddd=dd.bytes;
    if dd.bytes>3
      ddd=dd.bytes;
      fname = sprintf('%s%s%03d_%06d.%s',workhorsedir,prefix,trannum,num,type_of_average)
      try
          tadcp=read_workhorse(fname);
      catch
          fprintf('Had trouble: %s\n',lasterr);
          fprintf('Pausing 20 seconds ...');
          for i=1:20
              pause(1);
          end
          tadcp=read_workhorse(fname);
      end
      adcp=workhorsetosci(tadcp);
%       adcp=workhorsetosci(tadcp);
%   angle_offcet=-90;
%   U = adcp.vel1+adcp.vel2*sqrt(-1);
%   U = U.*exp(sqrt(-1)*angle_offcet*pi/180);
%   adcp.vel1 = real(U);
%   adcp.vel2 = imag(U);
      savename = sprintf('%s/%s%03d%03d%s.mat',savedir,prefix,trannum,num,type_of_average);
      save(savename,'adcp');  
    end
  else
    fname = sprintf('%s%s%03d_%06d.%s',workhorsedir,prefix,trannum,num+1,type_of_average);
    if exist(fname)
      num=num+1;
      ddd=0;
    else
      fprintf(1,'Pausing\n');
      for i=1:waittime
          if kill_script==0
              pause(1)
              if i==round(i/10)*10
                  fprintf(1,'.');
              end
          else
              return;
          end
      end;
    end
  end
end
