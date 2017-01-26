function [] = chi_generate_dTdz_i(basedir, rfid, varargin)
%% [] = chi_generate_dTdz_i(basedir, rfid, [dt, do_P, min_dz])
%
%     This function calculates vertical stratification
%     based the internal data of the chipod/gusT
%
%     INPUT
%        basedir : unit directory
%        rfid    : raw-file name 
%        dt      : time-window for gradient caluclation in sec (default = 60)
%        do_P    : if 1 pressure is used instead of acceleration for z (default 0)
%        min_dz  : if the standart deviation of z for a given intreval is smaller ...
%                  than min_dz, Tz is set to nan (default min_dz = .1 m)
%
%   created by: 
%        Johannes Becherer
%        Mon Nov 28 16:30:14 PST 2016

%_____________________optional arguments______________________
   if nargin < 3
      dt    = 60; 
      do_P  = 0; 
      min_dz= .1;
   else
      dt = varargin{1};
   end

   if nargin < 4
      do_P  = 0; 
      min_dz= .1;
   else
      do_P = varargin{2};
   end

   if nargin < 5
      min_dz= .1;
   else
      min_dz = varargin{3};
   end
%_____________________preper saving______________________
         is1 = strfind(rfid,'_');  % find under score
         is2 = strfind(rfid,'.');  % find dot
      savestamp   = [rfid((is1):(is2)) 'mat'];
      savedir     = [basedir filesep 'proc' filesep 'dTdz' filesep];


%_____________________load raw_file______________________
   % load header
   head = chi_get_calibration_coefs(basedir);
   data = chi_calibrate_all([basedir filesep 'raw' filesep rfid], head);

%_____________________pick depth (acc or pressure)______________________
   if do_P % pressure
      data.z = -data.depth;
   else % acceleration
      data.z = -data.a_dis_z;
   end
 
%---------------------split pieces dt long pieces----------------------
   J{1}  =  1:length(data.time);
   Nf    = round( dt/( diff(data.time(1:2))*3600*24  ) );   % Nf is the length of the fragment
   I     = split_fragments(J, Nf, round(Nf*9/10));  

%---------------------run through all segments----------------------
   if isfield(data, 'T') % for gusT
      Tz_i.time   = nan(1,length(I));
      Tz_i.Tz     = nan(1,length(I));
      Tz_i.T      = nan(1,length(I));
      Tz_i.z      = nan(1,length(I));
      for i = 1:length(I)
         Tz_i.time(i) = nanmean(data.time(I{i}));
         Tz_i.T(i)    = nanmean(data.T(I{i}));
         Tz_i.z(i)    = nanmean(data.z(I{i}));

         
         if std(data.z(I{i}))>min_dz % check if there is enough vertical variability
            p          = polyfit( data.z(I{i}), data.T(I{i}),1);
            Tz_i.Tz(i) = p(1);
         else % if there is to lee vertical variation set nan
            Tz_i.Tz(i) = nan;
         end
      end

      Tz_i.S         = ones(length(I),1)*35;
      data.S         = ones(length(data.time),1)*35;
      [Tz_i.N2,~,~]  = cal_N2_from_TS(data.time, data.T,  data.S, data.depth, Tz_i.time, Tz_i.Tz, 600);


      %---------------------save data----------------------
      [~,~,~] =  mkdir(savedir);
      save([savedir  'dTdz' savestamp], 'Tz_i');

   else % for chipods
      Tz_i.time   = nan(1,length(I));
      Tz_i.z      = nan(1,length(I));

      Tz_i.Tz1    = nan(1,length(I));
      Tz_i.T1     = nan(1,length(I));
      Tz_i.Tz2    = nan(1,length(I));
      Tz_i.T2     = nan(1,length(I));
      Tz_i.Tz12   = nan(1,length(I));
      Tz_i.T12    = nan(1,length(I));
      for i = 1:length(I)
         Tz_i.time(i) = nanmean(data.time(I{i}));
         Tz_i.z(i)    = nanmean(data.z(I{i}));

         % T1
         Tz_i.T1(i) = nanmean(data.T1(I{i}));
         % T2
         Tz_i.T2(i)  = nanmean(data.T2(I{i}));
         % combo T1 and T2
         Tz_i.T12(i)  = nanmean( .5*(data.T2(I{i}) + data.T1(I{i})) );
         if std(data.z(I{i}))>min_dz;
            p          = polyfit( data.z(I{i}), data.T1(I{i}),1);
            Tz_i.Tz1(i) = p(1);
            p          = polyfit( data.z(I{i}), data.T2(I{i}),1);
            Tz_i.Tz2(i) = p(1);
            p          = polyfit( data.z(I{i}), .5*(data.T2(I{i}) + data.T1(I{i})) , 1);
            Tz_i.Tz12(i) = p(1);
         else % if there is to lee vertical variation set nan
            Tz_i.Tz1(i) = nan;
            Tz_i.Tz2(i) = nan;
            Tz_i.Tz12(i) = nan;
         end
      end

      data.S         = ones(length(data.time),1)*35;
      Tz_i.S         = ones(1,length(I))*35;

      % T1
      [Tz_i.N2_1,~,~]  = cal_N2_from_TS(data.time, data.T1,  data.S, data.depth, Tz_i.time, Tz_i.Tz1, 600);

      % T2
      [Tz_i.N2_2,~,~]  = cal_N2_from_TS(data.time, data.T2,  data.S, data.depth, Tz_i.time, Tz_i.Tz2, 600);

      % T12
      [Tz_i.N2_12,~,~]  = cal_N2_from_TS(data.time, .5*(data.T2 + data.T1),  data.S, data.depth, Tz_i.time, Tz_i.Tz12, 600);
   

      %---------------------save data----------------------
      [~,~,~] =  mkdir(savedir);
      save([savedir  'dTdz' savestamp], 'Tz_i');
   end


end
