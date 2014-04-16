function swave=smoothwavelet(wave,dt,period,dj,scale)
% Smoothing as in the appendix of Torrence and Webster "Inter decadal changes in the ENSO-Monsoon System" 1998
% 
% used in wavelet coherence calculations
% 
%
% Only applicable for the Morlet wavelet. 
%
% (C) Aslak Grinsted 2002-2004
%

% -------------------------------------------------------------------------
%   Copyright (C) 2002-2004, Aslak Grinsted
%   This software may be used, copied, or redistributed as long as it is not
%   sold and this copyright notice is reproduced on each copy made.  This
%   routine is provided as is without any express or implied warranties
%   whatsoever.

% TODO: take mother argument
%


swave=zeros(size(wave));
twave=zeros(size(wave));

%filter in time:.... todo maybe use filter instead of conv?
for i=1:size(wave,1)
    sc=period(i)/dt; % time/cycle / time/sample = samples/cycle
    t=(-round(sc*4):round(sc*4))*dt;
    filter=exp(-t.^2/(2*scale(i)^2));
    filter=filter/sum(filter); %filter must have unit weight
    
    smooth=conv(wave(i,:),filter);
    cutlen=(length(t)-1)*.5;
    twave(i,:)=smooth((cutlen+1):(end-cutlen)); %remove paddings
end

%scale smoothing (boxcar with width of .6)

%
% TODO: optimize. Because this is done many times in the monte carlo run.
%
dj0=0.6;
dj0steps=dj0/(dj*2);
for i=1:size(twave,1)
    number=0;
    for l=1:size(twave,1);
        if ((abs(i-l)+.5)<=dj0steps)
            number=number+1;
            swave(i,:)=swave(i,:)+twave(l,:);
        elseif ((abs(i-l)+.5)<=(dj0steps+1))
            fraction=mod(dj0steps,1);
            number=number+fraction;
            swave(i,:)=swave(i,:)+twave(l,:)*fraction;
        end
    end
    swave(i,:)=swave(i,:)/number;
end
%swave=twave;