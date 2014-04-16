
%[fname,pname]=uigetfile('*.sbd','Seabird FIle Selection');
% fname=input('enter file name: ','s');
pname = '\\Ladoga\datad\cruises\tx01\mooring\';

firstfile=input('enter first file number: ');
lastfile=input('enter last file number: ');

icnt=0;
nfiles=lastfile-firstfile+1;
sr=10; % sample rate in Hz
ll=nfiles*3600*sr; % total record length at 10 Hz, nfiles, 1 hr long each
len=36000; % single file length 

adv.time=nan*ones(1,ll);
adv.id=nan*ones(1,ll);
adv.numbytes=nan*ones(1,ll);
adv.samplenum=nan*ones(1,ll);
adv.checksum=nan*ones(1,ll);
adv.velx=nan*ones(1,ll);
adv.vely=nan*ones(1,ll);
adv.velz=nan*ones(1,ll);
adv.ampx=nan*ones(1,ll);
adv.ampy=nan*ones(1,ll);
adv.ampz=nan*ones(1,ll);
adv.cmx=nan*ones(1,ll);
adv.cmy=nan*ones(1,ll);
adv.cmz=nan*ones(1,ll);

for jj=firstfile:lastfile
fname = sprintf('tx01%04d.adv',jj);

icnt=icnt+len;
fid=fopen([pname fname]);
adv.start_time=char((fread(fid,20))');
hr=str2num(adv.start_time(6:7));
mn=str2num(adv.start_time(9:10));
sc=str2num(adv.start_time(12:13));
adv.end_time=char((fread(fid,20))');
disp(adv.start_time)
disp(adv.end_time)

clear ii
ii=0;
while (feof(fid)==0)&(ii<len),
   ii = ii + 1;
%   disp(ii)
    if ii==1
        adv.time(icnt-len+ii)=datenum(2001,4,26,hr,mn,sc);
    else
        adv.time(icnt-len+ii)=adv.time(icnt-len+ii-1)+1/sr/60/60/24;
    end
   adv.id(icnt-len+ii)=fread(fid,1,'uchar');
   adv.numbytes(icnt-len+ii)=fread(fid,1,'uchar');
   adv.samplenum(icnt-len+ii)=fread(fid,1,'uint16');
   adv.velx(icnt-len+ii)=fread(fid,1,'int16');
   adv.vely(icnt-len+ii)=fread(fid,1,'int16');
   adv.velz(icnt-len+ii)=fread(fid,1,'int16');
   adv.ampx(icnt-len+ii)=fread(fid,1,'uchar');
   adv.ampy(icnt-len+ii)=fread(fid,1,'uchar');
   adv.ampz(icnt-len+ii)=fread(fid,1,'uchar');
   adv.cmx(icnt-len+ii)=fread(fid,1,'uchar');
   adv.cmy(icnt-len+ii)=fread(fid,1,'uchar');
   adv.cmz(icnt-len+ii)=fread(fid,1,'uchar');
   adv.checksum(icnt-len+ii)=fread(fid,1,'uint16');
   if feof(fid)
      break
   end
end   
fclose(fid)
size(adv)

end

datelim=[datenum(2001,4,26,19,0,0),datenum(2001,4,26,22,20,0)]

figure(1)

subplot(211),plot(adv.time,adv.ampx,adv.time,adv.ampy,adv.time,adv.ampz);grid;datetick
legend('ampx','ampy','ampz')
ylabel('amplitude')
set(gca,'xticklabel','','xlim',datelim)

subplot(212),plot(adv.time,adv.velx/100,adv.time,adv.vely/100,adv.time,adv.velz/100);grid
legend('velx','vely','velz')
ylabel('velocity [cm/s]')
set(gca,'xlim',datelim)

fout=['C:\work\data\analysis\tx01\mooring\tx01_adv'];

eval(['save ' fout ' adv'])
