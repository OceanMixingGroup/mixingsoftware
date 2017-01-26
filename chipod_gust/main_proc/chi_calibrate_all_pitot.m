function [data] = chi_calibrate_all_pitot(rfid, head)
%%  [data] = chi_calibrate_all_pitot(rfid, head)
%     
%        This function reads chipod/gusT raw data and calibrates them acording
%        to the coefficients in head including pitot velocities
%
%        Input
%           rfid   :  path the the specific raw-file
%           head   :  corresponding header
%           head.W :  corresponding header for Pitot tube
%
%        Output
%           data   : data structure containing calibrated data
%
%   created by: 
%        Johannes Becherer
%        Fri Sep  2 15:53:26 PDT 2016

%_____________________chipod or gust?______________________

if isfield(head.coef, 'T1')
   is_chipod = 1;
   disp(' instrument identified as CHIPOD')
   data = chi_calibrate_chipod_pitot(rfid, head);
else
   is_chipod = 0;
   disp(' instrument identified as GUST')
   data = chi_calibrate_gust_pitot(rfid, head);
end

