% add_to_sum.m
% adds averaged data to a summary file.  
% Will likely be redone for HOME...

n=q.script.num-sum.filemin+1;
l=length(avg.P);
f=round(avg.P(2))-1;
f=nanmax(f,1);
t=l+f-1;
if t>length(sum.depths)
    t=length(sum.depths);
    l=t-f+1;
end
% if l>2
   if f>0
     g=9.81;
     sum.depthmax=max(round(max(avg.P)),sum.depthmax);
     sum.EPS1(:,n)=NaN; sum.EPS1(f:t,n)=avg.EPSILON1(1:l)';
     sum.EPS2(:,n)=NaN; sum.EPS2(f:t,n)=avg.EPSILON2(1:l)';
     sum.EPS(:,n)=NaN; sum.EPS(f:t,n)=avg.EPSILON(1:l)';
     sum.N2(:,n)=NaN; sum.N2(f:t,n)=g*avg.DRHODZ(1:l)'./avg.SIGMA(1:l)';
     sum.SIGMA(:,n)=NaN; sum.SIGMA(f:t,n)=real(avg.SIGMA(1:l)');
     sum.CHI(:,n)=NaN; sum.CHI(f:t,n)= avg.CHI(1:l)';
     sum.THETA(:,n)=NaN; sum.THETA(f:t,n)=real(avg.THETA(1:l)');
     sum.S(:,n)=NaN; sum.S(f:t,n)=real(avg.S(1:l)');
     sum.C(:,n)=NaN; sum.C(f:t,n)=real(avg.C(1:l)');
     sum.SCAT(:,n)=NaN; sum.SCAT(f:t,n)=real(avg.SCAT(1:l)');
     sum.AZ2(:,n)=NaN; sum.AZ2(f:t,n)=avg.AZ2(1:l)';
     sum.FALLSPD(:,n)=NaN; sum.FALLSPD(f:t,n)=avg.FALLSPD(1:l)';
     sum.P(:,n)=NaN; sum.P(f:t,n)=avg.P(1:l)';
     sum.pmax(1,n)=max(avg.P);
     sum.DYN_Z(n)=head.dynamic_gz;
     sum.starttime(n,1:20)=head.starttime;
     sum.endtime(n,1:20)=head.endtime;
     sum.direction(n)=head.direction;
     sum.filenums=[sum.filenums n];

     bad_gps=0;
     if length(head.lon.start)<10; head.lon.start='00000.0000'; bad_gps=1; end
     if length(head.lat.start)<9; head.lat.start='0000.0000'; bad_gps=1; end
     if length(head.lon.end)<10; head.lon.end=head.lon.start; bad_gps=1; end
     if length(head.lat.end)<9; head.lat.end=head.lat.start; bad_gps=1; end
 
     lat_start_b=str2num(head.lat.start(1:2))+str2num(head.lat.start(3:9))/60;
     lat_end_b=str2num(head.lat.end(1:2))+str2num(head.lat.end(3:9))/60;
     lat_b=.5*(lat_start_b+lat_end_b);
     lon_start_b=str2num(head.lon.start(1:3))+str2num(head.lon.start(4:10))/60;
     lon_end_b=str2num(head.lon.end(1:3))+str2num(head.lon.end(4:10))/60;
     lon_b=.5*(lon_start_b+lon_end_b);
 
     sum.lat(1,n)=lat_b;
     sum.lon(1,n)=lon_b;
     day1_b=str2num(head.starttime(15:17));
     day2_b=str2num(head.endtime(15:17));
     
     if length(head.time.start)<10
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
     if length(head.time.end)<10; head.time.end=head.time.start; bad_gps=1; end
     if bad_gps; disp('BAD GPS!!!'); end
     time1_b=str2num(head.time.start(1:2))+str2num(head.time.start(3:4))/60 ...
           +str2num(head.time.start(5:10))/3600.;
     time2_b=str2num(head.time.end(1:2))+str2num(head.time.end(3:4))/60 ...
           +str2num(head.time.end(5:10))/3600.;
     time_b=.5* ( day1_b+time1_b/24 + day2_b+time2_b/24 )+datenum(year,0,0);;
     sum.time(1,n)=time_b;
     sum.castnumber(1,n)=q.script.num;
     sum.filemax=q.script.num;
     save([sum.pathname sum.filename],'sum')
  end
% end
