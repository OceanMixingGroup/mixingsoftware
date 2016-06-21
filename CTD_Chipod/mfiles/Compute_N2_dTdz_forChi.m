function ctd=Compute_N2_dTdz_forChi(ctd,z_smooth)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function ctd=Compute_N2_dTdz_forChi(ctd,z_smooth)
%
% Compute N^2 and dT/dz from ctd data. Part of CTD-chipod processing routines.
% Replaces a section of code that was repeated in processing script.
%
%
% INPUT
% ctd      : CTD data with required fields: s1,t1,p,lat
% z_smooth : Depth range to smooth N^2 and dT/dz over
%
% OUTPUT
% ctd      : Structure with dT/dz and N^2 added.
%
%-------------------------------
% 05/11/15 - A. Pickering - apickering@coas.oregonstate.edu
% 01/21/16 - AP - Clean up and document a little
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

% fill in missing data w/ interp
ctd.s1=interp_missing_data(ctd.s1,100);
ctd.t1=interp_missing_data(ctd.t1,100);

% compute N^2 from 1m ctd data 
[bfrq] = sw_bfrq(ctd.s1,ctd.t1,ctd.p,nanmean(ctd.lat)); %
ctd.N2=abs(conv2(bfrq,ones(z_smooth,1)/z_smooth,'same')); % smooth once
ctd.N2=conv2(ctd.N2,ones(z_smooth,1)/z_smooth,'same'); % smooth twice
ctd.N2=ctd.N2([1:end end]);

% compute dTdz from 1m ctd data 
tmp1=sw_ptmp(ctd.s1,ctd.t1,ctd.p,1000);
ctd.dTdz=[0 ; abs(conv2(diff(tmp1),ones(z_smooth,1)/z_smooth,'same'))./diff(ctd.p)];
ctd.dTdz=conv2(ctd.dTdz,ones(z_smooth,1)/z_smooth,'same');

return
%end
%%