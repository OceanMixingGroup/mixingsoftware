function bigadcp=makebigtrim(start,stop,rawdir,matdir,prefix);
% merges trim sonar files from start to stop time

d=dir([rawdir 'pingdata*']);

bigadcp = [];
for i=1:length(d);
  % get the time..
  t = datenum(d(i).date);
  if t>start & t<=stop & exist([matdir prefix d(i).name(end-2:end) '.mat'])
    load([matdir prefix d(i).name(end-2:end)]);
    bigadcp=mergefields(bigadcp,adcp);
  end;
  
end;

