% add_bad_to_sum.m
% adds bad profile to summary file when process_file fails
n=n+1;
cham.EPSILON1(:,n)=NaN;
cham.EPSILON2(:,n)=NaN;
cham.EPSILON(:,n)=NaN;
cham.N2(:,n)=NaN;
cham.SIGMA(:,n)=-999;
cham.CHI(:,n)=NaN;
cham.THETA(:,n)=-999;
cham.T(:,n)=-999;
cham.S(:,n)=-999;
cham.C(:,n)=NaN;
cham.SCAT(:,n)=-999;
cham.AZ2(:,n)=NaN;
cham.FALLSPD(:,n)=NaN;
cham.P(:,n)=NaN;
cham.pmax(1,n)=NaN;
cham.DYN_Z(n)=NaN;
cham.starttime(n,1:20)=head.starttime;
cham.endtime(n,1:20)=head.endtime;
cham.direction(n)=head.direction;
cham.filenums(n)=n;
cham.castnumber(1,n)=q.script.num;
cham.filemax=q.script.num;

bad_gps=0;
if length(head.lon.start)<10; head.lon.start='00000.0000'; bad_gps=1; end
if length(head.lat.start)<9; head.lat.start='0000.0000'; bad_gps=1; end
if length(head.lon.end)<10; head.lon.end=head.lon.start; bad_gps=1; end
if length(head.lat.end)<9; head.lat.end=head.lat.start; bad_gps=1; end

lat_start_b=str2num(head.lat.start(1:2))+str2num(head.lat.start(3:9))/60;
lat_end_b=str2num(head.lat.end(1:2))+str2num(head.lat.end(3:9))/60;
lat_b=lat_start_b;
lon_start_b=str2num(head.lon.start(1:3))+str2num(head.lon.start(4:10))/60;
lon_end_b=str2num(head.lon.end(1:3))+str2num(head.lon.end(4:10))/60;
lon_b=lon_start_b;

%      cham.lat(1,n)=lat_b;
%      cham.lon(1,n)=lon_b;
cham.lat(1,n)=lat_start_b;
cham.lon(1,n)=-lon_start_b;
day1_b=str2num(head.starttime(15:17));
day2_b=str2num(head.endtime(15:17));
dotpos=find(head.time.start=='.');
if  dotpos<7
    head.time.start(1:2)=head.starttime(6:7);
    head.time.start(3:4)=head.starttime(9:10);
    head.time.start(5:6)=head.starttime(12:13);
    head.time.start(7:10)='.000';
    head.time.end(1:2)=head.endtime(6:7);
    head.time.end(3:4)=head.endtime(9:10);
    head.time.end(5:6)=head.endtime(12:13);
    head.time.end(7:10)='.000';
    bad_gps=1;
end
if dotpos==7 || length(head.time.start)==9
    head.time.start(10)='0';
end
dotpos=find(head.time.end=='.');
if dotpos<7; head.time.end=head.time.start; bad_gps=1; end
if dotpos==7 || length(head.time.end)==9
    head.time.end(10)='0';
end
if bad_gps; disp('BAD GPS!!!'); end
time1_b=str2num(head.time.start(1:2))+str2num(head.time.start(3:4))/60 ...
    +str2num(head.time.start(5:10))/3600.;
time2_b=str2num(head.time.end(1:2))+str2num(head.time.end(3:4))/60 ...
    +str2num(head.time.end(5:10))/3600.;
time_b=.5* ( day1_b+time1_b/24 + day2_b+time2_b/24 )+datenum(year,0,0);;
cham.time(1,n)=time_b;
save([cham.pathname cham.filename],'cham')

