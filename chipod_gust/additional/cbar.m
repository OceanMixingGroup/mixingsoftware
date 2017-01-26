function [] = cbar(axc, cax, cmap)
%% function [] = cbar(axc, cax, cmap)
%     this function plot a colorbar in the given axc
%     with color vector  cax
%     and colormap cmap
%
%     Created by
%        Johannes Becherer
%        Mon Aug 15 14:59:52 PDT 2016


if(nargin==1)
   set(axc, 'visible', 'off' )
   return
end

apos=get(axc,'Position');
casm=[cax ;cax];
if(apos(3)>apos(4)) % horizontal  colorbars
    contourf(axc, casx,[0 1],casm,cax,'edgecolor','none');
        colormap(axc, cmap);
        set(axc, 'Yticklabel',{},'Ytick',[]);
        xlim(axc, cax([1 end]));
        caxis(axc, cax([1 end]));
else % for vertical colorbars
    contourf(axc, [0 1],cax,casm',cax,'edgecolor','none');
        colormap(axc, cmap);
        set(axc, 'Xticklabel',{},'Xtick',[]);
        ylim(axc, cax([1 end]));
        caxis(axc, cax([1 end]));
        if(apos(1)>.5)
            set(axc, 'Yaxislocation','right');
        end
end
