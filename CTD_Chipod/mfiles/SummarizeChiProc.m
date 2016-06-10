function SummarizeChiProc(ChiInfo,BaseDir)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% SummarizeChiProc.m
%
% Load Xproc.mat from MakeCasts and summarize CTD and chippod data.
%
% check that CTD cast is >x mins, and Prange>xm, otherwise might be bad
%
%---------------
% 06/10/16 - AP
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

%clear ; close all

saveplots=1

%~~~
cruise=ChiInfo.Project;
%cd(fullfile(BaseDir,)
figdir=fullfile(BaseDir,'Figures')
%~~~

load( fullfile( BaseDir,'mfiles','Xproc.mat'))


%% Plot if we have chi for each cast data

figure(1);clf
agutwocolumn(0.75)
wysiwyg

for iSN=1:length(Xproc.SNs)
    
    clear whSN idg
    
    whSN=Xproc.SNs{iSN}
    idg=find(Xproc.(whSN).IsChiData==1);
    
    ax1=subplot(2,1,1);
    plot(Xproc.icast(idg),Xproc.(whSN).IsChiData(idg)+iSN-1,'o')
    %    plot(Xproc.(whSN).drange(idg,1),Xproc.(whSN).IsChiData(idg)+iSN-1,'o')
    hold on
    grid on
    
    %     ax2=subplot(212);
    %     plot(Xproc.icast(idg),Xproc.(whSN).IsChiData(idg)+iSN-1,'o')
    % %    plot(Xproc.(whSN).drange(idg,1),Xproc.(whSN).IsChiData(idg)+iSN-1,'o')
    %     hold on
    %     grid on
    
end % iSN
%

% axes(ax1)
% datetick('x')
%
% set(gca,'YTick',1:4)
% set(gca,'YTickLabel',['SN1001' ;'SN1006'; 'SN1008' ;'SN1014'])
% set(gca,'Fontsize',15)
title([cruise ' - Casts w/ \chi pod data'])

%axes(ax2)
xlabel('Cast id','fontsize',16)
set(gca,'YTick',1:length(Xproc.SNs))
set(gca,'YTickLabel',Xproc.SNs)%['SN1001' ;'SN1006'; 'SN1008' ;'SN1014'])
set(gca,'Fontsize',15)

if saveplots==1
    figname=[cruise '_haveChiData_all']
    print(fullfile(figdir,figname),'-dpng')
end

%% Plot time offsets

figure(1);clf
agutwocolumn(1)
wysiwyg

yl=20*[-1 1];

for iSN=1:length(Xproc.SNs)
    
    clear whSN idg
    
    whSN=Xproc.SNs{iSN}
    idg=find(Xproc.(whSN).IsChiData==1);
    
    ax1=subplot(ceil(length(Xproc.SNs))/2,2,iSN);
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

%%
% 
% id1=find(Xproc.(whSN).IsChiData==1);
% id2=find(Xproc.(whSN).T1cal==1);
% id5=find(abs(Xproc.(whSN).toffset)<60);
% id3=find(Xproc.duration*24*60 < 20)
% id4=find(Xproc.Prange < 100)
% idg=intersect(id2,id5);
% 
% disp([num2str(length(id3)) ' out of ' num2str(Ncasts) ' casts have duration less than 20 mins '])
% disp([num2str(length(id4)) ' out of ' num2str(Ncasts) ' casts have P range less than 100 m '])
% 
% disp([num2str(length(id1)) ' out of ' num2str(Ncasts) ' casts have chi data '])
% disp([num2str(length(id2)) ' out of ' num2str(Ncasts) ' casts have good T1 cal '])
% disp([num2str(length(id5)) ' out of ' num2str(Ncasts) ' casts have toffset <1 min '])
% 
% disp([num2str(length(idg)) ' out of ' num2str(Ncasts) ' casts have good T1 cal AND t-offset <1 min '])

%%
% 
% clc
% for iSN=1:length(Xproc.SNs)
%     
%     clear whSN id1 id2 id22 id3 id4 id5 idg
%     whSN=Xproc.SNs{iSN};
%     id1=find(Xproc.(whSN).IsChiData==1);
%     id2=find(Xproc.(whSN).T1cal==1);
%     id22=find(Xproc.(whSN).T2cal==1);
%     id5=find(abs(Xproc.(whSN).toffset)<60);
%     id3=find(Xproc.duration*24*60 < 20);
%     id4=find(Xproc.Prange < 100);
%     idg=intersect(id2,id5);
%     
%     
%     
%     disp([whSN ':'])
%     disp('\begin{itemize}')
%     
%     disp([ '\item ' num2str(length(id3)) ' out of ' num2str(Ncasts) ' casts have duration less than 20 mins '])
%     disp([ '\item '  num2str(length(id4)) ' out of ' num2str(Ncasts) ' casts have P range less than 100 m '])
%     
%     disp([ '\item '  num2str(length(id1)) ' out of ' num2str(Ncasts) ' casts have $\chi$pod data '])
%     disp([ '\item '  num2str(length(id2)) ' out of ' num2str(Ncasts) ' casts have good T1 cal '])
%     
%     %     if strcmp(whSN,'SN1001')
%     %         disp([ '\item '  num2str(length(id22)) ' out of ' num2str(Ncasts) ' casts have good T2 cal '])
%     %     end
%     
%     disp([ '\item '  num2str(length(id5)) ' out of ' num2str(Ncasts) ' casts have toffset less than 1 min '])
%     disp('\end{itemize}')
%     
% end

%% Lets make a more condensed table with the same info as above

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
    id1=find(Xproc.(whSN).IsChiData==1);
    id2=find(Xproc.(whSN).T1cal==1);
    id22=find(Xproc.(whSN).T2cal==1);
    id5=find(abs(Xproc.(whSN).toffset)<60);
    id3=find(Xproc.duration*24*60 < 20);
    id4=find(Xproc.Prange < 100);
    idg=intersect(id2,id5);
    
    disp([whSN and num2str(length(id1)) and num2str(length(id2)) and num2str(length(id5)) lend])
    
    %     disp([whSN ':'])
    %     disp('\begin{itemize}')
    %
    %     disp([ '\item ' num2str(length(id3)) ' out of ' num2str(Ncasts) ' casts have duration less than 20 mins '])
    %     disp([ '\item '  num2str(length(id4)) ' out of ' num2str(Ncasts) ' casts have P range less than 100 m '])
    %
    %     disp([ '\item '  num2str(length(id1)) ' out of ' num2str(Ncasts) ' casts have $\chi$pod data '])
    %     disp([ '\item '  num2str(length(id2)) ' out of ' num2str(Ncasts) ' casts have good T1 cal '])
    %
    % %     if strcmp(whSN,'SN1001')
    % %         disp([ '\item '  num2str(length(id22)) ' out of ' num2str(Ncasts) ' casts have good T2 cal '])
    % %     end
    %
    %     disp([ '\item '  num2str(length(id5)) ' out of ' num2str(Ncasts) ' casts have toffset less than 1 min '])
    %     disp('\end{itemize}')
    %
end
disp('\hline')
disp('\end{tabular}')
disp('\end{center}')
disp('\label{procinfo}')
disp('\end{table}')


%%