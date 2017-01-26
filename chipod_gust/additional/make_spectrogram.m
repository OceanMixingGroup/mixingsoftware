function [PS, psd, f, T] = make_spectrogram(t, x, SWidth, TSteps)
%% function [PS, psd, f, T] = make_spectrogram(t, x, SWidth, TSteps)
%        This function generates a spectrogram PS of the vector x
%         x       : 1 dimensional data vector
%         t       : coresponding time (equidistant and in days)
%         SWidth  : spectrum width in days
%         TSteps  : Time step for the spectrogram in days.

%   %test
%   SWidth = 1000;
%   TSteps = 499;
%   t = 1:.5:3000;
%   x = sin(t/200*2*pi);

   dt  = diff(t(1:2)) ; % time step in days
   Nww = floor(SWidth/dt);
     
   % % set spectrum parameters
   NFFTmax = Nww;       % set largest FFT-segment 
   %NFFTmax = 2^floor(log2(Nww));       % set largest FFT-segment 

   Ffac    = 4;                % increase frequency range by this factor
   p       = 0.95;             % set confidence interval
   pPlot   = 5e-1;             % plot confidence intervals around this value
   Fmin    = 3e-3;              % lowest frequency range from 0 to Fmin
   fs      = 1/(dt*3600*24);    %   sampling rate Hz  

   IT = 1:Nww;
   cnt = 1;
   DT = round(TSteps/dt);
   ii = IT;
   while ii(end)<length(t)
       T(cnt) = mean(t(ii));
       [f , psd(:,cnt), ~, ~]  = iow_fancypsd(x(ii), NFFTmax, Ffac, Fmin, fs, p, pPlot);
       ii = [ii] + DT;
       cnt = cnt+1;
   end
           
   F = repmat(f,[1 length(T)]);
   PS = psd.*F;  
