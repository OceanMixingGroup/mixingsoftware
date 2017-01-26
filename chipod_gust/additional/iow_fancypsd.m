function [F,P,Ctop,Cbot] = iow_fancypsd(x,NFFTmax,Ffac,Fmin,Fs,p,pPlot)
% This routine computes a series of spectral densities with increasingly
% smaller segment length, NFFT, according to the Welch algorithm with 50% 
% overlap. The maximum segment length used in the first iteration is 
% NFFTmax. For each iteration, the segment length is divided by two, and a 
% new spectrum is computed. The spectrum with the largest segment length, 
% NFFTmax, is used for the frequency windo from 0 to Fmin. The spectrum 
% from the next interation is used for the frequency range from Fmin to 
% Ffac*Fmin, and so on until the Nyquist frequency is reached. Due to the 
% increasingly smaller segment length, the confidence intervals become 
% stepwise smaller towards higher frequencies.

% Input arguments: 
% x:        Data vector. If x is complex, rotary spectra will be computed
% NFFTMax:  Maximum segment length used in first iteration
% Ffac:     Frequency window shifts by Ffac for every iteration
% Fmin:     Lowest frequency window ranges from 0 to Fmin
% Fs:       Sampling frequency
% p:        Confidence interval (e.g. p=0.95)
% pPlot:    Center confidence intervals around this value (for plotting)

% Output arguments:
% F:        Frequency vector
% P:        Power spectral density. If x is complex, also P is complex:
%           real(P) contains the counter-clockwise rotary spectrum
%           imag(P) contains the clockwise rotary spectrum             
% Ctop:     Upper confidence level (with respect to 'pPlot')
% Cbot:     Lower confidence level (with respect to 'pPlot')
%
% Info: lars.umlauf@io-warnemuende.de



%% initialize

% Inititalize output arrays
F     = [];
P     = [];
Cbot  = [];
Ctop  = [];

% Inititalize spectrum parameters
NFFT  = NFFTmax;        % segment and window width
Fl    = 0;              % lower range for frequency window
Fu    = Fmin;           % upper range for frequency window


%% iterate until Nyquist frequency is exceeded 

it = 0;

while( Fl < 0.5*Fs )

    % count interation
    it = it + 1;
    
    % report current parameters
    disp(['Iteration:        ' num2str(it)] );
    disp(['Freq. window:     ' num2str(Fl,'%2.2e') ' - ' ... 
                               num2str(Fu,'%2.2e')]); 
    disp(['NFFT:             ' num2str(NFFT,'%6.0f')]);
    disp(['Freq. resolution: ' num2str(Fs/NFFT,'%2.2e')]);
    disp(' ');
   
    % compute spectrum for current segment length
    OverlapPercent = 50;

    Hs   = spectrum.welch('Hamming',NFFT,OverlapPercent);
    
    if isreal(x)
        hpsd = psd(Hs,x,'NFFT',NFFT,'Fs',Fs, ...
                        'ConfLevel',p,'SpectrumType','onesided');
        isRotary = 0;
    else
        hpsd = psd(Hs,x,'NFFT',NFFT,'Fs',Fs, ...  
                        'ConfLevel',p,'SpectrumType','twosided');
                   
        isRotary = 1;
    end

    % save current iteration
    Fit      = hpsd.Frequencies;
    Pit      = hpsd.Data;
    Cit      = hpsd.ConfInterval; 
    
    % construct rotary spectra from left and right hand sides of complex
    % spectra
    
    if isRotary
 
        % Nup is the highest frequency that can be represented
        Nup = NFFT/2;

        if round(Nup) == Nup
            % even
            Nup   = NFFT/2 + 1;
            even = 1;
        else
            % odd
            Nup   = (NFFT+1)/2;
            even = 0;
        end 

        % interprete right hand side of spectrum as counter-clockwise
        Fit        = Fit(1:Nup);
        Pplus      = Pit(1:Nup);


        % interprete left hand side of spectrum as clockwise
        % Matlab spectra have be flipped
        Pminus     = zeros(Nup,1);
        if even
            Pminus(2:Nup-1) = Pit(NFFT:-1:Nup+1);
        else
            Pminus(2:Nup)   = Pit(NFFT:-1:Nup+1);
        end

        % compose complex spectrum
        Pit = Pplus + i*Pminus;
  
        % just use the right hand side of confidence intervals
        % (left hand side will be equal)
        Cit       = Cit(1:Nup,:);
        
    end

    % cut out the frequency window of this iteration
    Ind      = find(Fit > Fl & Fit < Fu); 
    Fit      = Fit(Ind);
    Pit      = Pit(Ind);    
    Cit      = Cit(Ind,:);

    % convert Matlab confidence intervals to version that is constant on a
    % log-log plot
    [Cbotit,Ctopit] = confLabel(real(Pit),Cit,pPlot);

    % append current frequency range to output 
    F    = [F ; Fit];
    P    = [P ; Pit];
    Cbot = [Cbot ; Cbotit];    
    Ctop = [Ctop ; Ctopit];    
    
        
    % update frequency range and segment length
    Fl    = Fu;
    Fu    = Ffac*Fu;
    NFFT  = floor(NFFT/2); 
    

end

end

function [Cbot Ctop] = confLabel(Psd,ConfInterval,CentralValue)
% This function converts from the Matlab way to plot confidence intervals
% to confidence intervals that do not depend on frequency if plotted
% log-log scale.

DCtop  =  log10(ConfInterval(:,2)) - log10(Psd);
DCbot  =  log10(Psd)               - log10(ConfInterval(:,1)); 

Ctop   = 10.^(log10(CentralValue) + DCtop);
Cbot   = 10.^(log10(CentralValue) - DCbot);

end