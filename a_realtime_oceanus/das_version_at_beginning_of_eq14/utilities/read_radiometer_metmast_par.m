function out=read_radiometer_metmast_par(fname)

fid=fopen(fname);
data=textscan(fid,'%s',1e6,'delimiter','\r');
fclose(fid);
data=char(data{:});
ik=strmatch('META_DATA_PRECISION',data);
out.readme=data(1:ik,:);
data=data(ik+1:end,:);
data(:,end+1)=',';
frm=['%s %s %s'];
tt=textscan(data',frm,size(data,1),'delimiter',',','bufsize',1e6);
tm=char(tt{2});
if strcmp(tm(1,1),'"') == 1
    tm = tm(:,2:end-1);
end
out.time=datenum(tm(:,1:10))+datenum(tm(:,12:23))-fix(datenum(tm(:,12:23)));

out.parVolts=char(tt{3});
out.parVolts=str2num(out.parVolts(:,2:7));
