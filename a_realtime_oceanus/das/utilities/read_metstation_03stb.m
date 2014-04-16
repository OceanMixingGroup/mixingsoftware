function out=read_metstation_03stb(fname)
fid=fopen(fname);
data=textscan(fid,'%s',1e6,'delimiter','\r');
fclose(fid);
data=char(data{:});
ik=strmatch('META_DATA_PRECISION',data);
out.readme=data(1:ik,:);
out.readme=char('Backup metstation','Use metstation_bow when possible',...
    'P - pressure [hPa]','T_air - air temperature [degC]',...
    'RH - relative humidity [%]','T_wetbulb - wet bulb temperature [degC]',...
    'T_dewpoint - dewpoint temperature [degC]',...
    'AH - absolute humidity [g/m^3]',out.readme);
tt=data(ik+1:end,:);
tt(:,end+1)=',';
frm='%s %s %s %f %s %f %s %f %s %f %s %f %s %s %s %s %s %s %s %s %s %s';
data=textscan(tt',frm,size(tt,1),'delimiter',',','bufsize',1e6);
tm=char(data{2});
out.time=datenum(tm(:,1:10))+datenum(tm(:,12:23))-fix(datenum(tm(:,12:23)));
out.P=data{4};
out.T_air=data{6};
out.RH=data{8};
out.T_wetbulb=data{10};
out.T_dewpoint=data{12};
out.AH=data{14};
end % function out=read_metstation_03stb(fname)

