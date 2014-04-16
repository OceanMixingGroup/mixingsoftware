function adcp=read_tao_adcp(fname)
% read_tao_adcp.m
% create mat files from ADCP data
% $Revision: 1.2 $ $Date: 2009/04/28 00:01:55 $ $Author: aperlin $	
% Originally A. Perlin
% updated by S. Warner on 2013/11/18

fid=fopen(fname,'r');
dd=textscan(fid,'%s',4,'delimiter','\r\n');
a=char(dd{:});
adcp.readme=[{'ADCP Data';'';a(1,:);''}];
ib=find(a(2,:)==',');
nblocks=str2num(a(2,ib(2)+1:ib(2)+4));
for i=1:nblocks
    dd=textscan(fid,'%s',2,'delimiter','\r\n');
    a=char(dd{:});
    ik=find(a(2,:)==',');
    nlines=str2num(a(2,ik(1)+1:ik(2)-6));
    nd=str2num(a(2,ik(2)+1:ik(2)+4));
    nl=ceil(nd/8);
    dd=textscan(fid,'%s',nl,'delimiter','\r\n');
    dd=textscan(fid,'%s',1);
    adcp(i).depth=fscanf(fid,'%f',nd);
    dd=textscan(fid,'%s',2,'delimiter','\r\n');
    ddd = char(dd{:}(2,:));
    % in newer downloads of velocity data there is a "quality" column that
    % needs to be taken into consideration
    if strcmp(ddd(27),'Q') == 1
        skipn = 3;
    else
        skipn = 2;
    end
    adcp(i).u=ones(nd,nlines)*NaN;
    adcp(i).v=ones(nd,nlines)*NaN;
    adcp(i).time=ones(1,nlines)*NaN;
    % load in the data from every time step
    for j=1:nlines
        time=fscanf(fid,'%14c',1);
        adcp(i).time(j)=datenum(time,' yyyymmdd HHMM');
        datestr(adcp(i).time(j));
        vel=fscanf(fid,'%f',nd*skipn);
        adcp(i).u(1:nd,j)=vel(1:skipn:end);
        adcp(i).v(1:nd,j)=vel(2:skipn:end);
        junk=fscanf(fid,'%1c',1);
    end
    adcp(i).u=adcp(i).u/100;
    adcp(i).v=adcp(i).v/100;
    bad=find(adcp(i).u<-9);
    adcp(i).u(bad)=NaN;
    bad=find(adcp(i).v<-9);
    adcp(i).v(bad)=NaN;
end
fclose(fid);
id=find(fname=='.');
save(fname(1:id-1),'adcp')
