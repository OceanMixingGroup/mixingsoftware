function Params=SetDefaultChiParams
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function Params=SetDefaultChiParams
%
% Function to load the default Params for CTD-chipod porcessing. To save
% typing when loading data for plotting etc. and just using default params.
%
% See also MakePathStr.m
%
%--------------------
% 06/22/16 - A.Pickering 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

do_T2_big=1;         % do calc for T2 if big chipod
Params.z_smooth=20;  % distance (m) over which to smooth N^2 and dT/dz
Params.nfft=128;     % nfft to use in computing wavenumber spectra
Params.extra_z=2;    % number of extra meters to get rid of due to CTD pressure loops.
Params.wthresh = 0.3;% w threshold for removing CTD pressure loops
Params.TPthresh=1e-6 % minimum TP variance to do calculation
Params.fmax=7;      % max freq to integrate TP spectrum to in chi calc
Params.resp_corr=0;  % correct TP spectra for freq response of thermistor
Params.fc=99;        % cutoff frequency for response correction
Params.gamma=0.2;    % mixing efficiency

%%

