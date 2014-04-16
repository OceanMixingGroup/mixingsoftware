% make_workhorse.m
% read short or long term averaged files using read_workhorse.m
% (read_surveyor.m), translates data to useful format (workhorsetosci.m)
% and saves mat files with adcp data
      % vel1: to EAST
      % vel2: to NORTH
      % vel3: to SURFACE
      % vel4: ERROR velocity
      % time1: ADCP time
      % time2: GPS time
clear all;
set_workhorse;
trannum=input('Enter number of ADCP transect --> ');

d=dir(sprintf('%s%s%03d_*.%s',survdir,survprefix,trannum,type_of_average));
  
while isempty(d)
   disp('No data... Waiting...')
   for i=1:60
     pause(1)
   end;
   d=dir(sprintf('%s%s%03d_*.%s',survdir,survprefix,trannum,type_of_average));
end   
sd=dir(sprintf('%s%s*.mat',survsavedir,survprefix));
num=0;
cfg=[];
clear adcp;
% savename = sprintf('%s/%s%03d%s.mat',survsavedir,survprefix,trannum,type_of_average);
ddd=0;
while 1
  d=dir(sprintf('%s%s%03d_*.%s',survdir,survprefix,trannum,type_of_average));
  fname = sprintf('%s%s%03d_%06d.%s',survdir,survprefix,trannum,num,type_of_average);
  dd=dir(fname);
  if dd.bytes>ddd
    ddd=dd.bytes;
    if dd.bytes>3
      ddd=dd.bytes;
      fname = sprintf('%s%s%03d_%06d.%s',survdir,survprefix,trannum,num,type_of_average)
      tadcp=read_surveyor(fname);
      adcp=workhorsetosci(tadcp);
      savename = sprintf('%s%s%03d%03d%s.mat',survsavedir,survprefix,trannum,num,type_of_average);
      save(savename,'adcp');  
    end
  else
    fname = sprintf('%s%s%03d_%06d.%s',survdir,survprefix,trannum,num+1,type_of_average);
    if exist(fname)
      num=num+1;
      ddd=0;
    else
      fprintf(1,'Pausing\n');
      for i=1:waittime
        pause(1)
        fprintf(1,'.');
      end;
    end
  end
end
