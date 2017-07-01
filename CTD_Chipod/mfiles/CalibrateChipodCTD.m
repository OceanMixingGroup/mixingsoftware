function [CTD_24hz,chidat] = CalibrateChipodCTD(CTD_24hz,chidat,az_correction,makeplot)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% [CTD_24hz chidat] = CalibrateChipodCTD(CTD_24hz,chidat,az_correction,makeplot)
%
% Function to apply calibration to chipod  temperature and temp. derivative.
%
% Part of CTD-chipod processing routines.
%
% Calls functions: get_T_calibration.m, calibrate_chipod_dtdt.m
%
% INPUT
% CTD_24hz       : 24hz CTD data (includes downcast and upcast)
% chidat         : structure w/ Chipod data for this period
% az_correction  : Correction for up/down mounting of accelerometer (+/-1)
% makeplot       : option to make figure
%
% OUTPUT
% CTD_24hz  : Same
% chidat    : Same, w/ T1 and T1P calibrated
%
% DEPENDS:
%  fast_psd.m
%  calibrate_chipod_dtdt.m
%  get_T_calibration.m
%
%---------------------------------
% 06/14/15 - A. Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

if ~exist('makeplot','var')
    makeplot=0;
end

% Find profile inds for CTD data (ctd profile 'starts' at 10m )
%ginds=get_profile_inds(CTD_24hz.p,10);
min_p = 20;
inds  = find(CTD_24hz.p>min_p);
ginds = inds(1):inds(end);

% Now we'll calibrate T by comparison to the CTD.
chidat.cal.datenum = chidat.datenum;
chidat.cal.P = interp1(CTD_24hz.datenum,CTD_24hz.p_lp,chidat.datenum);
chidat.cal.T_CTD = interp1(CTD_24hz.datenum,CTD_24hz.t1,chidat.datenum);
chidat.cal.fspd = chidat.fspd;
[chidat.cal.coef.T1,chidat.cal.T1] = get_T_calibration(CTD_24hz.datenum(ginds),CTD_24hz.t1(ginds),chidat.datenum,chidat.T1);

%% Apply our calibration for DTdt.

chidat.cal.T1P = calibrate_chipod_dtdt(chidat.T1P , chidat.cal.coef.T1P , chidat.T1 , chidat.cal.coef.T1);

test_dtdt = 1; %%% this does a digital differentiation to determine whether the differentiator time constant is correct.
if test_dtdt
    
    cal=chidat.cal;
    dt=median(diff(chidat.datenum))*3600*24;
    cal.dTdt_dig=[0 ; diff(cal.T1)/dt];
    
    figure;clf
    
    subplot(211)
    plot(chidat.datenum,cal.dTdt_dig,chidat.datenum,cal.T1P);
    ylim(5*[-1 1])
    grid on
    datetick('x')
    title(['SN ' chidat.Info.loggerSN])
    lim1 = chidat.datenum(round(length(chidat.datenum)/3));
    lim2 = chidat.datenum(round(length(chidat.datenum)/2));
    ginds2 = find( (chidat.datenum)>lim1 & (chidat.datenum)<lim2 );
    vline(lim1,'b--');
    vline(lim2,'b--');
    
    % compute spectrum of analog differentiation
    [p,f] = fast_psd(cal.T1P(ginds2),256,100);
    
    % compute spectrum of digital differentiaton
    [p2,f] = fast_psd(cal.dTdt_dig(ginds2),256,100);
    
    % plot the two spectra
    subplot(212)
    loglog(f,p2,f,p,'linewidth',2);
    axis tight
    grid on
    legend('digital','analog','location','best')
    xlabel('Frequency [hz]')
    title(['Spectra of dT/dt - \tau =' num2str(chidat.cal.coef.T1P)])
    ylabel('\Phi_{T_z} [^oC^2/s^{-2}]')
    freqline(0);
    freqline(20);
    
end % test_dtdt

% if it's a 'big' chipod, do 2nd sensor also
if chidat.Info.isbig
    
    [chidat.cal.coef.T2,chidat.cal.T2] = get_T_calibration(CTD_24hz.datenum(ginds),CTD_24hz.t1(ginds),chidat.datenum,chidat.T2);
    chidat.cal.T2P = calibrate_chipod_dtdt(chidat.T2P,chidat.cal.coef.T2P,chidat.T2,chidat.cal.coef.T2);
    
    if test_dtdt
        
        cal=chidat.cal;
        dt=median(diff(chidat.datenum))*3600*24;
        cal.dTdt_dig=[0 ; diff(cal.T2)/dt];
        oset=min(chidat.datenum);
        % compute spectrum of analog differentiation
        [p,f]=fast_psd(cal.T2P(ginds2),256,100);
        % compute spectrum of digital differentiaton
        [p2,f]=fast_psd(cal.dTdt_dig(ginds2),256,100);
        
        % plot the two spectra
        figure;clf
        
        loglog(f,p2,f,p,'linewidth',2);
        axis tight
        grid on
        legend('digital','analog','location','best')
        xlabel('Frequency [hz]')
        title(['T2- Spectra of dT/dt - \tau =' num2str(chidat.cal.coef.T1P)])
        ylabel('\Phi_{T_z} [^oC^2/s^{-2}]')
        
    end % test_dtdt
    
else
    
end % isbig

return

%%