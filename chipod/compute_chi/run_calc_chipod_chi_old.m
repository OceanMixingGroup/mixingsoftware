function run_calc_chipod_chi(dpath,outpath,dpl,unit,ts,tf,dt,depth,hpf_cutoff,do_noise,salinity)
% function run_calc_chipod_chi(dpl,unit,ts,dt,depth)
% dpath - data directory, i.e. '\\mserver\data\chipod\tao_sep05\'
% this directory should contain the following directories/files:
% /data/[unit]/raw_data_files
% /current_data/current.mat with structure cur.XXX inside
% /noise_spec/noise_spec_chipod???_T?.mat
% /transfer_fcn/transfer_functions.mat
% outpath - directory were processed files will be saved, i.e. '\\mserver\analysis\chipod\tao_sep05\'
% dpl - deployment name (string), i.e. 'or07b'
% unit - input number, (integer) i.e. 305
% ts - start time, Matlab format
% tf - finish time, Matlab format
% dt - time increment in days (e.g., 2/24 for 2 hours). New file is
%      compiled for every dt days 
% depth - unit depth, it is used to get current data from correct ADCP bin
% hpf_cutoff - hpf filter cutoff in Hz. - optional, but should be adjusted  
% for every cruise!!!
% do_noise - a flag, which say whether noise filters applied (1 - aplly the
% filters, 0 - not)
% salinity - salinity at the location to calculate alpha, nu & Kt
% avg and spectra are computed for 1 sec incriments
%   $Revision: 1.11 $  $Date: 2010/06/04 18:10:31 $
warning off
fmax=15;
gamma=0.2;
nfft=64;
g=9.81;
analog_filter_order=4;
analog_filter_freq=50;
warning off
mkdir([outpath]);
mkdir([outpath '\' num2str(unit)]);
% load transfer function for thermistor
if exist([dpath '\transfer_fcn\transfer_functions.mat'])
    load([dpath '\transfer_fcn\transfer_functions.mat'])
    trans_fcn=1;
    trans_fcn1=1;
    trans_fcn2=1;
else
    disp('Transfer function not found.')
    disp('Use default: filter order 2, cutoff frequency 32')
    trans_fcn=0;
    trans_fcn1=0;
    trans_fcn2=0;
    thermistor_filter_order=2;
    thermistor_cutoff_frequency=32;
end
% load noise limits for thermistors
if do_noise==1
    load([dpath 'noise_spec\noise_spec_chipod',num2str(unit),'_T1']);noise1=noise;
    load([dpath 'noise_spec\noise_spec_chipod',num2str(unit),'_T2']);noise2=noise;
end
niter=floor((tf+1/24/3600-ts)/dt);
for itime=1:niter
    tf=ts+dt;
    clear cal data head
    [cal,data,head]=get_chipod_cals(dpath,dpl,unit,ts,tf,depth,hpf_cutoff);
    while isempty(cal) && itime<=niter
        ts=ts+dt;tf=ts+dt;
        itime=itime+1;
        [cal,data,head]=get_chipod_cals(dpath,dpl,unit,ts,tf,depth,hpf_cutoff);
    end
    clear data avg
    len_series=length(cal.time_fast)/120;
    avg.time=NaN*ones(1,len_series);
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
    if isfield(cal,'RX')
        avg.velu=NaN*ones(1,len_series);
        avg.veln=NaN*ones(1,len_series);
        avg.vele=NaN*ones(1,len_series);
        avg.dispu=NaN*ones(1,len_series);
        avg.dispn=NaN*ones(1,len_series);
        avg.dispe=NaN*ones(1,len_series);
    end
    if isfield(cal,'W1')
        avg.r1omega_3P=NaN*ones(1,len_series);
        avg.fspd_3P=NaN*ones(1,len_series);
    end
    avg.P=NaN*ones(1,len_series);
    avg.dT1dz=NaN*ones(1,len_series);
    avg.T1=NaN*ones(1,len_series);
    avg.chi1=NaN*ones(1,len_series);
    avg.eps1=NaN*ones(1,len_series);
%     avg.k1=NaN*ones(nfft/2,len_series);
%     avg.spec1=NaN*ones(nfft/2,len_series);
%     avg.f_start1=NaN*ones(1,len_series);
%     avg.f_stop1=NaN*ones(1,len_series);  
%     avg.k_start1=NaN*ones(1,len_series);
%     avg.k_stop1=NaN*ones(1,len_series);  
%     avg.nfreqs1=NaN*ones(1,len_series);  
    avg.dT2dz=NaN*ones(1,len_series);
    avg.T2=NaN*ones(1,len_series);
    avg.chi2=NaN*ones(1,len_series);
    avg.eps2=NaN*ones(1,len_series);
%     avg.k2=NaN*ones(nfft/2,len_series);
%     avg.spec2=NaN*ones(nfft/2,len_series);
%     avg.f_start2=NaN*ones(1,len_series);
%     avg.f_stop2=NaN*ones(1,len_series);  
%     avg.k_start2=NaN*ones(1,len_series);
%     avg.k_stop2=NaN*ones(1,len_series);  
%     avg.nfreqs2=NaN*ones(1,len_series);  
    thestep=120;
    ik=0;
    for i=1:thestep:length(cal.T1Pt)%1:thestep:(length(cal.T1Pt)-thestep)
        ik=ik+1;
        idfast=i+[0:(thestep-1)];
        id=1+(i-1)/12+[0:(thestep-1)/12];
        idslow=1+(i-1)/120+[0:(thestep-1)/120];
        avg.time(ik)=nanmean(cal.time(id));
        avg.P(ik)=nanmean(cal.P(id));
        avg.T1(ik)=nanmean(cal.T1(id));
        avg.T2(ik)=nanmean(cal.T2(id));
        tstart=avg.time(ik)-60/24/3600;tend=avg.time(ik)+60/24/3600;
        avg.dT1dz(ik)=get_dTdz_byslope(cal.DEPTH,cal.T1,cal.time,tstart,tend);
        avg.dT2dz(ik)=get_dTdz_byslope(cal.DEPTH,cal.T2,cal.time,tstart,tend);

        % we calculate two values of alpha in case one of termistors was bad
        nu1=sw_visc(salinity,avg.T1(ik),depth);
        nu2=sw_visc(salinity,avg.T2(ik),depth);
        tdif1=sw_tdif(salinity,avg.T1(ik),depth);
        tdif2=sw_tdif(salinity,avg.T2(ik),depth);
        alpha1=sw_alpha(salinity,avg.T1(ik),depth);
        alpha2=sw_alpha(salinity,avg.T2(ik),depth);

        avg.curspd(ik)=nanmean(cal.curspd(idfast));
        avg.velz(ik)=nanmean(cal.velz(idfast));
        avg.vely(ik)=nanmean(cal.vely(idfast));
        avg.velx(ik)=nanmean(cal.velx(idfast));
        avg.dispz(ik)=nanmean(cal.dispz(idfast));
        avg.dispy(ik)=nanmean(cal.dispy(idfast));
        avg.dispx(ik)=nanmean(cal.dispx(idfast));
        avg.cur_u(ik)=nanmean(cal.cur_ufast(idfast));
        avg.cur_v(ik)=nanmean(cal.cur_vfast(idfast));
        avg.fspd(ik)=nanmean(cal.fspd(idfast));        
        avg.mnfspd(ik)=nanmin(cal.fspd(idfast));
        avg.mxfspd(ik)=nanmax(cal.fspd(idfast));
        if ~all(isnan(cal.CMP))
            avg.CMP(ik)=nanmean(cal.CMP(idslow));
            avg.cur_x(ik)=nanmean(cal.cur_xfast(idfast));
            avg.cur_y(ik)=nanmean(cal.cur_yfast(idfast));
            if isfield(cal,'W1')
                avg.fspd_3P(ik)=nanmean(cal.fspd_3P(idfast));        
            end    
        else
            avg.cur_x(ik)=NaN;
            avg.cur_y(ik)=NaN;
        end
        if isfield(cal,'RX')
            avg.r1omega(ik)=nanmean(cal.r1omega(idfast));
            avg.velu(ik)=nanmean(cal.velu(idfast));
            avg.veln(ik)=nanmean(cal.veln(idfast));
            avg.vele(ik)=nanmean(cal.vele(idfast));
            avg.dispu(ik)=nanmean(cal.dispu(idfast));
            avg.dispn(ik)=nanmean(cal.dispn(idfast));
            avg.dispe(ik)=nanmean(cal.dispe(idfast));
        end
       
        % chi1
        dTdz=avg.dT1dz(ik);
        if sum([trans_fcn,trans_fcn1])
            try
                if strcmpi(head.sensor_id(head.sensor_index.T1,5),'P')
                    thermistor_filter_order=transfer.filter_ord.(['p',head.sensor_id(head.sensor_index.T1,1:5)]);
                    thermistor_cutoff_frequency=transfer.filter_freq.(['p',head.sensor_id(head.sensor_index.T1,1:5)]);
                else
                    thermistor_filter_order=transfer.filter_ord.(['p',head.sensor_id(head.sensor_index.T1,1:4)]);
                    thermistor_cutoff_frequency=transfer.filter_freq.(['p',head.sensor_id(head.sensor_index.T1,1:4)]);
                end
            catch
                disp('Transfer function not found.')
                disp('Use default: filter order 2, cutoff frequency 32')
                trans_fcn=0;
                trans_fcn1=0;
                thermistor_filter_order=2;
                thermistor_cutoff_frequency=32;
            end
        else
            thermistor_filter_order=2;
            thermistor_cutoff_frequency=32;
        end
        if avg.fspd(ik) >= 0.04 && alpha1>0 && dTdz>1e-3          
            samplerate=head.samplerate(head.sensor_index.T1P);
            if head.coef.T1P(3)~=0
                [tp_power,freq]=fast_psd(cal.T1Pt(idfast),nfft,samplerate);%psd of dT/dt
                tp_power=tp_power./(10.^(head.coef.T1P(3).*log10(freq)+head.coef.T1P(4)));
            else
                [tp_power,freq]=fast_psd(cal.T1Pt(idfast),nfft,samplerate);%psd of dT/dt
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
            % compute chi
            if ~all(isnan(cal.CMP)) && isfield(cal,'W1')
                fspd=avg.fspd_3P(ik);
            else
                fspd=avg.fspd(ik);
            end
            [chi,epsil,k,spec,k_kraich,spec_kraich,stats]=get_chipod_chi(freq,tp_power,fspd,nu1,tdif1,dTdz,...
                'alpha',alpha1,'fmax',fmax,'gamma',gamma,'doplots',0);
            avg.chi1(ik)=chi(1);avg.eps1(ik)=epsil(1);
%             avg.k1(:,ik)=k;avg.spec1(:,ik)=spec;
%             avg.f_start1(ik)=stats.f_start;avg.f_stop1(ik)=stats.f_stop;  
%             avg.k_start1(ik)=stats.k_start;avg.k_stop1(ik)=stats.k_stop;  
%             avg.nfreqs1(ik)=stats.n_freq;      
        end
        % chi2
        dTdz=avg.dT2dz(ik);
        if sum([trans_fcn,trans_fcn2])
            try
                if strcmpi(head.sensor_id(head.sensor_index.T2,5),'P')
                    thermistor_filter_order=transfer.filter_ord.(['p',head.sensor_id(head.sensor_index.T2,1:5)]);
                    thermistor_cutoff_frequency=transfer.filter_freq.(['p',head.sensor_id(head.sensor_index.T2,1:5)]);
                else
                    thermistor_filter_order=transfer.filter_ord.(['p',head.sensor_id(head.sensor_index.T2,1:4)]);
                    thermistor_cutoff_frequency=transfer.filter_freq.(['p',head.sensor_id(head.sensor_index.T2,1:4)]);
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
        if avg.fspd(ik) >= 0.04 && alpha2>0 && dTdz>1e-3
            samplerate=head.samplerate(head.sensor_index.T2P);
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
            [chi,epsil,k,spec,k_kraich,spec_kraich,stats]=get_chipod_chi(freq,tp_power,avg.fspd(ik),nu2,tdif2,dTdz,...
                'alpha',alpha2,'fmax',fmax,'gamma',gamma,'doplots',0);
            avg.chi2(ik)=chi(1);avg.eps2(ik)=epsil(1);
%             avg.k2(:,ik)=k;avg.spec2(:,ik)=spec;
%             avg.f_start2(ik)=stats.f_start;avg.f_stop2(ik)=stats.f_stop;  
%             avg.k_start2(ik)=stats.k_start;avg.k_stop2(ik)=stats.k_stop;  
%             avg.nfreqs2(ik)=stats.n_freq;  
        end
        if round((i-1)/12000)==(i-1)/12000
            disp([datestr(avg.time(ik)),', chi1=' num2str(avg.chi1(ik)) ', epsilon1=' num2str(avg.eps1(ik))])
        end
    end
    fs=datestr(ts,30);
    if exist('freq','var')
        avg.freq=freq;
    else
        avg.freq=NaN*ones(1,nfft/2);
    end
    avg.readme=strvcat('made with run_calc_chipod_chi.m');
    disp(fs);
    save([outpath '\' num2str(unit) '\avg_chi_' fs],'avg')
    ts=ts+dt;
end