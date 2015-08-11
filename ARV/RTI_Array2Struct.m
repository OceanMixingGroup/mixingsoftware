function Vel=RTI_Array2Struct(Ensembles)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% RTI_Array2Struct.m
%
% Output from ReadRTI.m is an array of structures, with one structure for
% each ensemble. This script transforms that into one structure 'Vel' with
% typical data format (depth-time) that we normally use for ADCP data.
%
% INPUT
% Ensembles : Structure output by ReadRTI.m
%
% OUTPUT
% Vel       : Structure with ADCP data in depth X time format
%
% August 9 2015 - A. Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

Nens=length(Ensembles)
Nbins=size(Ensembles(1).BeamVel,1)

%%
Vel=struct();
Vel.MakeInfo=['Made ' datestr(now) 'w/ RTI_Array2Struct.m ']

EmptyMat=nan*ones(Nbins,Nens);
Vel.u=EmptyMat;
Vel.v=EmptyMat;
Vel.w=EmptyMat;

Vel.dnum=nan*ones(1,Nens);
Vel.pitch=nan*ones(1,Nens);
Vel.roll=nan*ones(1,Nens);
Vel.heading=nan*ones(1,Nens);

Vel.bt_range0=nan*ones(1,Nens);
Vel.bt_range1=nan*ones(1,Nens);
Vel.bt_range2=nan*ones(1,Nens);
Vel.bt_range3=nan*ones(1,Nens);

Vel.bt_status=nan*ones(1,Nens);

Vel.bt_u=nan*ones(1,Nens);
Vel.bt_v=nan*ones(1,Nens);
Vel.bt_w=nan*ones(1,Nens);
Vel.btheading=nan*ones(1,Nens);

Vel.z=nan*ones(Nbins,1);

hb=waitbar(0,'Reading Ensembles into Vel structure')
for iens=1:Nens
    waitbar(iens/Nens,hb)
    Vel.u(:,iens)=Ensembles(iens).EarthVel(:,1);
    Vel.v(:,iens)=Ensembles(iens).EarthVel(:,2);
    Vel.w(:,iens)=Ensembles(iens).EarthVel(:,3);
    
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
    
    Vel.dnum(iens)=dnum;
    
    
    % ancillary data (includes binsize, pitch and roll)
    clear Anc range_first binsize heading pitch roll temp
    Anc=Ensembles(iens).Ancillary;
    range_firstbin=Anc(1); % range to 1st bin
    binsize=Anc(2); % bin size
    % make a depth vector from bin sizes
    Vel.range_firstbin=range_firstbin;
    Vel.z=range_firstbin : binsize : range_firstbin+((Nbins-1)*binsize);
    Vel.binsize=binsize;
    
    Vel.heading(iens)=Anc(5);
    Vel.pitch(iens)=Anc(6);
    Vel.roll(iens)=Anc(7);
    Vel.temp(iens)=Anc(8);
    
    
    
    % bottom-tracking data
    clear BTdat
    BTdat=Ensembles(iens).BottomTrack;
    bt_time_first=BTdat(1);
    bt_time_last=BTdat(2);
    
    Vel.bt_range0(iens)=BTdat(15);
    Vel.bt_range1(iens)=BTdat(16);
    Vel.bt_range2(iens)=BTdat(17);
    Vel.bt_range3(iens)=BTdat(18);
    
    Vel.bt_status(iens)=BTdat(12);
    
    Vel.bt_u(iens)=BTdat(47);
    Vel.bt_v(iens)=BTdat(48);
    Vel.bt_w(iens)=BTdat(49);
    
    Vel.btheading(iens)=BTdat(3);
    
end

delete(hb)


%%

figure(1);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.1, 0.05, 0.02, 0.06, 0.1, 0.02, 1,5);

idn=find(Vel.roll<0);
Vel.roll(idn)=Vel.roll(idn)+360;

axes(ax(1))
ezpc(Vel.dnum,Vel.z,Vel.u)
hold on
plot(Vel.dnum,Vel.bt_range0,'k.')
cb=colorbar
cb.Label.String=('ms^{-1}')
ylabel('Depth [m]','fontsize',16)
caxis(1*[-1 1])
datetick('x')
SubplotLetterMW('u')
xtloff
grid on

axes(ax(2))
ezpc(Vel.dnum,Vel.z,Vel.v)
hold on
plot(Vel.dnum,Vel.bt_range0,'k.')
cb=colorbar
cb.Label.String=('ms^{-1}')
ylabel('Depth [m]','fontsize',16)
caxis(1*[-1 1])
datetick('x')
SubplotLetterMW('v')
xtloff
grid on

axes(ax(3))
ezpc(Vel.dnum,Vel.z,Vel.w)
hold on
plot(Vel.dnum,Vel.bt_range0,'k.')
cb=colorbar
cb.Label.String=('ms^{-1}')
ylabel('Depth [m]','fontsize',16)
caxis(1*[-1 1])
datetick('x')
SubplotLetterMW('w')
xtloff
grid on

axes(ax(4))
plot(Vel.dnum,Vel.pitch)
hold on
plot(Vel.dnum,Vel.roll-180)
ylabel('Deg.','fontsize',16)
cb=colorbar;killcolorbar(cb)
%plot(Vel.dnum,Vel.heading)
legend('pitch','roll','location','best')
grid on
datetick('x')
xtloff

axes(ax(5))
plot(Vel.dnum,Vel.heading)
hold on
plot(Vel.dnum,Vel.btheading)
grid on
ylabel('Deg','fontsize',16)
cb=colorbar;killcolorbar(cb)
datetick('x')
SubplotLetterMW('heading')
legend('mag.','BT','location','best')
xlabel(['Time on ' datestr(floor(nanmin(Vel.dnum)))],'fontsize',16)


linkaxes(ax,'x')

%%
