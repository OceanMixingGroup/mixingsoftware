  

transducerdepth=5;
dx=4;
dz=8;
for day =[1];
  inpath = ...
    sprintf('\\\\ladoga\\datad\\cruises\\tx01\\biosonics\\DT2001\\OCT\\day%d',day)
  
  d=dir([inpath '\*.dt4'])
  for j=1:length(d)
    fin = sprintf('%s\\%s',inpath,d(j).name)
    fout = sprintf('\\\\ladoga\\datad\\cruises\\tx01\\biosonics\\mat\\200110%02d%s.mat',day,d(j).name(1:4))
    pings=fastreadbio(fin,transducerdepth,dx,dz);
    save(fout,'pings');
  end;
  
end;
