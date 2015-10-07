function [idb]=FindChipodGlitches2(dnum,TP,template,Thresh,plotit)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% [idb]=FindChipodGlitches2(dnum,TP,template,Thresh,plotit)
%
% Simple function to find glitches with shape 'template' in chipod data by
% sliding template over data and finding where it matches. Takes advantage
% of fact that the glitches are very uniform and periodic.
%
% This is for older, 'big' chipods that had glitches. The glitches show up
% as spikes in TP at regular intervals (~1sec); I think they are caused by
% the instrument writing data to the file.
%
% INPUT
% dnum     : Time vector from chipod
% TP       : Temp. derivative from chipod
% template : Glitch template
% plotit   : option to plot results
%
% OUTPUT
% idb: Indices of bad data ('glitches')
%
%--------------------------------
% A. Pickering - July 17 2015 - apickering@coas.oregonstate.edu
% 09/28/15 - AP - Move to CTD_Chipod folder and make more general (was
% written specifically for Mendocino data before).
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

makeplot=0; % plot as we go for debugging

test=nan*ones(size(dnum));
Glen=length(template)-1;

for whi=1:length(dnum)-Glen
    clear I ind dif
    I=whi;
    ind=[I:I+Glen];
    %test(whi)= nansum(TP(ind)-template(:) ) ;
    dif=(TP(ind)-nanmean(TP(ind)) ) - ( template-nanmean(template));
        
    test(whi)=nansum(dif.^2);
    
    if makeplot==1
        figure(1);clf
        subplot(211)
        plot(dnum,TP)
        hold on
        %  plot(dnum(ind),TP(ind),'o')
        plot(dnum(ind),template)
        datetick('x')
        axis tight
        xlim(dnum(I)+[-1/86400 1/86400])
        if abs(test(whi))<0.2e-5
        title(['test=' num2str(test(whi))],'fontcolor','r')
        else
            title(['test=' num2str(test(whi))])
        end
        
        subplot(212)
        plot(dnum(ind),TP(ind)-nanmean(TP(ind)))
        hold on
        plot(dnum(ind),template-nanmean(template))
        
        pause
    end
end
%%

%%
%id=find(abs(test)<0.2e-5);% Mendo
%id=find(abs(test)<1e-4); % IWISE11
id=find(abs(test)<Thresh); % IWISE11
%
idb=[id id+1 id+2 id+3 id+4 id+5 id+6 id+7 id+8];
idb=unique(idb(:));
idb=idb(find(idb<length(dnum))); % don't want indices after end

if plotit==1
    
%     
%     figure(1);clf
%     ax = MySubplot(0.1, 0.03, 0.02, 0.06, 0.1, 0.08, 1,2);
%     axes(ax(1))
%     plot(dnum,TP)
%     
%     axes(ax(2))
%     plot(dnum,abs(test))
%     linkaxes(ax,'x')

    figure(1);clf
    ax = MySubplot(0.1, 0.03, 0.02, 0.06, 0.1, 0.08, 1,2);
    
    clear tp2
    tp2=TP;
    tp2(idb)=nan;
    
    axes(ax(1))
    plot(dnum,TP)
    
    axes(ax(2))
    plot(dnum,tp2)
    
    linkaxes(ax)
end

return
%%