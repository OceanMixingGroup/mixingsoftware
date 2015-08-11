function Vel=RTI_Array2Struct(Ensembles)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% RTI_Array2Struct.m
%
% Output from ReadRTI.m is an array of structures, with one structure for
% each ensemble. This script transforms that into one structure 'Vel' with
% typical data format (depth-time) that we normally use for ADCP data. 
%
% Assumes we have data from a dual-frequency ADCP, with the 2 frequencies
% in alternating ensembles.
%
% INPUT
% Ensembles : Structure output by ReadRTI.m
%
% OUTPUT
% Vel       : Structure with ADCP data in depth X time format
%
% History
%-------------------------
% 08/09/15 - A. Pickering - apickering@coas.oregonstate.edu
% 08/11/15 - AP - Need to separate 2 frequences (alternating ensembles)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

% total # ensembles
Nens=length(Ensembles)

% get the 2 system frequencies (in kHz)
sysfreq1=Ensembles(1).SystemSettings(7)/1e3
sysfreq2=Ensembles(2).SystemSettings(7)/1e3

% make sure we have 2 frequencies
if sysfreq1==sysfreq2
    error('Only one frequency?')
end

% figure out how many ensembles we have for each frequency
Nens1=0;
Nens2=0;
for iens=1:Nens
    thfreq=Ensembles(iens).SystemSettings(7)/1e3;
    if thfreq==sysfreq1
        Nens1=Nens1+1;
    elseif thfreq==sysfreq2
        Nens2=Nens2+1;
    end
end

% figure out how many bins we have for each frequency
Nbins1=Ensembles(1).Ensemble(2);
Nbins2=Ensembles(2).Ensemble(2);

% Make empty structure and fields for data
Vel=struct();
Vel.MakeInfo=['Made ' datestr(now) 'w/ RTI_Array2Struct.m ']

% Frequency '1'
clear whfreq Nt Nz EmptyMat
whfreq=num2str(sysfreq1)
Nt=Nens1
Nz=Nbins1
EmptyMat=nan*ones(Nz,Nt);
Vel.(['F' whfreq 'kHz']).u=EmptyMat;
Vel.(['F' whfreq 'kHz']).v=EmptyMat;
Vel.(['F' whfreq 'kHz']).w=EmptyMat;

Vel.(['F' whfreq 'kHz']).dnum=nan*ones(1,Nt);
Vel.(['F' whfreq 'kHz']).pitch=nan*ones(1,Nt);
Vel.(['F' whfreq 'kHz']).roll=nan*ones(1,Nt);
Vel.(['F' whfreq 'kHz']).heading=nan*ones(1,Nt);

Vel.(['F' whfreq 'kHz']).bt_range0=nan*ones(1,Nt);
Vel.(['F' whfreq 'kHz']).bt_range1=nan*ones(1,Nt);
Vel.(['F' whfreq 'kHz']).bt_range2=nan*ones(1,Nt);
Vel.(['F' whfreq 'kHz']).bt_range3=nan*ones(1,Nt);

Vel.(['F' whfreq 'kHz']).bt_status=nan*ones(1,Nt);

Vel.(['F' whfreq 'kHz']).bt_u=nan*ones(1,Nt);
Vel.(['F' whfreq 'kHz']).bt_v=nan*ones(1,Nt);
Vel.(['F' whfreq 'kHz']).bt_w=nan*ones(1,Nt);
Vel.(['F' whfreq 'kHz']).btheading=nan*ones(1,Nt);

Vel.(['F' whfreq 'kHz']).z=nan*ones(Nz,1);

% Frequency '2'
clear whfreq Nt Nz EmptyMat
whfreq=num2str(sysfreq2)
Nt=Nens2
Nz=Nbins2
EmptyMat=nan*ones(Nz,Nt);
Vel.(['F' whfreq 'kHz']).u=EmptyMat;
Vel.(['F' whfreq 'kHz']).v=EmptyMat;
Vel.(['F' whfreq 'kHz']).w=EmptyMat;

