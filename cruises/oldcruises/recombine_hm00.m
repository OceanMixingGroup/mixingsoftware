% script to read marlin mat files 

% specify Marlin tow number(s)

itow=[1];

for it=itow
   
str_it=num2str(it+100);

if it == 1
   iprof=[194:407]; %tow01
elseif it == 2
   iprof=[415:592]; % tow02
end

[lx ly]=size(iprof);
time_avg=2;
ll=ly*160/time_avg; % factor to presize the arrays
marlin.time=nan*ones(1,ll);
marlin.ptime=nan*ones(1,ll);
%fallspd=nan*ones(1,ll);
%vx=nan*ones(1,ll);
marlin.press2=nan*ones(1,ll);
marlin.t2=nan*ones(1,ll);
%marlin.pitch=nan*ones(1,ll);
marlin.roll=nan*ones(1,ll);
marlin.az=nan*ones(1,ll);
marlin.scat1=nan*ones(1,ll);
marlin.scat2=nan*ones(1,ll);
marlin.speed=nan*ones(1,ll);
marlin.t2p2=nan*ones(1,ll);
marlin.pitch1=nan*ones(1,ll);
marlin.pitch2=nan*ones(1,ll);
marlin.az=nan*ones(1,ll);
marlin.axhi=nan*ones(1,ll);
marlin.axlo=nan*ones(1,ll);
marlin.ayhi=nan*ones(1,ll);
marlin.aylo=nan*ones(1,ll);
marlin.azhi=nan*ones(1,ll);
marlin.azlo=nan*ones(1,ll);
marlin.eps1=nan*ones(1,ll);
marlin.eps2=nan*ones(1,ll);
marlin.eps3=nan*ones(1,ll);

icnt=0;

fout=['c:\work\data\analysis\HOME\marlin\summaries\hm00_tow',str_it(2:3)];

for ip=iprof
   fname=['c:\work\data\analysis\HOME\marlin\tow',str_it(2:3),...
         '\cal_hm00_',num2str(ip),'.mat'];
   if exist(fname) ~= 0
   eval(['load ' fname])
   disp(fname)
   
% find length of data set
len=length(avg.P2);
icnt=icnt+len;

% make arrays
%fallspd(icnt-len+1:icnt)=avg.FALLSPD;
%vx(icnt-len+1:icnt)=avg.VX;
marlin.time(icnt-len+1:icnt)=avg.TIME;
marlin.ptime(icnt-len+1:icnt)=avg.PTIME;
marlin.press1(icnt-len+1:icnt)=avg.P1;
marlin.press2(icnt-len+1:icnt)=avg.P2;
marlin.scat1(icnt-len+1:icnt)=avg.SCAT1;
marlin.scat2(icnt-len+1:icnt)=avg.SCAT2;
marlin.speed(icnt-len+1:icnt)=avg.FALLSPD;
marlin.t2(icnt-len+1:icnt)=avg.T2;
marlin.t2p2(icnt-len+1:icnt)=avg.T2P2;
marlin.pitch1(icnt-len+1:icnt)=7.4+avg.AX1_TILT;
marlin.pitch2(icnt-len+1:icnt)=6.5+avg.AX2_TILT;
marlin.roll(icnt-len+1:icnt)=avg.AZ_TILT;
marlin.az(icnt-len+1:icnt)=avg.AY;
marlin.axhi(icnt-len+1:icnt)=avg.AXHI;
marlin.axlo(icnt-len+1:icnt)=avg.AXLO;
marlin.ayhi(icnt-len+1:icnt)=avg.AYHI;
marlin.aylo(icnt-len+1:icnt)=avg.AYLO;
marlin.azhi(icnt-len+1:icnt)=avg.AZHI;
marlin.azlo(icnt-len+1:icnt)=avg.AZLO;
marlin.eps1(icnt-len+1:icnt)=avg.EPSILON1;
marlin.eps2(icnt-len+1:icnt)=avg.EPSILON2;
marlin.eps3(icnt-len+1:icnt)=avg.EPSILON3;

end

end

eval(['save ' fout ' marlin '])

end
