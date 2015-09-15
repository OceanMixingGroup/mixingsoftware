% initialize_summary_file.m
%
% comments added by sjw, January 2014
%
% This code is called by make_chameleon_timer_oceanus. It should not be run
% independently.
%
% This code initializes the structure cham which is where all of the data
% will be saved, and then it adds all of the previously processed files.



% make structure q.script which will be used eventually to call the correct
% file by raw_load
q.script.prefix=cruise_id;
q.script.pathname=path_raw;


% make directories for the single drop .mat files and for the summary files
% turn warnings off so they don't say that a directory already exists
warning off
path_save=[path_cham 'mat' filesep];
mkdir(path_save)
path_sum=[path_cham 'sum' filesep];
mkdir(path_sum);
warning on

% check to see if there is an existing summary file
% disp('Start a new summary file of add to an existing one?')
% oldnew = input('0 = old sum file, 1 = new sum file: ');
%     
oldnew = 1;

if oldnew == 0
    
    % choose the old summary file
    path_sum=[path_cham filesep 'sum' filesep];
    [file_b path_b]=uigetfile([path_sum '*.mat'],['Choose Summary File']);

    load([path_b file_b])
    sumfile = [path_b file_b];
    
    n = length(cham.time);
    
    
    % add processed files that have not already been added to the summary
    % list all of the processed files
    allfilesprocdir = dir([path_save '*.mat']);
    clear allfilesproc
    
    if n < length(allfilesprocdir)
    
        for ii = n+1:length(allfilesprocdir)
            allfilesproc(ii) = str2num(allfilesprocdir(ii).name(end-8:end-4));
        end

        tic
        for ii = n+1:length(allfilesprocdir)

            numtosum = allfilesproc(ii);
            q.script.num = numtosum;

            clear avg
            load([path_save allfilesprocdir(ii).name])


            % finds an average over depth ranges and saves structure cham to the
            % summary file
            add_to_sum_oceanus

        end
    end
    
    
    
elseif oldnew == 1
    



%%%%%% initialize a structure called "cham" which will contain all of the data
dd = dir([path_save '*.mat']);
N = length(dd);


% init = NaN*ones(n_dep,N);
% init1D = NaN*ones(1,N);
init=NaN*ones(n_dep,1);
init1D = NaN;
clear cham;

cham.EPSILON1=init;
cham.EPSILON2=init;
cham.EPSILON=init;
cham.N2=init;
cham.SIGMA=init;
cham.CHI=init;
cham.THETA=init;
cham.T1=init;
cham.T2=init;
cham.SAL=init;
cham.COND=init;
cham.SCAT=init;
cham.FLR=init;
cham.AZ2=init;
cham.FALLSPD=init;
cham.P=init;
cham.depthmax=1;
cham.pmax=init1D;
cham.DYN_Z = init1D;
cham.starttime = NaN;
cham.endtime = NaN;
cham.direction = init1D;
cham.filenums = init1D;
cham.castnumber = init1D;

cham.lat = init1D;
cham.lon = init1D;
cham.time = init1D;

cham.depth = 1:max_depth_bins;  

cham.filemin=firstfile;
cham.filemax=firstfile;







% add the path and filenames to the cham structure
cham.pathname = path_sum;
cham.filename = [cruise_id '_sum.mat'];




%%%%%%%% create the summary file which contains the structure 'cham'
% ***** this has been changed to be in set_chameleon where it does not need
% to be entered each time by the user *****
save([cham.pathname cham.filename],'cham')
sumfile = [cham.pathname cham.filename];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add previously processed files to summary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get a list of all the .mat files saved in the processed directory and add
% them to this new summary file

% start a counter that will determine where each processed file goes within
% the summary. (add_to_sum wants this to be zero indexed.)
n=0;

% list all of the processed files
allfilesprocdir = dir([path_save '*.mat']);
if length(allfilesprocdir) == 0;
    disp(['created summary file ' cham.pathname cham.filename])
    disp('no processed files to add')
else

    for ii = 1:length(allfilesprocdir)
        allfilesproc(ii) = str2num(allfilesprocdir(ii).name(end-8:end-4));
    end
    startind = find(allfilesproc == firstfile);
    tic
    for ii = startind:length(allfilesproc)

        numtosum = allfilesproc(ii);
        q.script.num = numtosum;

        clear avg
        load([path_save allfilesprocdir(ii).name])


        % finds an average over depth ranges and saves structure cham to the
        % summary file
        add_to_sum_oceanus

    end
    ttoc = toc;  


    disp(['created summary file ' cham.pathname cham.filename])
    disp(['and added ' num2str(n) ' files in ' num2str(ttoc) ' seconds' ])
    
end


end