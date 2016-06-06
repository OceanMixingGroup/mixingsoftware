function C=CheckFileStatusChipod(cruise,allSNs,castdirs,castnums)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% CheckFileStatusChipod
%
% Modified from CheckFileStatusChipod_P16N.m
%
% General function to summarize what casts we have good CTD and/or chipod data for.
%
% Assumes paths/filenames follow general rules that I made up
%
%
% INPUT:
%---------
% cruise   :
% allSNs   : List of chipod SNs
% castdirs : up or down for each SN
% castnums : castnumbers
%
% OUTPUT
%---------
% C : Structure with indices of good/bad data
%
% Makes a summary plot also.
% Also writes a txt file summarizing results
%
% History
%--------------------------------------
% 12/14/15 - A. Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear

% paths for this dataset
Load_chipod_paths_TTide_Leg1

% deployment info for this dataset
Chipod_Deploy_Info_TTIDE

% make a text file to print a summary of results to
txtfname=['FileStatusCheck' datestr(floor(now)) '.txt'];
fileID= fopen(fullfile(chi_proc_path,txtfname),'a');
fprintf(fileID,['\n \n CTD-chipod File Check Summary\n']);
fprintf(fileID,['\n \n Created ' datestr(now) '\n']);
fprintf(fileID,['\n \n chi_proc_path: ' chi_proc_path '\n']);

% make list of CTD casts (NOTE this won't include towyos for TTIDE)
ctd_list=dir(fullfile(CTD_out_dir_24hz,['*' ChiInfo.CastString '*.mat']))
%ctd_list=dir(fullfile(CTD_out_dir_bin,['*' ChiInfo.CastString '*.mat']))

% list of chipod SNs to look at
allSNs=ChiInfo.SNs
%
Ncasts=length(ctd_list);
%
isgood_ctd_bin=nan*ones(1,Ncasts);
isgood_ctd_raw=nan*ones(1,Ncasts);
isgood_chi_raw=nan*ones(1,Ncasts);
isgood_chi_avg=nan*ones(1,Ncasts);

C=struct();
C.ChiDataDir=chi_proc_path;
emptystruct=struct('isgood_ctd_bin',isgood_ctd_bin,'isgood_ctd_raw',isgood_ctd_raw,'isgood_chi_raw',isgood_chi_raw,'isgood_chi_avg',isgood_chi_avg);
whsens='T1';

for iSN=1:length(allSNs)
    
    clear whSN castdir
    
    whSN=allSNs{iSN}
    %    castdir=ChiInfo.(whSN).InstDir.(whsens);
    castdir='up'
    
    fprintf(fileID,['\n \n ~~~~~~~~~~~~~~ ' whSN ' ' castdir ' \n']);
    
    C.([whSN '_' castdir])=emptystruct;
    allcastnums=[]
    %
    for whfile=1:length(ctd_list)%
        clear avg ctd whcast chifile ctdfile_bin ctdfile_raw chifile1
        
        clear castname castnum
        castname=ctd_list(whfile).name(1:end-4);
        castnum=castname(12:14);
        allcastnums=[allcastnums str2num(castnum)];
        
        %        whcast=sprintf(['%03d'],castnums(whfile));
        chifile1=fullfile(chi_proc_path,whSN,'cal',['cal_' castname '_' whSN '_' castdir 'cast.mat']);
        chifile=fullfile(chi_proc_path,whSN,'avg',['avg_' castname '_' whSN '_' castdir 'cast_' whsens '.mat']);
        
        %        ctdfile_bin=fullfile(CTD_out_dir_bin,['RH_' whcast '.mat']);
        %       ctdfile_raw=fullfile(CTD_out_dir_raw,['RH_' whcast '_0.mat']);
        
        %
        %         if ~exist(ctdfile_bin,'file')
        %             fprintf(fileID,[' \n Cast ' whcast  ': No CTD binned \n']);
        %             C.([whSN '_' castdir]).isgood_ctd_bin(whfile)=0;
        %         else
        %             C.([whSN '_' castdir]).isgood_ctd_bin(whfile)=1;
        %         end
        
        %         if ~exist(ctdfile_raw,'file')
        %             fprintf(fileID,[' \n Cast ' whcast  ': No CTD 24Hz \n']);
        %             C.([whSN '_' castdir]).isgood_ctd_raw(whfile)=0;
        %         else
        %             C.([whSN '_' castdir]).isgood_ctd_raw(whfile)=1;
        %
        %         end
        %
        if ~exist(chifile1,'file')
            fprintf(fileID,[' \n Cast ' castname  ': No chi data for profile \n']);
            C.([whSN '_' castdir]).isgood_chi_raw(whfile)=0;
        else
            C.([whSN '_' castdir]).isgood_chi_raw(whfile)=1;
            
        end
        
        if ~exist(chifile,'file')
            fprintf(fileID,[' \n Cast ' castname  ': No chi processed \n']);
            C.([whSN '_' castdir]).isgood_chi_avg(whfile)=0;
        else
            C.([whSN '_' castdir]).isgood_chi_avg(whfile)=1;
            
        end
        
    end % cast #
    
end % SN
%

%%

%

%vars={'ctd_raw' 'ctd_bin' 'chi_raw' 'chi_avg'}
vars={'chi_raw' 'chi_avg'}

figure(1);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.15, 0.05, 0.2, 0.06, 0.1, 0.05, 1,length(vars));
for ivar=1:length(vars)
    
    axes(ax(ivar))
    
    for iSN=1:length(allSNs)
        clear idg idb whSN castdir
        whSN=allSNs{iSN};
        
        %        castdir=castdirs{iSN};
        castdir='up'
        idg=find(C.([whSN '_' castdir]).(['isgood_' vars{ivar}])==1);
        idb=find(C.([whSN '_' castdir]).(['isgood_' vars{ivar}])==0);
        
        if ~isempty(idg)
            
            fprintf(fileID,[' \n ' whSN  ': ' num2str(round(length(idg)/length(ctd_list)*100)) ' %% good ' vars{ivar} ' \n']);
            %disp([' \n ' whSN  ': ' num2str(round(length(idg)/length(castnums)*100)) '%% good ' vars{ivar} ' \n']);
            
            hg=plot(allcastnums(idg),iSN,'rd','linewidth',2);
            hold on
        end
        
        if ~isempty(idb)
            hb=plot(allcastnums(idb),iSN,'ko','linewidth',2);
            hold on
        end
        
    end
    
    grid on
    ylabel(vars{ivar},'interpreter','none')
    
    set(gca,'YTick',1:length(allSNs))
    set(gca,'YTickLabel',allSNs)
    
end

axes(ax(length(vars)))
xlabel('Cast #')

axes(ax(1))
title(['P16N ' cruise ' Good (red) & bad (black) \chi-pod data'])
linkaxes(ax)

fclose(fileID)
%%