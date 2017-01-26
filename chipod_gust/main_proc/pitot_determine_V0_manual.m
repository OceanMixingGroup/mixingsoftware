function [W]  = pitot_determine_V0_manual(basedir, varagin)
%% [W]  = pitot_determine_V0_manual(basedir, varagin)
%        
%        This function generates a header file to calibrate the
%        pitot tube based on a figure of the voltage and a manual input
%        of the user
%
%        INPUT
%           basedir     :  directory of the instrument


%_____________________get list of all raw data______________________
   [fids, fdate] = chi_find_rawfiles(basedir);

%_____________________load header file______________________
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

%_____________________write first pitot header______________________

   W = head_p.W;
   %W.Ps = [0 0 0 0 0];
   W.V0 = 0;           
   if(isfield(data,'T1')) % chipod
      W.T0 = nanmedian(data.T1); 
   else % gusT
      W.T0 = nanmedian(data.T); 
   end
   W.P0 = nanmedian(data.P);

   head.W = W;

%_____________________calibrate pito tube______________________
d.time = [];
d.T    = [];
d.P    = [];
d.V_cal= [];
for i = 1:min([length(fids); 3]) % add maximum 3 files
   rfid = fids{i};
   d1 = chi_calibrate_all_pitot([basedir filesep 'raw' filesep rfid], head);

   d.time = [d.time; d1.time];
   d.T    = [d.T; d1.T];
   d.P    = [d.P; d1.P];
   d.V_cal= [d.V_cal; d1.V_cal];
end


%_____________________plot data______________________
  figure
   ax(1) = subplot(3,1,1);
   ax(2) = subplot(3,1,2);
   ax(3) = subplot(3,1,3);
      if(isfield(data,'T1')) % chipod
         d.T = d.T1; 
      end

   a=1;
   plot(ax(a), d.time, d.P);
      ylabel(ax(a), 'pres in [psi]')

   a=2;
   plot(ax(a), d.time, d.T);
      ylabel(ax(a), 'T [^circ C]')

   a=3;
      [b,a1] = butter(2, .0003, 'low');
      d.V_filt = filtfilt(b ,a1 , d.V_cal);
   plot(ax(a), d.time, d.V_cal);
   hold(ax(a),'on');
   plot(ax(a), d.time, d.V_filt, 'k', 'Linewidth',2);
      ylabel(ax(a), 'W [volts]')

   datetick(ax(a), 'keeplimits');

   linkaxes(ax, 'x')
   

%_____________________get user input______________________

W.V0 = input('desired value for V_0 = ');
W.T0 = input('desired value for T_0 = ');
W.P0 = input('desired value for P_0 = ');


   close gcf;
%_____________________save pitot header______________________
save([basedir filesep 'calib' filesep 'head_p.mat'], 'W');
