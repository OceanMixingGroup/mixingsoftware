function ctd=read_ctd_oceanus(fname) 
%
% ctd=read_ctd_oceanus(fname) 
%
% used by make_ctd_oceanus to read the .cnv files from the Oceanus CTD.
%
% Originally by Sasha Perlin
% updated by Sally Warner, January 2014

% open & load file
fid=fopen(fname);
readme=textscan(fid,'%s',1,'delimiter','\r');
aa=char(readme{:});
while ~strncmpi(aa(end,:),'*END*',5)
    readme=textscan(fid,'%s',1,'delimiter','\r');
    aa(end+1,1:length(char(readme{:})))=char(readme{:});
end
tt=strfind(cellstr(aa),'* NMEA UTC (Time)');
tlat=strfind(cellstr(aa),'* NMEA Latitude');
tlon=strfind(cellstr(aa),'* NMEA Longitude');
tvar=strfind(cellstr(aa),'# name');
ivar=0;
for ii=1:length(tt)
    if~isempty(tt{ii})
        ind=ii;
        time=datenum(aa(ind,21:40),'mmm dd yyyy HH:MM:SS');
    end
    if~isempty(tlon{ii})
        ind=ii;
        ctd.lon=str2num(aa(ind,19:23))+str2num(aa(ind,24:29))/60;
        if strmatch('W',aa(ind,:)')
            ctd.lon=-ctd.lon;
        end
    end
    if~isempty(tlat{ii})
        ind=ii;
        ctd.lat=str2num(aa(ind,18:21))+str2num(aa(ind,22:26))/60;
        if strmatch('S',aa(ind,:)')
            ctd.lat=-ctd.lat;
        end
    end
    if~isempty(tvar{ii})
        ivar=ivar+1;
    end
end
frm=[];
for ii=1:ivar
    frm=[frm ' %f'];
end
% data=textscan(fid,frm,'delimiter',' ');
status=fseek(fid,1,'cof'); % reposition 1 byte close to the end
data=textscan(fid,frm,1e6);
ctd.cond1=data{1};
ctd.cond2=data{2};
ctd.sigma1=data{3};
ctd.sigma2=data{4};
ctd.depth=data{5};
ctd.fluorescence_WET_Labs=data{6};
ctd.oxygen_saturation_Garcia_Gordon=data{7};
ctd.oxygen_saturation_Weiss=data{8};
ctd.oxygen_raw=data{9};
ctd.par=data{10};
ctd.theta1=data{11};
ctd.theta2=data{12};
ctd.sal1=data{13};
ctd.sal2=data{14};
ctd.pressure=data{15};
ctd.readme=aa;
fclose(fid);
