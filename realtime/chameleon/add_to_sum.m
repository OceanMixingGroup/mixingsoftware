% add_to_sum.m
% n=q.script.num-cham.filemin+1;
% n=n+1;
l=length(avg.P);
if length(avg.P)>1
    f=round(avg.P(2))-1;
else
    f=round(avg.P(1));
end
f=nanmax(f,1);
t=l+f-1;
if t>length(cham.depth)
    t=length(cham.depth);
    l=t-f+1;
end
% if l>2
if f>0
    n=n+1;
    g=9.81;
    cham.depthmax=max(round(max(avg.P)),cham.depthmax);
    cham.EPSILON1(:,n)=NaN; cham.EPSILON1(f:t,n)=avg.EPSILON1(1:l)';
    cham.EPSILON2(:,n)=NaN; cham.EPSILON2(f:t,n)=avg.EPSILON2(1:l)';
    cham.EPSILON(:,n)=NaN; cham.EPSILON(f:t,n)=avg.EPSILON(1:l)';
    cham.N2(:,n)=NaN; cham.N2(f:t,n)=g*avg.DRHODZ(1:l)'./avg.SIGMA(1:l)';
    cham.SIGMA(:,n)=NaN; cham.SIGMA(f:t,n)=real(avg.SIGMA(1:l)');
    cham.CHI(:,n)=NaN; cham.CHI(f:t,n)= avg.CHI(1:l)';
    cham.THETA(:,n)=NaN; cham.THETA(f:t,n)=real(avg.THETA(1:l)');
    cham.T(:,n)=NaN; cham.T(f:t,n)=real(avg.T(1:l)');
    cham.S(:,n)=NaN; cham.S(f:t,n)=real(avg.S(1:l)');
    cham.C(:,n)=NaN; cham.C(f:t,n)=real(avg.C(1:l)');
    cham.SCAT(:,n)=NaN; cham.SCAT(f:t,n)=real(avg.SCAT(1:l)');
    cham.AZ2(:,n)=NaN; cham.AZ2(f:t,n)=avg.AZ2(1:l)';
    cham.FALLSPD(:,n)=NaN; cham.FALLSPD(f:t,n)=avg.FALLSPD(1:l)';
    cham.P(:,n)=NaN; cham.P(f:t,n)=avg.P(1:l)';
    cham.pmax(1,n)=max(avg.P);
    cham.DYN_Z(n)=head.dynamic_gz;
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
end
% end
