function [] = chi_qsum_proc(basedir, rfid, varargin)
%% [] = chi_qsum_proc(basedir, rfid, [Dtime])
%     This function drives the quick summary
%     of a single raw-files based on the given flags
%
%     INPUT
%        basedir : unit directory
%        rfid    : raw-file name 
%        Dtime   : optional argument to at a time shift for chipod/gust data
%
%   created by: 
%        Johannes Becherer
%        Mon Oct 24 14:20:34 PDT 2016

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
      savedir     = [basedir filesep 'proc' filesep 'qsum' filesep];
      savedir_r   = [basedir filesep 'proc' filesep 'qsum_r' filesep];


%_____________________load raw_file______________________
   % load header
   head = chi_get_calibration_coefs(basedir);

%_____________________get raw data______________________

if isfield(head.coef, 'T1')
   is_chipod = 1;
   disp(' instrument identified as CHIPOD')
   [rdat, ~]  = raw_load_chipod([basedir filesep 'raw' filesep rfid]);
else
   is_chipod = 0;
   disp(' instrument identified as GUST')
   [rdat]  = raw_load_gust([basedir filesep 'raw' filesep rfid]);
   rdat.time_cmp = rdat.time(1:25:end);
end


%_____________________get calibrated data______________________
   data = chi_calibrate_all([basedir filesep 'raw' filesep rfid], head);

%_____________________average on 1 sec intervalls______________________
   S     = average_fields(data, 100);
   R     = average_fields(rdat, 100);

%---------------------save data----------------------
   [~,~,~] =  mkdir(savedir);
   [~,~,~] =  mkdir(savedir_r);
   save([savedir  'qsum' savestamp], 'S');
   save([savedir_r 'qsum_r' savestamp], 'R');


end