Vel.(['F' whfreq 'kHz']).dnum=nan*ones(1,Nt);
Vel.(['F' whfreq 'kHz']).pitch=nan*ones(1,Nt);
Vel.(['F' whfreq 'kHz']).roll=nan*ones(1,Nt);
Vel.(['F' whfreq 'kHz']).heading=nan*ones(1,Nt);

Vel.(['F' whfreq 'kHz']).bt_range0=nan*ones(1,Nt);
Vel.(['F' whfreq 'kHz']).bt_range1=nan*ones(1,Nt);
Vel.(['F' whfreq 'kHz']).bt_range2=nan*ones(1,Nt);
Vel.(['F' whfreq 'kHz']).bt_range3=nan*ones(1,Nt);

Vel.(['F' whfreq 'kHz']).bt_status=nan*ones(1,Nt);

Vel.(['F' whfreq 'kHz']).bt_u=nan*ones(1,Nt);
Vel.(['F' whfreq 'kHz']).bt_v=nan*ones(1,Nt);
Vel.(['F' whfreq 'kHz']).bt_w=nan*ones(1,Nt);
Vel.(['F' whfreq 'kHz']).btheading=nan*ones(1,Nt);

Vel.(['F' whfreq 'kHz']).z=nan*ones(Nz,1);
%Vel.(['F' num2str(sysfreq1) 'kHz'])=S;
%Vel.(['F' num2str(sysfreq2) 'kHz'])=S;
%%
hb=waitbar(0,'Reading Ensembles into Vel structure')

% counter for each frequency
ii1=0;
ii2=0;

for iens=1:Nens
    waitbar(iens/Nens,hb)
    
    clear whfreq whens
    if iseven(iens)
        whfreq=num2str(sysfreq2);
        ii1=ii1+1;       
        whens=ii1;
    else
        whfreq=num2str(sysfreq1);
        ii2=ii2+1;
        whens=ii2;
    end
        
    Vel.(['F' whfreq 'kHz']).u(:,whens)=Ensembles(iens).EarthVel(:,1);
    Vel.(['F' whfreq 'kHz']).v(:,whens)=Ensembles(iens).EarthVel(:,2);
    Vel.(['F' whfreq 'kHz']).w(:,whens)=Ensembles(iens).EarthVel(:,3);
    
    % ensenmble data (includes date and time)
    clear yr mo dd hh mm ss dnum
    yr=Ensembles(iens).Ensemble(7);
    mo=Ensembles(iens).Ensemble(8);
    dd=Ensembles(iens).Ensemble(9);
    hh=Ensembles(iens).Ensemble(10);
    mm=Ensembles(iens).Ensemble(11);
    ss=Ensembles(iens).Ensemble(12) + Ensembles(iens).Ensemble(13)/100;
    dnum=datenum(yr,mo,dd,hh,mm,ss);
    datestr(dnum)   ;
    
    Vel.(['F' whfreq 'kHz']).dnum(whens)=dnum;
    
     Nbins=Ensembles(iens).Ensemble(2);
    % ancillary data (includes binsize, pitch and roll)
    clear Anc range_first binsize heading pitch roll temp
    Anc=Ensembles(iens).Ancillary;
    range_firstbin=Anc(1); % range to 1st bin
    binsize=Anc(2); % bin size
    % make a depth vector from bin sizes
    Vel.(['F' whfreq 'kHz']).range_firstbin=range_firstbin;
    Vel.(['F' whfreq 'kHz']).z=range_firstbin : binsize : range_firstbin+((Nbins-1)*binsize);
    Vel.(['F' whfreq 'kHz']).binsize=binsize;
    
    Vel.(['F' whfreq 'kHz']).heading(whens)=Anc(5);
    Vel.(['F' whfreq 'kHz']).pitch(whens)=Anc(6);
    Vel.(['F' whfreq 'kHz']).roll(whens)=Anc(7);
    Vel.(['F' whfreq 'kHz']).temp(whens)=Anc(8);
    
        
    % bottom-tracking data
    clear BTdat bt_time_first 
    BTdat=Ensembles(iens).BottomTrack;
