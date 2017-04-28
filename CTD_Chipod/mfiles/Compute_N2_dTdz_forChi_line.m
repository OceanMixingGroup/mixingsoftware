function ctd=Compute_N2_dTdz_forChi_line(ctd,bin_size)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function ctd=Compute_N2_dTdz_forChiLine(ctd,z_smooth)
%
% Modified from Compute_N2_dTdz_forChi
%
% * in overlapping bins, fit straight line to T and sgth to get T_z and N^2
%
% Compute N^2 and dT/dz from ctd data. Part of CTD-chipod processing routines.
% Replaces a section of code that was repeated in processing script.
%
%
% INPUT
% ctd      : CTD data with required fields: s1,t1,p,lat
% bin_size : Bin sizes to compute N^2 and dT/dz over
%
% OUTPUT
% ctd      : Structure with dT/dz and N^2 added.
%
%-------------------------------
% 3/31/17 - A. Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

% fill in missing data w/ interp
ctd.s1 = interp_missing_data(ctd.s1,100);
ctd.t1 = interp_missing_data(ctd.t1,100);

% compute pot. temp and dens.
ptmp = sw_ptmp(ctd.s1, ctd.t1, ctd.p, 0);
sgth = sw_pden(ctd.s1, ctd.t1, ctd.p, 0);

p_bins = [ 0.5 : bin_size : nanmax(ctd.p) ] ;

dTdz = nan*ones(length(p_bins),1);
N2   = nan*ones(length(p_bins),1);

% sort potential temp
clear t_pot t_pot_sort
[ptmp_sort , Iptmp] = sort(ptmp,1,'descend');

% sorth pot. dens.
[sgth_sort , Isgth] = sort(sgth,1,'ascend');

for ibin = 1:length(p_bins)
    
    clear iz z1 z2
    z1 = p_bins(ibin) - bin_size ;
    z2 = p_bins(ibin) + bin_size ;
    iz = find(ctd.p>z1 & ctd.p<z2) ;
    
    % fit a line to pot. temp to get slope
    clear P
    P = polyfit(ctd.p(iz),ptmp_sort(iz),1);
    dTdz(ibin) = -P(1);
    
    clear P1 drhodz
    P1 = polyfit(ctd.p(iz),sgth_sort(iz),1);
    % calculate N^2 from this fit
    clear drhodz n2_2 drho dz n2_3
    drhodz = -P1(1);
    N2(ibin) = -9.81/nanmean(sgth)*drhodz;
    
end


ctd.N2 = interp1(p_bins,N2,ctd.p);
ctd.dTdz = interp1(p_bins,dTdz,ctd.p);


return
%end
%%