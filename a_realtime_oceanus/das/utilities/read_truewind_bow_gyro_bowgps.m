function out=read_truewind_bow_gyro_bowgps(fname)
% adapted from read_truewind_bow_adu5 which I think are the same


fid=fopen(fname);
data=textscan(fid,'%s',1e6,'delimiter','\r');
fclose(fid);
data=char(data{:});
ik=strmatch('META_DATA_PRECISION',data);
out.readme=data(1:ik,:);
% out.readme=char('dir_r - wind direction relative [deg]',...
%     'spd_r - wind speed relative [m/s]',...
%     'sog - speed over ground [m/s]',...
%     'cog - course over ground [deg]',...
%     'u_t - eastward wind speed true [m/s]',...
%     'v_t - northward wind speed true [m/s]',...
%     'spd_t - wind speed true [m/s]',...
%     'dir_r - wind direction true [deg]','',out.readme);
out.readme=char('u_t - eastward wind speed true [m/s]',...
    'v_t - northward wind speed true [m/s]','',out.readme);
tt=data(ik+1:end,:);
idata=strmatch('DATA',tt);
tt=tt(idata,:);
tt(:,end+1)=',';
frm=['%s %s %s' '%s %s %s' '%s %f %f %s %s'];
data=textscan(tt',frm,size(tt,1),'delimiter',',','bufsize',1e6);
tm=char(data{2});

out.time=datenum(tm(:,1:10))+datenum(tm(:,12:23))-fix(datenum(tm(:,12:23)));
out.u_t=data{8}*0.5144; %convert knots to m/s
out.v_t=data{9}*0.5144;


% frm=['%s %s %s' '%s %s %s' '%s %f %f %f %f'];
% data=textscan(tt',frm,size(tt,1),'delimiter',',','bufsize',1e6);
% tm=char(data{2});
% out.time=datenum(tm(:,1:10))+datenum(tm(:,12:23))-fix(datenum(tm(:,12:23)));
% tm=char(data{3});out.dir_r=str2num(tm(:,2:4));
% tm=char(data{4});out.spd_r=str2num(tm(:,2:7))*0.5144;
% tm=char(data{5});out.heading=str2num(tm(:,2:8));
% tm=char(data{6});out.sog=str2num(tm(:,2:7))*0.5144;
% tm=char(data{7});out.cog=str2num(tm(:,2:7));
% out.u_t=data{8}*0.5144;
% out.v_t=data{9}*0.5144;
% out.spd_t=data{10}*0.5144;
% out.dir_t=data{11};
% 
% out.time=datenum(tt(:,6:16))+datenum(tt(:,18:29))-fix(datenum(tt(:,18:29)));
% out.dir_r=str2num(tt(:,34:36));out.dir_r(out.dir_r==999)=NaN;
% out.spd_r=str2num(tt(:,41:46))*0.5144;out.spd_r(out.spd_r>150)=NaN;
% out.heading=str2num(tt(:,51:57));
% out.sog=str2num(tt(:,62:67));
% out.cog=str2num(tt(:,72:77));
% out.u_t=str2num(tt(:,80:95));out.u_t(out.u_t>150)=NaN;
% out.v_t=str2num(tt(:,99:115));out.v_t(out.v_t>150)=NaN;
end 

