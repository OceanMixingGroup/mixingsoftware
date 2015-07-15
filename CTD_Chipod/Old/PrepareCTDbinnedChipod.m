function []=PrepareCTDbinnedChipod(ctdprofile,chidat,zsmooth)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% PrepareCTDbinnedChipod.m
%
% Compute N^2 and dT/dz
%
% INPUT
% binned ctd data for 1 cast: Assumed to contain downcast and upcast
% Required CTD fields: t,s,p,lat
% chidat
% zsmooth
%
% OUTPUT
% CTD and chipod data for up and downcasts
%
% Copied from part of process_chipod_script_AP.m
%
% May 5, 2015 - A. Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%
load([CTD_path castname(1:end-6) '.mat']);

% find max pressure of CTD cast
[p_max,ind_max]=max(chidat.cal.P);
if is_downcast
    fallspeed_correction=-1;
    ctd=datad_1m;
    chi_inds=[1:ind_max];
    sort_dir='descend';
else
    fallspeed_correction=1;
    ctd=datau_1m;
    chi_inds=[ind_max:length(chidat.cal.P)];
    sort_dir='ascend';
end

% this plot for diagnostics to see if we are picking
% right half of profile (up/down)
% figure(99);clf
% plot(chidat.datenum,chidat.T1P)
% hold on
% plot(chidat.datenum(chi_inds),chidat.T1P(chi_inds))

ctd.s1=interp_missing_data(ctd.s1,100);
ctd.t1=interp_missing_data(ctd.t1,100);

% compute N^2 from 1m ctd data with 20 smoothing
smooth_len=20;
[bfrq] = sw_bfrq(ctd.s1,ctd.t1,ctd.p,nanmean(ctd.lat)); % JRM removed "vort,p_ave" from outputs
ctd.N2=abs(conv2(bfrq,ones(smooth_len,1)/smooth_len,'same')); % smooth once
ctd.N2=conv2(ctd.N2,ones(smooth_len,1)/smooth_len,'same'); % smooth twice
ctd.N2_20=ctd.N2([1:end end]);

% compute dTdz from 1m ctd data with 20 smoothing
tmp1=sw_ptmp(ctd.s1,ctd.t1,ctd.p,1000);
ctd.dTdz=[0 ; abs(conv2(diff(tmp1),ones(smooth_len,1)/smooth_len,'same'))./diff(ctd.p)];
ctd.dTdz_20=conv2(ctd.dTdz,ones(smooth_len,1)/smooth_len,'same');

% compute N^2 from 1m ctd data with 50 smoothing
smooth_len=50;
[bfrq] = sw_bfrq(ctd.s1,ctd.t1,ctd.p,nanmean(ctd.lat)); %JRM removed "vort,p_ave" from outputs
ctd.N2=abs(conv2(bfrq,ones(smooth_len,1)/smooth_len,'same')); % smooth once
ctd.N2=conv2(ctd.N2,ones(smooth_len,1)/smooth_len,'same'); % smooth twice
ctd.N2_50=ctd.N2([1:end end]);

% compute dTdz from 1m ctd data with 50 smoothing
tmp1=sw_ptmp(ctd.s1,ctd.t1,ctd.p,1000);
ctd.dTdz=[0 ; abs(conv2(diff(tmp1),ones(smooth_len,1)/smooth_len,'same'))./diff(ctd.p)];
ctd.dTdz_50=conv2(ctd.dTdz,ones(smooth_len,1)/smooth_len,'same');

% pick max dTdz and N^2 from these two?
ctd.dTdz=max(ctd.dTdz_50,ctd.dTdz_20);
ctd.N2=max(ctd.N2_50,ctd.N2_20);

%~~ plot N2 and dTdz
doplot=1;
if doplot
    figure(3);clf
    subplot(121)
    h20= plot(log10(abs(ctd.N2_20)),ctd.p)
    hold on
    h50=plot(log10(abs(ctd.N2_50)),ctd.p)
    hT=plot(log10(abs(ctd.N2)),ctd.p)
    xlabel('log_{10}N^2'),ylabel('depth [m]')
    title(castname,'interpreter','none')
    grid on
    axis ij
    legend([h20 h50 hT],'20m','50m','largest','location','best')
    
    subplot(122)
    plot(log10(abs(ctd.dTdz_20)),ctd.p)
    hold on
    plot(log10(abs(ctd.dTdz_50)),ctd.p)
    plot(log10(abs(ctd.dTdz)),ctd.p)
    xlabel('dTdz [^{o}Cm^{-1}]'),ylabel('depth [m]')
    grid on
    axis ij
    
    print('-dpng',[fig_path  'chi_' short_labs{up_down_big} '/cast_' cast_suffix '_N2_dTdz'])
end

%~~~ now let's do the chi computations:

% remove loops in CTD data
extra_z=2; % number of extra meters to get rid of due to CTD pressure loops.
wthresh = 0.4;
[datau2,bad_inds] = ctd_rmdepthloops(CTD_24hz,extra_z,wthresh);
tmp=ones(size(datau2.p));
tmp(bad_inds)=0;
chidat.cal.is_good_data=interp1(datau2.datenum,tmp,chidat.cal.datenum,'nearest');
%

%%