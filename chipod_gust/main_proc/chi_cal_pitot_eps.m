function [eps, varargout] = chi_cal_pitot_eps(data, W)
%% [eps, [data, M]] = chi_cal_pitot_eps(data, W) 
%     
%     This function calculates dissipation rates based on Pitot speeds
%
%     INPUT
%        data     :  calibrated chipod/ gusT data
%        data.W   :  must be contained Raw-voltage of Pitot
%        W        :  pitot header should contain (V0, T0, P0, Pd, T, Ps) [like W] 
%
%     OUTPUT
%        eps      :  product structure 
%                       contains : time, eps, slope, l_k, m_spd, M_spd, M_turn, M_tot
%        data     :  like input structure with additional velocity information 
%                       spd, spd_e, U, ...
%        M        :  structure containing mask vectors
%
%
%   created by: 
%        Johannes Becherer
%        Thu Nov 17 17:34:43 PST 2016




%_____________________parameters______________________
dt = diff(data.time(1:2))*3600*24;


%_____________________for chipods______________________
if isfield(data, 'T1')
   data.T = data.T1;
end




%_____________________calibrate speed______________________
   cal.V0 = W.V0;
   cal.T0 = W.T0;
   cal.P0 = W.P0;
   cal.Vs = 1/W.Pd(2);
   cal.Ts = W.T(2);
   cal.Ps = W.Ps(2);
   [data.spd, data.Pdym, data.V_cal] = pitot_calibrate(data.W, data.T, data.P,...
            cal.V0, cal.T0, cal.P0, cal.Vs, cal.Ts, cal.Ps);

   % get directional information for U
   data.U  = pitot_add_direction( data.time, data.spd, data.time_cmp, data.cmp);

%_____________________filter speed______________________

   %---------------------define masks----------------------------------

   % cut-off speeds smaller than 15 cm/s
      M.spd = data.spd< .15;

   % excluse times when turning
      % delta angle
      alpha = angle(qbutter(data.U, .025)); % low pass filtered for 4 Hz;
      dalpha = abs(diff(cos(alpha))) + abs(diff(sin(alpha)));
      dalpha = [dalpha; dalpha(end)]; % make vector as long as others (small error  with (100 hz)) 

      % turning should be less than pi/2 (1) /sec
      da_max = 1*dt;

      M.turn = dalpha > da_max;
 
   % acceleration filter (not implemented yet)
   %M.acc = data.Acc<.1;


   %---------------------apply filter----------------------
   data.spd_e           = data.spd;
   data.spd_e(M.spd)    = nan;
   data.spd_e(M.turn)   = nan;
   
   

%_____________________cal epsilon______________________

   %---------------------find pieces that are at least 2 sec long----------------------
   J = find_series1s(~isnan(data.spd_e), 2/(dt));
   %ii = cell2mat(I);  % make a flat index array

   %---------------------split pieces longer than 4 sec----------------------
   Nf = ceil(2/(dt));   % Nf is the length of the fragment
   if isempty(J)
       I = [];
   else
       I  = split_fragments(J, Nf, 0);  
   end

   %---------------------initialize----------------------
   eps.eps      = nan(1,length(I));
   eps.slope    = nan(1,length(I));
   eps.time     = nan(1,length(I));
   eps.l_k      = nan(1,length(I));
   eps.m_spd    = nan(1,length(I));

   %---------------------fit data----------------------
   for i = 1:length(I)
      warning('off')
      [eps.eps(i), eps.slope(i), eps.m_spd(i), eps.l_k(i)] = fit_longitudinal_kolmogorov(data.time(I{i}),  data.spd_e(I{i}), [2 10], 0);
      %[eps.eps(i), eps.slope(i), eps.m_spd(i), eps.l_k(i)] = fit_longitudinal_kolmogorov(data.time(I{i}),  data.spd_e(I{i}), [.5 2], 0);
      %[eps.eps(i), eps.slope(i), eps.m_spd(i), eps.l_k(i)] = fit_longitudinal_kolmogorov(data.time(I{i}),  data.spd(I{i}), [2 10], 0);
      eps.time(i) = median(data.time(I{i}));
   end


%_____________________add aditional information______________________

   %_____________________what percentage does maks filter______________________
   N = length(data.time); 
   eps.M_spd  = sum(M.spd)/N;
   eps.M_turn = sum(M.turn)/N;
   eps.M_tot  = sum(isnan(data.spd_e))/N;
   
   
   %_____________________additional output______________________
   varargout{1} = data;
    varargout{2} = M;
   
   

