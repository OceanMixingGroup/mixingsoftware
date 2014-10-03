function out=read_thermometer_bow(fname)
fid=fopen(fname);
data=textscan(fid,'%s',1e6,'delimiter','\r');
fclose(fid);
data=char(data{:});
ik=strmatch('META_DATA_PRECISION',data);
out.readme=data(1:ik,:);
out.readme=char('"Undisturbed" temperature, 0.5 m depth',out.readme);
tt=data(ik+1:end,:);
idata=strmatch('DATA',tt);
tt=tt(idata,:);
tt(:,end+1)=',';

frm=['%s %s %s %s %s'];
ttt=textscan(tt',frm,size(tt,1),'delimiter',',','bufsize',1e6);

tm=char(ttt{2});
if strcmp(tm(1,1),'"') == 1
    tm = tm(:,2:end-1);
end
out.time=datenum(tm(:,1:10))+datenum(tm(:,12:23))-fix(datenum(tm(:,12:23)));

temp = char(ttt{3});
temp = temp(:,2:end);
out.T = str2num(temp);


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

