function out=read_oxygen_mll_flowthrough(fname)

fid=fopen(fname);
data=textscan(fid,'%s',1e6,'delimiter','\r');
fclose(fid);
data=char(data{:});
ik=strmatch('META_DATA_PRECISION',data);
out.readme=data(1:ik,:);
out.readme=char('oxygen [ml/ml]','',out.readme);

tt=data(ik+1:end,:);
tt(:,end+1)=',';
frm=['%s %s %s %s %s %s'];
ttt=textscan(tt',frm,size(tt,1),'delimiter',',','bufsize',1e6);

tm=char(ttt{2});
if strcmp(tm(1,1),'"') == 1
    tm = tm(:,2:end-1);
end

out.time=datenum(tm(:,1:10))+datenum(tm(:,12:23))-fix(datenum(tm(:,12:23)));

dummy=char(ttt{6});
out.oxygen = str2num(dummy(:,1:15));



