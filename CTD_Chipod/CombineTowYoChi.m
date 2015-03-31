%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% CombineTowYoChi.m
%
% Combine processed chipod CTD data from towyos into single structure for
% plotting and analysis.
%
% Started 30 mar 2015 - A. Pickering
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

cd /Users/Andy/Cruises_Research/mixingsoftware/CTD_Chipod

% Set Paths etc.
% ~~ Paths for Andy's laptop
% Path where ctd data are located (already processed into mat files). There
% should be a folder in it called /24Hz
CTD_path='/Users/Andy/Dropbox/TTIDE_OBSERVATIONS/scienceparty_share/TTIDE-RR1501/data/ctd_processed/';
% Path where chipod data are located
chi_data_path='/Users/Andy/Cruises_Research/Tasmania/Data/Chipod_CTD/';
% path where processed chipod
chi_processed_path='/Users/Andy/Cruises_Research/Tasmania/Data/Chipod_CTD/Processed/';
% path to save figures to
%fig_path=[chi_processed_path 'figures/'];
%ChkMkDir(fig_path)

% Make a list of all ctd files
CTD_list=dir([CTD_path  '24hz/' '*_leg1_*.mat']);

% % make a text file to print a summary of results to
% if exist(fullfile(chi_processed_path,'TowyoResults.txt'),'file')
%     delete(fullfile(chi_processed_path,'TowyoResults.txt'))
% end
%
% fileID= fopen(fullfile(chi_processed_path,'TowyoResults.txt'),'a');
%
% fprintf(fileID,['Created ' datestr(now) '\n'])
% fprintf(fileID,[CTD_path '\n'])
% fprintf(fileID,[chi_data_path '\n'])
% fprintf(fileID,[chi_processed_path '\n'])
% fprintf(fileID,[fig_path '\n'])

% we loop through and do processing for each ctd file
%hb=waitbar(0,'Looping through ctd files')

% ind for TTide towyos: 61-68, 102-117,120-131, 151-206

