function varargout=xwt(x,y,varargin)
% Cross wavelet transform
%
% USAGE: [Wxy,period,scale,coi]=xwt(x,y,[,settings])
%
% 
% Settings: Pad,Dj,S0,J1,Mother  : see help on wavelet
%           MaxScale             : 
%           Makefigure           : make the figure or just return the output
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
            'BlackandWhite',0);
Args=parseArgs(varargin,Args,{'BlackandWhite'});
if isempty(Args.J1)
    if isempty(Args.MaxScale)
        Args.MaxScale=(n*.17)*2; %auto maxscale
    end
    Args.J1=round(log2(Args.MaxScale/Args.S0)/Args.Dj);
end



%-----------:::::::::::::--------- ANALYZE ----------::::::::::::------------

[X,period,scale,coix] = wavelet(x(:,2),dt,Args.Pad,Args.Dj,Args.S0,Args.J1,Args.Mother);
[Y,period,scale,coiy] = wavelet(y(:,2),dt,Args.Pad,Args.Dj,Args.S0,Args.J1,Args.Mother);

% truncate X,Y to common time interval (this is first done here so that the coi is minimized)
idx=find((x(:,1)>=(t(1)))&(x(:,1)<=(t(end))));
X=X(:,idx);
coix=coix(idx);

idx=find((y(:,1)>=(t(1)))&(y(:,1)<=(t(end))));
Y=Y(:,idx);
coiy=coiy(idx);

coi=min(coix,coiy);

% -------- Cross
Wxy=X.*conj(Y);



% sinv=1./(scale');
% sinv=sinv(:,ones(1,size(Wxy,2)));
% 
% sWxy=smoothwavelet(sinv.*Wxy,dt,period,dj,scale);
% Rsq=abs(sWxy).^2./(smoothwavelet(sinv.*(abs(wave1).^2),dt,period,dj,scale).*smoothwavelet(sinv.*(abs(wave2).^2),dt,period,dj,scale));
% freq = dt ./ period;

%---- Significance levels
%Pk1=fft_theor(freq,lag1_1);
%Pk2=fft_theor(freq,lag1_2);
Pkx=ar1spectrum(lag1x,period./dt);
Pky=ar1spectrum(lag1y,period./dt);


V=2;
Zv=3.9999;
signif=sigmax*sigmay*sqrt(Pkx.*Pky)*Zv/V;
sig95 = (signif')*(ones(1,n));  % expand signif --> (J+1)x(N) array
sig95 = abs(Wxy) ./ sig95;
if ~strcmpi(Args.Mother,'morlet')

    sig95(:)=nan;
end

if Args.MakeFigure
    Yticks = 2.^(fix(log2(min(period))):fix(log2(max(period))));
    if Args.BlackandWhite
        levels = [0.25,0.5,1,2,4,8,16];
        [cout,H]=safecontourf(t,log2(period),log2(abs(Wxy/(sigmax*sigmay))),log2(levels));%,log2(levels));  %*** or use 'contourf3ill'
        cout(1,:)=2.^cout(1,:);

        HCB=colorbarf(cout,H);
        barylbls=rats([0 levels 0]');
        barylbls([1 end],:)=' ';
        barylbls(:,find(all(barylbls==' ',1)))=[];
        set(HCB,'yticklabel',barylbls);
        cmap=(1:-.01:.5)'*.9;
        cmap(:,2:3)=cmap(:,[1 1]);
        %cmap(:,1:2)=cmap(:,1:2)*.8;
        colormap(cmap);
        set(gca,'YLim',log2([min(period),max(period)]), ...
            'YDir','reverse', ...
            'YTick',log2(Yticks(:)), ...
            'YTickLabel',num2str(Yticks'), ...
            'layer','top')
        %xlabel('Time')
        ylabel('Period')
        hold on

        aWxy=angle(Wxy);

        phs_dt=round(length(t)/30); tidx=max(floor(phs_dt/2),1):phs_dt:length(t);
        phs_dp=round(length(period)/30); pidx=max(floor(phs_dp/2),1):phs_dp:length(period);
        phaseplot(t(tidx),log2(period(pidx)),aWxy(pidx,tidx),.05,5);

        if strcmpi(Args.Mother,'morlet')
            [c,h] = contour(t,log2(period),sig95,[1 1],'k');
            set(h,'linewidth',3)
        else
            warning('XWT Significance level calculation is only valid for morlet wavelet.')
            %TODO: alternatively load from same file as wtc (needs to be coded!)
        end
        plot(t,log2(coi),'k','linewidth',3)
        %hcoi=fill([t([1 1:end end])],log2([period(end) coi period(end)]),'r')
        %set(hcoi,'alphadatamapping','direct','facealpha',.3)
        hold off
    else
        H=imagesc(t,log2(period),log2(abs(Wxy/(sigmax*sigmay))));

        clim=get(gca,'clim'); %center color limits around log2(1)=0
        clim=[-1 1]*max(clim(2),3);
        set(gca,'clim',clim)

        HCB=safecolorbar;
        set(HCB,'ytick',-7:7);
        barylbls=rats(2.^(get(HCB,'ytick')'));
        barylbls([1 end],:)=' ';
        barylbls(:,find(all(barylbls==' ',1)))=[];
        set(HCB,'yticklabel',barylbls);
        
        set(gca,'YLim',log2([min(period),max(period)]), ...
            'YDir','reverse', ...
            'YTick',log2(Yticks(:)), ...
            'YTickLabel',num2str(Yticks'), ...
            'layer','top')
        %xlabel('Time')
        ylabel('Period')
        hold on

        aWxy=angle(Wxy);

        phs_dt=round(length(t)/30); tidx=max(floor(phs_dt/2),1):phs_dt:length(t);
        phs_dp=round(length(period)/30); pidx=max(floor(phs_dp/2),1):phs_dp:length(period);
        phaseplot(t(tidx),log2(period(pidx)),aWxy(pidx,tidx),.03,5);

        if strcmpi(Args.Mother,'morlet')
            [c,h] = contour(t,log2(period),sig95,[1 1],'k');
            set(h,'linewidth',2)
        else
            warning('XWT Significance level calculation is only valid for morlet wavelet.')
            %TODO: alternatively load from same file as wtc (needs to be coded!)
        end
        tt=[t([1 1])-dt*.5;t;t([end end])+dt*.5];
        hcoi=fill(tt,log2([period([end 1]) coi period([1 end])]),'w');
        set(hcoi,'alphadatamapping','direct','facealpha',.5)
        hold off
    end
end

varargout={Wxy,period,scale,coi};
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