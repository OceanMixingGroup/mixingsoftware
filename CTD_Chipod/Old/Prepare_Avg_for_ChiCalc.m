function [avg todo_inds]=Prepare_Avg_for_ChiCalc(nfft,chi_todo_now,ctd)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function [avg todo_inds]=Prepare_Avg_for_ChiCalc(nfft,chi_todo_now,ctd)
%
% Prepare for chi calculation (see ComputeChi_for_CTDprofile.m).
%
% NOTE - 01/21/16 - AP - This was part of older original processing
% routines. 
%
%
% INPUT
% nfft          : # points to use for chi calculation
% chi_todo_now  : Chipod data to do calculation for.(Required fields are
% datenum,P)
% ctd           : CTD data to do calculation for. (Required fields are
% datenum,p,N2,dTdz,t1,s1).
%
% OUTPUT
% avg           : Structure where chi results go.
% todo_inds     : Indices of chipod data to do caluclation for (depends on
% nfft).
%
%----------------------------
% 05/11/15 - A. Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%
% make a structure 'avg' that will contain the results
% of chi computed in overlapping windows
clear avg
avg=struct();

% AP - for new up/down separated chi structures
todo_inds=1:nfft/2:(length(chi_todo_now.datenum)-nfft);
todo_inds=todo_inds(:);

tfields={'datenum','P','N2','dTdz','fspd','T','S','P','theta','sigma',...
    'chi1','eps1','KT1','TP1var'};
for n=1:length(tfields)
    avg.(tfields{n})=NaN*ones(size(todo_inds));
end

% new AP
avg.datenum=chi_todo_now.datenum(todo_inds+(nfft/2));% This is the mid-value of the bin
avg.P=chi_todo_now.P(todo_inds+(nfft/2));
good_inds=find(~isnan(ctd.p));

% interpolate ctd data to same pressures as chipod
avg.N2=interp1(ctd.p(good_inds),ctd.N2(good_inds),avg.P);
avg.dTdz=interp1(ctd.p(good_inds),ctd.dTdz(good_inds),avg.P);
avg.T=interp1(ctd.p(good_inds),ctd.t1(good_inds),avg.P);
avg.S=interp1(ctd.p(good_inds),ctd.s1(good_inds),avg.P);

% note sw_visc not included in newer versions of sw?
% avg.nu=sw_visc(avg.S,avg.T,avg.P);
avg.nu=sw_visc_ctdchi(avg.S,avg.T,avg.P);
% avg.tdif=sw_tdif(avg.S,avg.T,avg.P);
avg.tdif=sw_tdif_ctdchi(avg.S,avg.T,avg.P);

avg.samplerate=1./nanmedian(diff(chi_todo_now.datenum))/24/3600;

return
%%