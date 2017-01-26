function [eps, slope, varargout] = fit_longitudinal_kolmogorov(time, u, f_range, varargin)
%% [eps, slope, [aspeed, l_k]] = fit_longitudinal_kolmogorov(time, u, f_range)
%
%     This function fits a short speed (longitudinal velocity) timeseries
%     against a longitudinal kolmogorov spectrum to determine the disspation
%     rate
%        
%        INPUT:
%           time     : time vector corresponding to u [matlab time]
%           u        : longitudinal velocity time series (short) [m/s]
%           f_range  : frequency range to fit the spectrum to [f_start f_stop] [Hz]
%
%        OUTPUT
%           eps      : dissipation rate [m/s^3]
%           slope    : spectral slope in f_range (as a quality controll, 
%                       should not deviate to much from -5/3)
%           aspeed   : average speed
%           l_k      : kolmogirov length 
%
%   created by: 
%        Johannes Becherer
%        Fri Nov  4 13:48:34 PDT 2016

%_____________________doplot______________________
if nargin <4
   do_plot =  0;
else
   do_plot = varargin{1};
end

if find(isnan(u))>0
   eps          = nan;
   slope        = nan;
   varargout{1} = nan;
   varargout{2} = nan;
   return
end



%_____________________determin important parametres______________________
   % mean velocity
   u_m = abs(nanmean(u));
   varargout{1} = u_m;

   % k_range (wave number range that corresponds to f_range)
   k_range = 2*pi/u_m*f_range;
   %k_range = f_range/u_m;

   % sample frequency in Hz
   fs = 1/(median(diff(time))*3600*24);

   % number of time steps in window
   Nw = length(time);
   
   % von Karman's constant 
   kappa=0.4; 

%_____________________calculate spectrum______________________
   
   % frquency spectrum
   if isnan(u_m)
      phi =nan;
      f=nan;
   else
      [phi,f] = gappy_psd( u, floor(Nw/2), fs, 5);
   end

   % convert to wave number spectrum
   spec = phi*u_m/2/pi;    % [m^2\cdots^{-2}/radpm]
   k    = 2*pi/u_m*f;      % [radpm] 
   %spec = phi*u_m;    % [m^2\cdots^{-2}/radpm]
   %k    = f/u_m;      % [radpm] 

   
%________ range of spectrum that corresponds to f_range___________
   % in case the range is the other way around
   if k_range(2)<k_range(1)
      k_range = fliplr(k_range);
   end

   % check if desired range is within the possible range
   if k_range(1)<k(1)
      warning(['the desired frequency range' num2str(k_range) ...
               'lies outside the possible domain' num2str(k([1 end]))]);
      k_range(1) = k(1);
   end
   if k_range(2)>k(end)
      warning(['the desired frequency range' num2str(k_range) ...
               'lies outside the possible domain' num2str(k([1 end]))]);
      k_range(2) = k(end);
   end

   % find all indexes of the spectrum within the range
   iif = find(k<=k_range(2) & k>=k_range(1));
   
   

%_____________________fit spectrum______________________
   
   % initial epsilon value for fiting
   eps_init=1e-8; 

   % fit k against spec using eps_init as inital value 
   if ~isnan(k)
      eps  = real(nlinfit(k(iif),spec(iif),@kol_spec,eps_init));
      %compute slope in log-space as quality controll______________________
      p     = polyfit(log10(k(iif)),log10(spec(iif)),1);
      slope = p(1);
   else
      eps = nan;
      slope = nan;
   end


   if abs(slope + 5/3)>1 
      warning(['the calculated slope' num2str(slope)  'strongly deviated from -5/3'])
   end


   nu = 1e-6;
   l_k = (nu^3/eps)^.25;
   varargout{2} = l_k;

%_____________________ploting______________________
if do_plot
   figure
      a = 1;
      ax(a) = subplot(2,1,1);
      plot(ax(a), time, u, 'Linewidth', 1);
      hold(ax(a),'on');
      plot(ax(a), time([1 end]), [1 1]*u_m, 'Linewidth', 1);
      t = text_corner(ax(a), ['$\langle{u}\rangle = $' num2str(u_m) ' m s$^{-1}$'], 1);
      ylabel(ax(a), 'speed [m/s]')
      datetick(ax(a), 'keeplimits');

      a = 2;
      ax(a) = subplot(2,1,2);
      plot(ax(a), k, spec, 'Linewidth', 1);
      hold(ax(a),'all');
      plot(ax(a), k(iif), spec(iif), 'Linewidth', 1);
      plot(ax(a), k(iif([1 end])), 1.5*(18/55)*eps^(2/3)*k(iif([1 end])).^(-5/3), 'k', 'Linewidth', 2);
      set(ax(a), 'Yscale', 'log', 'Xscale', 'log');
      plot(ax(a), [1 1]*(2*pi/l_k), get(ax(a),'Ylim'), '--',  'Linewidth', 1);
      plot(ax(a), [1 1]*(2*pi*.1/l_k), get(ax(a),'Ylim'), ':',  'Linewidth', 1);
      
      %plot(ax(a), k(iif([1 end])), k(iif([1 end])).^(slope), 'Linewidth', 1);
      t = text_corner(ax(a), ['$\epsilon = $' num2str(eps, '%1.3e') ' m$^2$ s$^{-3}$'], 3);
      
      
      
      xlabel(ax(a), 'k [rad/m]')
      ylabel(ax(a), 'E(k) [m^2/s^{2} m/rad]')
      
end


end   % end main function


%%_____________________spectrum function______________________

%---------------------spectrum Jim uses----------------------
   % other spectrum used by Jim
    %    var_spd=nanvar(real(spd(ii)));
    %    f1=f(iif).*var_spd.^(3/2)./nanmean(real(spd(ii)));
    %    epsJ(i) = nlinfit(f1,f(iif).*phi(iif)./kappa./var_spd,@Wspecnhfit,eps);
function specnh = Wspecnhfit(eps,x)
   specnh=x./eps./(1+3.1.*(x./eps).^(5/3));
end

%---------------------longitudinal kolmogorov spec----------------------
function spec = kol_spec(eps,x)
   spec=1.5*(18/55)*x.^(-5/3)*eps^(2/3);
end
