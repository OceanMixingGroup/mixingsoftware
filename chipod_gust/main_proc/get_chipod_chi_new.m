function [chi,epsil,k,spec,k_kraich,spec_kraich,stats]=...
    get_chipod_chi_new(freq,tp_power,fspd,nu,tdif,dTdz,nsqr)
%
% function [chi,epsil,k,spec,k_kraich,spec_kraich,stats]=...
%    get_chipod_chi(freq,tp_power,fspd,nu,tdif,dTdz,varargin)
%
% to compute chi and epsilon from chipod data.  
%
% Required arguments are:
% - freq,
% - the frequencies of tp_spec (corrected temperature gradient [dT/dt] spectrum), 
% - fallspd (in m/s), 
% - nu (viscosity),
% - tdif (thermal diffusivity), 
% - dTdz (a scalar vertical gradient), 
% - the head structure, and 
% - this_sensor (the sensor name in the head structure). 
%
% In addition, here are some variables that could be set from varargin:
% - alpha (1/rho drho/dT), 
% - nsqr (g/rho drho/dz) - buoyancy frequency,  
% - fmax - the maximum frequency to intergrate the temperatue spectrum to.
% - gamma - the mixing efficiency
% - g - gravity
% - n_iterations - the number of times to iterate on epsilon
% - doplots - whether or not to plot the data.  
%
% this routine makes n_iterations estimates of epsilon and chi, through
% the assumption that K_T=K_\rho, and returns 
% chi (a vector of chi estimates, where chi(1) is the value on which the
% routine converged, and chi(10) was the first estimate)
% epsil (a vector of epsilon estimates, where epsil(1) is the converged
% value, and epsil(10) was the first estimate
% k, spec and k_kraich, spec_kraich, both wavenumbers and spectra
% associated with the final fits.    
%   $Revision: 1.7 $  $Date: 2011/02/17 22:44:01 $
%
% First, you must send the power spectral density calculated as
%    [tp_power,freq]=fast_psd(tp,nfft,samplerate);
% And corrected as:    
% tp_power=invert_filt(freq,invert_filt(freq,tp_power,thermistor_filter_order, ...
%     thermistor_cutoff_frequency),analog_filter_order,analog_filter_freq);
    
%% get input variables in order

warning off 

    fmax=15;
    gamma=0.2;
    q=7;
    n_iterations=5;

%   doplots=0;
    
    
%% good indices

good_inds=find(~isnan(tp_power));
tp_power=tp_power(good_inds);
freq=freq(good_inds);    
if isempty(good_inds)
    freq(1)=0.001;
end

%%
k=freq/fspd;
spec_time=tp_power/fspd^2;% If tp_power is power of dT/dt, than our units are 
                     % K^2/[s^2 Hz]=[K^2/s] we need to
                     % divide by fspd^2 to get [K^2/m^2/Hz] 

                     


%% plot?
%if doplots, figure(17),clf,cols='rbgmykbbbbbbbbbbbb';end

%% calculate chi and epsilon
chi_out  =   nan(1,n_iterations);
epsil    =   chi_out;

epsilon  =   1e-7; % this is the first guess. ;
for b=1:n_iterations

    ks = ((epsilon/(nu^3))^.25 )/2/pi;
    k_start = 2;
    kb=(ks*sqrt(nu/tdif));
    k_end = kb/2;
    f_start= k_start * fspd;
    f_stop = k_end * fspd;
    if f_stop>fmax;
        f_stop=fmax;
    end
    if max(freq)<f_stop
        f_stop=max(freq);
    end
    if f_start<freq(1)
        f_start=freq(1);
    end
    if f_stop<f_start
        f_stop=f_start+0.1;
    end
    iq=find(freq>=f_start & freq<=f_stop, 1);
    if isempty(iq)
        [c1,i1]=min(abs(freq-f_start));
        [c2,i2]=min(abs(freq-f_stop));
        if c2<c1
            f_stop=freq(i2);
        else
            f_start=freq(i1);
        end
    end
    %  freq=tp_freq';
    chi_part= 6*tdif* integrate_new(f_start,f_stop,freq',spec_time');
    chi=chi_part;
    if(isnan(chi) || chi==0) % additional catch for chi==0, associated to a zero spectrum
        epsil=NaN;k_kraich=NaN;spec_kraich=NaN;
        stats.k_start=NaN;
        stats.k_stop=NaN;
        stats.f_start=NaN;
        stats.f_stop=NaN;
        stats.n_freq=NaN;
        %         [f_start f_stop min(freq) max(freq)]
        %         pause
        spec=k.*NaN;
        return
    end
    chi_test=chi_part*2;
    b_freq=(10.^(-2:.1:3.5))';
    count=0;
    change_chi_part = 0;
    while abs(chi_part/chi_test-1)>.05
        count=count+1;
        b_spec= kraichnan_new(nu,b_freq/fspd,kb,tdif,chi,q)/fspd;
        if change_chi_part
            chi_part= 6*tdif* integrate_new(f_start,f_stop,freq',spec_time'); % this should only be done if f_start or f_stop has been changed
            change_chi_part = 0;
        end
        chi_test=6*tdif*integrate_new(f_start,f_stop,b_freq,b_spec);
        chi=chi*chi_part/chi_test;
        % Now get a new estimate of kb and f_stop:
        epsilon=nsqr*chi/(2*gamma*dTdz^2);
        kb = (((epsilon/(nu^3))^.25 )/2/pi)*sqrt(nu/tdif);
        f_stop=(kb/2)*fspd;
        if f_stop>fmax;
            change_chi_part = 1;
            f_stop=fmax;
        end
        if max(freq)<f_stop
            change_chi_part = 1;
            f_stop=max(freq);
        end
        if f_stop<f_start && f_start>freq(1)
            change_chi_part = 1;
            f_start=freq(1);
        end
        if f_stop>=f_start
            change_chi_part = 1;
            iq=find(freq>=f_start & freq<=f_stop, 1);
            if isempty(iq)
                [c1,i1]=min(abs(freq-f_start));
                [c2,i2]=min(abs(freq-f_stop));
                if c2<c1
                    f_stop=freq(i2);
                else
                    f_start=freq(i1);
                end
            end
            iq2=find(b_freq>=f_start & b_freq<=f_stop, 1);
            if isempty(iq2)
                [c1,i1]=min(abs(b_freq-f_start));
                [c2,i2]=min(abs(b_freq-f_stop));
                if c2<c1
                    f_stop=b_freq(i2);
                else
                    f_start=b_freq(i1);
                end
            end
        end
        if count>20
            f_stop=f_start;
%                 disp(['Exceeded maximum number of iterations: count=' num2str(count)])
%                 disp(['Result converged within ' num2str(abs(chi_part/chi_test-1)*100) '%'])
%                 disp('\chi is set to NaN')
            break
        end

    end


    % Now determine some statistics.
    if f_stop>=f_start
        iq=find(freq>=f_start & freq<=f_stop, 1);
        if isempty(iq)
            [c1,i1]=min(abs(freq-f_start));
            [c2,i2]=min(abs(freq-f_stop));
            if c2<c1
                f_stop=freq(i2);
            else
                f_start=freq(i1);
            end
        end
        iq2=find(b_freq>=f_start & b_freq<=f_stop, 1);
        if isempty(iq2)
            [c1,i1]=min(abs(b_freq-f_start));
            [c2,i2]=min(abs(b_freq-f_stop));
            if c2<c1
                f_stop=b_freq(i2);
            else
                f_start=b_freq(i1);
            end
        end
    end
    f_range=freq(freq>f_start & freq<f_stop);
    if numel(f_range)>0
        stats.k_start=f_range(1)/fspd;
        stats.k_stop=f_range(end)/fspd;
        stats.f_start=f_range(1);
        stats.f_stop=f_range(end);
        stats.n_freq=length(f_range);
        chi=6*tdif*integrate_new(min(b_freq),max(b_freq),b_freq,b_spec);
    else
        stats.k_start=NaN;
        stats.k_stop=NaN;
        stats.f_start=NaN;
        stats.f_stop=NaN;
        stats.n_freq=NaN;
        b_spec=NaN;
        chi=NaN;
    end

    % Now estimate epsilon from chi:
    epsilon=nsqr*chi/(2*gamma*dTdz^2);
    chi_out(b)=chi;
    epsil(b)=epsilon;

    k_kraich=b_freq/fspd;
    spec_kraich=b_spec*fspd;% to convert from K/[m^2*Hz] to K/[m^2*cpm]
    spec=spec_time*fspd;% to convert from K/[m^2*Hz] to K/[m^2*cpm]

%     if doplots
%         loglog(k,spec,k_kraich,spec_kraich,cols(b))
%         hold on;
%         title(['chit=' num2str(chi(end)) ', epsilon=' num2str(epsil(end))])
%         xlabel('k [cpm]');
%         ylabel('spectrum [(K/m)^2/cpm]');
%         ylim([.00000001 0.1])
%         plot([stats.k_start stats.k_start],ylim,'k--')
%         plot([stats.k_stop stats.k_stop],ylim,'k--')
%     end
end

chi=fliplr(chi_out);
epsil=fliplr(epsil);
return
