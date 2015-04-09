function [avg, ctd]=Compute_CTDchipod_profile(chidat,ctd)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% [avg, ctd]=Compute_CTDchipod_profile(chidat,ctd)
%
% Compute_CTDchipod_profile.m
%
% Modified from part of process_chipod_script_AP.m
%
% INPUTS
% chidat : chipod data (load_chipod_data.m)
% ctd    : Data structure with fields:
%   T : temperature
%   P : pressure 
%   N2: buoyancy frequency
%   dTdz : temperature gradient
%
% OUTPUTS
%   avg
%   ctd
%
% A. Pickering - 31 Mar. 2015
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

%~~~ now let's do the chi computations:


%~~ compute time offset and align profiles
% need to use 24Hz data for this?
% could do outside this function, assume chidat already corrected?

%~~ calibrate chipod temperature


% remove loops in CTD data
extra_z=2; % number of extra meters to get rid of due to CTD pressure loops.
wthresh = 0.4;
[datau2,bad_inds] = ctd_rmdepthloops(data2,extra_z,wthresh);
tmp=ones(size(datau2.p));
tmp(bad_inds)=0;
cal.is_good_data=interp1(datau2.datenum,tmp,cal.datenum,'nearest');
%

%%% Now we'll do the main looping through of the data.
clear avg
nfft=128;
todo_inds=chi_inds(1:nfft/2:(length(chi_inds)-nfft))';
%                plot(chidat.datenum(todo_inds),chidat.T1P(todo_inds))
tfields={'datenum','P','N2','dTdz','fspd','T','S','P','theta','sigma',...
    'chi1','eps1','chi2','eps2','KT1','KT2','TP1var','TP2var'};
for n=1:length(tfields)
    avg.(tfields{n})=NaN*ones(size(todo_inds));
end
avg.datenum=cal.datenum(todo_inds+(nfft/2)); % This is the mid-value of the bin
avg.P=cal.P(todo_inds+(nfft/2));
good_inds=find(~isnan(ctd.p));
avg.N2=interp1(ctd.p(good_inds),ctd.N2(good_inds),avg.P);
avg.dTdz=interp1(ctd.p(good_inds),ctd.dTdz(good_inds),avg.P);
avg.T=interp1(ctd.p(good_inds),ctd.t1(good_inds),avg.P);
avg.S=interp1(ctd.p(good_inds),ctd.s1(good_inds),avg.P);

% note sw_visc not included in newer versions of sw?
addpath  /Users/Andy/Cruises_Research/mixingsoftware/seawater
% avg.nu=sw_visc(avg.S,avg.T,avg.P);
avg.nu=sw_visc_ctdchi(avg.S,avg.T,avg.P);

% avg.tdif=sw_tdif(avg.S,avg.T,avg.P);
avg.tdif=sw_tdif_ctdchi(avg.S,avg.T,avg.P);

avg.samplerate=1./nanmedian(diff(cal.datenum))/24/3600;

h = waitbar(0,['Computing chi for cast ' cast_suffix]);
for n=1:length(todo_inds)
    clear inds
    inds=todo_inds(n)-1+[1:nfft];
    
    if all(cal.is_good_data(inds)==1)
        avg.fspd(n)=mean(cal.fspd(inds));
        
        [tp_power,freq]=fast_psd(cal.T1P(inds),nfft,avg.samplerate);
        avg.TP1var(n)=sum(tp_power)*nanmean(diff(freq));
        
        if avg.TP1var(n)>1e-4
            
            % not sure what this is for...
            fixit=0;
            if fixit
                trans_fcn=0;
                trans_fcn1=0;
                thermistor_filter_order=2;
                thermistor_cutoff_frequency=32;
                analog_filter_order=4;
                analog_filter_freq=50;
                tp_power=invert_filt(freq,invert_filt(freq,tp_power,thermistor_filter_order, ...
                    thermistor_cutoff_frequency),analog_filter_order,analog_filter_freq);
            end
            
            %try
            
            % [chi1,epsil1,k,spec,kk,speck,stats]=get_chipod_chi(freq,tp_power,avg.fspd(n),avg.nu(n),...
            %  avg.tdif(n),avg.dTdz(n),'nsqr',avg.N2(n));
            %  % AP 27 Mar - fspd needs to be positive?
            %  wasn't working for downcasts before with
            %    above function call
            [chi1,epsil1,k,spec,kk,speck,stats]=get_chipod_chi(freq,tp_power,abs(avg.fspd(n)),avg.nu(n),...
                avg.tdif(n),avg.dTdz(n),'nsqr',avg.N2(n));
            %catch
            %	chi1=NaN;
            %	epsil1=NaN;
            %end
            
            avg.chi1(n)=chi1(1);
            avg.eps1(n)=epsil1(1);
            avg.KT1(n)=0.5*chi1(1)/avg.dTdz(n)^2;
            
        else
            %disp('fail2')
        end
    else
        % disp('fail1')
    end
    
    if ~mod(n,10)
        waitbar(n/length(todo_inds),h);
    end
    
end
delete(h)

%~~ Plot chi, KT, and dTdz
figure(4);clf

subplot(131)
plot(log10(avg.chi1),avg.P),axis ij
xlabel('log_{10}(avg chi)')
ylabel('Depth [m]')
grid on
title(['cast ' cast_suffix])

subplot(132)
plot(log10(avg.KT1),avg.P),axis ij
xlabel('log_{10}(avg Kt1)')
grid on
title([short_labs{up_down_big}],'interpreter','none')

subplot(133)
plot(log10(abs(avg.dTdz)),avg.P),axis ij
grid on
xlabel('log_{10}(avg dTdz)')
%print('-dpng',[fig_path  'chi_' short_labs{up_down_big} '/cast_' cast_suffix '_chi_' short_labs{up_down_big} '_avg_chi_KT_dTdz'])
%~~

%%