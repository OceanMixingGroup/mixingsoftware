function [todo_inds,Nwindows]=MakeCtdChiWindows(TP,nfft)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function WindowData=MakeCtdChiWindows(TP)
%
% Determine windows (usually ~1sec) to use for CTD-chipod calculations of chi. Bad
% data should be NaNed out in T' data (TP) prior to running this. Finds
% good (not NaN) continous segments of data to use for windows. For short
% segments (< min_seg_length), just that segment is used. Longer segments are split into
% overlapping windows. This is especially important for data from big
% chipods that have regular glitches.
%
% INPUT:
% TP   : Time series of temperature derivative from chipod
% nfft : # points to use in spectra of TP (nfft combined with sampling rate
% will determine the length of the windows in sec)
%
%
% OUTPUT:
% todo_inds : Indices for each window (start and end)
% Nwindows  : Total # of windows
%
% Dependencies:
% FindContigSeq.m
%
%--------------
% 10/07/15 - AP - apickering@coas.oregonstate.edu - initial coding
% 01/21/16 - AP - Clean up and document a little
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

% parameters
min_seg_length=85;
max_seg_length=180;

% first, find continous segments of good data (no NaNs)
clear idg b Nsegs todo_inds
idg=~isnan(TP);
b=FindContigSeq(idg);
Nsegs=length(b.reglen);

todo_inds=[];

%~ loop through segments and find inds
for iseg=1:Nsegs
    
    clear seglength inds
    
    % length of this segment
    seglength=b.reglen(iseg);
    
    if seglength > max_seg_length % long segment, use multiple overlapping windows
        clear indc
        indc= b.first(iseg) : (nfft/2) : b.last(iseg);
        
        for n=1:length(indc)
            clear inds
            inds=indc(n)-1+[1:nfft];
            % window at end might go past data we
            % have...
            if inds(end)<length(TP)
                todo_inds=[todo_inds ; [inds(1) inds(end)]];
            end
            
        end
        
    elseif seglength > min_seg_length  &&  seglength < max_seg_length % shorter segment, use just 1 window
        
        inds=b.first(iseg):b.last(iseg);
        todo_inds=[todo_inds ; [inds(1) inds(end)]];
        
    end % seg length
    
end % each segment

Nwindows=length(todo_inds);


%%