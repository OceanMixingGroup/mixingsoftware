function out=read_fluorometer_flowthrough(fname)
fid=fopen(fname);
data=textscan(fid,'%s',1e6,'delimiter','\r');
fclose(fid);
data=char(data{:});
ik=strmatch('META_DATA_PRECISION',data);
out.readme=data(1:ik,:);
data=data(ik+1:end,:);
data(:,end+1)=',';
frm=['%s %s %s'];
data=textscan(data',frm,size(data,1),'delimiter',',','bufsize',1e6);
tm=char(data{2});
out.time=datenum(tm(:,1:10))+datenum(tm(:,12:23))-fix(datenum(tm(:,12:23)));
vv=char(data{3});
out.Volt=str2num(vv(:,2:7));
end % function out=read_fluorometer_flowthrough(fname)
