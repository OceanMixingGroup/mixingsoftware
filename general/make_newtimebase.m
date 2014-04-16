function time = make_newtimebase(time0,irep);
% function time = make_newtimebase(time0,irep);
% returns the time that is irepped properly. i.e. for cal files,
% cal.TIME is 16000 long, but cal.S1 is 65000 long, so irep=4;...

% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:45 $ $Author: aperlin $	

  
% make the time series for different ireps...
ind0 = 1:length(time0);
ind = 1:1/irep:length(time0);
  
time = interp1(ind0,time0,ind);
% this is irep-1 too short...
if irep>1
  dt = diff(time(end-1:end));
  time = [time time(end)+(1:irep-1)*dt];
end;

