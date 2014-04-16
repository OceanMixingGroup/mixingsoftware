function varargout=wtc(x,y,varargin)
% Wavelet coherence
%
% USAGE: [Rsq,period,scale,coi]=wtc(x,y,[,settings])
%
% 
% Settings: Pad,Dj,S0,J1,Mother  <- see help on wavelet
%           MaxScale, Makefigure
%           MonteCarloCount      : for the sig95 level calculation.
%           BlackandWhite        : black and white figure
%
% Please ackwowledge the use of this software in any publications:
%   "Crosswavelet and wavelet coherence software were provided by
%   A. Grinsted."
%
% (C) Aslak Grinsted 2002-2004
%
% http://www.pol.ac.uk/home/research/waveletcoherence/


% -------------------------------------------------------------------------
%   Copyright (C) 2002-2004, Aslak Grinsted
%   This software may be used, copied, or redistributed as long as it is not
%   sold and this copyright notice is reproduced on each copy made.  This
%   routine is provided as is without any express or implied warranties
%   whatsoever.


% ------validate and reformat timeseries.
[x,dt]=formatts(x);
[y,dty]=formatts(y);
if dt~=dty
    error('timestep must be equal between time series')
end
t=(max(x(1,1),y(1,1)):dt:min(x(end,1),y(end,1)))'; %common time period
if length(t)<4
    error('The two time series must overlap.')
end


lag1x=ar1(x(:,2));
nx=size(x,1);
sigmax=std(x(:,2));

lag1y=ar1(y(:,2));
ny=size(y,1);
sigmay=std(y(:,2));

n=length(t);

%----------default arguments for the wavelet transform-----------
Args=struct('Pad',1,...      % pad the time series with zeroes (recommended)
            'Dj',1/12, ...    % this will do 12 sub-octaves per octave
            'S0',2*dt,...    % this says start at a scale of 2 years
            'J1',[],...
            'Mother','Morlet', ...
            'MaxScale',[],...   %a more simple way to specify J1
            'MakeFigure',(nargout==0),...
            'MonteCarloCount',1000,...
            'BlackandWhite',0);
Args=parseArgs(varargin,Args,{'BlackandWhite'});
if isempty(Args.J1)
    if isempty(Args.MaxScale)
        Args.MaxScale=(n*.17)*2; %auto maxscale
    end
    Args.J1=round(log2(Args.MaxScale/Args.S0)/Args.Dj);
end

if ~strcmpi(Args.Mother,'morlet')
    warning('Smoothing operator is designed for morlet wavelet.')
end


%-----------:::::::::::::--------- ANALYZE ----------::::::::::::------------

[X,period,scale,coix] = wavelet(x(:,2),dt,Args.Pad,Args.Dj,Args.S0,Args.J1,Args.Mother);
[Y,period,scale,coiy] = wavelet(y(:,2),dt,Args.Pad,Args.Dj,Args.S0,Args.J1,Args.Mother);

