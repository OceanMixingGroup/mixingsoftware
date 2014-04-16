% make_adp_timeseries
% reads individual yaq01 data files and makes a time series of the 
% adp velocities, etc

ifil=[2:170];  % yaq01 - deployed file07, recovered file 10
 
icnt=0; % counter to keep track of individual profiles

[lx ly]=size(ifil);
%ll=180*ly; % factor to presize the arrays with 20 s samples 
           % and 1 hr files
ll=720*ly; % factor to presize the arrays with 5 s samples 
           % and 1 hr files        
nbins=25; % no. of bins to keep
clear adp           
           
adp.time=nan*ones(1,ll);
adp.ptime=nan*ones(1,ll);
adp.temp=nan*ones(1,ll);
adp.roll=nan*ones(1,ll);
adp.pitch=nan*ones(1,ll);
adp.u=nan*ones(nbins,ll);
adp.v=nan*ones(nbins,ll);
adp.w=nan*ones(nbins,ll);
dp.mn_u=nan*ones(1,ll);
adp.mn_v=nan*ones(1,ll);
adp.mn_w=nan*ones(1,ll);
adp.hdg=nan*ones(1,ll);
adp.pressure=nan*ones(1,ll);


for ip=ifil
   str_ip=num2str(10000+ip);
   filin=['\\Ladoga\datad\cruises\tx01\mooring\\tx01',str_ip(2:5),'.adp']
   d=dir(filin);
   if exist(filin) & d.bytes>2001
       clear a
       a=read_adp(filin)
       len=length(a.profile.time);
       decimal_length=1/180:1/180:len/180;
       icnt=icnt+len;
       adp.ptime(icnt-len+1:icnt)=ip+decimal_length;
       adp.time(icnt-len+1:icnt)=a.profile.time;
       adp.u(:,icnt-len+1:icnt)=a.profile.vel1(1:nbins,:);
       adp.v(:,icnt-len+1:icnt)=a.profile.vel2(1:nbins,:);
       adp.w(:,icnt-len+1:icnt)=a.profile.vel3(1:nbins,:);
       adp.mn_u(icnt-len+1:icnt)=mean(a.profile.vel1(2:5,:));
       adp.mn_v(icnt-len+1:icnt)=mean(a.profile.vel2(2:5,:));
       adp.mn_w(icnt-len+1:icnt)=mean(a.profile.vel3(2:5,:));
       adp.hdg(icnt-len+1:icnt)=a.profile.meanheading;
       adp.temp(icnt-len+1:icnt)=a.profile.meantemp;
       adp.pitch(icnt-len+1:icnt)=a.profile.meanpitch;
       adp.roll(icnt-len+1:icnt)=a.profile.meanroll;
       adp.pressure(icnt-len+1:icnt)=a.profile.meanpres;
	end
end

fout=['c:\work\data\analysis\tx01\mooring_mat\tx01_adp_timeseries'];

eval(['save ' fout ' adp'])
