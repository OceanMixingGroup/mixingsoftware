%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Make_Combined_Chi_Struct_Template.m
%
% Combine all processed CTD-chipod profiles into one structure. Processed
% files come from DoChiCalc...m
%
% %*** Indicates where you will need to change for your specific cruise. 
%
% Dependencies:
% - Load_chipod_paths_Template.m
% - Chipod_Deploy_Info_Template.m
% - binprofile.m
%
%----------------------------------
% 06/13/16 - AP - A. Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% 

clear ; close all

%***
Load_chipod_paths_Template
Chipod_Deploy_Info_Template
this_file_name='Make_Combined_Chi_Struct_Template.m'
savedata=0
% Local path for /mixingsoftware repo ***
mixpath='/Users/Andy/Cruises_Research/mixingsoftware/';
%***

addpath(fullfile(mixpath,'CTD_Chipod','mfiles'));


% Make a list of all the 24 hz CTD casts we have
CTD_list=dir(fullfile(CTD_out_dir_24hz,['*' ChiInfo.CastString '*.mat*']));
Ncasts=length(CTD_list);
disp(['There are ' num2str(Ncasts) ' CTD casts to process in ' CTD_out_dir_24hz])

% *** Params for chipod processing (determines file paths to proc data)
% These are default values, so you don't need to change unless you used others.
Params.z_smooth=20;  % distance (m) over which to smooth N^2 and dT/dz
Params.nfft=128;     % nfft to use in computing wavenumber spectra
Params.TPthresh=1e-6 % minimum TP variance to do calculation
Params.fmax=7;       % max freq to integrate TP spectrum to in chi calc
Params.resp_corr=0;  % correct TP spectra for freq response of thermistor
Params.fc=99;        % cutoff frequency for response correction
Params.gamma=0.2;    % mixing efficiency

% Naming string for chipod files based on params
params_str=MakePathStr(Params)

% Parameters for depth-binnning
zmin=0;
dzbin=10;
zmax=6000;
zbin = [zmin:dzbin:zmax]';
minobs=2;

% Make empty structures for the combined data
lat=nan*ones(1,Ncasts);
lon=nan*ones(1,Ncasts);
dnum=nan*ones(1,Ncasts);
eps=nan*ones(length(zbin),Ncasts);
chi=eps;
KT=eps;
dTdz=eps;
N2=eps;
t=eps;
s=eps;
TPvar=eps;

emptystruct=struct('lat',lat,'lon',lon,'dnum',dnum,'TPvar',TPvar,'eps',eps,'chi',chi,'KT',KT,'dTdz',dTdz,'N2',N2,'t',t,'s',s);

XC=struct();
XC.Name=[ChiInfo.Project];
XC.ChiDataDir=chi_proc_path;
XC.MakeInfo=['Made ' datestr(now) ' w/ ' this_file_name];
XC.BinInfo=['Profiles averaged in ' num2str(dzbin) 'm bins'];
XC.allSNs=ChiInfo.SNs;
XC.castnames={};


% Loop through each sensor
for iSN=1:length(ChiInfo.SNs)
    
    clear whSN castdir
    whSN=ChiInfo.SNs{iSN};
    
    % Do each direction (downcast/upcast)
    for idir=1:2
        
        clear castdir
        switch idir
            case 1
                castdir='up';
            case 2
                castdir='down';
        end
        
        % If it's a 'big' chipod, we'll get T2 also
        if ChiInfo.(whSN).isbig
            ntodo=2;
        else
            ntodo=1;
        end
        
        for isens=1:ntodo
            switch isens
                case 1
                    whsens='T1';
                case 2
                    whsens='T2'
            end
            
            XC.([whSN '_' castdir '_' whsens])=emptystruct ;
            
            % Initialize a waitbar
            hb=waitbar(0,['Getting profiles for ' whSN ' ' castdir])
            
            % Loop through each cast
            for icast=1:Ncasts
                
                waitbar(icast/Ncasts,hb)
                
                clear avg ctd_cast castStr ctdfile chifile
                
                % Name of the file we're working on
                ctd_cast=CTD_list(icast).name;
                
                %***
                castStr=ctd_cast(1:end-9); % Assumes file ends w/ _24hz.mat
                
                % Name of the processed chipod file (if it exists)                
                chifile=fullfile(chi_proc_path,whSN,'avg',params_str,['avg_' castStr '_' castdir 'cast_' whSN '_' whsens '.mat'] )         ;
                
                if  exist(chifile,'file')==2 
                    
                    clear avg 
                    load(chifile)
                    
                    avg.P(find(avg.P<0))=nan;
                    
                    [XC.([whSN '_' castdir '_' whsens]).TPvar(:,icast) zout ] = binprofile(avg.TP1var,avg.P, zmin, dzbin, zmax,minobs );
                    [XC.([whSN '_' castdir '_' whsens]).eps(:,icast)   zout ] = binprofile(avg.eps1  ,avg.P, zmin, dzbin, zmax,minobs );
                    [XC.([whSN '_' castdir '_' whsens]).chi(:,icast)   zout ] = binprofile(avg.chi1  ,avg.P, zmin, dzbin, zmax,minobs );
                    [XC.([whSN '_' castdir '_' whsens]).KT(:,icast)    zout ] = binprofile(avg.KT1   ,avg.P, zmin, dzbin, zmax,minobs );
                    [XC.([whSN '_' castdir '_' whsens]).dTdz(:,icast)  zout ] = binprofile(avg.dTdz  ,avg.P, zmin, dzbin, zmax,minobs );
                    [XC.([whSN '_' castdir '_' whsens]).N2(:,icast)    zout ] = binprofile(avg.N2    ,avg.P, zmin, dzbin, zmax,minobs );
                    
                    [XC.([whSN '_' castdir '_' whsens]).t(:,icast) zout]   =binprofile(avg.T,avg.P, zmin, dzbin, zmax,minobs);
                    [XC.([whSN '_' castdir '_' whsens]).s(:,icast) zout]   =binprofile(avg.S,avg.P, zmin, dzbin, zmax,minobs);

                    XC.([whSN '_' castdir '_' whsens]).lon(icast)=nanmean(ctd.lon);
                    XC.([whSN '_' castdir '_' whsens]).lat(icast)=nanmean(ctd.lat);
                    XC.([whSN '_' castdir '_' whsens]).dnum(icast)=nanmean(ctd.datenum);

                end
                
                %pause
                
            end % wh cast
            delete(hb)
            XC.([whSN '_' castdir '_' whsens]).P=zbin;
            
        end % whsens
        
    end % idir (castdir)
    
end % wh SN


if savedata==1
    pathstr=MakePathStr(Params)
    save(fullfile(BaseDir,'data',[ChiInfo.Project '_XC_' pathstr]),'XC')
end

%%
