% get seabird data files 
% specify range of files

ts=input('Enter start profile --> ');
tf=input('Enter end profile --> ');
iprof=[ts:tf];

sbd.ptime=[];
sbd.time=[];
sbd.temp=[];
sbd.cond=[];

prefix='m99b';
suffix='.sbd.r'; % reordered files have .r suffix
pname='d:\raw_data\m99b\seabird\reordered\';
fout=['d:\analysis\m99b\seabird\mat_files\m99b_sbd_',num2str(iprof(1)),'_',num2str(iprof(end))];

for ip=iprof;
  	ip_str=num2str(10000+ip);
	fname=[prefix ip_str(2:5) suffix];
   if ('exist(fname)~=0')
   disp(ip)
   [temperature,cond,start_time,end_time,f_c,f_t]=rd_sbd_longs(pname,fname);
   % make ptime_sbd series
   len=length(f_t);
   decimal_length=1/320:1/320:len/320;
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
   sbd.time=[sbd.time datenum(yr,month,sdy,shr,smn,ssc:1:ssc+len)];
   % subsample to 1/sec
   sbd.temp=[sbd.temp temperature(1:1:length(temperature))'];
   sbd.cond=[sbd.cond cond(1:1:length(cond))'];
  end
end

eval(['save ' fout ' sbd'])

figure(2)
subplot(211),plot(sbd.ptime,sbd.temp);grid
axis([xlim 2 9])
ylabel('Sbd Temperature')
subplot(212),plot(sbd.ptime,sbd.cond);grid
axis([xlim 3.0 3.6])
ylabel('Sbd Conductivity')
