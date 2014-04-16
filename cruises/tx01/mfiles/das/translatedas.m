dasdir = '\\ladoga\datad\cruises\tx01\das\';

d=dir([dasdir '\*.ck'])
das=[];
for i=1:length(d);
  fname = [dasdir  d(i).name];
  tdas=dasread(fname);
  if isempty(das)
    das=tdas;
  else
    fnames = fieldnames(tdas);
    for j=1:length(fnames)
      dat=[getfield(das,fnames{j}) getfield(tdas,fnames{j})];
      das=setfield(das,fnames{j},dat);
    end;
  end;
end;

  bad = find(das.lon<-1e4);
  das.lon(bad)=NaN;
  bad = find(das.lat<-1e4);
  das.lat(bad)=NaN;
