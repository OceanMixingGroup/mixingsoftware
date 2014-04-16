% get seabird data files 
% specify range of file numbers

sbd_time=[];
sbd_temp=[];
sbd_cond=[];

prefix='m99b';
suffix='.sbd';
pname='d:\data\m99b\seabird\Sbd_raw\';
iprof=[988:1268];
fout=['d:\data\m99b\seabird\mat_files\m99b_sbd_',num2str(iprof(1)),'_',num2str(iprof(end))];

for ip=iprof;
  	ip=num2str(10000+ip);
	fname=[prefix ip(2:5) suffix];
  if ('exist(fname)~=0')
   [temperature,cond,start_time,end_time,f_c,f_t]=rd_sbd_longs(pname,fname);
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
   sbd_time=[sbd_time datenum(yr,month,sdy,shr,smn,ssc:1:ssc+319)];
   % subsample to 1/sec
   sbd_temp=[sbd_temp temperature(1:1:length(temperature))'];
   sbd_cond=[sbd_cond cond(1:1:length(cond))'];
  end
end

eval(['save ' fout ' sbd_time sbd_temp sbd_cond'])

subplot(211),plot(sbd_time,sbd_temp);datetick;grid
axis([xlim 2 17])
subplot(212),plot(sbd_time,sbd_cond);datetick;grid
axis([xlim 3.0 4.0])