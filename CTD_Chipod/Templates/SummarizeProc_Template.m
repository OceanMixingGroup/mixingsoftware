%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% SummarizeProc_Template.m
%
% Load Xproc.mat from MakeCasts and summarize CTD and chippod data.
%
%
%---------------
% 06/14/16 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

saveplots=1

%***
cruise='Template'
cd(['/Users/Andy/Cruises_Research/ChiPod/' cruise '/mfiles'])
figdir=['/Users/Andy/Cruises_Research/ChiPod/' cruise '/Figures/']
%~~~

load('Xproc.mat')


%% Plot if we have data, if T1cal is good, and time offset for one chipod

iSN=2
whSN=Xproc.SNs{iSN}

Ncasts=length(Xproc.icast)
rr=3
cc=1

figure(1);clf
agutwocolumn(1)
wysiwyg

ax1=subplot(rr,cc,1);
plot(Xproc.icast,Xproc.(whSN).IsChiData,'o')
grid on
SubplotLetterMW('chi data');
title(whSN)

ax2=subplot(rr,cc,2);
plot(Xproc.icast,Xproc.(whSN).T1cal,'o')
grid on
SubplotLetterMW('T1 cal');

ax3=subplot(rr,cc,3);
plot(Xproc.icast,Xproc.(whSN).toffset,'o')
grid on
ylabel('toffset')
xlabel('icast','fontsize',16)
gridxy

linkaxes([ax1 ax2 ax3],'x')

%% Plot if we have chi data for each chipod

figure(1);clf
agutwocolumn(1)
wysiwyg

for iSN=1:length(Xproc.SNs)
    
    clear whSN idg
    
    whSN=Xproc.SNs{iSN}
    idg=find(Xproc.(whSN).IsChiData==1);
    
    ax1=subplot(2,1,1);
    plot(Xproc.drange(idg,1),Xproc.(whSN).IsChiData(idg)+iSN-1,'o')
    hold on
    grid on
    
    ax2=subplot(212);
    plot(Xproc.icast(idg),Xproc.(whSN).IsChiData(idg)+iSN-1,'o')
    hold on
    grid on
    
end % iSN
%

axes(ax1)
datetick('x')
xlabel('date','fontsize',16)
set(gca,'YTick',1:length(Xproc.SNs))
set(gca,'YTickLabel',Xproc.SNs)%
set(gca,'Fontsize',15)
title([cruise ' - Casts w/ \chi pod data'])
ylim([0 length(Xproc.SNs)+1])

axes(ax2)
xlabel('Cast id','fontsize',16)
set(gca,'YTick',1:length(Xproc.SNs))
set(gca,'YTickLabel',Xproc.SNs)%
set(gca,'Fontsize',15)
ylim([0 length(Xproc.SNs)+1])

if saveplots==1
    figname=[cruise '_haveChiData_all']
    print(fullfile(figdir,figname),'-dpng')
end

%% Plot time offsets for each chipod

figure(1);clf
agutwocolumn(1)
wysiwyg

yl=50*[-1 1];

for iSN=1:length(Xproc.SNs)
    
    clear whSN idg
    
    whSN=Xproc.SNs{iSN}
    idg=find(Xproc.(whSN).IsChiData==1);
    
    if length(Xproc.SNs)>1
        
        ax1=subplot(ceil(length(Xproc.SNs)/2),2,iSN);
        
    else
        
    end % if more than 1 SN
    
    plot(Xproc.icast(idg),Xproc.(whSN).toffset(idg),'o')
    hold on
    idb=find(abs(Xproc.(whSN).toffset(idg))>yl(2));
    plot(Xproc.icast(idb),yl(2)*ones(size(idb)),'rx')
    grid on
    title(whSN)
    xlim([1 length(Xproc.icast)])
    ylim(yl)
    gridxy
    xlabel('castID')
    ylabel('sec')
    
    
    
end % iSN
%

if saveplots==1
    figname=[cruise '_timeoffsets_all']
    print(fullfile(figdir,figname),'-dpng')
end



%% Make a table with processing info that can be pasted into Latex notes

clc
and=' & ';
lend=' \\ ';

disp('\begin{table}[htdp]')
disp(['\caption{Some $\chi$pod processing summary info for ' cruise ...
    '. There were ' num2str(length(Xproc.icast)) ' CTD casts.}'])
disp('\begin{center}')
disp('\begin{tabular}{|c|c|c|c|}')

disp('\hline')
% Table column names
disp(['SN' and '$\chi$ data' and 'T1cal Good' and 'toffset $<$ 1min' lend])
disp('\hline')
disp('\hline')

for iSN=1:length(Xproc.SNs)
    
    clear whSN id1 id2 id22 id3 id4 id5 idg
    whSN=Xproc.SNs{iSN};
    id1=find(Xproc.(whSN).IsChiData==1);   % Have chipod data
    id2=find(Xproc.(whSN).T1cal==1);       % T1 cal good (1=good)
    id22=find(Xproc.(whSN).T2cal==1);      % T1=2 cal good (1=good)
    id5=find(abs(Xproc.(whSN).toffset)<60);% Time offset <1min (good)
    id3=find(Xproc.duration*24*60 < 20);   % Cast duration <20min (probably bad)
    id4=find(Xproc.Prange < 100);          % Cast pressure range <100m (probably bad)
    idg=intersect(id2,id5);
    
    disp([whSN and num2str(length(id1)) and num2str(length(id2)) and num2str(length(id5)) lend])
    
end

disp('\hline')
disp('\end{tabular}')
disp('\end{center}')
disp('\label{procinfo}')
disp('\end{table}')


%%