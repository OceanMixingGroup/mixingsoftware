function [mod,obs]=calc_chi_inertial_subrange(ave,tstart,tfinish,dt,unit,depth,salinity,dpath,dpl,hpf_cutoff,sensors,time_offset)
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
if nargin<13
    time_offset=0;
end
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
        time_span=round((cal.time(end)-cal.time(1))*86400);% [s]
        if time_span>80
            dTdz=NaN*ones(1,fix(time_span/60)-1);
            nfft=min([2^17,length(cal.T1Px)/2]);
            for sensor=sensors
                kk=0;
                dTdz0=NaN*ones(1,fix(time_span/60)-1);
                dtime=60; % [s]
                spr=head.samplerate(head.sensor_index.T1P);
                spr2=head.samplerate(head.sensor_index.AX);
                for ii=dtime:dtime:time_span-dtime;
                    kk=kk+1;
                    if any(head.version==[16 32 48 64])
                        inst=max([ii*head.samplerate(head.sensor_index.T1)-dtime*head.samplerate(head.sensor_index.T1)+1,1]);
                        infn=min([ii*head.samplerate(head.sensor_index.T1)+dtime*head.samplerate(head.sensor_index.T1),length(cal.time)]);
                        dTdz0(kk)=get_dTdz_byslope(cal.DEPTH,eval(['cal.T' num2str(sensor)]),cal.time,cal.time(inst),cal.time(infn));
                    else
                        DEPTH=makelen2(cal.DEPTH,head.samplerate(head.sensor_index.T1)/head.samplerate(head.sensor_index.P));
                        dTdz0(kk)=get_dTdz_byslope(DEPTH,eval(['cal.T' num2str(sensor)]),cal.time_acc,...
                            cal.time(ii*spr-dtime*spr+1),...
                            cal.time(ii*spr+dtime*spr));
                    end
                end
                dTdz0=fillgap(dTdz0,1);
                dTdz_fast=interp1([dtime*spr2:dtime*spr:length(cal.T1Px)-dtime*spr+spr],...
                    dTdz0,1:length(cal.T1Px),'linear','extrap');
                fspd=makelen2(cal.fspd,spr/spr2);
                velz=makelen2(cal.velz,spr/spr2);
                wv=dTdz_fast.*velz./fspd;
                hpf=1/10;
                lpf=1;
                [b,a]=butter(2,2*hpf/spr,'high');
                wvf1=filtfilt(b,a,wv);
                [b,a]=butter(2,2*lpf/spr,'low');
                wvf=filtfilt(b,a,wvf1);
%                 if strcmpi(signal,'TP')
                    pTP=gappy_fast_cohere(eval(['cal.T' num2str(sensor) 'Px']),wvf,nfft,...
                        spr,4*spr);
%                 else
                    eval(['cal.T' num2str(sensor) '_fast=interp1(1:length(cal.T1),cal.T' num2str(sensor) ',[1:length(cal.T1Px)]/(length(cal.T1Px)/length(cal.T1)),''linear'',''extrap'');']);
                    if size(cal.time,2)==1;
                        eval(['cal.T' num2str(sensor) '_fast=cal.T' num2str(sensor) '_fast'';']);
                    end
                    pT=gappy_fast_cohere(eval(['gradient(cal.T' num2str(sensor) '_fast,1/spr)./fspd']),...
                        wvf,nfft,spr,4*spr);
%                     p=gappy_fast_cohere(eval(['gradient(cal.T' num2str(sensor) '_fast,1/spr)/nanmean(fspd)']),...
%                         wvf,nfft,spr,4*spr);
%                 end
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
                if isfield(pTP,'f')
                    % remove coherence signal with surface waves
                    f=pTP.f;
                    pow=abs((pTP.xx-abs(pTP.xy./pTP.yy).^2.*abs(pTP.yy)))';
                    [bin]=binavg(f,pow,0.05);
                    chi_fit_1=1e-12;chi_fit_2=1e-3;
                    ic_f1=0.05;ic_f2=0.5;% the frequency subrange for inertial convective
                    [chi_fit,fval,exitflag,output] = fminbnd(@e_ic,chi_fit_1,chi_fit_2,optimset('TolX',1e-12,'Display',...
                        'off','MaxIter',100),bin.spc,bin.frq,ic_f1,ic_f2,N2,dTdz,cal,gamma,Ct);
                   
                    if exitflag==1
%                         P_ic=(2*pi)^(4/3)*Ct*(N2/2/gamma/dTdz^2)^(-1/3)*chi_fit^(2/3).*nanmean(cal.fspd)^(-4/3).*(bin.frq).^(1/3);
                        eval(['mod.chiT' num2str(sensor) 'P(iik)=chi_fit;']);
                        eval(['mod.epsT' num2str(sensor) 'P(iik)=N2*chi_fit/(2*gamma*dTdz^2);']);
                        eval(['mod.dT' num2str(sensor) 'dz(iik)=nanmean(dTdz0);']);
                    end
                end
                if isfield(pT,'f')
                    % remove coherence signal with surface waves
                    f=pT.f;
                    pow=abs((pT.xx-abs(pT.xy./pT.yy).^2.*abs(pT.yy)))';
                    [bin]=binavg(f,pow,0.05);
                    chi_fit_1=1e-12;chi_fit_2=1e-3;
                    ic_f1=0.05;ic_f2=0.5;% the frequency subrange for inertial convective
                    [chi_fit,fval,exitflag,output] = fminbnd(@e_ic,chi_fit_1,chi_fit_2,optimset('TolX',1e-12,'Display',...
                        'off','MaxIter',100),bin.spc,bin.frq,ic_f1,ic_f2,N2,dTdz,cal,gamma,Ct);
                   
                    if exitflag==1
                        eval(['mod.chiT' num2str(sensor) '(iik)=chi_fit;']);
                        eval(['mod.epsT' num2str(sensor) '(iik)=N2*chi_fit/(2*gamma*dTdz^2);']);
%                         eval(['mod.dT' num2str(sensor) 'dz(iik)=nanmean(dTdz0);']);
                    end
                end
%                         eval(['mod.fval_chi' num2str(sensor) '(iik)=fval;']);
%                         if ~isfield(mod,'P_ic1')
%                             mod.P_ic1=NaN*ones(length(P_ic),niter);
%                             mod.f1=NaN*ones(length(P_ic),niter);
%                             mod.pp_coh1=NaN*ones(length(P_ic),niter);
%                         end
%                         if ~isfield(mod,'P_ic2')
%                             mod.P_ic2=NaN*ones(length(P_ic),niter);
%                             mod.f2=NaN*ones(length(P_ic),niter);
%                             mod.pp_coh2=NaN*ones(length(P_ic),niter);
%                         end
%                         eval(['mod.P_ic' num2str(sensor) '(1:length(P_ic),iik)=P_ic;']);
%                         eval(['mod.f' num2str(sensor) '(1:length(P_ic),iik)=bin.frq;']);
% %                         eval(['mod.pp_coh' num2str(sensor) '(1:length(P_ic),iik)=bin.spc/2/pi;']);
%                         eval(['mod.pp_coh' num2str(sensor) '(1:length(P_ic),iik)=bin.spc;']);
            end
        end
    end
    mod.time(iik)=(tf+ts)/2;
end

