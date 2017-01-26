function [data, head] = quick_calibrate(ddir, rfid)
%% [data, head] = quick_calibrate(ddir, rfid)
%
%         This function is meant to quickly calibrate a given raw-file (chipod
%         or gust)   
%
%         INPUT (if nothing input via gui)
%           ddir     : directory to rawe file
%           rfid     : raw-file name
%
%        OUTPUT
%           data     : data structure (calibrated)
%           head     : header structure
%           
%   created by: 
%        Johannes Becherer
%        Tue Nov 15 13:11:44 PST 2016


%_____________________in case there are not enough inputs select file from gui______________________
if nargin == 1
   [rfid, ~] = uigetfile([ddir filesep '*.*'],'Load Binary File');
end
if nargin < 1
   [rfid, ddir] = uigetfile('*.*','Load Binary File');
end


%_____________________get header______________________
%basedir = [ddir filesep '..' filesep] 
basedir = [ddir(1:(end-4)) filesep] ;
hfid = [basedir filesep 'calib' filesep 'header.mat'] ;

   if exist(hfid, 'file')
      load(hfid)
   else % no header found
      choice = questdlg('I did not find a header file', ...
               'Header file', ...
                'Use raw-file header (only chipods)','Find header file','Find header file');

      switch choice % What to do?
         case 'Use raw-file header (only chipods)'    
            disp(['generating new header file based on raw_data']);
            [~, head] = raw_load_chipod([ddir rfid]);
         case 'Find header file'
            [hfid, hdir] = uigetfile('*.*','Load Binary File');
            load([hdir hfid]);
      end

      save(hfid, 'head');
   end


%_____________________calibrate______________________
data = chi_calibrate_all([ddir rfid], head);
