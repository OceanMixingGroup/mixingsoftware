function [chi] = chi_chi_proc(Tp, S, Tz, T)
%% [chi] = chi_chi_proc(Tp, S, Tz)
%
%   This is the main chi processing routine
%
%   INPUT
%     Tp.time  :  time vector of temperature derivitve
%     Tp.tp    :  temperature derivitve
%     S.time   :  time vector of spd 
%     S.spd    :  speed
%     Tz.time  :  time vector of Tz and N2   
%     Tz.Tz    :  Tz
%     Tz.N2    :  N2
%     T.time   :  time vector of T 
%     T.T      :  T
%     [T.S]    :  S (default set to 35 psu) 
%     T.depth  :  depth
%
%   OUTPUT
%     chi.chi  :  chi data
%     chi.eps  :  dissipation rates
%     chi.time :  time vector
%     chi.spd  :  average speed used for the calculation
%     chi.T    :  temperature used to calculate viscosity
%     chi.S    :  salinity used to calculate viscosity
%     chi.depth:  depth used to calculate viscosity
%     chi.Tz   :  temperature gradietn used to do the calculations 
%     chi.N2   :  N2 used to do the calculations 
%     chi.mask :  mask used  
%
%   created by: 
%        Johannes Becherer
%        Fri Nov 25 13:37:45 PST 2016
  

%_____________________default values______________________

min_dTdz = 1e-4;

if ~isfield(T, 'S') 
   T.S = ones(size([T.T]))*35;
end


% define some constants
fmax  = 15;
gamma = 0.2;

%disp('Using default transfer function: filter order 2, cutoff frequency 32')
%_____________________spectral filter stuff______________________
analog_filter_order          = 4;
analog_filter_freq           = 50;
trans_fcn                    = 0;
trans_fcn1i                  = 0;
trans_fcn2i                  = 0;
thermistor_filter_order      = 2;
thermistor_cutoff_frequency  = 32;
    

%_____________________bring spd and Tp to same time grid______________________
   if length(S.time) ~= length(Tp.time)
      S.spd  = interp1( S.time, S.spd, Tp.time, 'nearest');
      S.time = Tp.time;
   end


%_____________________cut time series into pieces for spectra______________________
   dt    = diff(Tp.time(1:2))*3600*24;
   Nf    = round(1/(dt));   % Nf is the length of the 1sec fragment
   J{1}  = 1:length(Tp.time); 
   I     = split_fragments(J, Nf, 0); % split in 1 sec intrevals with no overlap  
   Ni    = length(I);   % total number of 1 sec fragments  


%_____________________construct final time vector______________________
   chi.time = nan(1,Ni);
   chi.spd  = nan(size(chi.time));
   for i = 1:Ni
      chi.time(i) = nanmean( Tp.time( I{i}) );
       % average speed
       chi.spd(i) = nanmean(S.spd(I{i}));
   end

%_____________interp stratification, temp, S, and depth on final time_______
   chi.dTdz    = interp1( Tz.time, Tz.Tz, chi.time);
   chi.N2      = interp1( Tz.time, Tz.N2, chi.time);
   chi.T       = interp1( T.time, T.T, chi.time);
   chi.S       = interp1( T.time, T.S, chi.time);
   chi.depth   = interp1( T.time, T.depth, chi.time);
   %----------calculate viscosity and diffusivity-------------
      nu   = nan(Ni, 1);
      tdif = nan(Ni, 1);
      for i = 1:Ni
         nu(i)    =  sw_visc( chi.S(i), chi.T(i), chi.depth(i));
         tdif(i)  =  sw_tdif( chi.S(i), chi.T(i), chi.depth(i));
      end
   %---------------------spectral constants----------------------
         samplerate = Nf;
         nfft       = samplerate/2;

%_____________________masking data______________________
   % avg.fspd(ik) >= 0.04  && dTdz(i)>min_dTdz 
   chi.mask = ones(size(chi.time));

   chi.mask(abs(chi.dTdz)<min_dTdz) = 0;
   chi.mask(isnan(chi.dTdz)) = 0;
   chi.mask(isnan(chi.N2)) = 0;
   chi.mask(chi.N2<0) = 0;
   chi.mask(chi.spd<.05) = 0;



%_____________________major processing ______________________
   %---------------------initialize----------------------
   chi.chi     = nan(1,Ni); 
   chi.eps     = nan(1,Ni);

   %-------loop through all 1 sec seqments---------------
   for i = 1:Ni

      if chi.mask(i)  % check if calculation should be executed 

          % calculate psd of dT/dt 
          [tp_power, freq] = fast_psd( Tp.tp(I{i}) ,nfft, samplerate);

          % corrections with transfer functions
          tp_power = invert_filt( freq, ...
                                 invert_filt( freq, tp_power, thermistor_filter_order, thermistor_cutoff_frequency), ...
                                 analog_filter_order, analog_filter_freq);

                          
          % fit spectrum
          [chi_tmp, eps_tmp , k,spec, k_kraich, spec_kraich, stats] =...
                  get_chipod_chi_new( freq, tp_power, chi.spd(i), nu(i), tdif(i), chi.dTdz(i), chi.N2(i)); 
          chi.chi(i) = chi_tmp(1);
          chi.eps(i) = eps_tmp(1);
                     

      else % masked out 
          chi.chi(i)  =  nan;
          chi.eps(i)  =  nan;
          chi.spd(i)  =  nanmean(S.spd(I{i}));
      end
            

   end