%Smooth X and Y before truncating!  (minimize coi)
sinv=1./(scale');


sX=smoothwavelet(sinv(:,ones(1,nx)).*(abs(X).^2),dt,period,Args.Dj,scale);
sY=smoothwavelet(sinv(:,ones(1,ny)).*(abs(Y).^2),dt,period,Args.Dj,scale);


% truncate X,Y to common time interval (this is first done here so that the coi is minimized)
idx=find((x(:,1)>=(t(1)))&(x(:,1)<=(t(end))));
X=X(:,idx);
sX=sX(:,idx);
coix=coix(idx);

idx=find((y(:,1)>=(t(1)))&(y(:,1)<=(t(end))));
Y=Y(:,idx);
sY=sY(:,idx);
coiy=coiy(idx);

coi=min(coix,coiy);

% -------- Cross wavelet -------
Wxy=X.*conj(Y);

% ----------------------- Wavelet coherence ---------------------------------
sWxy=smoothwavelet(sinv(:,ones(1,n)).*Wxy,dt,period,Args.Dj,scale);
Rsq=abs(sWxy).^2./(sX.*sY);

if Args.MakeFigure
    
    wtcsig=wtcsignif(Args.MonteCarloCount,[lag1x lag1y],dt,length(t)*2,Args.Pad,Args.Dj,Args.S0,Args.J1,Args.Mother,.6); 
    wtcsig=(wtcsig(:,2))*(ones(1,n));
    wtcsig=Rsq./wtcsig;

    Yticks = 2.^(fix(log2(min(period))):fix(log2(max(period))));
    
    if Args.BlackandWhite
        levels = [0 0.5 0.8 0.9 1];
        [cout,H]=safecontourf(t,log2(period),Rsq,levels);

        colorbarf(cout,H)
        cmap=[0 1;.5 .9;.8 .8;.9 .6;1 .5];
        cmap=interp1(cmap(:,1),cmap(:,2),(0:.1:1)');
        cmap=cmap(:,[1 1 1]);
        colormap(cmap)
        set(gca,'YLim',log2([min(period),max(period)]), ...
            'YDir','reverse', 'layer','top', ...
            'YTick',log2(Yticks(:)), ...
            'YTickLabel',num2str(Yticks'), ...
            'layer','top')
        ylabel('Period')
        hold on

        %phase plot
        aWxy=angle(Wxy);
        lowRidx=find(Rsq<.5); %remove phase indication where Rsq is low
        aaa=aWxy;
        aaa(lowRidx)=NaN;
        %[xx,yy]=meshgrid(t(1:5:end),log2(period));

        phs_dt=round(length(t)/30); tidx=max(floor(phs_dt/2),1):phs_dt:length(t);
        phs_dp=round(length(period)/30); pidx=max(floor(phs_dp/2),1):phs_dp:length(period);
        phaseplot(t(tidx),log2(period(pidx)),aaa(pidx,tidx),.05,5);

        if ~all(isnan(wtcsig))
            [c,h] = contour(t,log2(period),wtcsig,[1 1],'k');
            set(h,'linewidth',2)
        end
        %suptitle([sTitle ' coherence']);
        plot(t,log2(coi),'k')
        hold off
    else
        H=imagesc(t,log2(period),Rsq);
        set(gca,'clim',[0 1])
        
        HCB=safecolorbar;
        
        set(gca,'YLim',log2([min(period),max(period)]), ...
            'YDir','reverse', 'layer','top', ...
            'YTick',log2(Yticks(:)), ...
            'YTickLabel',num2str(Yticks'), ...
            'layer','top')
        ylabel('Period')
        hold on

        %phase plot
        aWxy=angle(Wxy);
        lowRidx=find(Rsq<.5); %remove phase indication where Rsq is low
        aaa=aWxy;
        aaa(lowRidx)=NaN;
        %[xx,yy]=meshgrid(t(1:5:end),log2(period));

        phs_dt=round(length(t)/30); tidx=max(floor(phs_dt/2),1):phs_dt:length(t);
        phs_dp=round(length(period)/30); pidx=max(floor(phs_dp/2),1):phs_dp:length(period);
        phaseplot(t(tidx),log2(period(pidx)),aaa(pidx,tidx),.03,5);

        if ~all(isnan(wtcsig))
            [c,h] = contour(t,log2(period),wtcsig,[1 1],'k');
            set(h,'linewidth',2)
        end
        %suptitle([sTitle ' coherence']);
        tt=[t([1 1])-dt*.5;t;t([end end])+dt*.5];
        hcoi=fill(tt,log2([period([end 1]) coi period([1 end])]),'w');
        set(hcoi,'alphadatamapping','direct','facealpha',.5)
        hold off
    end
end

varargout={Rsq,period,scale,coi};
varargout=varargout(1:nargout);






function [cout,H]=safecontourf(varargin)
vv=sscanf(version,'%i.');
if (version('-release')<14)|(vv(1)<7)
    [cout,H]=contourf(varargin{:});
else
    [cout,H]=contourf('v6',varargin{:});
end

function hcb=safecolorbar(varargin)
vv=sscanf(version,'%i.');

if (version('-release')<14)|(vv(1)<7)
    hcb=colorbar(varargin{:});
else
    hcb=colorbar('v6',varargin{:});
end

