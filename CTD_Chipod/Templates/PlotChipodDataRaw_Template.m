%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% PlotChipodDataRaw_Template.m
%
% Plot the raw chipod data files, to do a quick check for any issues with
% data.
%
%
%-----------------------------
% 07/05/16 - A. Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all ; clc

saveplot=1

% *** Change 'Template' to project name
Load_chipod_paths_Template
Chipod_Deploy_Info_Template

% *** path for 'mixingsoftware' ***
mixpath='/Users/Andy/Cruises_Research/mixingsoftware/'
addpath(fullfile(mixpath,'CTD_Chipod','mfiles'))
addpath(fullfile(mixpath,'general')) % makelen.m in /general is needed
addpath(fullfile(mixpath,'marlcham')) % for integrate.m
addpath(fullfile(mixpath,'adcp')) % need for mergefields_jn.m in load_chipod_data

allSNs=ChiInfo.SNs

dtt=10;

isbig=0

%%
for iSN=1:length(allSNs)
    clear data_dir chi_file_list Nfiles   whSN
    
    whSN=allSNs{iSN}
    data_dir=fullfile(chi_data_path,whSN)
    
    figdir=fullfile(BaseDir,'Figures','chipodraw',whSN)
    ChkMkDir(figdir)
    
    
    % make list of all the data files we have
    chi_file_list=dir( fullfile(data_dir,['/*' whSN '*']))
    Nfiles=length(chi_file_list)
    %
    
    for whfile=1:Nfiles
        
        disp(['working on file ' num2str(whfile) ' out of ' num2str(Nfiles) ' for ' whSN])
        
        clear fname
        fname=fullfile(data_dir,chi_file_list(whfile).name);
        
        clear data head chidat
        close all
        %~~~ load chipod data
        try
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
            
            if isbig==1 % 'Big' chipod, need to plot T1 AND T2
                
                figure(1);clf
                agutwocolumn(1)
                wysiwyg
                ax = MySubplot(0.1, 0.03, 0.02, 0.06, 0.1, 0.08, 1,4);
                
                axes(ax(1))
                plot(chidat.datenum(1:dtt:end),chidat.T1(1:dtt:end))
                datetick('x',15)
                title(chi_file_list(whfile).name,'interpreter','none')
                grid on
                SubplotLetterMW('T1');
                
                axes(ax(2))
                plot(chidat.datenum(1:dtt:end),chidat.T2(1:dtt:end))
                datetick('x',15)
                grid on
                SubplotLetterMW('T2');
                
                axes(ax(3))
                plot(chidat.datenum(1:dtt:end),chidat.T1P(1:dtt:end))
                datetick('x',15)
                ylim([2.04 2.05])
                grid on
                SubplotLetterMW('T1P');
                
                axes(ax(4))
                plot(chidat.datenum(1:dtt:end),chidat.T2P(1:dtt:end))
                datetick('x',15)
                xlabel(['Time on ' datestr(floor(chidat.datenum(1)))])
                ylim([2.04 2.05])
                grid on
                SubplotLetterMW('T2P');
                
                linkaxes(ax,'x')
                
            else % 'mini' chipod, just plot T1
                
                figure(1);clf
                agutwocolumn(1)
                wysiwyg
                ax = MySubplot(0.1, 0.03, 0.02, 0.06, 0.1, 0.05, 1,3);
                
                axes(ax(1))
                plot(chidat.datenum(1:dtt:end),chidat.T1(1:dtt:end))
                datetick('x',15)
                title(chi_file_list(whfile).name,'interpreter','none')
                grid on
                SubplotLetterMW('T1');
                %
                axes(ax(2))
                plot(chidat.datenum(1:dtt:end),chidat.T1P(1:dtt:end))
                datetick('x',15)
                ylim([2.04 2.05])
                grid on
                SubplotLetterMW('T1P');
                
                axes(ax(3))
                plot(chidat.datenum(1:dtt:end),chidat.AX(1:dtt:end))
                hold on
                plot(chidat.datenum(1:dtt:end),chidat.AZ(1:dtt:end))
                grid on
                datetick('x')
                xlabel(['Time on ' datestr(floor(chidat.datenum(1)))])
                
                legend('AX','AZ','location','best')
                
                linkaxes(ax,'x')
                
            end % isbig
            
            if saveplot==1
                figname=fullfile(figdir,[whSN '_RawData_' chi_file_list(whfile).name(1:end-4)]);
                print('-dpng','-r300',figname)
            end
            
        end % try
        
    end % whfile
    
end % iSN
%%