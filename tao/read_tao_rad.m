function rad=read_tao_rad(fname)
% read_tao_rad.m
% create mat files from Shortwave Radiation data
% $Revision: 1.5 $ $Date: 2009/04/28 00:01:56 $ $Author: aperlin $	
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
dd=textscan(fid,'%s',2,'delimiter','\r\n');
a=char(dd{:});
rad.readme=strvcat('Downwelling Shortwave Radiation (W/m**2) and standard deviation ',...
    ' ',a(1,:),a(2,:),' ',qlt,srs);
ib=find(a(1,:)==',');
nblocks=str2double(a(1,ib(1)+1:ib(1)+4));
for i=1:nblocks
    dd=textscan(fid,'%s',3,'delimiter','\r\n');
    a=char(dd{:});
    ik=find(a(1,:)==',');
    nlines=str2double(a(1,ik(1)+1:end-6));
    ikk=find(a(2,:)=='Q');
    depth=str2double(a(2,20:ikk-1));
    rad(i).depth=depth(1);
%     kk=strfind(fname,'_dy');
    stdev=strfind(a(3,:),'StDev');
    mx=strfind(a(3,:),'Max');
    source=strfind(a(2,:),'SOURCE');
    secs=strfind(a(3,:),'HHMMSS');
    if ~isempty(stdev) && ~isempty(mx) && ~isempty(source)
        tmp=textscan(fid,['%s %s %f %f %f %s %s'],nlines);
        if ~isempty(secs)
            rad(i).time=datenum([char(tmp{1}) char(tmp{2})],'yyyymmddHHMMSS');
        else
            rad(i).time=datenum([char(tmp{1}) char(tmp{2})],'yyyymmddHHMM');
        end
        rad(i).swrad=tmp{3};rad(i).swrad(rad(i).swrad<-999)=NaN;
        rad(i).stdev=tmp{4};rad(i).stdev(rad(i).stdev<-999)=NaN;
        rad(i).swrad_max=tmp{5};rad(i).swrad_max(rad(i).swrad_max<-999)=NaN;
        rad(i).quality=tmp{6};
        rad(i).source=tmp{7};
    elseif ~isempty(stdev) && isempty(mx) && ~isempty(source)
        tmp=textscan(fid,['%s %s %f %f %s %s'],nlines);
        if ~isempty(secs)
            rad(i).time=datenum([char(tmp{1}) char(tmp{2})],'yyyymmddHHMMSS');
        else
            rad(i).time=datenum([char(tmp{1}) char(tmp{2})],'yyyymmddHHMM');
        end
        rad(i).swrad=tmp{3};rad(i).swrad(rad(i).swrad<-999)=NaN;
        rad(i).stdev=tmp{4};rad(i).stdev(rad(i).stdev<-999)=NaN;
        rad(i).quality=tmp{5};
        rad(i).source=tmp{6};
    elseif isempty(stdev) && isempty(mx) && ~isempty(source)
        tmp=textscan(fid,['%s %s %f %s %s'],nlines);
        if ~isempty(secs)
            rad(i).time=datenum([char(tmp{1}) char(tmp{2})],'yyyymmddHHMMSS');
        else
            rad(i).time=datenum([char(tmp{1}) char(tmp{2})],'yyyymmddHHMM');
        end
        rad(i).swrad=tmp{3};rad(i).swrad(rad(i).swrad<-999)=NaN;
        rad(i).quality=tmp{4};
        rad(i).source=tmp{5};
    elseif isempty(stdev) && isempty(mx) && isempty(source)
        tmp=textscan(fid,['%s %s %f %s'],nlines);
        if ~isempty(secs)
            rad(i).time=datenum([char(tmp{1}) char(tmp{2})],'yyyymmddHHMMSS');
        else
            rad(i).time=datenum([char(tmp{1}) char(tmp{2})],'yyyymmddHHMM');
        end
        rad(i).swrad=tmp{3};rad(i).swrad(rad(i).swrad<-999)=NaN;
        rad(i).quality=tmp{4};
   end
   dd=textscan(fid,'%s',1,'delimiter','\r\n');
end
fclose(fid);
id=find(fname=='.');
save(fname(1:id-1),'rad')
