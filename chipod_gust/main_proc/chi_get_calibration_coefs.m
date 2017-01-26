function [head]  = chi_get_calibration_coef(basedir)
%% function [head]  = chi_get_calibration_coef(basedir)
%     This function returns a coeffcient structure that could be
%     used by chi_calibrate_rawdata()
% 
%     1. the function tries to load the header from an existing header.mat in ./calib/header.mat
%     2. if this file does not exist read raw file and generate header.mat



   fid = [basedir filesep 'calib' filesep 'header.mat'] ;

   % check if header file exit
   if exist(fid, 'file')
      load(fid)
   else 

      disp([fid ' not found']);
      disp(['generating new header file based on raw_data']);
      [rfids, ~] = chi_find_rawfiles(basedir);
      % read raw-data
      [~, head] = raw_load_chipod([basedir filesep 'raw' filesep rfids{1}]);

      % save header in proper destination
      save(fid, 'head');
   end
