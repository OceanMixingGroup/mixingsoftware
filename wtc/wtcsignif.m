function wtcsig=wtcsignif(mccount,ar1,dt,n,pad,dj,s0,j1,mother,cutoff)
% Wavelet Coherence Significance Calculation (Monte Carlo)
%
% wtcsig=wtcsignif(mccount,ar1,dt,n,pad,dj,s0,j1,mother,cutoff)
%
% mccount: number of time series generations in the monte carlo run (the greater the better)
% ar1: a vector containing the 2 AR(1) coefficients. example: ar1=[.7 .6].
% dt,pad,dj,s0,j1,mother: see wavelet help... 
% n: length of each generated timeseries. (the longer than the better)
%
% cutoff: a level which is certainly below the 95% significance level
%         (used to minimize memory requirements.)
%
% RETURNED
% wtcsig: the 95% significance level as a function of scale... (scale,sig95level)
%
% (C) Aslak Grinsted 2002-2004
%

% -------------------------------------------------------------------------
%   Copyright (C) 2002-2004, Aslak Grinsted
%   This software may be used, copied, or redistributed as long as it is not
%   sold and this copyright notice is reproduced on each copy made.  This
%   routine is provided as is without any express or implied warranties
%   whatsoever.


% TODO: also make XWT Signif calculation since it is cheap.


% do a check that it is not the same as last time... (for optimization purposes)
checkvalues=[ar1(:)' dt n pad dj s0 j1 double(mother)]; %cutoff is unimportant.
%TODO: REMOVE ar1's and n from checkvalues (maybe?)

checkhash=['' mod(sum(log(checkvalues+1)*123),25)+'a' mod(sum(log(checkvalues+1)*54321),25)+'a'];
%the hash is used to distinguish cache files.
try
    [lastmccount,lastcheckvalues,lastwtcsig]=loadbnm(['wtcsignif-cached-' checkhash '.bnm']);
    if (lastmccount>=mccount)&(isequal(single(checkvalues),lastcheckvalues)) %single is important because bnm is single precision.
        wtcsig=lastwtcsig;
        return
    end
catch
end




warned=0;
%precalculate stuff that's constant outside the loop
d1=ar1noise(n,1,ar1(1),1);    
[W1,period,scale,coi] = wavelet(d1,dt,pad,dj,s0,j1,mother);
outsidecoi=zeros(size(W1));
for s=1:length(scale)
    outsidecoi(s,:)=(period(s)<=coi);
end
sinv=1./(scale');
sinv=sinv(:,ones(1,size(W1,2)));

sig95=zeros(size(scale));

maxscale=1;
for s=1:length(scale)
    if any(outsidecoi(s,:)>0)
        maxscale=s;
    else
        sig95(s)=NaN;
        if ~warned
            warning('Long wavelengths completely influenced by COI. (suggestion: set n higher, or j1 lower)'); warned=1;
        end
    end
end

%PAR1=1./ar1spectrum(ar1(1),period');
%PAR1=PAR1(:,ones(1,size(W1,2)));
%PAR2=1./ar1spectrum(ar1(2),period');
%PAR2=PAR2(:,ones(1,size(W1,2)));

wlc={}; %saved coherences... (coherence above cutoff and outside coi)
wlcidx=[];
belowcutoff=zeros(1,maxscale);
for s=1:maxscale
    wlc{s}=[];
    wlcidx=1;
end

wbh = waitbar(0,['Running Monte Carlo (significance)... (H=' checkhash ')'],'Name','Monte Carlo (WLC)');
for ii=1:mccount
    waitbar(ii/mccount,wbh);
    d1=ar1noise(n,1,ar1(1),1);    
    d2=ar1noise(n,1,ar1(2),1);    
    [W1,period,scale,coi] = wavelet(d1,dt,pad,dj,s0,j1,mother);
    [W2,period,scale,coi] = wavelet(d2,dt,pad,dj,s0,j1,mother);
%    W1=W1.*PAR1; %whiten spectra
%    W2=W2.*PAR1;
    sWxy=smoothwavelet(sinv.*(W1.*conj(W2)),dt,period,dj,scale);
    Rsq=abs(sWxy).^2./(smoothwavelet(sinv.*(abs(W1).^2),dt,period,dj,scale).*smoothwavelet(sinv.*(abs(W2).^2),dt,period,dj,scale));
    
    for s=1:maxscale
        cd=Rsq(s,find(outsidecoi(s,:)));
        idx=find(cd>cutoff);
        belowcutoff(s)=belowcutoff(s)+(length(cd)-length(idx));
        cd=cd(idx);
        wlc{s}=[wlc{s} cd];
        %todo: can be optimized so it doesn't have to dynamically resize the array all the time... 
        %(has a large effect if mccount & n is large)
    end
end
close(wbh);


for s=1:maxscale
    cd=sort(wlc{s});
    totallength=belowcutoff(s)+length(cd);
    sig95(s)=interp1(belowcutoff(s)+(0:(length(cd)-1)),cd,(totallength-1)*.95);
end
wtcsig=[scale' sig95'];

if any(isnan(sig95))&(~warned)
    warning(sprintf('Sig95 calculation failed. (Cutoff=%f is too high!)',cutoff))
else
    savebnm(['wtcsignif-cached-' checkhash '.bnm'],mccount,checkvalues,wtcsig); %save to a cache....
end

