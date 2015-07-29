function [CTD_24hz chidat]=AlignChipodCTD(CTD_24hz,chidat,az_correction,makeplot)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function [CTD_raw chidat]=AlignChipodCTD.m
%
% For CTD chipod processing
%
% Function to align chipod data with CTD.
%
% INPUT
% CTD_24hz       : 24hz CTD data (includes downcast and upcast)
% chidat         : Chipod data for this period.
% az_correction  : Correction for accelerometer mounted up/down on Rosette
% makeplot       : option to make figure
%
% OUTPUT
% CTD_24hz  : Same, w/ dp/dt added
% chidat    : Same, w/ time offset computed and added
% Also computes fspd (lowpassed dp/dt) and adds to chidat
%
% June 14, 2015 - A. Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

if ~exist('makeplot','var')
    makeplot=0
end
 
% % low-passed dp/dt
CTD_24hz.p_lp=conv2(medfilt1(CTD_24hz.p),hanning(30)/sum(hanning(30)),'same');
CTD_24hz.dpdt=gradient(CTD_24hz.p_lp,nanmedian(diff(CTD_24hz.datenum*86400)));
CTD_24hz.dpdt(CTD_24hz.dpdt>10)=mean(CTD_24hz.dpdt); % JRM added to remove large spike spikes in dpdt

% Compute high-passed dp/dt (ie vertical velocity of ctd)
CTD_24hz.dpdt_hp=CTD_24hz.dpdt-conv2(CTD_24hz.dpdt,hanning(750)/sum(hanning(750)),'same');
CTD_24hz.dpdt_hp(abs(CTD_24hz.dpdt_hp)>2)=mean(CTD_24hz.dpdt_hp); % JRM added to remove large spike spikes in dpdt_hp

% Compute chipod w by integrating z-accelertion
tmp=az_correction*9.8*(chidat.AZ-median(chidat.AZ)); tmp(abs(tmp)>10)=0;
tmp2=tmp-conv2(tmp,hanning(3000)/sum(hanning(3000)),'same');
w_from_chipod=cumsum(tmp2*nanmedian(diff(chidat.datenum*86400)));
w_from_chipod=w_from_chipod-nanmean(w_from_chipod); % remove mean

if makeplot==1
% plot:
figure(1);clf
ax1= subplot(2,1,1);
plot(CTD_24hz.datenum,CTD_24hz.dpdt_hp,'k',chidat.datenum,w_from_chipod,'r'),hold on
ylim(nanmin([nanmax(CTD_24hz.dpdt_hp) 1.5])*[-1 1])
legend('ctd dp/dt','w_{chi}','orientation','horizontal','location','best')
%title([castname ' ' short_labs{up_down_big}],'interpreter','none')
title([chidat.castname ' - SN' chidat.Info.loggerSN ],'interpreter','none')
ylabel('w [m/s]')
datetick('x')
grid on
end

% Find profile inds for CTD data (ctd profile 'starts' at 10m )
%ginds=get_profile_inds(CTD_24hz.p,10);
min_p=20;
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
ax2=subplot(2,1,2);
plot(CTD_24hz.datenum,CTD_24hz.dpdt_hp,'k',chidat.datenum,w_from_chipod,'r')
ylim(nanmin([nanmax(CTD_24hz.dpdt_hp) 1.5])*[-1 1])
legend('ctd dp/dt','corrected w_{chi}','orientation','horizontal','location','best')
title(['time offset=' num2str(offset*86440) 's'])
grid on
datetick('x')
ylabel('w [m/s]')
linkaxes([ax1 ax2])
end
%print('-dpng',[fig_path  'chi_' short_labs{up_down_big} '/cast_' cast_suffix '_w_TimeOffset'])
%%