%    bt_time_first=BTdat(1);
 %   bt_time_last=BTdat(2);
    
    Vel.(['F' whfreq 'kHz']).bt_range0(whens)=BTdat(15);
    Vel.(['F' whfreq 'kHz']).bt_range1(whens)=BTdat(16);
    Vel.(['F' whfreq 'kHz']).bt_range2(whens)=BTdat(17);
    Vel.(['F' whfreq 'kHz']).bt_range3(whens)=BTdat(18);
    
    Vel.(['F' whfreq 'kHz']).bt_status(whens)=BTdat(12);
    
    Vel.(['F' whfreq 'kHz']).bt_u(whens)=BTdat(47);
    Vel.(['F' whfreq 'kHz']).bt_v(whens)=BTdat(48);
    Vel.(['F' whfreq 'kHz']).bt_w(whens)=BTdat(49);
    
    Vel.(['F' whfreq 'kHz']).btheading(whens)=BTdat(3);
    
end

delete(hb)


%%

whfreq=num2str(sysfreq1)
whfreq=num2str(sysfreq2)

figure(1);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.1, 0.05, 0.02, 0.06, 0.1, 0.02, 1,5);

idn=find(Vel.(['F' whfreq 'kHz']).roll<0);
Vel.(['F' whfreq 'kHz']).roll(idn)=Vel.(['F' whfreq 'kHz']).roll(idn)+360;

axes(ax(1))
ezpc(Vel.(['F' whfreq 'kHz']).dnum,Vel.(['F' whfreq 'kHz']).z,Vel.(['F' whfreq 'kHz']).u)
hold on
plot(Vel.(['F' whfreq 'kHz']).dnum,Vel.(['F' whfreq 'kHz']).bt_range0,'k.')
cb=colorbar
cb.Label.String=('ms^{-1}')
ylabel('Depth [m]','fontsize',16)
caxis(1*[-1 1])
datetick('x')
SubplotLetterMW('u')
title([whfreq 'kHz'])
xtloff
grid on

axes(ax(2))
ezpc(Vel.(['F' whfreq 'kHz']).dnum,Vel.(['F' whfreq 'kHz']).z,Vel.(['F' whfreq 'kHz']).v)
hold on
plot(Vel.(['F' whfreq 'kHz']).dnum,Vel.(['F' whfreq 'kHz']).bt_range0,'k.')
cb=colorbar
cb.Label.String=('ms^{-1}')
ylabel('Depth [m]','fontsize',16)
caxis(1*[-1 1])
datetick('x')
SubplotLetterMW('v')
xtloff
grid on

axes(ax(3))
ezpc(Vel.(['F' whfreq 'kHz']).dnum,Vel.(['F' whfreq 'kHz']).z,Vel.(['F' whfreq 'kHz']).w)
hold on
plot(Vel.(['F' whfreq 'kHz']).dnum,Vel.(['F' whfreq 'kHz']).bt_range0,'k.')
cb=colorbar
cb.Label.String=('ms^{-1}')
ylabel('Depth [m]','fontsize',16)
caxis(1*[-1 1])
datetick('x')
SubplotLetterMW('w')
xtloff
grid on

axes(ax(4))
plot(Vel.(['F' whfreq 'kHz']).dnum,Vel.(['F' whfreq 'kHz']).pitch)
hold on
plot(Vel.(['F' whfreq 'kHz']).dnum,Vel.(['F' whfreq 'kHz']).roll-180)
ylabel('Deg.','fontsize',16)
cb=colorbar;killcolorbar(cb)
%plot(Vel.dnum,Vel.heading)
legend('pitch','roll','location','best')
grid on
datetick('x')
xtloff

axes(ax(5))
plot(Vel.(['F' whfreq 'kHz']).dnum,Vel.(['F' whfreq 'kHz']).heading)
hold on
plot(Vel.(['F' whfreq 'kHz']).dnum,Vel.(['F' whfreq 'kHz']).btheading,'o')
grid on
ylabel('Deg','fontsize',16)
cb=colorbar;killcolorbar(cb)
datetick('x')
SubplotLetterMW('heading')
legend('mag.','BT','location','best')
xlabel(['Time on ' datestr(floor(nanmin(Vel.(['F' whfreq 'kHz']).dnum)))],'fontsize',16)


linkaxes(ax,'x')

%%
