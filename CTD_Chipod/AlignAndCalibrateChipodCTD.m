function [CTD_24hz chidat]=AlignAndCalibrateChipodCTD(CTD_24hz,chidat,az_correction,makeplot)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function [CTD_raw chidat]=AlignAndCalibrateChipodCTD.m
%
% For CTD chipod processing
%
% Function to align chipod data with CTD and apply calibration to chipod
% temperature and temp. derivative.
%
% INPUT
% CTD_24hz       : 24hz CTD data (includes downcast and upcast)
% chidat         : Chipod data for this period.
% az_correction  :
% makeplot       : option to make figure
%
% OUTPUT
% CTD_24hz  : Same, w/ dp/dt added
% chidat    : Same, w/ time offset computed and added, and T1 and T1P
% calibrated
%
%
% Copied from part of process_chipod_script_AP.m
%
% May 5, 2015 - A. Pickering - apickering@coas.oregonstate.edu
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

if ~exist('makeplot','var')
    makeplot=0
end

% don't use low-passed p?
% % low-passed p
CTD_24hz.p_lp=conv2(medfilt1(CTD_24hz.p),hanning(30)/sum(hanning(30)),'same');
CTD_24hz.dpdt=gradient(CTD_24hz.p_lp,nanmedian(diff(CTD_24hz.datenum*86400)));
CTD_24hz.dpdt(CTD_24hz.dpdt>10)=mean(CTD_24hz.dpdt); % JRM added to remove large spike spikes in dpdt

% could just highpass isntead of subracting lowpass?
% Compute high-passed dp/dt (ie vertical velocity of ctd)
CTD_24hz.dpdt_hp=CTD_24hz.dpdt-conv2(CTD_24hz.dpdt,hanning(750)/sum(hanning(750)),'same');
CTD_24hz.dpdt_hp(abs(CTD_24hz.dpdt_hp)>2)=mean(CTD_24hz.dpdt_hp); % JRM added to remove large spike spikes in dpdt_hp

% Compute chipod w by integrating z-accelertion
tmp=az_correction*9.8*(chidat.AZ-median(chidat.AZ)); tmp(abs(tmp)>10)=0;
tmp2=tmp-conv2(tmp,hanning(3000)/sum(hanning(3000)),'same');
w_from_chipod=cumsum(tmp2*nanmedian(diff(chidat.datenum*86400)));

if makeplot==1
% plot:
figure(1);clf
ax1= subplot(211);
plot(CTD_24hz.datenum,CTD_24hz.dpdt_hp,'b',chidat.datenum,w_from_chipod,'r'),hold on
legend('ctd dp/dt','w_{chi}','orientation','horizontal','location','best')
%title([castname ' ' short_labs{up_down_big}],'interpreter','none')
ylabel('w [m/s]')
datetick('x')
grid on
end

% Find profile inds for CTD data (ctd profile 'starts' at 10m )
%ginds=get_profile_inds(CTD_24hz.p,10);
min_p=10;
inds=find(CTD_24hz.p>min_p);
ginds=inds(1):inds(end);

%%
% find time offset between ctd and chipod data (by matching w)
offset=TimeOffset(CTD_24hz.datenum(ginds),CTD_24hz.dpdt_hp(ginds),chidat.datenum,w_from_chipod);

% apply correction to chipod time
chidat.datenum=chidat.datenum+offset; %
chidat.time_offset_correction_used=offset;
chidat.fspd=interp1(CTD_24hz.datenum,-CTD_24hz.dpdt,chidat.datenum);

if makeplot==1
ax2=subplot(212);
plot(CTD_24hz.datenum,CTD_24hz.dpdt_hp,'b',chidat.datenum,w_from_chipod,'g')
legend('ctd dp/dt','corrected w_{chi}','orientation','horizontal','location','best')
title(['time offset=' num2str(offset*86440) 's'])
grid on
datetick('x')
ylabel('w [m/s]')

linkaxes([ax1 ax2])
end
%print('-dpng',[fig_path  'chi_' short_labs{up_down_big} '/cast_' cast_suffix '_w_TimeOffset'])

%%% Now we'll calibrate T by comparison to the CTD.
chidat.cal.datenum=chidat.datenum;
chidat.cal.P=interp1(CTD_24hz.datenum,CTD_24hz.p_lp,chidat.datenum);
chidat.cal.T_CTD=interp1(CTD_24hz.datenum,CTD_24hz.t1,chidat.datenum);
chidat.cal.fspd=chidat.fspd;

[chidat.cal.coef.T1,chidat.cal.T1]=get_T_calibration(CTD_24hz.datenum(ginds),CTD_24hz.t1(ginds),chidat.datenum,chidat.T1);

% Apply our calibration for DTdt.
chidat.cal.T1P=calibrate_chipod_dtdt(chidat.T1P,chidat.cal.coef.T1P,chidat.T1,chidat.cal.coef.T1);

% test_dtdt=0; %%% this does a digital differentiation to determine whether the differentiator time constant is correct.
% if test_dtdt
%     dt=median(diff(chidat.datenum))*3600*24;
%     cal.dTdt_dig=[0 ; diff(cal.T1)/dt];
%     oset=min(chidat.datenum);
%     plot(chidat.datenum-oset,cal.dTdt_dig,chidat.datenum-oset,cal.T1P);
%     paus, ax=axis
%     ginds2=find((chidat.datenum-oset)>ax(1) & (chidat.datenum-oset)<ax(2));
%     [p,f]=fast_psd(cal.T1P(ginds2),256,100);
%     [p2,f]=fast_psd(cal.dTdt_dig(ginds2),256,100);
%     figure(4)
%     loglog(f,p2,f,p);
% end


if chidat.Info.isbig
    % big chipods have 2 sensors?
    [chidat.cal.coef.T2,chidat.cal.T2]=get_T_calibration(CTD_24hz.datenum(ginds),CTD_24hz.t1(ginds),chidat.datenum,chidat.T2);
    chidat.cal.T2P=calibrate_chipod_dtdt(chidat.T2P,chidat.cal.coef.T2P,chidat.T2,chidat.cal.coef.T2);
else
   chidat.cal.T2=chidat.cal.T1;
   chidat.cal.T2P=chidat.cal.T1P;
end

test_cal_coef=0;

if test_cal_coef
    ccal.coef1(a,1:5)=cal.coef.T1;
    ccal.coef2(a,1:5)=cal.coef.T2;
    figure(104)
    plot(ccal.coef1),hold on,plot(ccal.coef2)
end

return

%%