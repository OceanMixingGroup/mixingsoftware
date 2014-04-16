% make_adcp_revelle.m
% read transfiles (that are converted from pingfiles 
% using xlate2.exe and transpingdata.m on Win98 computer)
% and saves mat files with adcp data
clear all;
set_nbadcp;
trannum=[];

d1=dir([transdir prefix '*']);
pendbytes=d1(end).bytes;
pendname=d1(end).name;

while 1
d1=dir([transdir prefix '*']);
d2=dir([matdir prefix '*']);
    
for i=1:length(d1)
    p(i)=str2num(d1(i).name(end-7:end-5));
    if d1(i).name==pendname;
        if pendbytes<d1(i).bytes
            predo=str2num(d1(i).name(end-7:end-5));
        else
            predo=[];
        end
    end
end
pendbytes=d1(end).bytes;
pendname=d1(end).name;
if isempty(d2);
    trnums=p;
else
    for i=1:length(d2)
        m(i)=str2num(d2(i).name(end-6:end-4));
    end
    trnums=setdiff(p,m);
    trnums=[trnums predo];
end

for trannum=trnums

num=1;
cfg=[];
clear adcp;
  savename = sprintf('%s/%s%03d.mat',matdir,prefix,trannum);
  d=dir(sprintf('%s%s%03dp.*',transdir,prefix,trannum));
  while num<=length(d);
    d=dir(sprintf('%s%s%03dP.*',transdir,prefix,trannum));
    if d(num).bytes>300
      fname = sprintf('%s%s%03dP.%03d',transdir,prefix,trannum,num)
      [tadcp,cfg,ens]=rdpadcp_revelle(fname,1,-1,cfg,year);
      % make good...
      if ~isempty(tadcp)
        tadcp=transadcp_ct03(tadcp,cfg);
        num = num+1;
        fprintf('NUM %d\n',num);
        if exist('adcp')==1;
          % now trim any repeats at the end....
          [t,ia]=setdiff(tadcp.mtime,adcp.mtime);
          bad = setdiff(1:length(tadcp.mtime),ia)
          if ~isempty(bad)
            tadcp = trimbad(tadcp,bad,'mtime');
          end;      
          if length(tadcp.mtime)>0
%             adcp=mergefields(adcp,tadcp,size(adcp.u,2));
            adcp=mergefields(adcp,tadcp);
          end;
        else
          adcp=tadcp;
        end;
%         save updatedsave adcp num cfg;
%         save(plotinfo.savename,'adcp','cfg');
      end; % if tadcp OK...
    end; % if the file is not empty...
  end; % end while we have new files to translate...
save(savename,'adcp','cfg');  
end

fprintf(1,'Pausing\n');
for i=1:300
    pause(1)
end;

end