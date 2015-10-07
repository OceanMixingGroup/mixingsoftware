function [todo_inds,Nwindows]=MakeCtdChiWindows(TP,nfft)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function WindowData=MakeCtdChiWindows(TP)
%
% Determine ~1sec windows to use for CTD-chipod calculations of chi. Bad
% data should be NaNed out in T' data (TP) prior to running this. Finds
% good (not NaN) continous segments of data to use for windows. For short
% segments, just that segment is used. Longer segments are split into 
% overlapping windows. This is especially important for data from big
% chipods that have regular glitches.
%
% INPUT:
% TP : Time series of temperature derivative from chipod
%
% OUTPUT:
%
% Dependencies:
% FindContigSeq.m
%
%--------------
% 10/7/15 - AP - apickering@coas.oregonstate.edu - initial coding
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

% parameters
min_seg_length=85;
max_seg_length=180;

% find continous segments of good data (no NaNs)
clear idg b Nsegs todo_inds
idg=~isnan(TP);
b=FindContigSeq(idg);
Nsegs=length(b.reglen);

todo_inds=[];

%~ loop through segments and find inds
for iseg=1:Nsegs
    
    clear seglength inds
    
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
        
    elseif seglength > min_seg_length  &&  seglength < max_seg_length % use just 1 window
        
        inds=b.first(iseg):b.last(iseg);
        todo_inds=[todo_inds ; [inds(1) inds(end)]];
        
    end % seg length
    
end % each segment

Nwindows=length(todo_inds);



%%