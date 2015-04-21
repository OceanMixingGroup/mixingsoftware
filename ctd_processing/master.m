icast = [310:311];
for a = 1:length(icast)
  b = icast(a);
  disp(b)
  load_hex_iwise(b);
end
if icast(1) <= 138 & icast(end) >= 139
  clear all
  load ../../ctd/processed/IWISE10_138.mat
  datad138 = datad;
  datad_1m138 = datad_1m;
  datau138 = datau;
  datau_1m138 = datau_1m;
  clear datad datad_1m datau datau_1m
  load ../../ctd/processed/IWISE10_139.mat
  datad139 = datad;
  datad_1m139 = datad_1m;
  datau139 = datau;
  datau_1m139 = datau_1m;
  clear datad datad_1m datau datau_1m

  datad.t1 = [datad138.t1; datad139.t1];
  datad.t2 = [datad138.t2; datad139.t2];
  datad.c1 = [datad138.c1; datad139.c1];
  datad.c2 = [datad138.c2; datad139.c2];
  datad.s1 = [datad138.s1; datad139.s1];
  datad.s2 = [datad138.s2; datad139.s2];
  datad.theta1 = [datad138.theta1; datad139.theta1];
  datad.theta2 = [datad138.theta2; datad139.theta2];
  datad.sigma1 = [datad138.sigma1; datad139.sigma1];
  datad.sigma2 = [datad138.sigma2; datad139.sigma2];
  datad.oxygen = [datad138.oxygen; datad139.oxygen];
  datad.trans = [datad138.trans; datad139.trans];
  datad.fl = [datad138.fl; datad139.fl];
  datad.lon = [datad138.lon; datad139.lon];
  datad.lat = [datad138.lat; datad139.lat];
  datad.time = [datad138.time; datad139.time];
  datad.nscan = [datad138.nscan; datad139.nscan];
  datad.depth = [datad138.depth; datad139.depth];
  datad.p = [datad138.p; datad139.p];
  datad.datenum = [datad138.datenum; datad139.datenum];
  datau = datau139;
  !rm ../../ctd/processed/IWISE10_138.mat
  !rm ../../ctd/processed/IWISE10_139.mat
  save('../../ctd/processed/IWISE10_138.mat', 'datad', 'datau')
  close call; clear all
end
