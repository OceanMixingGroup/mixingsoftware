function [] = chi_pitot_proc(basedir, rfid, varargin)
%% [] = chi_pitot_proc(basedir, rfid, [Dtime])
%     This function drives the processing for the Pitot velocities
%     of a single raw-files based on the given flags
%
%     INPUT
%        basedir : unit directory
%        rfid    : raw-file name 
%        Dtime   : optional argument to at a time shift for chipod/gust data
%
%   created by: 
%        Johannes Becherer
%        Wed Sep 21 11:12:10 PDT 2016


%_____________________time shift______________________
   if nargin < 4
      Dtime = 0; 
   else
      Dtime = varargin{1};
   end


%_____________________preper saving______________________
         is1 = strfind(rfid,'_');  % find under score
         is2 = strfind(rfid,'.');  % find dot
      savestamp   = [rfid((is1):(is2)) 'mat'];
      savedir     = [basedir filesep 'proc' filesep 'pitot' filesep];


%_____________________load raw_file______________________
   % load header
   head     = chi_get_calibration_coefs(basedir);
   W        = chi_get_calibration_coefs_pitot(basedir);
   head.W   = W;
   data = chi_calibrate_all_pitot([basedir filesep 'raw' filesep rfid], head);

%_____________________average on 1 sec intervalls______________________
   
   % remove waves from signal
   data = pitot_remove_waves(data);

   pitot = average_fields(data, 1);

%---------------------save data----------------------
   [~,~,~] =  mkdir(savedir);
   save([savedir  'pitot' savestamp], 'pitot');


end
