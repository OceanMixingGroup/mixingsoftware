classdef chi_processing_flags
%% This class is meant to be used for chipod processing
%     it provides all necessary flags to drive the chipod
%     or gust processing 
%      - if you wnat to change any of the master flags
%           use the corresponding flunction (see below)
%           to also change the inter-dependencies
%  
%  METHODS
%    basic:
%        status()             % gives the current set of flags
%        readme()             % readme for the different flags
%        all_on()             % set all flags to 1
%        all_off()            % set all flags to 0
%        auto_set(unit_dir)   % fills in flags automatically for a given directory
%        make_cons()          % makes flags consitent by switching off all sub flags 
%                                that conflict with master flags
%    change master flags:
%        c_gst()  
%        c_vel_p()  
%        c_vel_m()  
%        c_ic()  
%        c_T1()  
%        c_T2()  
%        c_Tzi()  
%        c_Tzm()  
%
%
%  created by
%     Johannes Becherer
%     Tue Aug 30 14:32:26 PDT 2016
   

    % % master flags
    % master.parallel = 0; % put 1 if you wnat to process in parallel 
    % master.gst    = 0;  % gusT (1) or chipod (0)
    % master.T1     = 0;  % set to 0 if T1 sensor was broken
    % master.T2     = 0;  % set to 0 if T2 sensor was broken
    % master.vel_p  = 0;  % use pitot velocities 
    % master.vel_m  = 0;  % use mooring velocities 
    % master.Tzi    = 0;  % use local (interal) stratification 
    % master.Tzm    = 0;  % use mooring stratification 
    % master.ic     = 0;  % do inertial sub-range fit of temperature (1)
   

    % % normal processing
    %  % for pitot eps
    %    epsp   = 0;  % intertial sub-range fit on pitot_velocities (1)

    %  % for gusT
    %    mmg    = 0;  % mooring velocities + mooring N2
    %    pmg    = 0;  % pitot velocities + mooring N2
    %    mig    = 0;  % mooring velocities + interal N2 (only for pumped gusts)
    %    pig    = 0;  % pitot velocities + interal N2  (only for pumped gusts)
    % 
    %  % for T1
    %    mm1    = 0;  % mooring velocities + mooring N2
    %    pm1    = 0;  % pitot velocities + mooring N2
    %    mi11   = 0;  % mooring velocities + interal N2 (T1 sensor)
    %    pi11   = 0;  % pitot velocities + interal N2  (T1 sensor)
    %    mi112  = 0;  % mooring velocities + interal N2 (T1+T2 sensor)
    %    pi112  = 0;  % pitot velocities + interal N2  (T1+T2 sensor)

    %  % for T1
    %    mm2    = 0;  % mooring velocities + mooring N2
    %    pm2    = 0;  % pitot velocities + mooring N2
    %    mi22   = 0;  % mooring velocities + interal N2 (T2 sensor)
    %    pi22   = 0;  % pitot velocities + interal N2  (T2 sensor)
    %    mi212  = 0;  % mooring velocities + interal N2 (T2+T1 sensor)
    %    pi212  = 0;  % pitot velocities + interal N2  (T2+T1 sensor)

    % % ic variables
    %    mmg_ic    = 0;  % mooring velocities + mooring N2
    %    pmg_ic    = 0;  % pitot velocities + mooring N2
    %    mig_ic    = 0;  % mooring velocities + interal N2 (only for pumped gusts)
    %    pig_ic    = 0;  % pitot velocities + interal N2  (only for pumped gusts)
    % 
    %    mm1_ic    = 0;  % mooring velocities + mooring N2
    %    pm1_ic    = 0;  % pitot velocities + mooring N2
    %    mi11_ic   = 0;  % mooring velocities + interal N2 (T1 sensor)
    %    pi11_ic   = 0;  % pitot velocities + interal N2  (T1 sensor)
    %    mi112_ic  = 0;  % mooring velocities + interal N2 (T1+T2 sensor)
    %    pi112_ic  = 0;  % pitot velocities + interal N2  (T1+T2 sensor)

    %    mm2_ic    = 0;  % mooring velocities + mooring N2
    %    pm2_ic    = 0;  % pitot velocities + mooring N2
    %    mi22_ic   = 0;  % mooring velocities + interal N2 (T2 sensor)
    %    pi22_ic   = 0;  % pitot velocities + interal N2  (T2 sensor)
    %    mi212_ic  = 0;  % mooring velocities + interal N2 (T2+T1 sensor)
    %    pi212_ic  = 0;  % pitot velocities + interal N2  (T2+T1 sensor)
            
   properties 
         % processing ids
          id;
         % master flags
          master;
         % processing flags
          proc;

   end 

   methods 
      
      function  obj = chi_processing_flags()
      %% init function for object
          %_____________________processing ids______________________
             obj.id{1} = 'mmg';
             obj.id{2} = 'pmg';
             obj.id{3} = 'mig';
             obj.id{4} = 'pig';

             obj.id{5} = 'mm1';
             obj.id{6} = 'pm1';
             obj.id{7} = 'mi11';
             obj.id{8} = 'pi11';
             obj.id{9} = 'mi112';
             obj.id{10} = 'pi112';

             obj.id{11} = 'mm2';
             obj.id{12} = 'pm2';
             obj.id{13} = 'mi22';
             obj.id{14} = 'pi22';
             obj.id{15} = 'mi212';
             obj.id{16} = 'pi212';
              % ic
             obj.id{17} = 'mmg_ic';
             obj.id{18} = 'pmg_ic';
             obj.id{19} = 'mig_ic';
             obj.id{20} = 'pig_ic';

             obj.id{21} = 'mm1_ic';
             obj.id{22} = 'pm1_ic';
             obj.id{23} = 'mi11_ic';
             obj.id{24} = 'pi11_ic';
             obj.id{25} = 'mi112_ic';
             obj.id{26} = 'pi112_ic';

             obj.id{27} = 'mm2_ic';
             obj.id{28} = 'pm2_ic';
             obj.id{29} = 'mi22_ic';
             obj.id{30} = 'pi22_ic';
             obj.id{31} = 'mi212_ic';
             obj.id{32} = 'pi212_ic';



         %_____________ master flags______________________________
         obj.master.parallel = 0; % put 1 if you wnat to process in parallel 
         obj.master.gst    = 0;  % gusT (1) or chipod (0)
         obj.master.T1     = 0;  % set to 0 if T1 sensor was broken
         obj.master.T2     = 0;  % set to 0 if T2 sensor was broken
         obj.master.vel_p  = 0;  % use pitot velocities 
         obj.master.vel_m  = 0;  % use mooring velocities 
         obj.master.Tzi    = 0;  % use local (interal) stratification 
         obj.master.Tzm    = 0;  % use mooring stratification 
         obj.master.ic     = 0;  % do inertial sub-range fit of temperature (1)
         obj.master.epsp   = 0;  % intertial sub-range fit on pitot_velocities (1)


         %_____________ processing flags_________________________________
         for i=1:length(obj.id)
            obj.proc.(obj.id{i}) = 0;
         end

      end

      function [id, spd, Tz, T] = get_id(obj, n)
      %%  [id , spd, Tz, T] = get_id(n)
      %  this function provides for a given interger n
      %  the corresponding processing ID id 
      %  plus strings for the coreponding flields
      %  necessary for the processing
      %     spd = (i.e. 'vel_p')
      %     Tz  = (i.e. 'dTdz_i1')
      %     T   = (i.e. 'T2')
         if(n>length(obj.id))
            error(['n must be from 1...' num2str(length(obj.id))]);
         end
         
         id = obj.id{n};

         %---------------------velocity flag----------------------
         if id(1) == 'p' 
            spd = 'vel_p';
         else
            spd = 'vel_m';
         end

         %---------------------stratification----------------------
         if id(2) == 'm'
            Tz = 'Tz_m';
         elseif id(2) == 'i'
            if id(3) == 'g'
               Tz = 'Tz_ig';
            elseif id(3) == '1'
               if length(id) ==4 | length(id) ==7
                  Tz = 'Tz_i1';
               else
                  Tz = 'Tz_i12';
               end
            elseif id(3) == '2'
               if length(id) ==4 | length(id) ==7
                  Tz = 'Tz_i2';
               else
                  Tz = 'Tz_i12';
               end
            end
         end

         %---------------------sensor flag----------------------
            if id(3) == 'g'
               T = 'T';
            elseif id(3) == '1'
               T = 'T1';
            elseif id(3) == '2'
               T = 'T2';
            end
         
      end
      

      function [] = status(obj) 
         disp('Currently the master flags are set to:')
         obj.master

         disp('and the folling processing flags are active:')
         for i = 1:length(obj.id)
            id = obj.id{i};
            if obj.proc.(id)
               disp([id])
            end
         end


      end

      function  obj = all_on(obj)
         fs = fields(obj.proc);
         for i =1:length(fs)
            obj.proc.(fs{i}) = 1;
         end
      end
      function obj = all_off(obj)
         fs = fields(obj.proc);
         for i =1:length(fs)
            obj.proc.(fs{i}) = 0;
         end
      end

      function obj = auto_set(obj, unit_dir)
         %% flags = auto_set(unit_dir)
         %     this function sets a standard set of flags
         %     for the given unit directory  
         

         % find out if gust or chipod
         % !!!!!!!!!!!!!!!!!!!!!!!!!
         if(~obj.master.gst) % if chipod switch on both sensor flags
            obj = obj.c_T1(1);
            obj = obj.c_T2(1);
         end

         % o not calculate inerttial sub-range fit by default
         obj = obj.c_ic(0);

         % check for pitot header if yes set pitot flag
            if exist([unit_dir filesep 'calib' filesep 'header_p.mat'], 'file');
               obj = obj.c_vel_p(1);
               obj.proc.epsp  = 1;
            end

         % check input directory for available mat files
         input = dir([unit_dir filesep 'input']);
         for f = 1:length(input)
            if strcmp(input(f).name, 'vel_m.mat')
               obj = obj.c_vel_m(1);
            end
            if strcmp(input(f).name, 'dTdz_i.mat')
               obj = obj.c_Tzi(1);
               if(~obj.master.gst) % check is all fields are there
                  load([unit_dir  filesep 'input' filesep 'dTdz_i.mat']) 
                  if ~isfield(Tz_i, 'Tz1')
                     obj = obj.c_T1(0);
                  end
                  if ~isfield(Tz_i, 'Tz2')
                     obj = obj.c_T2(0);
                  end
               end
            end
            if strcmp(input(f).name, 'dTdz_m.mat')
               obj = obj.c_Tzm(1);
            end
         end
         
         % switch off inconsitent flags
         obj = obj.make_cons();

         obj.status;
      end


      function obj = make_cons(obj)
      %% This function switches off all
      %  inconsitent flags
         
         % ckeck all master flags master flags
         if obj.master.gst    == 0; obj = obj.c_gst(0); end
         if obj.master.vel_p  == 0; obj = obj.c_vel_p(0); end
         if obj.master.vel_m  == 0; obj = obj.c_vel_m(0); end
         if obj.master.ic     == 0; obj = obj.c_ic(0); end
         if obj.master.T1     == 0; obj = obj.c_T1(0); end
         if obj.master.T2     == 0; obj = obj.c_T2(0); end
         if obj.master.Tzi    == 0; obj = obj.c_Tzi(0); end
         if obj.master.Tzm    == 0; obj = obj.c_Tzm(0); end

      end

      function obj = c_vel_m(obj, a)
         if nargin<2
            a   = ~obj.master.vel_m;
         end
         obj.check_a(a);
          obj.master.vel_m = a;

         if(a==1)
            obj.proc.mmg       = 1;  
            obj.proc.mig       = 1;  
            obj.proc.mm1       = 1;  
            obj.proc.mi11      = 1;  
            obj.proc.mi112     = 1;  
            obj.proc.mm2       = 1;  
            obj.proc.mi22      = 1;  
            obj.proc.mi212     = 1;  
            obj.proc.mmg_ic    = 1;  
            obj.proc.mig_ic    = 1;  
            obj.proc.mm1_ic    = 1;  
            obj.proc.mi11_ic   = 1;  
            obj.proc.mi112_ic  = 1;  
            obj.proc.mm2_ic    = 1;  
            obj.proc.mi22_ic   = 1;  
            obj.proc.mi212_ic  = 1;  
         else
            obj.proc.mmg       = 0;  
            obj.proc.mig       = 0;  
            obj.proc.mm1       = 0;  
            obj.proc.mi11      = 0;  
            obj.proc.mi112     = 0;  
            obj.proc.mm2       = 0;  
            obj.proc.mi22      = 0;  
            obj.proc.mi212     = 0;  
            obj.proc.mmg_ic    = 0;  
            obj.proc.mig_ic    = 0;  
            obj.proc.mm1_ic    = 0;  
            obj.proc.mi11_ic   = 0;  
            obj.proc.mi112_ic  = 0;  
            obj.proc.mm2_ic    = 0;  
            obj.proc.mi22_ic   = 0;  
            obj.proc.mi212_ic  = 0;  
         end

      end

      function obj = c_vel_p(obj, a)
         if nargin<2
            a   = ~obj.master.vel_p;
         end
         obj.check_a(a);
          obj.master.vel_p = a;

         if(a==1)
            obj.proc.pmg       = 1;  
            obj.proc.pig       = 1;  
            obj.proc.pm1       = 1;  
            obj.proc.pi11      = 1;  
            obj.proc.pi112     = 1;  
            obj.proc.pm2       = 1;  
            obj.proc.pi22      = 1;  
            obj.proc.pi212     = 1;  
            obj.proc.pmg_ic    = 1;  
            obj.proc.pig_ic    = 1;  
            obj.proc.pm1_ic    = 1;  
            obj.proc.pi11_ic   = 1;  
            obj.proc.pi112_ic  = 1;  
            obj.proc.pm2_ic    = 1;  
            obj.proc.pi22_ic   = 1;  
            obj.proc.pi212_ic  = 1;  
         else
            obj.proc.pmg       = 0;  
            obj.proc.pig       = 0;  
            obj.proc.pm1       = 0;  
            obj.proc.pi11      = 0;  
            obj.proc.pi112     = 0;  
            obj.proc.pm2       = 0;  
            obj.proc.pi22      = 0;  
            obj.proc.pi212     = 0;  
            obj.proc.pmg_ic    = 0;  
            obj.proc.pig_ic    = 0;  
            obj.proc.pm1_ic    = 0;  
            obj.proc.pi11_ic   = 0;  
            obj.proc.pi112_ic  = 0;  
            obj.proc.pm2_ic    = 0;  
            obj.proc.pi22_ic   = 0;  
            obj.proc.pi212_ic  = 0;  
         end

      end

      function obj = c_gst(obj, a)
         if nargin<2
            a   = ~obj.master.gst;
         end
         obj.check_a(a);
          obj.master.gst = a;

         % clear interdependencies
         if(a==1) % if gusty

            obj = obj.c_T1(0);
            obj = obj.c_T2(0);
         else
            obj.proc.mmg       = 0;  
            obj.proc.pmg       = 0;  
            obj.proc.mig       = 0;  
            obj.proc.pig       = 0;  
            obj.proc.mmg_ic    = 0;  
            obj.proc.pmg_ic    = 0;  
            obj.proc.mig_ic    = 0;  
            obj.proc.pig_ic    = 0;  
         end

      end

      function obj = c_ic(obj, a)
         if nargin<2
            a   = ~obj.master.ic;
         end
         obj.check_a(a);
          obj.master.ic = a;

         if(a==1) 
            obj.proc.mmg_ic    = 1;  
            obj.proc.pmg_ic    = 1;  
            obj.proc.mig_ic    = 1;  
            obj.proc.pig_ic    = 1;  
            obj.proc.mm1_ic    = 1;  
            obj.proc.pm1_ic    = 1;  
            obj.proc.mi11_ic   = 1;  
            obj.proc.pi11_ic   = 1;  
            obj.proc.mi112_ic  = 1;  
            obj.proc.pi112_ic  = 1;  
            obj.proc.mm2_ic    = 1;  
            obj.proc.pm2_ic    = 1;  
            obj.proc.mi22_ic   = 1;  
            obj.proc.pi22_ic   = 1;  
            obj.proc.mi212_ic  = 1;  
            obj.proc.pi212_ic  = 1;  
         else
            obj.proc.mmg_ic    = 0;  
            obj.proc.pmg_ic    = 0;  
            obj.proc.mig_ic    = 0;  
            obj.proc.pig_ic    = 0;  
            obj.proc.mm1_ic    = 0;  
            obj.proc.pm1_ic    = 0;  
            obj.proc.mi11_ic   = 0;  
            obj.proc.pi11_ic   = 0;  
            obj.proc.mi112_ic  = 0;  
            obj.proc.pi112_ic  = 0;  
            obj.proc.mm2_ic    = 0;  
            obj.proc.pm2_ic    = 0;  
            obj.proc.mi22_ic   = 0;  
            obj.proc.pi22_ic   = 0;  
            obj.proc.mi212_ic  = 0;  
            obj.proc.pi212_ic  = 0;  
         end

      end

      function obj = c_T1(obj, a)
         if nargin<2
            a   = ~obj.master.T1;
         end
         obj.check_a(a);
          obj.master.T1 = a;

         if(a==1) 
            obj.proc.mm1       = 1;  
            obj.proc.pm1       = 1;  
            obj.proc.mi11      = 1;  
            obj.proc.pi11      = 1;  
            obj.proc.mi112     = 1;  
            obj.proc.pi112     = 1;  
            obj.proc.mi212     = 1;  
            obj.proc.pi212     = 1;  
            obj.proc.mm1_ic    = 1;  
            obj.proc.pm1_ic    = 1;  
            obj.proc.mi11_ic   = 1;  
            obj.proc.pi11_ic   = 1;  
            obj.proc.mi112_ic  = 1;  
            obj.proc.pi112_ic  = 1;  
            obj.proc.mi212_ic  = 1;  
            obj.proc.pi212_ic  = 1;  

         else
            obj.proc.mm1       = 0;  
            obj.proc.pm1       = 0;  
            obj.proc.mi11      = 0;  
            obj.proc.pi11      = 0;  
            obj.proc.mi112     = 0;  
            obj.proc.pi112     = 0;  
            obj.proc.mi212     = 0;  
            obj.proc.pi212     = 0;  
            obj.proc.mm1_ic    = 0;  
            obj.proc.pm1_ic    = 0;  
            obj.proc.mi11_ic   = 0;  
            obj.proc.pi11_ic   = 0;  
            obj.proc.mi112_ic  = 0;  
            obj.proc.pi112_ic  = 0;  
            obj.proc.mi212_ic  = 0;  
            obj.proc.pi212_ic  = 0;  
         end

      end

      function obj = c_T2(obj, a)
         if nargin<2
          a = ~obj.master.T2;
         end
         obj.check_a(a);
         obj.master.T2 = a;

         if(a==1) 
            obj.proc.mi112     = 1;  
            obj.proc.pi112     = 1;  
            obj.proc.mm2       = 1;  
            obj.proc.pm2       = 1;  
            obj.proc.mi22      = 1;  
            obj.proc.pi22      = 1;  
            obj.proc.mi212     = 1;  
            obj.proc.pi212     = 1;  
            obj.proc.mi112_ic  = 1;  
            obj.proc.pi112_ic  = 1;  
            obj.proc.mm2_ic    = 1;  
            obj.proc.pm2_ic    = 1;  
            obj.proc.mi22_ic   = 1;  
            obj.proc.pi22_ic   = 1;  
            obj.proc.mi212_ic  = 1;  
            obj.proc.pi212_ic  = 1;  
         else
            obj.proc.mi112     = 0;  
            obj.proc.pi112     = 0;  
            obj.proc.mm2       = 0;  
            obj.proc.pm2       = 0;  
            obj.proc.mi22      = 0;  
            obj.proc.pi22      = 0;  
            obj.proc.mi212     = 0;  
            obj.proc.pi212     = 0;  
            obj.proc.mi112_ic  = 0;  
            obj.proc.pi112_ic  = 0;  
            obj.proc.mm2_ic    = 0;  
            obj.proc.pm2_ic    = 0;  
            obj.proc.mi22_ic   = 0;  
            obj.proc.pi22_ic   = 0;  
            obj.proc.mi212_ic  = 0;  
            obj.proc.pi212_ic  = 0;  
         end

      end

      function obj = c_Tzi(obj, a)
         if nargin<2
          a = ~obj.master.Tzi;
         end
         obj.check_a(a);
         obj.master.Tzi = a;

         if(a==1) 
            obj.proc.mig       = 1;  
            obj.proc.pig       = 1;  
            obj.proc.mi11      = 1;  
            obj.proc.pi11      = 1;  
            obj.proc.mi112     = 1;  
            obj.proc.pi112     = 1;  
            obj.proc.mi22      = 1;  
            obj.proc.pi22      = 1;  
            obj.proc.mi212     = 1;  
            obj.proc.pi212     = 1;  
            obj.proc.mig_ic    = 1;  
            obj.proc.pig_ic    = 1;  
            obj.proc.mi11_ic   = 1;  
            obj.proc.pi11_ic   = 1;  
            obj.proc.mi112_ic  = 1;  
            obj.proc.pi112_ic  = 1;  
            obj.proc.mi22_ic   = 1;  
            obj.proc.pi22_ic   = 1;  
            obj.proc.mi212_ic  = 1;  
            obj.proc.pi212_ic  = 1;  
         else
            obj.proc.mig       = 0;  
            obj.proc.pig       = 0;  
            obj.proc.mi11      = 0;  
            obj.proc.pi11      = 0;  
            obj.proc.mi112     = 0;  
            obj.proc.pi112     = 0;  
            obj.proc.mi22      = 0;  
            obj.proc.pi22      = 0;  
            obj.proc.mi212     = 0;  
            obj.proc.pi212     = 0;  
            obj.proc.mig_ic    = 0;  
            obj.proc.pig_ic    = 0;  
            obj.proc.mi11_ic   = 0;  
            obj.proc.pi11_ic   = 0;  
            obj.proc.mi112_ic  = 0;  
            obj.proc.pi112_ic  = 0;  
            obj.proc.mi22_ic   = 0;  
            obj.proc.pi22_ic   = 0;  
            obj.proc.mi212_ic  = 0;  
            obj.proc.pi212_ic  = 0;  
         end

      end

      function obj = c_Tzm(obj, a)
         if nargin<2
          a = ~obj.master.Tzm;
         end
         obj.check_a(a);
         obj.master.Tzm = a;

         if(a==1) 
            obj.proc.mmg    = 1; 
            obj.proc.pmg    = 1;  
            obj.proc.mm1    = 1;  
            obj.proc.pm1    = 1;  
            obj.proc.mm2    = 1;  
            obj.proc.pm2    = 1;  
            obj.proc.mmg_ic = 1;  
            obj.proc.pmg_ic = 1;  
            obj.proc.mm1_ic = 1;  
            obj.proc.pm1_ic = 1;  
            obj.proc.mm2_ic = 1;  
            obj.proc.pm2_ic = 1; 
         else
            obj.proc.mmg    = 0; 
            obj.proc.pmg    = 0;  
            obj.proc.mm1    = 0;  
            obj.proc.pm1    = 0;  
            obj.proc.mm2    = 0;  
            obj.proc.pm2    = 0;  
            obj.proc.mmg_ic = 0;  
            obj.proc.pmg_ic = 0;  
            obj.proc.mm1_ic = 0;  
            obj.proc.pm1_ic = 0;  
            obj.proc.mm2_ic = 0;  
            obj.proc.pm2_ic = 0; 
         end

      end

      function check_a(obj, a)
         if(a~=1 & a~=0)
            error('the value must be 0 or 1');
         end
      end

      function [] = readme(obj) 
         disp({'______ THE DIFFERENT FLAGS HAVE THE FOLLOWING MEANING_______';
              ''      ;
               'parallel : put 1 if you wnat to process in parallel' ;
               '';
               '% master flags';
               'gst    :  gusT (1) or chipod (0)';
               'T1     :  set to 0 if T1 sensor was broken';
               'T2     :  set to 0 if T2 sensor was broken';
               'vel_p  :  use pitot velocities ';
               'vel_m  :  use mooring velocities ';
               'Tzi    :  use local (interal) stratification ';
               'Tzm    :  use mooring stratification ';
               'ic     :  do inertial sub-range fit of temperature (1)';
               ' ';
               '';
               '% normal processing';
                '% for pitot eps';
                  'epsp   :  intertial sub-range fit on pitot_velocities (1)';
               '';
                '% for gusT';
                  'mmg    :  mooring velocities + mooring N2';
                  'pmg    :  pitot velocities + mooring N2';
                  'mig    :  mooring velocities + interal N2 (only for pumped gusts)';
                  'pig    :  pitot velocities + interal N2  (only for pumped gusts)';
              ' ';
                '% for T1';
                  'mm1    :  mooring velocities + mooring N2';
                  'pm1    :  pitot velocities + mooring N2';
                  'mi11   :  mooring velocities + interal N2 (T1 sensor)';
                  'pi11   :  pitot velocities + interal N2  (T1 sensor)';
                  'mi112  :  mooring velocities + interal N2 (T1+T2 sensor)';
                  'pi112  :  pitot velocities + interal N2  (T1+T2 sensor)';
                  '';
                '% for T1';
                  'mm2    :  mooring velocities + mooring N2';
                  'pm2    :  pitot velocities + mooring N2';
                  'mi22   :  mooring velocities + interal N2 (T2 sensor)';
                  'pi22   :  pitot velocities + interal N2  (T2 sensor)';
                  'mi212  :  mooring velocities + interal N2 (T2+T1 sensor)';
                  'pi212  :  pitot velocities + interal N2  (T2+T1 sensor)';
                  '';
               '% ic variables';
                  'mmg_ic    :  mooring velocities + mooring N2';
                  'pmg_ic    :  pitot velocities + mooring N2';
                  'mig_ic    :  mooring velocities + interal N2 (only for pumped gusts)';
                  'pig_ic    :  pitot velocities + interal N2  (only for pumped gusts)';
               ;
                  'mm1_ic    :  mooring velocities + mooring N2';
                  'pm1_ic    :  pitot velocities + mooring N2';
                  'mi11_ic   :  mooring velocities + interal N2 (T1 sensor)';
                  'pi11_ic   :  pitot velocities + interal N2  (T1 sensor)';
                  'mi112_ic  :  mooring velocities + interal N2 (T1+T2 sensor)';
                  'pi112_ic  :  pitot velocities + interal N2  (T1+T2 sensor)';
                  '';
                  'mm2_ic    :  mooring velocities + mooring N2';
                  'pm2_ic    :  pitot velocities + mooring N2';
                  'mi22_ic   :  mooring velocities + interal N2 (T2 sensor)';
                  'pi22_ic   :  pitot velocities + interal N2  (T2 sensor)';
                  'mi212_ic  :  mooring velocities + interal N2 (T2+T1 sensor)';
                  'pi212_ic  :  pitot velocities + interal N2  (T2+T1 sensor)';
               '-----------------------------------------------------------------------'})
      end


   end
end
