dirname = 'c:\data\hm02\cals\july2002';
d = dir([dirname '\*.dat']);
for i=29:length(d)
  drop_point(d(i).name,'hm02cals');
end;
