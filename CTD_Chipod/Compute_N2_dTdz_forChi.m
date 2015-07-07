function ctd=Compute_N2_dTdz_forChi(ctd,z_smooth)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function ctd=Compute_N2_dTdz_forChi(ctd)
%
% Compute N^2 and dT/dz from ctd data. Part of CTD-chipod processing.
% Replaces section of code that was repeated in processing script.
%
%
% INPUT
% ctd      : CTD data
% z_smooth : Depth range to smooth N^2 and dT/dz over
%
% OUTPUT
% ctd      : Structure with dT/dz and N^2 added.
%
% May 11, 2015 - A. Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

% fill in missing data w/ interp
ctd.s1=interp_missing_data(ctd.s1,100);
ctd.t1=interp_missing_data(ctd.t1,100);

% compute N^2 from 1m ctd data 
%z_smooth=20;
[bfrq] = sw_bfrq(ctd.s1,ctd.t1,ctd.p,nanmean(ctd.lat)); %
ctd.N2=abs(conv2(bfrq,ones(z_smooth,1)/z_smooth,'same')); % smooth once
ctd.N2=conv2(ctd.N2,ones(z_smooth,1)/z_smooth,'same'); % smooth twice
ctd.N2=ctd.N2([1:end end]);

% compute dTdz from 1m ctd data 
tmp1=sw_ptmp(ctd.s1,ctd.t1,ctd.p,1000);
ctd.dTdz=[0 ; abs(conv2(diff(tmp1),ones(z_smooth,1)/z_smooth,'same'))./diff(ctd.p)];
ctd.dTdz=conv2(ctd.dTdz,ones(z_smooth,1)/z_smooth,'same');

% compute N^2 from 1m ctd data with 50m smoothing
% z_smooth=50;
% [bfrq] = sw_bfrq(ctd.s1,ctd.t1,ctd.p,nanmean(ctd.lat)); 
% ctd.N2=abs(conv2(bfrq,ones(z_smooth,1)/z_smooth,'same')); % smooth once
% ctd.N2=conv2(ctd.N2,ones(z_smooth,1)/z_smooth,'same'); % smooth twice
% ctd.N2_50=ctd.N2([1:end end]);

% compute dT/dz from 1m ctd data with 50m smoothing
% tmp1=sw_ptmp(ctd.s1,ctd.t1,ctd.p,1000);
% ctd.dTdz=[0 ; abs(conv2(diff(tmp1),ones(z_smooth,1)/z_smooth,'same'))./diff(ctd.p)];
% ctd.dTdz_50=conv2(ctd.dTdz,ones(z_smooth,1)/z_smooth,'same');

% pick max dT/dz and N^2 from these two?
%ctd.dTdz=max(ctd.dTdz_50,ctd.dTdz_20);
%ctd.N2=max(ctd.N2_50,ctd.N2_20);

return
%end
%%