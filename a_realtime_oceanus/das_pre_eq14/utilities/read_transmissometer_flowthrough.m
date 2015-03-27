function out=read_transmissometer_flowthrough(fname)
fid=fopen(fname);
data=textscan(fid,'%s',1e6,'delimiter','\r');
fclose(fid);
data=char(data{:});
ik=strmatch('META_DATA_PRECISION',data);
out.readme=data(1:ik,:);

tt=data(ik+1:end,:);
tt(:,end+1)=',';

frm=['%s %s %s'];
ttt=textscan(tt',frm,size(tt,1),'delimiter',',','bufsize',1e6);

tm=char(ttt{2});
if strcmp(tm(1,1),'"') == 1
    tm = tm(:,2:end-1);
end
out.time=datenum(tm(:,1:10))+datenum(tm(:,12:23))-fix(datenum(tm(:,12:23)));

volt = char(ttt{3});
volt = volt(:,2:7);
out.Volt = str2num(volt);


% tt(:,end+1)=',';
% frm='%s %s %s %s %s';
% data=textscan(tt',frm,size(tt,1),'delimiter',',','bufsize',1e6);
% tm=char(data{2});
% if strcmp(tm(1,1),'"') == 1
%     tm = tm(:,2:end-1);
% end
% out.time=datenum(tm(:,1:10))+datenum(tm(:,12:23))-fix(datenum(tm(:,12:23)));
% tt=char(data{3});
% out.T=str2num(tt(:,2:7));
end % function out=read_transmissometer_flowthrough(fname)

