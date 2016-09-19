%
% Add a 'ctd' structure to XC with 1m binned CTD for all profiles.
%
%%

clear ; close all

project='P15S'

eval(['Load_chipod_paths_' project])

load(fullfile(BaseDir,'mfiles','proc_info.mat'))

proc_info.Prange(find(proc_info.Prange>8000))=nan;

Nfiles=length(proc_info.icast);

% Parameters for depth-binnning
zmin=0;
dzbin=10;
zmax=nanmax(proc_info.Prange);
zbin = [zmin:dzbin:zmax]';
minobs=0;

t=nan*ones(length(zbin),Nfiles);
s=t;

for ifile=1:Nfiles
    
    clear datad_1m
    
    try
        % load CTD data
        load(fullfile(CTD_out_dir_bin,[proc_info.Name{ifile} '.mat']))
        
        % bin the CTD data
        [t(:,ifile) zout ] = binprofile(datad_1m.t1,datad_1m.p, zmin, dzbin, zmax,minobs );
        [s(:,ifile) zout ] = binprofile(datad_1m.s1,datad_1m.p, zmin, dzbin, zmax,minobs );
    catch
        disp(['Problem with ' proc_info.Name{ifile}])
        
    end
end
%%
proc_info.ctd.t=t;
proc_info.ctd.s=s;
proc_info.ctd.p=zout;

%%
ax=plot_ctd_from_xc(proc_info)
%%


figname='P15S_ctd_t_s.png'
print(fullfile(BaseDir,'Figures',figname),'-dpng')

%