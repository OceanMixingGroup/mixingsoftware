function avg=average_data_gen(series,varargin)
% function AVG=AVERAGE_DATA(SERIES,PROPERTY1,VALUE1,PROPERTY2,VALUE2,...)
% This function averages variables from the structure CAL and returns them
% in the structure AVG.  SERIES may be any of the CAL fieldnames (P,TP for
% example) or epsilon1 (from S1), epsilon2 (from S2) or chi1 (from
% TP or TP1 or T1P) or chiXXX (from XXX)
% and SERIES is a cell array (eg. series={'T1','EPSILON1','AX','UC'})
% The current properties and their defaults are:
% min_bin=0; % first depth or time bin
% max_bin=inf; % final depth or time bin
% binsize=1; % in m for P, or seconds for TIME, or whatever.
% depth_or_time='P' % this is the cal.?? series to be used for binning.
% nfft=256; % number of slow-sampled data points in each averaging interval
% whole_bins=0; % set to 1 for bins spaced at 1m, 2m instead of 0.5m, 1.5m etc.
% epsilon_glitch_factor=6; % the ratio of EPSILON1/EPSILON2 which, if
%                            exceeded, selects the smaller epsilon for avg.EPSILON
%
% Example:  avg=average_data({'T1','CHI1','EPSILON2'},'min_bin',15, ...
%          'depth_or_time','P2','nfft',128)
% 
% will average cal.T1, calculate chi_t from cal.T1, and calculate epsilon 
% from cal.S2 over the range 15m-bottom.  Spectra are calculated using
% 128*head.irep.SERIES points for each of the SERIES S1 and T1.  Each
% segment is overlapped by 50%.  The series cal.P2 is used for binning.  To
% use time for binning, run make_time_series and set the property 
% 'depth_or_time' to 'time'.
%
% NOTE that 'FALLSPD' MUST preceed 'EPSILON' and 
% 'EPSILON?' must preceed 'CHI' calculations
%
% also note that there must be at least nfft/16 points in each bin.
%
% This script differs from average_data.m
% It uses calc_epsilon_filt_gen.m routine to calculate EPSILON
% for spiked shear data without losing variance
% The script calls set_filters_{preffix}.m file where all filters and coefficiants are
% defined.
%******************************************************************
% ********* AN EXAMPLE OF SET_FILTERS_hm00.M FILE **********************
%    % set_filters.m
%    % A suppliment file for average_data_gen.
%    % Here you can set filters that will be used to calculate
%    % EPSILON in calc_epsilon_filt_gen.m routine.
%    % In addition high and low frequency cutoff and high frequency 
%    % cutoff coefficient are defined here (see documentation to 
%    % calc_epsilon_filt_gen.m).
%    % Choice of filters and coefficients depends on cast number
%    % (it could be different for different tows)
%    % Note: variable q (for cast number) should be defined as GLOBAL
%    % in main script and in average_data_gen.m routine
%    %$$$$$$$$ DO NOT CHANGE THIS SECTION!! $$$$$$$$$$$$$$$$$$$$$
%    global q
%    clear filters;
%    % SET DEFAULTS
%    filters={};
%    k_start=2; % [cpm]
%    k_stop=90; % [cpm]
%    kstop_coef=0.5;
%    eps=eval(['avg.EPSILON' prb '(n)']);
%    %$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%   
%    %##### IN THIS SECTION YOU SET FILTERS AND COEFFICIENTS ####
%    %##### AS FUNCTION OF CAST NUMBER ##########################
%    % Filters set according to EPSILON estimation (variable eps)
%    % EPSILON estimated in average_data_gen script before applying filters
%    % Filters could be different for diferent probes (variable prb)
%    % and could depend on ADP (variable cal.FLAG, cal.FLAG(:)=1 when 
%    % ADP is ON)
%    cast=q.script.num;
%    k_start=1; % [cpm]
%    if cast>=194 & cast<=407 
%        if eps<3e-8 % filters set according to EPSILON estimation
%            if cal.FLAG(1)==1 % cal.FLAG=1 when ADP was turned ON
%                              % filters depend on ADP
%                if prb==1 | prb==2 % prb is the probe number. Filters could
%                                   % be different for different probes
%                    filters={'n2.4-6.8','l12'};
%                else
%                    filters={'n3-8','l12'};
%                end
%            else % ADP turned OFF
%                if prb==1 | prb==2 
%                    filters={'n2.4-6.8','n12-18','n27-32'};
%                else
%                    filters={'n3-8','n12-18','n27-32'};
%                end
%            end
%        elseif eps<8e-8
%            if prb==1 | prb==2
%                filters={'n2.4-6.8'};
%            else
%                filters={'n3-8'};
%            end
%        end
%    elseif cast>=417 & cast<=592
%        % TOW #2
%        if eps<3e-8 % filters set according to EPSILON estimation
%            if cal.FLAG(1)==1
%                filters={'l11'};
%            else % ADP turned OFF
%                filters={'n11-21','n26.6-32.5'};
%            end
%        elseif eps<8e-8
%            filters={'n11-21','n26.5-32.5'};
%        end
%    end
%****** END OF EXAMPLE *************************************************
%***********************************************************************
min_bin=0; % first depth bin
max_bin=inf; % final depth bin 
depth_or_time='P'; % this is the cal.?? series to be used for binning.
whole_bins=0; % set to 1 for bins spaced at 1m, 2m instead of 0.5m, 1.5m etc.
binsize=1; % in m
nfft=256; % number of slow-sampled data points for an epsilon calculation
epsilon_glitch_factor=6; % the ratio of EPSILON1/EPSILON2 which, if
%                          % exceeded, selects the smaller epsilon for avg.EPSILON
% overlap=128; % desired number of points to overlap

