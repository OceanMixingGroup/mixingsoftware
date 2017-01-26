%     this is the driver for the callibration generating 
%     a callibrated file for each raw file
%
%   created by: 
%        Johannes Becherer
%        Tue Nov 15 11:26:39 PST 2016

clear all;
close all;

%_____________________flags______________________
do_parallel = 1;


%_____________________include path of processing flies______________________
path(path, '~/arbeit/new_mix/main_proc/');% include  path to preocessing routines


%_____________________set directories______________________    
   here    =   pwd;                % mfiles folder
   basedir =   here(1:(end-6));    % substract the mfile folder
   savedir =   [basedir 'proc/'];  % directory directory to save data
   unit    = chi_get_unit_name(basedir); % get unit name

%_____________________generate output folder______________________



%_____________________get list of all raw data______________________
   [fids, fdate] = chi_find_rawfiles(basedir);
   
         sdir = [basedir filesep 'raw' filesep 'calib' filesep ];
         [~, ~, ~] = mkdir(sdir);

%_____________________load header______________________
   head = chi_get_calibration_coefs(basedir);


%_____________processing loop through all raw files__________________

   % init parallel pool
   if(do_parallel)
      parpool;
      % parallel for-loop
      parfor f=1:length(fids)
         rfid = fids{f};
         data = chi_calibrate_all([basedir filesep 'raw' filesep rfid], head);
         save([sdir rfid '.mat'], 'data', 'head');
      end
      % close parpool
      delete(gcp);
   else
      for f=1:length(fids)
         rfid = fids{f};
         data = chi_calibrate_all([basedir filesep 'raw' filesep rfid], head);
         save([sdir rfid '.mat'], 'data', 'head');
      end
   end


