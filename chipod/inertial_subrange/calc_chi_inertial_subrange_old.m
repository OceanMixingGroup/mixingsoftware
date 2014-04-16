function [mod,obs]=calc_chi_inertial_subrange(ave,tstart,tfinish,dt,unit,depth,salinity,dpath,dpl,hpf_cutoff,sensors,signal)
% [mod,obs]=calc_chi_inertial_subrange(ave,ts,tf,dt,unit,depth,dpath,dpl,hpf_cutoff)
% ave - structure of 1 min means of chi1,chi2,eps1,eps2 computed from 
%     microstructure temperature measurements.
% ts - start time. Matlab time format.
% tf - end time
% dt - time interval (1 hour?)
% unit - unit number
% depth - deployment depth of the unit [m].
% dpath - data path to Chipod data. Data files should be in [dpath,'\data\',num2str(unit),'\']
% dpl - deployment name (string), i.e. 'eq08'
% hpf_cutoff - hpf filter cutoff in Hz. (0.04? Should be adjusted for every cruise!).
% sensors - sensor numbers for calculation
g=9.81;
Ct=0.4;
gamma=0.2;
niter=floor((tfinish-tstart)/dt);
obs.chi1=NaN*ones(1,niter);
obs.eps1=NaN*ones(1,niter);
obs.dT1dz=NaN*ones(1,niter);
obs.chi2=NaN*ones(1,niter);
obs.eps2=NaN*ones(1,niter);
obs.dT2dz=NaN*ones(1,niter);
mod.chi1=NaN*ones(1,niter);
mod.fval_chi1=NaN*ones(1,niter);
mod.eps1=NaN*ones(1,niter);
mod.chi2=NaN*ones(1,niter);
mod.fval_chi2=NaN*ones(1,niter);
mod.eps2=NaN*ones(1,niter);
mod.time=NaN*ones(1,niter);
iik=0;
warning off
for itime=1:niter
    disp([num2str(itime) ,'/',num2str(niter)])
    iik=iik+1;
    ts=tstart+(itime-1)*dt;
    tf=ts+dt;
    clear cal data head
    [cal,data,head]=get_chipod_cals(dpath,dpl,unit,ts,tf,depth,hpf_cutoff,time_offset);
    if ~isempty(cal)
        if length(cal.time)>8000
            dTdz=NaN*ones(1,fix(length(cal.time)/600)-1);
            nfft=min([2^17,length(cal.fspd)/2]);
            for sensor=sensors
                kk=0;
                dTdz0=NaN*ones(1,fix(length(cal.time)/600)-1);
                for ii=600:600:length(cal.time)-600;
                    kk=kk+1;
                    dTdz0(kk)=get_dTdz_byslope(cal.DEPTH,eval(['cal.T' num2str(sensor)]),cal.time,cal.time(ii-599),cal.time(ii+600));
                end
                dTdz_fast=interp1([7200:7200:length(cal.curspd)-7200],dTdz0,1:length(cal.curspd),'linear','extrap');
                wv=dTdz_fast.*cal.velz./cal.fspd;
                hpf=1/10;
                lpf=1;
                [b,a]=butter(2,2*hpf/head.samplerate(head.sensor_index.T1P),'high');
                wvf1=filtfilt(b,a,wv);
                [b,a]=butter(2,2*lpf/head.samplerate(head.sensor_index.T1P),'low');
                wvf=filtfilt(b,a,wvf1);
                if strcmpi(signal,'TP')
                    p=gappy_fast_cohere(eval(['cal.T' num2str(sensor) 'Px']),wvf,nfft,120,480);
                else
                    eval(['cal.T' num2str(sensor) '_fast=interp1(1:length(cal.time),cal.T' num2str(sensor) ',[1:length(cal.AX)]/12,''linear'',''extrap'');']);
                    p=gappy_fast_cohere(eval(['gradient(cal.T' num2str(sensor) '_fast,1/120)./cal.fspd']),wvf,nfft,120,480);
                end
                if isfield(p,'f')
                    f=p.f;
                    pow=abs((p.xx-abs(p.xy./p.yy).^2.*abs(p.yy)))';
                    [bin]=binavg(f,pow,0.05);
                    
                    indT=find(ave.time>ts & ave.time<tf);
                    dTdz_obs=eval(['ave.dT' num2str(sensor) 'dz(indT)']);
                    dTdz=nanmean(dTdz_obs);
                    alpha=sw_alpha(salinity,nanmean( eval(['ave.T' num2str(sensor) '(indT)'])),depth);
                    N2=g*alpha*dTdz;
                    eps=eval(['ave.eps' num2str(sensor) '(indT)']);
                    chi=eval(['ave.chi' num2str(sensor) '(indT)']);
                    eval(['obs.chi' num2str(sensor) '(iik)=nanmean(chi);']);
                    eval(['obs.eps' num2str(sensor) '(iik)=nanmean(eps);']);
                    eval(['obs.dT' num2str(sensor) 'dz(iik)=dTdz;']);
                    
                    chi_fit_1=1e-12;chi_fit_2=1e-4;
                    ic_f1=0.05;ic_f2=0.5;% the frequency subrange for inertial convective
                    [chi_fit,fval,exitflag,output] = fminbnd(@e_ic,chi_fit_1,chi_fit_2,optimset('TolX',1e-12,'Display',...
                        'off','MaxIter',100),bin.spc/2/pi,bin.frq,ic_f1,ic_f2,N2,dTdz,cal,gamma,Ct);
                   
                    if exitflag==1
                        P_ic=2*pi*chi_fit*Ct*(N2*chi_fit/2/gamma/dTdz^2)^(-1/3).*(2*pi.*bin.frq/nanmean(cal.fspd)).^(1/3)./nanmean(cal.fspd);
                        eval(['mod.chi' num2str(sensor) '(iik)=chi_fit;']);
                        eval(['mod.eps' num2str(sensor) '(iik)=N2*chi_fit/(2*gamma*dTdz^2);']);
                        eval(['mod.fval_chi' num2str(sensor) '(iik)=fval;']);
                        if ~isfield(mod,'P_ic1')
                            mod.P_ic1=NaN*ones(length(P_ic),niter);
                            mod.f1=NaN*ones(length(P_ic),niter);
                            mod.pp_coh1=NaN*ones(length(P_ic),niter);
                        end
                        if ~isfield(mod,'P_ic2')
                            mod.P_ic2=NaN*ones(length(P_ic),niter);
                            mod.f2=NaN*ones(length(P_ic),niter);
                            mod.pp_coh2=NaN*ones(length(P_ic),niter);
                        end
                        eval(['mod.P_ic' num2str(sensor) '(1:length(P_ic),iik)=P_ic;']);
                        eval(['mod.f' num2str(sensor) '(1:length(P_ic),iik)=bin.frq;']);
                        eval(['mod.pp_coh' num2str(sensor) '(1:length(P_ic),iik)=bin.spc/2/pi;']);
                    end
                end
            end
        end
    end
    mod.time(iik)=(tf+ts)/2;
end

