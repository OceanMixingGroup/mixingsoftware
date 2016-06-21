function run_calc_chipod_chi(dpath,outpath,dpl,unit,ts,tf,dt,depth,...
    hpf_cutoff,do_noise,salinity,bkgrnd_dTdz,bkgrnd_Nsq,time_offset,min_dTdz)
% 
% OLD:  function run_calc_chipod_chi(dpath,outpath,dpl,unit,ts,tf,dt,depth,...
%    hpf_cutoff,do_noise,salinity,use_n2,time_offset,min_dTdz)
% 
% NOW:   function run_calc_chipod_chi(dpath,outpath,dpl,unit,ts,tf,dt,depth,...
%     hpf_cutoff,do_noise,salinity,bkgrnd_dTdz,bkgrnd_Nsq,time_offset,min_dTdz)
%
% INPUT
% dpath - data directory, i.e. '~\ganges\data\chipod\[dpl]\' where
% dpl = name of the deployment i.e. 'tao11_140

% the directory dpath should contain the following directories/files:
%     /data/[unit]/raw_data_files
%     /mooring_data/mooring_[dpl].mat, with structure moor.XXX  
%     /transfer_fcn/transfer_functions.mat (if not there, defaults are used)
%     /noise_spec/noise_spec_chipod???_T?.mat (if not there, defaults are used)

