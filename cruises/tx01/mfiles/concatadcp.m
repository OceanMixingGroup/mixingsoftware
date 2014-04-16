adcp=concatadcp(adcp1,adcp2);

fnames = fieldnames(adcp1);
adcp=[];
for i=1:length(fnames)
  dat1 = getfield(adcp1,fnames{i});
  dat2 = getfield(adcp2,fnames{i});
  adcp=setfield(adcp,fnames{i},[dat1 dat2]);
end;
