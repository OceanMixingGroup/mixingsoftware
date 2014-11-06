function out=read_echosounder_well(fname)
fid=fopen(fname);
disp(fname)
data=textscan(fid,'%s',1e6,'delimiter','\r');
fclose(fid);
data=char(data{:});
ik=strmatch('META_DATA_PRECISION',data);
out.readme=data(1:ik,:);
data=data(ik+1:end,:);
data(:,end+1)=',';
frm=['%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s'];
data=textscan(data',frm,size(data,1),'delimiter',',','bufsize',1e6);

% read in the time
tm=char(data{2});
if strcmp(tm(1,1),'"') == 1
    tm = tm(:,2:end-1);
end
out.time=datenum(tm(:,1:10))+datenum(tm(:,12:23))-fix(datenum(tm(:,12:23)));

% read in the data from the echosounder
%%% not sure what the units are or what the data are telling us is
%%% happening physically. Not even sure that these are the useful columns
%%% to be grabbing...
vv3 =char(data{8});
out.echo_3kHz=str2num(vv3(:,1:5));

vv12 = char(data{17});
out.echo_12kHz=str2num(vv12(:,1:5));
end
