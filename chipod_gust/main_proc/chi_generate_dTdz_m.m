function [Tz_m] = chi_generate_dTdz_m(t1, z1, T1, S1, t2, z2, T2, S2,  sdir);
% [Tz_m] = chi_generate_dTdz_m(t1, z1, T1, S1, t2, z2, T2, S2,  sdir);
%
%        This function generates an input file for chi-processing dTdz_m.m at
%        directory sdir based on 2 CTD-time series T1 above chipod/gust and T2
%        below
%        
%        Input
%           t1          : time vector of 1st CTD time series
%           z1          : depth in meter from surface
%           T1          : temperature vector of 1st CTD time series
%           S1          : salinity vector of 1st CTD time series (could also be constant scalar)
%           t2          : time vector of 2nd CTD time series
%           z2          : depth in meter from surface
%           T2          : temperature vector of 2nd CTD time series
%           S2          : salinity vector of 2nd CTD time series (could also be constant scalar)
%           sdir        : directory to save dTdz_m.met to
% 
%        Output
%           Tz_m.time   : time vector  (1min averages)
%           Tz_m.Tz     : temperature gradient
%           Tz_m.N2     : buoyancy freqency
%
%   created by: 
%        Johannes Becherer
%        Fri Sep  2 13:49:20 PDT 2016


%---------------------check salinity id sclar----------------------
   if length(S1)==1
      S1 = ones(size(T1))*S1;
   end
   if length(S2)==1
      S2 = ones(size(T2))*S2;
   end



%---------------------create time vector----------------------
   % find beginning
   ts = max(t1(1), t2(1));
   % find end
   tf = max(t1(end), t2(end));

   % construct time array
   dt = 1/(24*60);      % one minute
   time = ts:dt:tf;     % time array

   % find delta time for the CTD series
   dt1 = diff(t1(1:2));
   dt2 = diff(t2(1:2));

   % vertical distance of both sensors in meter
   dz = abs(z1-z2);

%---------------------cal gradient----------------------
   % in case the time series are sampled much quicker then one minute 
   % low pass filter them
   if dt1/dt < 1
      T1 = qbutter(T1, dt1/dt);
      S1 = qbutter(S1, dt1/dt);
   end
   if dt2/dt < 1
      T2 = qbutter(T2, dt2/dt);
      S2 = qbutter(S2, dt2/dt);
   end

   % interpolate time series on common time stamp
   T1_int = interp1(t1, T1, time);
   T2_int = interp1(t2, T2, time);
   S1_int = interp1(t1, S1, time);
   S2_int = interp1(t2, S2, time);

   % cal temperature gradient
   Tz_m.Tz = (T1_int-T2_int)/dz;

   % cal density
   %D1 = sw_dens(S1_int,T1_int,abs(z1));
   %D2 = sw_dens(S2_int,T2_int,abs(z2));
   
   % N2
   %g        = 9.81;
   %rho_0    = 1025;
   %Tz_m.N2  = -g/rho_0*(D1-D2)/dz;
   [Tz_m.N2,~,~]  = cal_N2_from_TS(t1, T1,  S1, ones(size(S1))*abs(.5*(z1+z2)), time, Tz_m.Tz, 600);

   Tz_m.time  = time;

%---------------------save----------------------
   save([sdir 'dTdz_m.mat'], 'Tz_m');
