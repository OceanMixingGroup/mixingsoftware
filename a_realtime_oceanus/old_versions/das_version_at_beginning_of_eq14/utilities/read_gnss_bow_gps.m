function out=read_gnss_bow_gps(fname)
%
% Note, adapted from read_gnss_adu5_bow which essentially contains the same
% data. However it has now been renamed. The goal is to save the lat, lon
% and heading.
fid=fopen(fname);
data=textscan(fid,'%s',1e6,'delimiter','\r');
fclose(fid);
data=char(data{:});
ik=strmatch('META_DATA_PRECISION',data);
out.readme=data(1:ik,:);
tt=data(ik+1:end,:);

igprmc=strmatch('GPRMC',tt(:,37:end));
igpvtg=strmatch('GPVTG',tt(:,37:end));

% position
if ~isempty(igprmc)
    gprmc=tt(igprmc,:);
    gprmc(:,end+1)=',';
    frm='%s %s %s %s %s %f %s %f %s %s %s %s %s %s';
    gprmc=textscan(gprmc',frm,size(gprmc,1),'delimiter',',','bufsize',1e6);
    tm=char(gprmc{2});
    if strcmp(tm(1,1),'"') == 1
        tm = tm(:,2:end-1);
    end
    out.pos_time=datenum(tm(:,1:10))+datenum(tm(:,12:23))-fix(datenum(tm(:,12:23)));
    out.lat=gprmc{6};
    out.lat=fix(out.lat/100)+(out.lat/100-fix(out.lat/100))/60*100;
    nsign=strfind(char(gprmc{7})','S');
    out.lat(nsign)=-out.lat(nsign);
    out.lon=gprmc{8};
    out.lon=fix(out.lon/100)+(out.lon/100-fix(out.lon/100))/60*100;
    nsign=strfind(char(gprmc{9})','W');
    out.lon(nsign)=-out.lon(nsign);
else
    out.pos_time=[];out.lat=[];out.lon=[];
end
% heading
if ~isempty(igpvtg)
    gpvtg=tt(igpvtg,:);
    gpvtg(:,end+1)=',';
    frm='%s %s %s %s %s %f %s %s %s %s %s';
    gpvtg=textscan(gpvtg',frm,size(gpvtg,1),'delimiter',',','bufsize',1e6);
    tm=char(gpvtg{2});
    if strcmp(tm(1,1),'"') == 1
        tm = tm(:,2:end-1);
    end
    out.heading_time=datenum(tm(:,1:10))+datenum(tm(:,12:23))-fix(datenum(tm(:,12:23)));
    out.heading=gpvtg{6};
else
    out.heading_time=[];out.heading=[];
end

