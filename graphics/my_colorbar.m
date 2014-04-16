function h=my_colorbar(pos,clims,label,hgca,kill_handle)
% function my_colorbar adds a custom colorbar to any plot that doesn't
% change the size of the original plot, nor does it get altered when you
% change the size of the original plot.
% $Date: 2008/01/31 20:22:46 $ $Revision: 1.1.1.1 $ $Author: aperlin $ 
% Originally J. Nash
    if nargin==5
        delete(kill_handle)
    end
    if nargin<4
        hgca=gca;
    end
    if nargin<3
        label='';
    end
    if nargin<2  
        clims=caxis;
    end
    if nargin==0
        pos=[];
    end
    if isempty(clims)
        clims=caxis;
    end
    
    tmp1=multcol(ones(128,4),linspace(0,1,128));
    tmp2=linspace(clims(1),clims(2),128);
    p=get(hgca,'position');
fs=get(hgca,'fontsize');
fw=get(hgca,'fontweight');
    do_vert=1;
    if do_vert
        if isempty(pos)
            pos=[p(1)+p(3)+.02 p(2)+p(4)*.1 .02 p(4)*.8];
        end
        h=axes('position',pos);
        pcolor([1:4],tmp2',tmp1);, shading flat, caxis([0 1])
        set(gca,'xtick',[],'fontsize',fs,'fontweight',fw,'yaxislocation','right','box','on','layer','top');
        ylabel(label)
    else
        pos=[p(1)-.11 p(2)+.13 .10 .02]
        axes('position',newpos);
        pcolor(tmp2,[1:4]',tmp1');, shading flat, caxis([0 1])
        set(gca,'ytick',[],'fontsize',fs);
        xlabel(label)                
    end
    axes(hgca);
    
