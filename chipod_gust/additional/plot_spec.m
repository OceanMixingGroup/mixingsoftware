function [F_U, PS, p1] = plot_spec(ax, X, fs, varargin)
%%  [f, P, p1] = plot_spec(ax, X, fs, [color], [nW])
%     this  function plots a spectrum of X with sample freq fs in ax
%     color = color of the plot
%     nW = number of windows (default =1);
%     lin = line element handle


if(nargin<4)
   col   = [0 0 0];
   nW    = 1;
elseif(nargin<5)
   col   = varargin{1};
   nW    = 1;
else
   col   = varargin{1};
   nW    = varargin{2};
end

   % % set spectrum parameters
   N = length(X);
   NFFTmax = 2^floor(log2(N/nW));  % set largest possible power 2 segment 
   Fmin    = NFFTmax*fs;              % lowest frequency range from 0 to Fmin
   Ffac    = 4;                % increase frequency range by this factor
   p       = 0.95;             % set confidence interval
   pPlot   = 5e-1;             % plot confidence intervals around this value

   [F_U , PS, ctop, cbot]  = iow_fancypsd( X, NFFTmax, Ffac, Fmin, fs, p, pPlot);

   
   if( isreal(PS(1)) )
      p1 = plot(ax, F_U, PS, 'color', col);
      hold(ax, 'on');
   else
      p1 = plot(ax, F_U, real(PS), '--', 'color', col);
      hold(ax, 'on');
      p2 = plot(ax, F_U, imag(PS), 'color', col);
      legend([p1, p2], 'anti-clockwise', 'clockwise' );
   end

      xlabel(ax, 'f [Hz]');
      set(ax, 'Yscale', 'log','Xscale', 'log','TickDir','out', 'color', 'none');
end
