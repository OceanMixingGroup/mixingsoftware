function out=read_radiometer_metmast(fname)
fid=fopen(fname);
data=textscan(fid,'%s',1e6,'delimiter','\r');
fclose(fid);
data=char(data{:});
ik=strmatch('META_DATA_PRECISION',data);
out.readme=data(1:ik,:);
out.readme=char('LW - computed longwave downwelling irradiance [W m^{-2}]',...
    'SW - computed shortwave downwelling irradiance [W m^{-2}]',out.readme);
tt=data(ik+1:end,:);
tt(:,end+1)=',';
frm='%s %s %s %s %s %f %f %f %f %f %f %f %s';
data=textscan(tt',frm,size(tt,1),'delimiter',',','bufsize',1e6);
tm=char(data{2});
out.time=datenum(tm(:,1:10))+datenum(tm(:,12:23))-fix(datenum(tm(:,12:23)));
out.LW=data{8};
out.SW=data{11};
end % function out=read_radiometer_metmast(fname)

