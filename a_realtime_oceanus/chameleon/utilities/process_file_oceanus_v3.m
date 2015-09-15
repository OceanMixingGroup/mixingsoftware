% process_file_oceanus.m
%
% Originally, this was written as process_file_oceanus, but that version
% had some grave errors, especially with the way the raw files were being
% written on YQ14 (and onward). It made most sense for me to rewrite it
% from scratch.
%
% This file looks to see what raw files exist. Then it looks to see which
% files have been processed. It then processes the raw files that have not yet
% been processed and adds them to the last position in the summary file.
%
% Unfortunately, it still has to create some weird variables like q.series
% and q.script.num, which are used deep within the functions. Also, most of the
% processing functions are from ages ago (and would benefit from a thorough
% rewrite.) These are: cali_realtime, average_data, calc_dynamic_z. For the
% YQ14 cruise, raw_load_cham2 was written. I rewrote a bit of
% add_to_sum_oceanus, but it is essentially the same as in previous
% versions of the code.
%
% written by Sally Warner, January 2014


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% !!!!! comment out when running with the timer !!!!!
% disp('If you are running with a timer, stop and comment out the clear')
% disp('statement in process_file_oceanus_v3.m')
% clear
% set_chameleon_oceanus;
% initialize_summary_file_oceanus;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% list raw files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get a list of all the good files saved in the raw file directory    
allfilesrawdir = dir([path_raw cruise_id '*']);
for ii = 1:length(allfilesrawdir)
    % change the file name into a number
%     allfilesraw(ii) = str2num(allfilesrawdir(ii).name(end-5:end))*1000;
    allfilesraw(ii) = str2num(allfilesrawdir(ii).name(end-4:end))*1000;
    % Sometimes corrupted files get written. Remove those files from the list.
    if allfilesrawdir(ii).bytes < 2001
        allfilesraw(ii) = NaN;
    end
end
allfilesraw = allfilesraw(~isnan(allfilesraw));

% remove files that have a filenumber lower than firstfile
% note: define firstfile in set_chameleon. It is the number of the first
% good file.
allfilesraw = allfilesraw(find(allfilesraw >= firstfile));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% list processed files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get a list of all the .mat files saved in the processed directory
allfilesprocdir = dir([path_save '*.mat']);
% clause if no files have been processed yet
if length(allfilesprocdir) == 0
    allfilesproc = 0;
else
    for ii = 1:length(allfilesprocdir)
        allfilesproc(ii) = str2num(allfilesprocdir(ii).name(end-8:end-4));
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% list raw files that NEED to be processed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find the files that have been written but have not yet been processed
clear indtoprocess nn
nn = 1;
for ii = 1:length(allfilesraw)
    if round(allfilesraw(ii)) ~= allfilesproc % (sjw nov 2014: don't know why the round is needed but without it 
        indtoprocess(nn) = ii;
        nn = nn + 1;
%         disp(['allfilesraw(' num2str(ii) ') = ' num2str(allfilesraw(ii))])
        
    end
end

% if no new files need to be processed, tell the user and break
if ~exist('indtoprocess','var') 
    disp(['Waiting for new raw files at ' datestr(now)])
    return
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% process raw files that have not been processed yet
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for ii = 1:length(indtoprocess)

    % get the name of the file that needs to be loaded and processed
    numtoprocess = allfilesraw(indtoprocess(ii));
%     dummy = num2str(numtoprocess + 100000);
%     load_file = [path_raw cruise_id '_' dummy(2:3) '.' dummy(4:6)];
    dummy = num2str(numtoprocess + 10000);
    load_file = [path_raw cruise_id '_' dummy(2) '.' dummy(3:5)];
    
    % raw_load and cali_realtime are looking for a structure q
    q.script.num = numtoprocess;

    % tell the user what file is being processed
    disp(['processing file: ' load_file])

	% define global variables
	clear global head data cal
	global data cal head
        
	% load raw data  
	% In January 2014, raw_load_cham2 replaced raw_load. VERY important
	% to use the new version.
	[data head] = raw_load_cham2(load_file);
        
        
	% calibrate raw data. A LOT goes on within this function and all of
	% its subfunctions. See notes for details.
	cali_realtime_oceanus_v3
        
	% define the number of points to use in the fast fourier transform
	nfft = 256;
        
	% define variables to be processed and sent to average_data
	q.series = {'fallspd','t1','t2','cond','sal','theta','sigma',...
        'epsilon1','epsilon2',...
        'chi','n2','az2','dtdz','drhodz','scat','flr','ax_tilt','ay_tilt'};
        warning off
        
	% if the processed data is NOT bad, save it and add it to the 
	% summary file. The variable "bad" comes from cali_realtime.
    if bad ~= 1

        % average calibrated data into 1m bins
        % SJW sept 2015: IMPORTANT NOTE! For final processing DO NOT use
        % this version of average_data. Need average_data_gen1 which is
        % used for final processing such as with EQ14 data. For realtime
        % visualization of chameleon, this is okay, but it is NOT okay for
        % the final dataset!!
        avg = average_data(q.series,'binsize',1,'nfft',nfft,'whole_bins',1);

        % remove glitches
        % SJW Sept 2015: for shallow locations like Yaquina Bay and Mobile
        % Bay, we're bringing the chameleon out of the water to begin the
        % drop. Don't want to NaN our these values at the surface because
        % losing the entire top of the water column
%         indfast = find(log10(avg.AZ2)>-4.5);
%         avg.EPSILON1(indfast) = NaN;
%         avg.EPSILON2(indfast) = NaN;
%         warning backtrace

        % calc dynamic height and max pressure and add to the header
        head = calc_dynamic_z(avg,head);
        head.p_max = max(cal.P);

    % if the data is not good, save a .mat file full of NaNs 
    else
        names=fieldnames(avg);
        for mm=1:length(names)
            eval(['avg.' char(names(mm)) '(:) = NaN;'])
            head.dynamic_gz=NaN;
            head.direction='u';
        end
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % save processed file
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create a .mat data file containing 1m binned data and header.
	% Each cast gets saved into a separate file in
	% /processed/chameleon/mat/
	% The file contains the structure avg
	dummy = num2str(numtoprocess + 100000);
	save_file = [path_save cruise_id '_' dummy(2:6) '.mat'];
	save(save_file,'avg','head')
	disp(['saving file: ' save_file])
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % add newly processed files to summary
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % add_to_sum is an old function that finds 1m vertical bins of 'avg'
    % and adds them to the structure 'cham' which is saved in a summary
    % file. Each new cast is added as it is processed.
    
    % note: add_to_sum uses a counter 'n' which it adds to every time a
    % file is added to add_to_sum. It needs to be set to zero in
    % initialize_summary_file_oceanus. (But we'll override that by looking 
    % at how many files have been saved already.)
%     load([path_sum cruise_id '_sum.mat'])
    load(sumfile)
    n = length(cham.time);
    
    % add this processed file to the summary
    add_to_sum_oceanus


end




