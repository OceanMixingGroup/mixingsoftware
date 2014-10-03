function out=read_thermometer_fwdintake(fname)
fid=fopen(fname);
data=textscan(fid,'%s',1e6,'delimiter','\r');
fclose(fid);
data=char(data{:});
ik=strmatch('META_DATA_PRECISION',data);
out.readme=data(1:ik,:);
out.readme=char('Forward intake temperature, 3 m depth',out.readme);
data=data(ik+1:end,:);
data(:,end+1)=',';
frm=['%s %s %s'];
data=textscan(data',frm,size(data,1),'delimiter',',','bufsize',1e6);
tm=char(data{2});
if strcmp(tm(1,1),'"') == 1
    tm = tm(:,2:end-1);
end
out.time=datenum(tm(:,1:10))+datenum(tm(:,12:23))-fix(datenum(tm(:,12:23)));
vv=char(data{3});
out.T=str2num(vv(:,2:7));
end % function out=read_thermometer_fwdintake(fname)