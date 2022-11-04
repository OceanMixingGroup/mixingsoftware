function PlotChipodDataRaw_General(the_project,mixpath)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% PlotChipodDataRaw_General.m
%
% Makes simple plots of all raw chipod data files, to do a quick check for
% any issues with data.
%
% INPUTS
% the_project
% mixpath
%
% Saves figures to fig_path/chipodraw/[whSN]
%
% Dependencies:
% raw_load_chipod.m
% load_mini_chipod
% ChkMkDir.m
% MySubplot.m
% SubplotLetterMW
%
% This script is part of CTD-chipod routines maintained in a github repo at
% https://github.com/OceanMixingGroup/mixingsoftware/tree/master/CTD_Chipod
%
%-----------------------------
% 02/10/16 - A. Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

saveplot=1

addpath(fullfile(mixpath,'CTD_Chipod'))

% Load paths for CTD and chipod data
eval(['Load_chipod_paths_' the_project])

% Load chipod deployment info
eval(['Chipod_Deploy_Info_' the_project])

allSNs = ChiInfo.SNs ;

for iSN = 1:length(allSNs)
    
    clear data_dir chi_file_list Nfiles whSN isbig
    
    whSN = allSNs{iSN};
    
    %data_dir=fullfile(chi_data_path,whSN(3:end))
    data_dir = fullfile(chi_data_path,whSN);
    
    isbig = ChiInfo.(whSN).isbig ;
    
    % make list of all the data files we have
    %chi_file_list=dir( fullfile(data_dir,['/*' whSN '*']))
    chi_file_list = dir( fullfile(data_dir));
    Nfiles = length(chi_file_list);
    
    disp([num2str(Nfiles) ' files found for ' num2str(whSN) ])
    
    for whfile = 1:Nfiles
        
        clear fname
        fname=fullfile(data_dir,chi_file_list(whfile).name);
        
        clear data head chidat
        close all

        if saveplot==1
            figdir = fullfile(fig_path,'chipodraw',whSN);
            figname = [chi_file_list(whfile).name(1:end-4)] ;
            if exist(fullfile(figdir,[figname,'.png']),'file')
                disp([figname,' has already been plotted; skipping...'])
                continue;
            end
        end

        %~~~ load chipod data
        try
            % 'big' chipod
            if isbig
                [data head]=raw_load_chipod(fname);
                chidat.datenum=data.datenum;
                len=length(data.datenum);
                if mod(len,2)
                    len=len-1; % for some reason datenum is odd!
                end
                chidat.T1=makelen(data.T1(1:(len/2)),len);
                chidat.T1P=data.T1P;
                chidat.T2=makelen(data.T2(1:(len/2)),len);
                chidat.T2P=data.T2P;
                chidat.AX=makelen(data.AX(1:(len/2)),len);
                chidat.AY=makelen(data.AY(1:(len/2)),len);
                chidat.AZ=makelen(data.AZ(1:(len/2)),len);
            else
                
                % its a minichipod
                try
                    [out,counter]=load_mini_chipod(fname);
                catch
                    try
                        [out,counter]=load_mini_chipod(fname,8400);
                    catch
                    end
                end
                
                chidat.datenum=counter;
                chidat.T1=out(:,2);
                chidat.T1P=out(:,1);
                chidat.AX=3*out(:,4);
                chidat.AZ=3*out(:,3);
                
            end
            
            % make a figure
            if isbig==1
                
                figure(1);clf
                agutwocolumn(1)
                wysiwyg
                ax = MySubplot(0.1, 0.03, 0.02, 0.06, 0.1, 0.08, 1,4);
                
                axes(ax(1)) ;
                plot(chidat.datenum,chidat.T1)
                datetick('x',15)
                title([whSN ' - ' chi_file_list(whfile).name],'interpreter','none')
                grid on
                SubplotLetterMW('T1');
                
                axes(ax(2));
                plot(chidat.datenum,chidat.T2)
                datetick('x',15)
                grid on
                SubplotLetterMW('T2');
                
                axes(ax(3)) ;
                plot(chidat.datenum,chidat.T1P)
                datetick('x',15)
                ylim([2 2.1])
                grid on
                SubplotLetterMW('T1P');
                
                axes(ax(4)) ;
                plot(chidat.datenum,chidat.T2P)
                datetick('x',15)
                xlabel(['Time on ' datestr(floor(chidat.datenum(1)))])
                ylim([2 2.1])
                grid on
                SubplotLetterMW('T2P') ;
                
                linkaxes(ax,'x')
                
            else
                
                figure(1);clf
                agutwocolumn(1)
                wysiwyg
                ax = MySubplot(0.1, 0.03, 0.02, 0.06, 0.1, 0.05, 1,3);
                
                axes(ax(1)) ;
                plot(chidat.datenum,chidat.T1)
                datetick('x',15)
                title(chi_file_list(whfile).name,'interpreter','none')
                title([whSN ' - ' chi_file_list(whfile).name],'interpreter','none')
                grid on
                SubplotLetterMW('T1') ;
                
                axes(ax(2)) ;
                plot(chidat.datenum,chidat.T1P)
                datetick('x',15)
                ylim([2 2.1])
                grid on
                SubplotLetterMW('T1P') ;
                
                axes(ax(3)) ;
                plot(chidat.datenum,chidat.AX)
                hold on
                plot(chidat.datenum,chidat.AZ)
                grid on
                datetick('x')
                xlabel(['Time on ' datestr(floor(chidat.datenum(1)))])
                legend('AX','AZ','location','best')
                
                linkaxes(ax,'x')
            end
            
            if saveplot==1
%                 figdir = fullfile(fig_path,'chipodraw',whSN);
                ChkMkDir(figdir)
%                 figname = [chi_file_list(whfile).name(1:end-4)] ;
                print( fullfile(figdir,figname),'-dpng')
            end
            
        end % try
        
    end % ifile
    
end % iSN
%%