% outpath - directory were processed files will be saved, ...
%     i.e. '~\ganges\data\chipod\[dpl]\'
% dpl - deployment ID (string), i.e. 'or07b'
% unit - input number, (integer) i.e. 305
% ts - start time, Matlab datenum format
% tf - finish time, Matlab datenum format
% dt - time increment in days (e.g., 2/24 for 2 hours). New file is
%     compiled for every dt days 
% depth - unit depth, it is used to get current data from correct ADCP bin
% hpf_cutoff - hpf filter cutoff in Hz. - optional, but should be adjusted  
%     for every cruise
% do_noise - a flag, which say whether noise filters applied (1 - apply the
%     filters, 0 - don't)
% salinity - salinity at the location to calculate alpha, nu & Kt
% bkgrnd_dTdz - either 0 or 1. If 0, use the local stratification measured
%     directly by the chipods. If 1, use the stratification from the mooring
% bkgrnd_Nsq - either 0 or 1. If 0, calculate the buoyancy frequency from
%     the local dTdz. If 1, use Nsq from the mooring (which should include
%     salinity.)
% time_offset - Chipod clock time offset from GMT, If GMT time is 2:00 and
% Chipod time is 1:00, time offset would be -3600
%
% avg and spectra are computed for 1 sec incriments
% min_dTdz is the minimum cutoff value of dTdz. For most chipod processing,
% this is set to 1e-3, but if this is NaNing out too much data, this
% parameter may need to be smaller.
%
%   $Revision: 1.23 $  $Date: 2013/11/07 23:34:18 $



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%% to switch this to a stand-alone .m file (for debugging) %%%%%
% clear all
% dpath='~/ganges/data/chipod/TAO11_140/';
% outpath='~/ganges/data/chipod/TAO11_140/Processed/chi_analysis_dTdz_N2_fromTAO/';
% dpl='tao11_140';
% unit = 312;
% ts = datenum(2011,10,17,0,0,0);
% tf = datenum(2012,4,11,2,0,1);
% % tf = datenum(2011,10,18,2,0,0);
% dt=2/24;
% depth = 29;
% hpf_cutoff=0.04;
% do_noise=0;
% salinity=35;
% use_n2=1;
% time_offset = 0;
% min_dTdz = 1e-3;

% %%%%%%%%%%%%%%%%%% end input
% % when switching back to a function remember to:
% % - uncomment lines 1 and 2
% % - uncomment nargin functions
% % - comment out input information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% nargins
% warning off
% if nargin<14
%     min_dTdz = 1e-3;
% end
% if nargin<13
%     time_offset=0;
% end
% if nargin<12
%     use_n2=0;
% end



%% basics

% define some constants
fmax=15;
gamma=0.2;
% nfft=64;
g=9.81;
analog_filter_order=4;
analog_filter_freq=50;
warning off

% make the folder in the save path
mkdir([outpath]);
mkdir([outpath filesep num2str(unit)]);

% look for transfer functions and if they're not there, use the default
if exist([dpath filesep 'transfer_fcn' filesep 'transfer_functions.mat'])
    load([dpath filesep 'transfer_fcn' filesep 'transfer_functions.mat'])
    trans_fcn=1;
    trans_fcn1=1;
    trans_fcn2=1;
else
    disp('Using default transfer function: filter order 2, cutoff frequency 32')
    trans_fcn=0;
    trans_fcn1=0;
    trans_fcn2=0;
    thermistor_filter_order=2;
    thermistor_cutoff_frequency=32;
end

% load noise limits for thermistors
if do_noise==1
    load([dpath 'noise_spec' filesep 'noise_spec_chipod',num2str(unit),'_T1']);noise1=noise;
    load([dpath 'noise_spec' filesep 'noise_spec_chipod',num2str(unit),'_T2']);noise2=noise;
end

%% loop through every time step

% niter is number of output files with length dt between ts and tf (so if
% dt is 2 hours and ts and tf are three months apart niter=(3months)(30days)(24/dt hours)
niter=floor((tf+1/24/3600-ts)/dt);
len_series=round(dt*86400); %seconds
for itime=1:niter
    tf=ts+dt;  % reset tf to be the time at end of this output file
    clear cal data head
    
    % load in the data from individual raw data files (calibrated and
    % converted from voltages to the real units in cal
    [cal,data,head]=get_chipod_cals_rama13(dpath,dpl,unit,ts,tf,depth,...
        hpf_cutoff,bkgrnd_dTdz,bkgrnd_Nsq,time_offset);
    
    % load in other raw files if needed to get files in the correct time
    % period between this output file's ts and tf
    while isempty(cal) && itime<=niter
        ts=ts+dt;tf=ts+dt;
        itime=itime+1;
        [cal,data,head]=get_chipod_cals_rama13(dpath,dpl,unit,ts,tf,depth,...
            hpf_cutoff,bkgrnd_dTdz,bkgrnd_Nsq,time_offset);
    end
    clear data avg
    
    % create time vector (even 1s spacing between ts and tf)
    avg.time=ts+1/86400:1/86400:tf;
    
    % predefine variables
    avg.fspd=NaN*ones(1,len_series);
    avg.mxfspd=NaN*ones(1,len_series);
    avg.mnfspd=NaN*ones(1,len_series);
    avg.curspd=NaN*ones(1,len_series);
    avg.velz=NaN*ones(1,len_series);
    avg.vely=NaN*ones(1,len_series);
    avg.velx=NaN*ones(1,len_series);
    avg.dispz=NaN*ones(1,len_series);
    avg.dispy=NaN*ones(1,len_series);
    avg.dispx=NaN*ones(1,len_series);
    avg.cur_u=NaN*ones(1,len_series);
    avg.cur_v=NaN*ones(1,len_series);
    avg.cur_x=NaN*ones(1,len_series);
    avg.cur_y=NaN*ones(1,len_series);
    avg.CMP=NaN*ones(1,len_series);
    avg.r1omega=NaN*ones(1,len_series);
    avg.pitch=NaN*ones(1,len_series);
    avg.roll=NaN*ones(1,len_series);
    avg.N2moor=NaN*ones(1,len_series);
    avg.dTdzmoor=NaN*ones(1,len_series);
    calfields=char(fieldnames(cal));
    
    % predefine variables which may or may not be included in this
    % deployment
    for jj=1:length(calfields)
        switch calfields(jj,1:8)
            case 'RX      '
                avg.velu=NaN*ones(1,len_series);
                avg.veln=NaN*ones(1,len_series);
                avg.vele=NaN*ones(1,len_series);
                avg.dispu=NaN*ones(1,len_series);
                avg.dispn=NaN*ones(1,len_series);
                avg.dispe=NaN*ones(1,len_series);
            case 'W1      '
                avg.r1omega_3P=NaN*ones(1,len_series);
                avg.fspd_3P=NaN*ones(1,len_series);
            case 'dTdz    '
                avg.dTdz=NaN*ones(1,len_series);
            case 'N2      '
                avg.N2=NaN*ones(1,len_series);                
        end
    end   
    if head.version==80
        avg.r1omega_3P=NaN*ones(1,len_series);
        avg.fspd_3P=NaN*ones(1,len_series);
    end
    
    % predefine more variables
    avg.P=NaN*ones(1,len_series);
    avg.dT1dz=NaN*ones(1,len_series);
    avg.T1=NaN*ones(1,len_series);
    avg.chi1=NaN*ones(1,len_series);
    avg.eps1=NaN*ones(1,len_series);
    avg.dT2dz=NaN*ones(1,len_series);
    avg.T2=NaN*ones(1,len_series);
    avg.chi2=NaN*ones(1,len_series);
    avg.eps2=NaN*ones(1,len_series);
    
    % loop through each 1s time step in avg...
    for ik=1:length(avg.time)
        
        % find the indices of cal that fall within a half second before and
        % after avg.time(ik)
        id=find(cal.time>=avg.time(ik)-0.5/86400 & cal.time<=avg.time(ik)+0.5/86400);
        
        % case with more than 5 data points within each second. If there
        % are fewer than 5 data points, that second of chipod data is left
        % as NaN.
        if length(id)>5
            
            % tstart is 1 min before avg.time(ik) and tend is 1min after
            % avg.time(ik) (for calculating dT/dz only)
            tstart = avg.time(ik)-60/24/3600;
            tend   = avg.time(ik)+60/24/3600;
            
            if any(head.version==[16 32 48 64])
                
                % indices of data collected at 120 Hz
                idfast=id(1)*12-11:id(end)*12;
                % indices of slow data
                idslow=floor(id(1)/10)+1:floor((1+id(end))/10);
                
                % find dTdz from the chipod temperatures
                avg.dT1dz(ik)=get_dTdz_byslope(cal.DEPTH,cal.T1,cal.time,tstart,tend);
                avg.dT2dz(ik)=get_dTdz_byslope(cal.DEPTH,cal.T2,cal.time,tstart,tend);
                
                % find the means of all fields as defined by index id or idslow
                avg.T1(ik)=nanmean(cal.T1(id));
                avg.T2(ik)=nanmean(cal.T2(id));
                avg.P(ik)=nanmean(cal.P(id));
                avg.CMP(ik)=nanmean(cal.CMP(idslow));
                avg.curspd(ik)=nanmean(cal.curspd(idfast));
                avg.velz(ik)=nanmean(cal.velz(idfast));
                avg.vely(ik)=nanmean(cal.vely(idfast));
                avg.velx(ik)=nanmean(cal.velx(idfast));
                avg.dispz(ik)=nanmean(cal.dispz(idfast));
                avg.dispy(ik)=nanmean(cal.dispy(idfast));
                avg.dispx(ik)=nanmean(cal.dispx(idfast));
                avg.fspd(ik)=nanmean(cal.fspd(idfast));
                avg.mnfspd(ik)=nanmin(cal.fspd(idfast));
                avg.mxfspd(ik)=nanmax(cal.fspd(idfast));
                avg.cur_u(ik)=nanmean(cal.cur_u(idfast));
                avg.cur_v(ik)=nanmean(cal.cur_v(idfast));
                avg.cur_x(ik)=nanmean(cal.cur_x(idfast));
                avg.cur_y(ik)=nanmean(cal.cur_y(idfast));
                avg.pitch(ik)=nanmean(cal.pitch(idfast));
                avg.roll(ik)=nanmean(cal.roll(idfast));
                avg.dTdzmoor(ik)=nanmean(cal.dTdzmoor(idfast));
                avg.N2moor(ik)=nanmean(cal.N2moor(idfast));
                for jj=1:length(calfields)
                    switch calfields(jj,1:8)
                        case 'RX      '
                            avg.r1omega(ik)=nanmean(cal.r1omega(idfast));
                            avg.velu(ik)=nanmean(cal.velu(idfast));
                            avg.veln(ik)=nanmean(cal.veln(idfast));
                            avg.vele(ik)=nanmean(cal.vele(idfast));
                            avg.dispu(ik)=nanmean(cal.dispu(idfast));
                            avg.dispn(ik)=nanmean(cal.dispn(idfast));
                            avg.dispe(ik)=nanmean(cal.dispe(idfast));
                        case 'W1      '
                            avg.fspd_3P(ik)=nanmean(cal.fspd_3P(idfast));
                            avg.r1omega_3P(ik)=nanmean(cal.r1omega_3P(idfast));
                        case 'dTdz    '
                            avg.dTdz(ik)=nanmean(cal.dTdz(idfast));
                        case 'N2      '
                            avg.N2(ik)=nanmean(cal.N2(idfast));
                    end
                end
                
            % case with different header versions  (timing indices have to 
            % be calculated differently than above). Find means, etc.
            % header version 80 (RAMA13, etc) is covered by this else statement
            else
                % calculate time index
                idfast=id;
                id=floor(idfast(1)/head.oversample(head.sensor_index.T1))+1:...
                    floor((1+idfast(end))/head.oversample(head.sensor_index.T1));
                
                idslow=floor(idfast(1)/head.oversample(head.sensor_index.CMP))+1:...
                    floor((1+idfast(end))/head.oversample(head.sensor_index.CMP));
                
                % calculate dT/dz from chipod temperature
                avg.dT1dz(ik)=get_dTdz_byslope(cal.DEPTH,cal.T1,cal.time_acc,tstart,tend);
                avg.dT2dz(ik)=get_dTdz_byslope(cal.DEPTH,cal.T2,cal.time_acc,tstart,tend);
                
                % find means within timesteps defined by id and idslow
                avg.T1(ik)=nanmean(cal.T1(id));
                avg.T2(ik)=nanmean(cal.T2(id));
                if head.samplerate(head.sensor_index.P)==50
                    avg.P(ik)=nanmean(cal.P(id));
                elseif head.samplerate(head.sensor_index.P)==5
                    avg.P(ik)=nanmean(cal.P(idslow));
                end
                avg.CMP(ik)=nanmean(cal.CMP(idslow));
                avg.curspd(ik)=nanmean(cal.curspd(id));
                avg.velz(ik)=nanmean(cal.velz(id));
                avg.vely(ik)=nanmean(cal.vely(id));
                avg.velx(ik)=nanmean(cal.velx(id));
                avg.dispz(ik)=nanmean(cal.dispz(id));
                avg.dispy(ik)=nanmean(cal.dispy(id));
                avg.dispx(ik)=nanmean(cal.dispx(id));
                avg.fspd(ik)=nanmean(cal.fspd(id));
                avg.mnfspd(ik)=nanmin(cal.fspd(id));
                avg.mxfspd(ik)=nanmax(cal.fspd(id));
                if isfield(cal,'W1')
                    avg.fspd_3P(ik)=nanmean(cal.fspd_3P(id));
                    avg.r1omega_3P(ik)=nanmean(cal.r1omega_3P(id));
                end
                avg.cur_u(ik)=nanmean(cal.cur_u(id));
                avg.cur_v(ik)=nanmean(cal.cur_v(id));
                avg.cur_x(ik)=nanmean(cal.cur_x(id));
                avg.cur_y(ik)=nanmean(cal.cur_y(id));
                avg.pitch(ik)=nanmean(cal.pitch(id));
                avg.roll(ik)=nanmean(cal.roll(id));
                avg.dTdzmoor(ik)=nanmean(cal.dTdzmoor(id));
                avg.N2moor(ik)=nanmean(cal.N2moor(id));
                for jj=1:length(calfields)
                    switch calfields(jj,1:8)
                        case 'RX      '
                            avg.r1omega(ik)=nanmean(cal.r1omega(id));
                            avg.velu(ik)=nanmean(cal.velu(id));
                            avg.veln(ik)=nanmean(cal.veln(id));
                            avg.vele(ik)=nanmean(cal.vele(id));
                            avg.dispu(ik)=nanmean(cal.dispu(id));
                            avg.dispn(ik)=nanmean(cal.dispn(id));
                            avg.dispe(ik)=nanmean(cal.dispe(id));
                        case 'dTdz    '
                            avg.dTdz(ik)=nanmean(cal.dTdz(id));
                        case 'N2      '
                            avg.N2(ik)=nanmean(cal.N2(id));
                    end
                end
            end
            %(end of averaging)
            
            
            
            % calculate viscosity and diffusivity
            nu1=sw_visc(salinity,avg.T1(ik),depth);
            nu2=sw_visc(salinity,avg.T2(ik),depth);
            tdif1=sw_tdif(salinity,avg.T1(ik),depth);
            tdif2=sw_tdif(salinity,avg.T2(ik),depth);
            
            % calculate two values of alpha in case one of termistors was bad
            alpha1=sw_alpha(salinity,avg.T1(ik),depth);
            alpha2=sw_alpha(salinity,avg.T2(ik),depth);
            
            % Rename N2 and dTdz if they exist. They exist when use_n2 = 1,
            % otherwise the local stratification will be used below
            if bkgrnd_dTdz == 1
                dTdz=avg.dTdz(ik);
            end
            if bkgrnd_Nsq == 1
                Nsqr=avg.N2(ik);
            end
%             if isfield(avg,'N2')
%                 Nsqr=avg.N2(ik);
%             end
%             if isfield(avg,'dTdz')
%                 dTdz=avg.dTdz(ik);
%             end
                
            % get the right samplerate 
            samplerate=head.samplerate(head.sensor_index.T1P);
            nfft=samplerate/2;
            
            %%%%%%%%%%%%%%%%%%%%%% chi1 %%%%%%%%%%%%%%%%%%%%%%
            
            % if dTdz from TAO mooring is not included, use the local dTdz
            % from the T1 thermistor
            if bkgrnd_dTdz == 0
%                 disp('using local dTdz')
                dTdz=avg.dT1dz(ik);
            end
            if bkgrnd_Nsq == 0
%                 disp('calculating Nsq from dTdz')
                Nsqr = g*alpha1*dTdz;
                % avg.NTsq1(ik) = Nsqr; % need to pre-define this variable
                % and add it to chi2.
               
            end
            
            % check if there is a transfer function to be used.
            if sum([trans_fcn,trans_fcn1])
                % if the transfer function exists, find the values for a
                % given instrument
                try
                    if strcmpi(head.sensor_id(head.sensor_index.T1,5),'P')
                        thermistor_filter_order=transfer.filter_ord.(['p',...
                            head.sensor_id(head.sensor_index.T1,1:5)]);
                        thermistor_cutoff_frequency=transfer.filter_freq.(['p',...
                            head.sensor_id(head.sensor_index.T1,1:5)]);
                    else
                        thermistor_filter_order=transfer.filter_ord.(['p',...
                            head.sensor_id(head.sensor_index.T1,1:4)]);
                        thermistor_cutoff_frequency=transfer.filter_freq.(['p',...
                            head.sensor_id(head.sensor_index.T1,1:4)]);
                    end
                % if there isn't a value of the transfer function for a 
                % given instrument, use the default values    
                catch
                    disp('Transfer function not found.')
                    disp('Use default: filter order 2, cutoff frequency 32')
                    trans_fcn=0;
                    trans_fcn1=0;
                    thermistor_filter_order=2;
                    thermistor_cutoff_frequency=32;
                end  
            % if no transfer function defined, use default values 
            else
                thermistor_filter_order=2;
                thermistor_cutoff_frequency=32;
            end
            
            % determine that dTdz is larger than the minium acceptible value, 
            % and that alpha and fspd are within acceptible ranges. If they
            % are not, chi1 is left as NaN.
            % want this to be abs(dTdz) because it's okay to be negative in
            % cases where Nsq is positive because it is compensated by salinity
            if avg.fspd(ik) >= 0.04 && alpha1>0 && abs(dTdz)>min_dTdz

                % calculate psd of dT/dt (apply a correction if coef is ~=0)
                if head.coef.T1P(3)~=0
                    [tp_power,freq]=fast_psd(cal.T1Pt(idfast),nfft,samplerate);
                    tp_power=tp_power./(10.^(head.coef.T1P(3).*log10(freq)+head.coef.T1P(4)));
                else
                    [tp_power,freq]=fast_psd(cal.T1Pt(idfast),nfft,samplerate);
                end
                % And corrected as:
                tp_power=invert_filt(freq,invert_filt(freq,tp_power,thermistor_filter_order, ...
                    thermistor_cutoff_frequency),analog_filter_order,analog_filter_freq);
                                
                % test to make sure above noise level - otherwise set to NaN
                if do_noise==1
                    idtst=find(tp_power<=20.*noise1.spec');
                    if numel(idtst)~=0
                        tp_power(idtst(1):end)=NaN;
                    end
                end
%                 this ought to be resurrectd when cal =3P works and we use
%                 pitot to get fspd
%                 % compute fspd
%                 if (~all(isnan(cal.CMP)) && isfield(cal,'W1')) || ...
%                         (~all(isnan(cal.CMP)) && head.version==80)
%                     fspd=avg.fspd_3P(ik);
%                 else
%                     fspd=avg.fspd(ik);
%                 end
                
                % calculate chi!!!
%                 if ~exist('Nsqr','var')
%                     [chi,epsil,k,spec,k_kraich,spec_kraich,stats]=...
%                         get_chipod_chi(freq,tp_power,avg.fspd(ik),nu1,tdif1,dTdz,...
%                         'alpha',alpha1,'fmax',fmax,'gamma',gamma,'doplots',0);
%                 else
                    [chi,epsil,k,spec,k_kraich,spec_kraich,stats]=...
                        get_chipod_chi(freq,tp_power,avg.fspd(ik),nu1,tdif1,dTdz,...
                        'nsqr',Nsqr,'fmax',fmax,'gamma',gamma,'doplots',0); 
%                 end
                avg.chi1(ik)=chi(1);avg.eps1(ik)=epsil(1);
                        
            end
            %%%%%%%%%%%%%%%%%%%%%% END chi1 %%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%% chi2 %%%%%%%%%%%%%%%%%%%%%%
            % (same comments as for chi1)
%             if ~isfield(avg,'dTdz')
%                 dTdz=avg.dT2dz(ik);
%             end
            if bkgrnd_dTdz == 0
%                 disp('using local dTdz')
                dTdz=avg.dT2dz(ik);
            end
            if bkgrnd_Nsq == 0
%                 disp('calculating Nsq from dTdz')
                Nsqr = g*alpha2*dTdz;
            end
            if sum([trans_fcn,trans_fcn2])
                try
                    if strcmpi(head.sensor_id(head.sensor_index.T2,5),'P')
                        thermistor_filter_order=transfer.filter_ord.(['p',...
                            head.sensor_id(head.sensor_index.T2,1:5)]);
                        thermistor_cutoff_frequency=transfer.filter_freq.(['p',...
                            head.sensor_id(head.sensor_index.T2,1:5)]);
                    else
                        thermistor_filter_order=transfer.filter_ord.(['p',...
                            head.sensor_id(head.sensor_index.T2,1:4)]);
                        thermistor_cutoff_frequency=transfer.filter_freq.(['p',...
                            head.sensor_id(head.sensor_index.T2,1:4)]);
                    end
                catch
                    disp('Transfer function not found.')
                    disp('Use default: filter order 2, cutoff frequency 32')
                    trans_fcn=0;
                    trans_fcn2=0;
                    thermistor_filter_order=2;
                    thermistor_cutoff_frequency=32;
                end
            else
                thermistor_filter_order=2;
                thermistor_cutoff_frequency=32;
            end
            if avg.fspd(ik) >= 0.04 && alpha2>0 && abs(dTdz)>min_dTdz % want this to be abs(dTdz) because it's okay to be negative
                if head.coef.T2P(3)~=0
                    [tp_power,freq]=fast_psd(cal.T2Pt(idfast),nfft,samplerate);%psd of dT/dt
                    tp_power=tp_power./(10.^(head.coef.T2P(3).*log10(freq)+head.coef.T2P(4)));
                else
                    [tp_power,freq]=fast_psd(cal.T2Pt(idfast),nfft,samplerate);%psd of dT/dt
                end
                % And corrected as:
                tp_power=invert_filt(freq,invert_filt(freq,tp_power,thermistor_filter_order, ...
                    thermistor_cutoff_frequency),analog_filter_order,analog_filter_freq);
                if do_noise==1
                    % test to make sure above noise level - otherwise set to NaN
                    idtst=find(tp_power<=20.*noise2.spec');
                    if numel(idtst)~=0
                        tp_power(idtst(1):end)=NaN;
                    end
                end
                % compute chi
%                 if ~exist('Nsqr','var')
%                     [chi,epsil,k,spec,k_kraich,spec_kraich,stats]=...
%                         get_chipod_chi(freq,tp_power,avg.fspd(ik),nu2,tdif2,dTdz,...
%                         'alpha',alpha2,'fmax',fmax,'gamma',gamma,'doplots',0);
%                 else
                    [chi,epsil,k,spec,k_kraich,spec_kraich,stats]=...
                        get_chipod_chi(freq,tp_power,avg.fspd(ik),nu2,tdif2,dTdz,...
                        'nsqr',Nsqr,'fmax',fmax,'gamma',gamma,'doplots',0);
%                 end
                avg.chi2(ik)=chi(1);avg.eps2(ik)=epsil(1);

            end
            %%%%%%%%%%%%%%%%%%%%%% END chi2 %%%%%%%%%%%%%%%%%%%%%%
            
            
            % print time step, dT/dz, chi1 and chi2 to screen every minute
            if round((ik-1)/60)==(ik-1)/60
                disp([datestr(avg.time(ik)),...
                    ', dT/dz=' num2str(dTdz)...
                    ', Nsq=' num2str(Nsqr)...
                    ', chi1=' num2str(avg.chi1(ik))...
                    ', chi2=' num2str(avg.chi2(ik))])
            end
        end
    end
    
    % create the file name
    fs=datestr(ts,30);
    
    % calculate average frequency
    if exist('freq','var')
        avg.freq=freq;
    else
        avg.freq=NaN*ones(1,nfft/2);
    end
    
    % make readme file
    avg.readme=strvcat('made with run_calc_chipod_chi.m');
    
    % fix imagenary NaNs
    avg.chi1(isnan(avg.chi1))=NaN;
    avg.chi2(isnan(avg.chi2))=NaN;
    avg.eps1(isnan(avg.eps1))=NaN;
    avg.eps2(isnan(avg.eps2))=NaN;
    
    % add depth to avg
    avg.depth = sw_dpth(avg.P,0);
    
    % display the output file name and save
    disp(fs);
    save([outpath filesep num2str(unit) filesep 'avg_chi_' fs],'avg')
    
    % step the time forward
    ts=ts+dt;
end