global head cal q

% Redefine any of the above defaults if they have been specified:
a=length(varargin)/2;
if a~=floor(a)
  error('must have matching number of property-pairs')
  return
end
for i=1:2:a*2
  tmp=varargin(i+1);
  if strcmp(lower(char(varargin(i))),'depth_or_time')
    eval(['depth_or_time=''' char(tmp) ''';' ])
  else
    eval([lower(char(varargin(i))) '=' num2str(tmp{:}) ';' ])
  end
end

% set the series for binning:  
eval(['binseries=cal.' upper(depth_or_time) ';'])

eval(['series={''' depth_or_time ''' series{:}};'])
% now do the averaging:
firstbin=binsize*max(floor(min(binseries)/binsize),min_bin/binsize)+(whole_bins~=0)*binsize/2;
lastbin=binsize*min(ceil(max(binseries)/binsize),max_bin/binsize)-(whole_bins~=0)*binsize/2;

avail_series=fieldnames(cal);
n=0;
for pressure=firstbin:binsize:(lastbin-binsize)
  
  temp=find(binseries>pressure & binseries<(pressure+binsize));
  n=n+1;
  if ~isempty(temp)
     min_ind(n)=temp(1);
     max_ind(n)=temp(length(temp));
     % the following makes it so that data is not given if there are less than
     % nfft/16 data points in the series
     n=n-((max_ind(n)-min_ind(n))<(nfft/16));
  else
     n=n-1;
  end
end
nmax=n;
for i=1:length(series)
    active=upper(char(series(i)));
    if strncmp(active,'EPSILON',7) | strncmp(active,'CHI',3) 
        if head.direction~='d'
            if strncmp(active,'EPSILON',7) 
                if length(active)>7
                    prb=active(8:length(active));
                else
                    prb='1';
                end
                eval(['avg.EPSILON' prb '(1:nmax)=NaN;']);
                avg.EPSILON(1:nmax)=NaN;
            elseif strncmp(active,'CHI',3)
                avg.CHI(1:nmax)=NaN;
            end
        else
            if exist('avg','var')
                tmp=fieldnames(avg);
                if any(strcmp((tmp),'T'))
                    temp=avg.T;
                elseif any(strcmp((tmp),'T1'))
                    temp=avg.T1;
                elseif any(strcmp((tmp),'T2'))
                    temp=avg.T2;
                elseif any(strcmp((tmp),'THETA'))
                    temp=avg.THETA;
                else
                    warning('Assuming T=10 deg C for viscosity')
                    temp=10*ones(size(min_ind));
                end
                if any(strcmp((tmp),'SAL'))
                    sal=avg.SAL;
                elseif any(strcmp((tmp),'S'))
                    sal=avg.S;
                else
                    warning('Assuming S=35 psu for viscosity calc')
                    sal=35*ones(size(min_ind));
                end    
                if any(strcmp((tmp),'P'))
                    pres=avg.P;
                elseif any(strcmp((tmp),'P1'))
                    pres=avg.P1;
                elseif any(strcmp((tmp),'P2'))
                    pres=avg.P2;
                else
                    warning('Assuming P=0 dBar for viscosity calc')
                    pres=zeros(size(min_ind));
                end    
            else
                warning('Assuming S=35 psu for viscosity calc')
                sal=35*ones(size(min_ind));
                warning('Assuming T=10 deg C for viscosity calc')
                temp=10*ones(size(min_ind));
                warning('Assuming P=0 dBar for viscosity calc')
                pres=zeros(size(min_ind));
            end
            if strncmp(active,'EPSILON',7)
                if length(active)>7
                    prb=active(8:length(active));
                else
                    prb='1';
                end
                for n=1:nmax
                    nu=sw_visc(sal(n),temp(n),pres(n));  
                    % 	  eval(['avg.EPSILON' prb '(n)=calc_epsilon(cal.S' prb '(1+(min_ind(n)-1)*head.irep.S' prb ...
                    % 										  ':max_ind(n)*head.irep.S' prb '),avg.FALLSPD(n),nfft,nu,' ...
                    % 								   'head.sensor_index.S' prb ');'])
                    %       
                    Sdata = getfield(cal,['S' prb]); 
                    sensorindex = getfield(head.sensor_index,['S' prb]);
                    irep = getfield(head.irep,['S' prb]);
                    samplerate = head.slow_samp_rate.*irep;
                    % cut-off and filter order for the anti-aliasing Butterworth
                    % filter.  Needed to correct shear spectrum.
                    filtord = 4;
                    fcutoff = head.filter_freq(sensorindex); 
                    fallspd = avg.FALLSPD(n);
                    sind = [1+(min_ind(n)-1)*irep:max_ind(n)*irep];
                    [f,ss] = calc_shearspec(Sdata(sind),samplerate,nfft,0.01*fallspd,filtord,fcutoff);
                    eval(['set_filters_' q.script.prefix]);
                    %variables FILTERS K_START,K_STOP,KSTOP_COEF that used in the next statement are calculated
                    %in set_filters script
                    if avg.FALLSPD(n)<200
                        eval(['avg.EPSILON' prb '(n)=calc_epsilon_filt1(ss,f,avg.FALLSPD(n),nfft,nu,' 'head.sensor_index.S' prb...
                            ',filters,k_start,k_stop,kstop_coef);'])
                    else
                        eval(['avg.EPSILON' prb '(n)=NaN;'])
                    end
                    %       eval(['avg.EPSILON' prb '(n)=calc_epsilon_filt_gen(cal.S' prb '(1+(min_ind(n)-1)*head.irep.S' prb ...
                    %                ':max_ind(n)*head.irep.S' prb '),avg.FALLSPD(n),nfft,nu,' 'head.sensor_index.S' prb...
                    %                ',filters,k_start,k_stop,kstop_coef);'])
                end
                
            elseif strncmp(active,'CHI',3)
                from=active(4:length(active));
                if isempty(from), from='1';,from1='';
                else from1=from;
                end
                % use the entire suffix if it is not a single number, otherwise
                if length(from)==1
                    if any(strcmp((avail_series),['T' from 'P']))
                        % use TXP if it is available
                        from=['T' from 'P'];
                    elseif any(strcmp((avail_series),['TP' from ]))
                        % use TPX if it is available
                        from=['TP' from ];
                    else
                        % use TP as a last resort
                        from='TP';
                    end
                end
                avg=select_epsilon(avg,epsilon_glitch_factor);
                for n=1:nmax
                    eval(['	avg.CHI' from1 '(n)=calc_chi(cal.' from '(1+(min_ind(n)-1)*head.irep.' from  ...
                            ':max_ind(n)*head.irep.' from '),avg.FALLSPD(n),avg.EPSILON(n),nfft,sw_visc(sal(n),temp(n),pres(n)),' ...
                            'sw_tdif(sal(n),temp(n),pres(n)),' ...
                            ' head.sensor_index.' from ');'])
                end
            end
        end
        
    else
        for n=1:nmax
            eval(['avg.' active '(n)=mean(cal.' active ...
                    '(1+(min_ind(n)-1)*head.irep.' active ...
                    ':max_ind(n)*head.irep.' active '));']);
        end
    end
end



function avg=select_epsilon(avg,epsilon_glitch_factor)
% function to select the smallest epsilon from two shear probes if one
% looks glitchy, otherwise use the average.
% Use S1 if only one shear probe is available.
% EPSILON is returned as avg.EPSILON  

  tmp=fieldnames(avg);
  	if any(strcmp(tmp,'EPSILON1')) & any(strcmp(tmp,'EPSILON2'))
	  avg.EPSILON=(avg.EPSILON1+avg.EPSILON2)/2;
	  % determine if EPSILON1>>>EPSILON2
	  a=find(avg.EPSILON1>epsilon_glitch_factor*avg.EPSILON2 | isnan(avg.EPSILON1));
	  avg.EPSILON(a)=avg.EPSILON2(a);
	  % determine if EPSILON2>>>EPSILON1
	  a=find(avg.EPSILON2>epsilon_glitch_factor*avg.EPSILON1 | isnan(avg.EPSILON2));
	  avg.EPSILON(a)=avg.EPSILON1(a);
	else
	  % if only one shear probe exists.
	  avg.EPSILON=avg.EPSILON1;
	end
