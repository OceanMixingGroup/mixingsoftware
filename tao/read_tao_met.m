function met=read_tao_met(fname)
% read_tao_met.m
% create mat files from meteo data (wind, air temperature, SST, rel.
% humidity)
% $Revision: 1.7 $ $Date: 2011/07/29 23:31:10 $ $Author: aperlin $	
% Originally A. Perlin
fid=fopen(fname,'r');
qlt=strvcat('Quality Code Definitions:',...
'0 = datum missing',...
'1 = highest quality; Pre/post-deployment calibrations agree to within',...
'sensor specifications.  In most cases only pre-deployment calibrations have',...
'been applied',...
'2 = default quality; Pre-deployment calibrations applied.  Default',...
'value for sensors presently deployed and for sensors which were either not',...
'recovered or not calibratable when recovered.',...
'3 = adjusted data; Pre/post calibrations differ, or original data do',...
'not agree with other data sources (e.g., other in situ data or climatology),',...
'or original data are noisy.  Data have been adjusted in an attempt to',...
'reduce the error.',...
'4 = lower quality; Pre/post calibrations differ, or data do not agree',...
'with other data sources (e.g., other in situ data or climatology), or data',...
'are noisy.  Data could not be confidently adjusted to correct for error.',...
'5 = sensor or tube failed');
srs=strvcat('Source code definitions:',...
'    0 - No Sensor, No Data ',...
'    1 - Real Time (Telemetered Mode)',...
'    2 - Derived from Real Time',...
'    3 - Temporally Interpolated from Real Time',...
'    4 - Source Code Inactive at Present',...
'    5 - Recovered from Instrument RAM (Delayed Mode)',...
'    6 - Derived from RAM',...
'    7 - Temporally Interpolated from RAM');
dd=textscan(fid,'%s',3,'delimiter','\r\n');
a=char(dd{:});
met.readme=strvcat('Meteorological data (wind, air temperature, SST, rel. humidity) ',...
    ' ',a(1,:),a(2,:),a(3,:),' ',qlt,srs);
ib=find(a(1,:)==',');
nblocks=str2num(a(1,ib(1)+1:ib(1)+4));
for i=1:nblocks
    dd=textscan(fid,'%s',3,'delimiter','\r\n');
    a=char(dd{:});
    ik=find(a(1,:)==',');
    nlines=str2double(a(1,ik(1)+1:end-6));
    ikk=find(a(2,:)=='Q');
    depth=str2num(a(2,18:ikk-1));
    met(i).depth_wind=depth(1);
    met(i).depth_airt=depth(5);
    met(i).depth_sst=depth(6);
    met(i).depth_rh=depth(7);
    secs=strfind(a(3,:),'HHMMSS');
    source=strfind(a(2,:),'SOURCE');
    if ~isempty(source)
        tmp=textscan(fid,['%s %s %f %f %f %f %f %f %f %s %s'],nlines);
    else
        tmp=textscan(fid,['%s %s %f %f %f %f %f %f %f %s'],nlines);
    end    
    if ~isempty(secs)
        met(i).time=datenum([char(tmp{1}) char(tmp{2})],'yyyymmddHHMMSS');
    else
        met(i).time=datenum([char(tmp{1}) char(tmp{2})],'yyyymmddHHMM');
    end
    met(i).uwnd=tmp{3};
    met(i).vwnd=tmp{4};
    met(i).airt=tmp{7};
    met(i).sst=tmp{8};
    met(i).rh=tmp{9};
    met(i).uwnd(met(i).uwnd<-99)=NaN;
    met(i).vwnd(met(i).vwnd<-99)=NaN;
    met(i).airt(met(i).airt<-99)=NaN;
    met(i).sst(met(i).sst<-99)=NaN;
    met(i).rh(met(i).rh<-99)=NaN;
    quality=char(tmp{10});
    met(i).quality_wndspd=cellstr(quality(:,1));
    met(i).quality_wnddir=cellstr(quality(:,2));
    met(i).quality_airt=cellstr(quality(:,3));
    met(i).quality_sst=cellstr(quality(:,4));
    met(i).quality_rh=cellstr(quality(:,5));
    if ~isempty(source)
        source=char(tmp{11});
        met(i).source_wndspd=cellstr(source(:,1));
        met(i).source_wnddir=cellstr(source(:,2));
        met(i).source_airt=cellstr(source(:,3));
        met(i).source_sst=cellstr(source(:,4));
        met(i).source_rh=cellstr(source(:,5));
    end
   dd=textscan(fid,'%s',1,'delimiter','\r\n');
end
fclose(fid);
id=find(fname=='.');
save(fname(1:id-1),'met')