for a=66%:length(CTD_list)
    %waitbar(a/length(CTD_list),hb)
    
    clear castname tlim time_range cast_suffix_tmp cast_suffix data2
    castname=CTD_list(a).name;
    
    %    fprintf(fileID,['\n ~~~' castname '~~~\n'])
    
    %load CTD profile
    load([CTD_path '24hz/' castname])
    % create a CTD time:
    % Sometimes the time needs to be converted from computer time into matlab (datenum?) time.
    % Time will be converted when CTD time is more than 5 years bigger than now.
    % JRM
    tlim=now+5*365;
    if data2.time > tlim
        % jen didn't save us a real 24 hz time.... so create timeseries. JRM
        % from data record
        %        disp('test!!!!!!!!!!')
        tmp=linspace(data2.time(1),data2.time(end),length(data2.time));
        data2.datenum=tmp'/24/3600+datenum([1970 1 1 0 0 0]);
    end
    
    clear tlim tmp
    time_range=[min(data2.datenum) max(data2.datenum)];
    cast_suffix_tmp=CTD_list(a).name; % Cast # may be different than file #. JRM
    cast_suffix=cast_suffix_tmp(end-8:end-6);
    
    
    % check if this is a towyo (only do towyos)
    %if ~exist(fullfile(CTD_path,[] '_leg1_' cast_suffix '_split*.mat']
    clear splitlist
    splitlist=dir([CTD_path '*' cast_suffix '_split*.mat']);
    
    if size(splitlist,1)>1 % this is a towyo
        
        %
        % Info for chipods deployed on CTD is entered here (SN, up/down, etc.).
        % Might run into issues if chipods are switched out during cruise...
        
        
        for up_down_big=2%:2
            % load chipod data
            short_labs={'up_1012','down_1013','big'};
            big_labs={'Ti UpLooker','Ti DownLooker','Unit 1002'};
            
            %            fprintf(fileID,['~' short_labs{up_down_big} '~\n'])
            
            switch up_down_big
                case 1
                    % Specify uplooker path JRM
                    chi_path=fullfile(chi_data_path,'1012')
                    az_correction=-1; % -1 if the Ti case is pointed down or up
                    suffix='A1012';
                    isbig=0;
                    cal.coef.T1P=0.097;
                    is_downcast=0;
                case 2
                    % Specify downlooker JRM
                    chi_path=fullfile(chi_data_path,'1013')
                    az_correction=1;
                    suffix='A1013';
                    isbig=0;
                    cal.coef.T1P=0.097;
                    is_downcast=1;
                case 3 % For now not doing big Chi
                    chi_path='../data/A16S/Chipod_CTD/';az_correction=1;
                    suffix='1002';
                    isbig=1;
                    cal.coef.T1P=0.105;
                    cal.coef.T2P=0.105;
                    is_downcast=0;
            end
            
            
            SplitFiles=dir([CTD_path '*_leg1_' cast_suffix '_split*.mat'])
            Nsplit=length(SplitFiles)
            chi_processed_path_specific=fullfile(chi_processed_path,['chi_' short_labs{up_down_big} ])
            
            chi_processed_path_avg=fullfile(chi_processed_path_specific,'avg');
            big=[];
            
            % first figure out min and max pressures
            Pall=[];
            for whsplit=1:Nsplit
                processed_file=fullfile(chi_processed_path_avg,['avg_' cast_suffix '_' short_labs{up_down_big} '_split' num2str(whsplit) '.mat'])
                clear avg ctd
                load(processed_file)
                Pall=[Pall ;avg.P];
            end
            
            minP=nanmin(Pall(:))
            maxP=nanmax(Pall(:))
            zvec=minP:1:maxP;
            %%
            fdnames={'KT1','N2','dTdz','fspd','T','S','theta','sigma','chi1','eps1'}
            for whf=1:length(fdnames)
                eval([fdnames{whf} 'all=nan* ones(length(zvec),Nsplit);']);
            end
            %

            dnumall=nan*ones(1,Nsplit);
            for whsplit=1:Nsplit
                processed_file=fullfile(chi_processed_path_avg,['avg_' cast_suffix '_' short_labs{up_down_big} '_split' num2str(whsplit) '.mat'])
                clear avg ctd
                load(processed_file)
                dnumall(whsplit)=nanmean(avg.datenum);
                
                for whf=1:length(fdnames)
                    clear idg
                    % interp won't work with NaNs so find good data
                    idg=find(~isnan(avg.(fdnames{whf})));
                    if ~isempty(idg)
                        eval([fdnames{whf} 'all(:,whsplit)=interp1(avg.P(idg),avg.' fdnames{whf} '(idg),zvec);']);
                    end
                end
            end
            %
            
            figure(1);clf
            subplot(312)
            ezpc(dnumall,zvec,log10(KT1all))
            colorbar
            datetick('x')
            
            subplot(313)
            ezpc(dnumall,zvec,log10(eps1all))
            colorbar
            datetick('x')
            
            subplot(311)
            ezpc(dnumall,zvec,(Tall))
            colorbar
            datetick('x')
            ylabel('Depth [m]')
            
            
            figure(2);clf
            semilogx(nanmean(KT1all,2),zvec)
            axis ij
            grid on
            %%
            
            clear avg
            avg_all=struct('dnum',dnumall,'KT1',KT1all,'N2',N2all)
            avg_all.MakeInfo=['Made ' datestr(now) ' w/ CombineTowYoChi.m']
            towyo_save_name=fullfile(chi_processed_path_avg,['avg_' cast_suffix '_' short_labs{up_down_big} '_towyoAll.mat'])
            save(towyo_save_name,'avg_all')
        
        end % diff chipods
    else
        disp('Not a towyo')
    end % if towyo
               
end % CTD files
%%