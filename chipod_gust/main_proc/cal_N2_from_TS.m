function [N2, Sz, s_TS] = cal_N2_from_TS( TSP_time, T, S, P,  Tz_time, Tz,  dt)
%%    [N2, Sz, s_TS] = cal_N2_from_TS( TSP_time, T, S, P,  Tz_time, Tz,  dt)
%
%        This function calculates N2 based on a given temperature gradient
%        and a T-S-relation 
%
%        INPUT
%           TSP_time    :  time vector of T,S, and P
%           T           :  temperature 
%           S           :  salinity
%           P           :  pressure in [dbar]
%           Tz_time     :  time vector of the temperature gradient
%           Tz          :  temperature gradient
%           dt          :  timeintrevals of T-S-relation (in sec)
%
%        OUTPUT (all output quantities are on the Tz_time grid)
%           N2          :  N2
%           Sz          :  salinity gradient
%           s_TS        :  slope of T-S relation
%
%   created by: 
%        Johannes Becherer
%        Mon Nov 28 18:27:19 PST 2016

%---------------------spli T and S into pieces dt long pieces----------------------
   J{1}  =  1:length(TSP_time);
   Nf    = round( dt/( diff(TSP_time(1:2))*3600*24  ) );   % Nf is the length of the fragment
   I     = split_fragments(J, Nf, 0);  

%_____________________calculated T-S-slope______________________
   time_sl   = nan(1,length(I));
   s_TS_tmp  = nan(1,length(I));
   for i = 1:length(I)
      time_sl(i) = nanmean(TSP_time(I{i}));
      % slope
      p           = polyfit( T(I{i}), S(I{i}),1);
      s_TS_tmp(i) = p(1);
   end
   % interpolate slope on commen time 
   s_TS  =  interp1( time_sl, s_TS_tmp, Tz_time);

%_____________________cal salinity gradient______________________

Sz =  s_TS .* Tz;
   
%_____________________calculate N2______________________

   alpha = nanmean(sw_alpha(S, T,  P, 'temp'));
   beta  = nanmean(sw_alpha(S, T,  P, 'temp'));
   g     = 9.81;

   N2 = -g*( -alpha*Tz + beta*Sz );

