function [bigdata,head,bigcal]=just_calibrate(num);
% function [data,head,cal]=just_calibrate(num);
% Recipe for calibrating a file.  
%

path_raw = 'c:\rawdata\HOME\Marlin\Marlin\';

q.script.pathname =  path_raw;
q.script.prefix = 'hm00';

bigdata = [];
bigcal=[];
numm=num;
for i=1:length(numm)
  num=numm(i)
  q.script.num=num;
  [data,head] = raw_load(q);
  [data,bad]=issync(data,head);
  if ~isempty(data.SYNC)
    cali_hm00_jmk_mg;
  end;
  if isempty(bigdata)
    bigdata=data
    bigcal=cal;
  else
    bigdata=mergefields_vert(bigdata,data);
    bigcal=mergefields_vert(bigcal,cal);
  end;
end;
