function proc_info = Add_CTD_to_XC(project)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Add a 'ctd' structure to XC with 1m binned CTD for all profiles.
%
% INPUT
% - project : Name of project
%
% OUTPUT
% - Returns proc_info w/ CTD data added
%
%----------------------
% 09/20/16 - A.Pickering
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

eval(['Load_chipod_paths_' project])

clear proc_info
load(fullfile(BaseDir,'Data','proc_info.mat'))

% throw out any unreasonable depths
proc_info.Prange(proc_info.Prange>8000)=nan;

Nfiles=length(proc_info.icast);

% Parameters for depth-binnning
zmin  = 0;
dzbin = 10;
zmax  = nanmax(proc_info.Prange);
zbin  = [zmin:dzbin:zmax]';
minobs= 0;

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
        
    end % try
    
end % ifile

%
proc_info.ctd.t=t;
proc_info.ctd.s=s;
proc_info.ctd.p=zout;
clear t s zout

%%