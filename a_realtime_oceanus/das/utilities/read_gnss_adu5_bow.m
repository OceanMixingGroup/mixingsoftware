function out=read_gnss_adu5_bow(fname)
% disp(fname)
fid=fopen(fname);
data=textscan(fid,'%s',1e6,'delimiter','\r');
fclose(fid);
data=char(data{:});
ik=strmatch('META_DATA_PRECISION',data);
out.readme=data(1:ik,:);
tt=data(ik+1:end,:);
igpggl=strmatch('GPGLL',tt(:,37:end));
igphdt=strmatch('GPHDT',tt(:,37:end));

% position
if ~isempty(igpggl)
    gpggl=tt(igpggl,:);
    gpggl(:,end+1)=',';
    frm='%s %s %s %f %s %f %s %s %s %s';
    gpggl=textscan(gpggl',frm,size(gpggl,1),'delimiter',',','bufsize',1e6);
    tm=char(gpggl{2});
    if strcmp(tm(1,1),'"') == 1
        tm = tm(:,2:end-1);
    end
    out.pos_time=datenum(tm(:,1:10))+datenum(tm(:,12:23))-fix(datenum(tm(:,12:23)));
    out.lat=gpggl{4};
    out.lat=fix(out.lat/100)+(out.lat/100-fix(out.lat/100))/60*100;
    nsign=strfind(char(gpggl{5})','S');
    out.lat(nsign)=-out.lat(nsign);
    out.lon=gpggl{6};
    out.lon=fix(out.lon/100)+(out.lon/100-fix(out.lon/100))/60*100;
    nsign=strfind(char(gpggl{7})','W');
    out.lon(nsign)=-out.lon(nsign);
else
    out.pos_time=[];out.lat=[];out.lon=[];
end
% heading
if ~isempty(igphdt)
    gphdt=tt(igphdt,:);
    gphdt(:,end+1)=',';
    frm='%s %s %s %f %s';
    gphdt=textscan(gphdt',frm,size(gphdt,1),'delimiter',',','bufsize',1e6);
    tm=char(gphdt{2});
    if strcmp(tm(1,1),'"') == 1
        tm = tm(:,2:end-1);
    end
    out.heading_time=datenum(tm(:,1:10))+datenum(tm(:,12:23))-fix(datenum(tm(:,12:23)));
    out.heading=gphdt{4};
else
    out.heading_time=[];out.heading=[];
end

end % function out=read_gnss_adu5_bow(fname)
