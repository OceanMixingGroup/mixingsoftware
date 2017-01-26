function [W]  = chi_get_calibration_coef_pitot(basedir) 
%% function [head]  = chi_get_calibration_coef(basedir)
%     This function returns a coeffcient structure that could be
%     used by chi_calibrate_rawdata()
% 
%     1. the function tries to load the header from an existing pitot.mat in ./calib/pitot.mat
%     2. if this file does not exist read raw file and generate header.mat
%
%
%   created by: 
%        Johannes Becherer
%        Wed Sep 21 11:22:59 PDT 2016



   fid = [basedir filesep 'calib' filesep 'header_p.mat'] ;

   % check if header file exit
   if exist(fid, 'file')
      load(fid)
   else 

      disp([fid ' not found']);
      disp(['generating new header file based on raw_data']);

      W = pitot_determine_V0_manual(basedir);


      % save header in proper destination
      save(fid, 'W');
   end
