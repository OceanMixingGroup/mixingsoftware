function [] = chi_main_proc(basedir, rfid, pflag, varargin)
%% [] = chi_main_proc(basedir, rfid, pflag, [Dtime])
%     This function drives the main chi processing
%     of a single raw-files based on the given flags
%
%     INPUT
%        basedir : unit directory
%        rfid    : raw-file name 
%        pflag   : chi_proccessing_flag object
%        Dtime   : optional argument to at a time shift for chipod/gust data
%
%        By
%         Johannes Becherer
%           Wed Aug 31 17:05:18 PDT 2016

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
      savedir     = [basedir filesep 'proc' filesep];


%_____________________load raw_file______________________
   % load header
   head = chi_get_calibration_coefs(basedir);
   data = chi_calibrate_all([basedir filesep 'raw' filesep rfid], head);
  

%_____________________get Input data______________________
    % load mooring stratification
      if(pflag.master.Tzm)
         fid = [basedir filesep 'input' filesep 'dTdz_m.mat'];
         if exist(fid, 'file');
            load(fid);
         else
            disp([fid ' does not exit']);
            disp('corresponding processing flags are switched off');
            pflag = pflag.c_Tzm(0);
         end
      end
    % load mooring stratification
      if(pflag.master.Tzi)
         fid = [basedir filesep 'input' filesep 'dTdz_i.mat'];
         if exist(fid, 'file');
            load(fid);
         else
            disp([fid ' does not exit']);
            disp('corresponding processing flags are switched off');
            pflag = pflag.c_Tzi(0);
         end
      end

    % load mooring velocity
      if(pflag.master.vel_m)
         fid = [basedir filesep 'input' filesep 'vel_m.mat'];
         if exist(fid, 'file');
            load(fid);
            vel_m1 = vel_m;
            clear vel_m;
            [vel_m.time, vel_m.spd] = chi_convert_vel_m_to_sensor_spd(vel_m1, data);
         else
            disp([fid ' does not exit']);
            disp('corresponding processing flags are switched off');
            pflag = pflag.c_vel_m(0);
         end
      end
      
    % calibrate pitot velocity
      if(pflag.master.vel_p)
         fid = [basedir filesep 'calib' filesep 'header_p.mat'];
         if exist(fid, 'file');
            % load Pitot header
            load(fid);
            if isfield(W, 'V0')
               % which temperature to use to calibrate
               if ~pflag.master.gst % if chipod
                  if pflag.master.T1
                     data.T = data.T1;
                  else % if T1 is broken
                     data.T = data.T2;
                  end
               end

               vel_p.time = data.time;
               [vel_p.spd, ~, ~] = pitot_calibrate( data.W, data.T, data.P,...
                        W.V0, W.T0, W.P0, 1/W.Pd(2), W.T(2), W.Ps(2) );
            else
               disp(['W.V0, W.T0 and W.P0 do not exit']);
               disp(['You need to calibrate the Pitot tube first!']);
            end
         else
            disp([fid ' does not exit']);
            disp('corresponding processing flags are switched off');
            pflag = pflag.c_vel_p(0);
         end
      end


%_____________________loop through all processing flags______________________
for i = 1:length(pflag.id)

      [id, spd_f, Tz_f, T_f] = pflag.get_id(i);

      if pflag.proc.(id) % check if flag is active 

         disp([ id ' is processed '  ]);
         
         % create output directory if not exist yet
         sdir = [savedir 'chi' filesep 'chi_' id];
         [~, ~, ~] = mkdir(sdir);
         
         %---------------------set input prarmeters----------------------
           switch spd_f;
            case 'vel_p'
               S.spd  = vel_p.spd;
               S.time = vel_p.time;
            case 'vel_m'
               S.spd  = vel_m.spd;
               S.time = vel_m.time;
           end

           switch T_f
            case 'T'
               Tp.tp   = data.TPt;
               Tp.time = data.time_tp;
               T.time  = data.time;
               T.T     = data.T;
               T.depth = data.depth;
            case 'T1'
               Tp.tp   = data.T1Pt;
               Tp.time = data.time_tp;
               T.time  = data.time;
               T.T     = data.T1;
               T.depth = data.depth;
           case 'T2'
               Tp.tp   = data.T2Pt;
               Tp.time = data.time_tp;
               T.time  = data.time;
               T.T     = data.T2;
               T.depth = data.depth;
           end

           switch Tz_f
            case 'Tz_m'
               Tz.time  =  Tz_m.time;
               Tz.Tz    =  Tz_m.Tz;
               Tz.N2    =  Tz_m.N2;
            case 'Tz_ig'
               Tz.time  =  Tz_i.time;
               Tz.Tz    =  Tz_i.Tz;
               Tz.N2    =  Tz_i.N2;
            case 'Tz_i1'
               Tz.time  =  Tz_i.time;
               Tz.Tz    =  Tz_i.Tz1;
               Tz.N2    =  Tz_i.N2_1;
            case 'Tz_i2'
               Tz.time  =  Tz_i.time;
               Tz.Tz    =  Tz_i.Tz2;
               Tz.N2    =  Tz_i.N2_2;
            case 'Tz_i12'
               Tz.time  =  Tz_i.time;
               Tz.Tz    =  Tz_i.Tz12;
               Tz.N2    =  Tz_i.N2_12;
           end
         
         %--------------------- Chi Processing----------------------
           if id([-1:0]+end) == 'ic'
            %chi = chi_chi_proc_ic(Tp, S, Tz) ;
           else
              chi = chi_chi_proc(Tp, S, Tz, T);
           end

         %---------------------save data----------------------
          save([sdir filesep  'chi' savestamp], 'chi');
         

      end
end

%_____________________do pitot epsilon______________________
if pflag.master.epsp
      disp('epsilon (Pitot) is processed')
      
      % load Pitot header
      load([basedir filesep 'calib' filesep 'header_p.mat']);

      % process data
      [eps, ~, ~] = chi_cal_pitot_eps(data, W);
      %---------------------save data----------------------
      sdir = [basedir 'proc' filesep 'eps' filesep];
      [~, ~, ~] = mkdir(sdir);
      save([sdir 'eps' savestamp], 'eps');
end


end
