% get seabird data files 
% specify tow#
% specify Marlin tow number(s)
itow=input('enter tow # -->  ');

for it=itow
   
str_it=num2str(it+100);

% these files specified for eps, chi computation - they should all
% have coincident adp files to compute speed from - for other calculations
% where speed not needed, can just go through in order, 
% checking for existence 1st
if it == 3
   iprof=[677:979]; %tow03
elseif it == 4
   iprof=[989:1268]; % tow04
elseif it == 5
   iprof=[1276:1681]; % tow05
elseif it == 6
   iprof=[1703:2086]; %tow06
elseif it == 7
   iprof=[2090:2460]; % tow07
elseif it == 8
   iprof=[2467:2699]; %tow08
elseif it == 9
   iprof=[2724:2859]; %tow08
elseif it == 10
   iprof=[2864:3076]; %tow10
elseif it == 11
   iprof=[3077:3365]; %tow11
elseif it == 12
   iprof=[3367:3710]; %tow12
elseif it == 13
   iprof=[3719:4060]; %tow13
elseif it == 14   
   iprof=[4083:4370]; % tow14
elseif it == 15   
   iprof=[4372:4453]; % tow 15
end

sbd.ptime=[];
sbd.time=[];
sbd.temp=[];
sbd.cond=[];

prefix='m99b';
suffix='.sbd.r'; % reordered files have .r suffix
pname='d:\raw_data\m99b\seabird\reordered\';
fout=['d:\analysis\m99b\seabird\mat_files\m99b_sbd_tow',str_it(2:3)];

for ip=iprof;
  	ip_str=num2str(10000+ip);
	fname=[prefix ip_str(2:5) suffix];
   if exist([pname fname])~=0
   disp(ip)
   [temperature,cond,start_time,end_time,f_c,f_t]=rd_sbd_longs(pname,fname);
   % make ptime_sbd series
   len=length(f_t);
   decimal_length=(1-0.5)/320:1/320:(len-0.5)/320;
   sbd.ptime=[sbd.ptime ip+decimal_length];
   % get times straight
   yr=1999;
   month=8;
   sdy=start_time(15:17);
   shr=str2num(start_time(6:7));
   smn=str2num(start_time(9:10));
   ssc=str2num(start_time(12:13));
   sdy=str2num(sdy)-212;
   strt=datenum(yr,month,sdy,shr,smn,ssc);
   edy=end_time(15:17);
   ehr=str2num(end_time(6:7));
   emn=str2num(end_time(9:10));
   esc=str2num(end_time(12:13));
   edy=str2num(edy)-212;
   endt=datenum(yr,month,edy,ehr,emn,esc);
   % make 1 s time series beginning at start_time
   sbd.time=[sbd.time datenum(yr,month,sdy,shr,smn,ssc:1:ssc+len-1)];
   % subsample to 1/sec
   sbd.temp=[sbd.temp temperature(1:1:length(temperature))'];
   sbd.cond=[sbd.cond cond(1:1:length(cond))'];
  end
end

eval(['save ' fout ' sbd'])
%pause(20)
%disp('pausing to save data')

figure(2)
subplot(211),plot(sbd.ptime,sbd.temp);grid
axis([xlim 2 9])
ylabel('Sbd Temperature')
subplot(212),plot(sbd.ptime,sbd.cond);grid
axis([xlim 3.0 3.6])
ylabel('Sbd Conductivity')

end
