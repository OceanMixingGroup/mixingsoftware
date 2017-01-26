function [] = find_pitot_calibration(basedir)
%%
%     This function is meant to find proper pitot calibration coeffs



%_____________________get list of all raw data______________________
   [fids, fdate] = chi_find_rawfiles(basedir);

%_____________________load standart header file______________________
   head = chi_get_calibration_coefs(basedir);

%_____________________round one calibration______________________
   data = chi_calibrate_all([basedir filesep 'raw' filesep fids{1}], head);


%_____________________load pitot calibs______________________

   fid = [basedir filesep 'calib' filesep 'head_p.mat'];
   if exist(fid, 'file');
      h_p = load(fid);
   else
      disp([fid ' does not exit']);
      disp(['You first need to organize the Pitot header']);
   end

%_____________________old Pitot header______________________
   W0 = head_p.W;

   if isfield(W0, 'V0')
      disp(['!!!!!! V0' ' already exit in header!!!!!!!!!']);
   else
      W0.V0 = 0;
      W0.T0 = 0;
      W0.P0 = 0;
   end


%_____________________write first pitot header______________________

   W     = head_p.W;
   W.V0  = 0;           
   if(isfield(data,'T1')) % chipod
      W.T0 = nanmedian(data.T1); 
   else % gusT
      W.T0 = nanmedian(data.T); 
   end
   W.P0 = nanmedian(data.P);

   head.W = W;
