function [todo_inds,Nwindows]=MakeCtdChiWindows_simple(TP,nfft)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function [todo_inds,Nwindows]=MakeCtdChiWindows_simple(TP,nfft)
%
% Get indices for windows for chipod calculations. This is OLDER simpler version
% (see MakeCtdChiWindows.m); which does not look for good segments of data
% 1st (so if TP contains a lot of bad data, this will result in few windows
% to use).
%
% INPUT
% TP   : Time series of temperature derivative from chipod
% nfft : # points to use in spectra of TP (nfft combined with sampling rate
% will determine the length of the windows in sec)
%
% OUTPUT:
% todo_inds : Indices for each window (start and end) [ Nwindows X 2 ]
% Nwindows  : Total # of windows

% OUTPUT
%
%------------------
% 01/21/16 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

todo_inds=1:nfft/2:(length(TP)-nfft);
todo_inds=todo_inds(:);
Nwindows=length(todo_inds);
todo_inds=[todo_inds todo_inds+nfft]; % [ start end]
%%
