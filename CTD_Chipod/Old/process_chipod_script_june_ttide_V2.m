% This is a stripped down version of the process script file. Step 1 on the road to
% transparencey
% I can compute dissipation for some station casts, but not all, and I have
% not made it adaptapable enough to handle tow-yos yet. The progam skips 
% tow-yos because the filename does not exist and simply moves on to the next 
% cast. To run the program set the path names correctly and hope for the best!

% Script to process all chipod data:
% Go through all of the casts.

%load CTD profile
CTD_path='/Volumes/scienceparty_share/TTIDE-RR1501/data/ctd_processed/';
chi_processed_path='../data/ttide/processed/';
fig_path=[chi_processed_path 'figures/'];
CTD_list=dir([CTD_path  '24hz/' '*_leg1_*.mat']);

for a=1:length(CTD_list) 
    castname=CTD_list(a).name;
    load([CTD_path '24hz/' castname])
    % create a CTD time:
    % Sometimesthe time needs to be converted from computer time into matlab time.
    % Time will be converted when CTD time is more than 5 years bigger than now.
    % JRM
    tlim=now+5*365;
    if data2.time > tlim
        % jen didn't save us a real 24 hz time.... so create timeseries. JRM
        % from data record
        tmp=linspace(data2.time(1),data2.time(end),length(data2.time));
        data2.datenum=tmp'/24/3600+datenum([1970 1 1 0 0 0]);
    end
    clear tlim tmp
    time_range=[min(data2.datenum) max(data2.datenum)]; 
    cast_suffix_tmp=CTD_list(a).name; % Cast # may be different than file #. JRM
    cast_suffix=cast_suffix_tmp(end-8:end-6); 
    
    for up_down_big=1;%:2
        % load chipod data
        short_labs={'up_1012','down_1013','big'};
        big_labs={'Ti UpLooker','Ti DownLooker','Unit 1002'};
     
        switch up_down_big
            case 1
                %               Specify uplooker path JRM
                chi_path='/Users/jurisa/analysis/CTD-chipod/data/ttide/Chipod_CTD/1012/';
                az_correction=-1; % -1 if the Ti case is pointed down or up
                suffix='A1012';
                isbig=0;
                cal.coef.T1P=0.097;
                is_downcast=0;
            case 2
                %               Specify downlooker JRM
                chi_path='..data/ttide/Chipod_CTD/1013/';
                az_correction=1;
                suffix='A1013';
                isbig=0;
                cal.coef.T1P=0.097;
                is_downcast=1;
            case 3 % For now not doing big Chi
                chi_path='../data/A16S/Chipod_CTD/';az_correction=1;
                suffix='1002';
                isbig=1;
                cal.coef.T1P=0.105;
                cal.coef.T2P=0.105;
                is_downcast=0;
        end
        d.time_range=datestr(time_range); % Time range of cast
        
        processed_file=[chi_processed_path 'chi_' short_labs{up_down_big} '/cast_' ...
            cast_suffix '_' short_labs{up_down_big} '.mat'];
        if  0 % exist(processed_file,'file') %commented for now becasue some files were made but contain no data
            load(processed_file)
        else
            chidat=load_chipod_data(chi_path,time_range,suffix,isbig);
            save(processed_file,'chidat')
        end
        
        chidat
        % try
        if length(chidat.datenum)>1000
            %%% First we'll compute fallspeed from dp/dz and compare this to chipod's
            %%% AZ to get the time offset.
            
            data2.p_lp=conv2(medfilt1(data2.p),hanning(30)/sum(hanning(30)),'same');
            data2.dpdt=gradient(data2.p_lp,nanmedian(diff(data2.datenum*86400)));
            data2.dpdt(data2.dpdt>10)=mean(data2.dpdt); % JRM added to remove large spike spikes in dpdt
            data2.dpdt_hp=data2.dpdt-conv2(data2.dpdt,hanning(750)/sum(hanning(750)),'same');
            data2.dpdt_hp(abs(data2.dpdt_hp)>2)=mean(data2.dpdt_hp); % JRM added to remove large spike spikes in dpdt_hp
            %chidat.AZ_hp=filter_series(chidat.AX,100,'h.02');
            tmp=az_correction*9.8*(chidat.AZ-median(chidat.AZ)); tmp(abs(tmp)>10)=0;
            tmp2=tmp-conv2(tmp,hanning(3000)/sum(hanning(3000)),'same');
            w_from_chipod=cumsum(tmp2*nanmedian(diff(chidat.datenum*86400)));
            % here's the plot:
            %hold off, plot(data2.datenum,data2.dpdt_hp,'b',chidat.datenum,w_from_chipod,'r'),hold on
            ginds=get_profile_inds(data2.p,10);
            offset=TimeOffset(data2.datenum(ginds),data2.dpdt_hp(ginds),chidat.datenum,w_from_chipod);
            chidat.datenum=chidat.datenum+offset;% JRM TimeOffset is not working right
            %plot(data2.datenum,data2.dpdt_hp,chidat.datenum,w_from_chipod)
            
            chidat.time_offset_correction_used=offset;
            chidat.fspd=interp1(data2.datenum,-data2.dpdt,chidat.datenum);
            
            %%% Now we'll calibrate T by comparison to the CTD.
            cal.datenum=chidat.datenum;
            cal.P=interp1(data2.datenum,data2.p_lp,chidat.datenum);
            cal.T_CTD=interp1(data2.datenum,data2.t1,chidat.datenum);
            cal.fspd=chidat.fspd;
            
            [cal.coef.T1,cal.T1]=get_T_calibration(data2.datenum(ginds),data2.t1(ginds),chidat.datenum,chidat.T1);
            %%% And now we apply our calibration for DTdt.
            cal.T1P=calibrate_chipod_dtdt(chidat.T1P,cal.coef.T1P,chidat.T1,cal.coef.T1);
           
            test_dtdt=0; %%% this does a digital differentiation to determine whether the differentiator time constant is correct.
            if test_dtdt
                dt=median(diff(chidat.datenum))*3600*24;
                cal.dTdt_dig=[0 ; diff(cal.T1)/dt];
                oset=min(chidat.datenum);
                plot(chidat.datenum-oset,cal.dTdt_dig,chidat.datenum-oset,cal.T1P);
                paus, ax=axis
                ginds2=find((chidat.datenum-oset)>ax(1) & (chidat.datenum-oset)<ax(2));
                [p,f]=fast_psd(cal.T1P(ginds2),256,100);
                [p2,f]=fast_psd(cal.dTdt_dig(ginds2),256,100);
                figure(4)
                loglog(f,p2,f,p);
            end
            
            
            if isbig
                
                [cal.coef.T2,cal.T2]=get_T_calibration(data2.datenum(ginds),data2.t1(ginds),chidat.datenum,chidat.T2);
                cal.T2P=calibrate_chipod_dtdt(chidat.T2P,cal.coef.T2P,chidat.T2,cal.coef.T2);
            else
                cal.T2=cal.T1;
                cal.T2P=cal.T1P;
            end
            
            do_timeseries_plot=1;
            if do_timeseries_plot
                
                xls=[min(data2.datenum(ginds)) max(data2.datenum(ginds))];
                figure(2)
                clf
                
                h(1)=subplot(411);
                plot(data2.datenum(ginds),data2.t1(ginds),chidat.datenum,cal.T1,chidat.datenum,cal.T2-.5)
                ylabel('T [\circ C]')
                xlim(xls)
                title(['Cast ' cast_suffix ', ' big_labs{up_down_big} '  ' datestr(time_range(1),'dd-mmm-yyyy HH:MM') '-' datestr(time_range(2),15) ', ' CTD_list(a).name])
                h(2)=subplot(412);
                plot(data2.datenum(ginds),data2.p(ginds));
                ylabel('P [dB]')
                xlim(xls)
                h(3)=subplot(413);
                plot(chidat.datenum,cal.T1P-.01,chidat.datenum,cal.T2P+.01)
                ylabel('dTdt [K/s]')
                xlim(xls)
                
                h(4)=subplot(414);
                plot(chidat.datenum,chidat.fspd)
                ylabel('fallspeed [m/s]')
                xlim(xls)
                datetick('x')
                xlabel(['Time on ' datestr(time_range(1),'dd-mmm-yyyy')])
                linkaxes(h,'x');
                orient tall
                pause(.01)
                
                print('-dpng','-r300',[fig_path  'chi_' short_labs{up_down_big} '/cast_' cast_suffix '_T_P_dTdz_fspd.png']);
            end
            
            test_cal_coef=0;
            
            if test_cal_coef
                ccal.coef1(a,1:5)=cal.coef.T1;
                ccal.coef2(a,1:5)=cal.coef.T2;
                figure(104)
                plot(ccal.coef1),hold on,plot(ccal.coef2)
            end
            
            %%% now let's do the computation of chi..
            
            % this gives us 1-m CTD data.
            
            %             toyoname=['CTD_toyo_' castname(end-8:end-6) '.mat'];
            % 			load([CTD_path toyoname]) % JRM was .name(1:end-8)
            if exist([CTD_path castname(1:end-6) '.mat'],'file')
                load([CTD_path castname(1:end-6) '.mat']);
                [p_max,ind_max]=max(cal.P);
                if is_downcast
                    fallspeed_correction=-1;
                    ctd=datad_1m;
                    chi_inds=[1:ind_max];
                    sort_dir='descend';
                else
                    fallspeed_correction=1;
                    ctd=datau_1m;
                    chi_inds=[ind_max:length(cal.P)];
                    sort_dir='ascend';
                end
                ctd.s1=interp_missing_data(ctd.s1,100);
                ctd.t1=interp_missing_data(ctd.t1,100);
                smooth_len=20;
                [bfrq] = sw_bfrq(ctd.s1,ctd.t1,ctd.p,nanmean(ctd.lat)); % JRM removed "vort,p_ave" from outputs
                ctd.N2=abs(conv2(bfrq,ones(smooth_len,1)/smooth_len,'same')); % smooth once
                ctd.N2=conv2(ctd.N2,ones(smooth_len,1)/smooth_len,'same'); % smooth twice
                ctd.N2_20=ctd.N2([1:end end]);
                tmp1=sw_ptmp(ctd.s1,ctd.t1,ctd.p,1000);
                ctd.dTdz=[0 ; abs(conv2(diff(tmp1),ones(smooth_len,1)/smooth_len,'same'))./diff(ctd.p)];
                ctd.dTdz_20=conv2(ctd.dTdz,ones(smooth_len,1)/smooth_len,'same');
                
                smooth_len=50;
                [bfrq] = sw_bfrq(ctd.s1,ctd.t1,ctd.p,nanmean(ctd.lat)); %JRM removed "vort,p_ave" from outputs
                ctd.N2=abs(conv2(bfrq,ones(smooth_len,1)/smooth_len,'same')); % smooth once
                ctd.N2=conv2(ctd.N2,ones(smooth_len,1)/smooth_len,'same'); % smooth twice
                ctd.N2_50=ctd.N2([1:end end]);
                tmp1=sw_ptmp(ctd.s1,ctd.t1,ctd.p,1000);
                ctd.dTdz=[0 ; abs(conv2(diff(tmp1),ones(smooth_len,1)/smooth_len,'same'))./diff(ctd.p)];
                ctd.dTdz_50=conv2(ctd.dTdz,ones(smooth_len,1)/smooth_len,'same');
                
                ctd.dTdz=max(ctd.dTdz_50,ctd.dTdz_20);
                ctd.N2=max(ctd.N2_50,ctd.N2_20);
                
                
                
                %			tmp2=sw_ptmp(ctd.s1,ctd.t1,ctd.p,2000);
                %			ctd.dTdz2=[0 ; conv2(diff(tmp2),ones(smooth_len,1)/smooth_len,'same')./diff(ctd.p)];
                %			tmp3=sw_ptmp(ctd.s1,ctd.t1,ctd.p,3000);
                %			ctd.dTdz3=[0 ; conv2(diff(tmp3),ones(smooth_len,1)/smooth_len,'same')./diff(ctd.p)];
                doplot=0;
                if doplot
                    subplot(121)
                    plot(log10(abs(ctd.N2)),ctd.p),
                    xlabel('N^2'),ylabel('depth')
                    subplot(122)
                    plot(log10(abs(ctd.dTdz)),ctd.p) % ,log10(abs(ctd.dTdz2)),ctd.p,log10(abs(ctd.dTdz3)),ctd.p)
                end
                % now let's do the chi computations:
                
                extra_z=2; % number of extra meters to get rid of due to CTD pressure loops.
                wthresh = 0.4;
                [datau2,bad_inds] = ctd_rmdepthloops(data2,extra_z,wthresh);
                tmp=ones(size(datau2.p));
                tmp(bad_inds)=0;
                cal.is_good_data=interp1(datau2.datenum,tmp,cal.datenum,'nearest');
                
                
                %%% Now we'll do the main looping through of the data.
                clear avg
                nfft=128;
                todo_inds=chi_inds(1:nfft/2:(length(chi_inds)-nfft))';
                tfields={'datenum','P','N2','dTdz','fspd','T','S','P','theta','sigma',...
                    'chi1','eps1','chi2','eps2','KT1','KT2','TP1var','TP2var'}
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
                avg.nu=sw_visc(avg.S,avg.T,avg.P);
                avg.tdif=sw_tdif(avg.S,avg.T,avg.P);
                avg.samplerate=1./nanmedian(diff(cal.datenum))/24/3600;
                
                h = waitbar(0,[CTD_list(a).name(1:end-8) 'Please wait...']);
                for n=1:length(todo_inds)
                    inds=todo_inds(n)-1+[1:nfft];
                    if all(cal.is_good_data(inds)==1)
                        avg.fspd(n)=mean(cal.fspd(inds));
                        
                        [tp_power,freq]=fast_psd(cal.T1P(inds),nfft,avg.samplerate);
                        avg.TP1var(n)=sum(tp_power)*nanmean(diff(freq));
                        if avg.TP1var(n)>1e-4
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
                            [chi1,epsil1,k,spec,kk,speck,stats]=get_chipod_chi(freq,tp_power,avg.fspd(n),avg.nu(n),...
                                avg.tdif(n),avg.dTdz(n),'nsqr',avg.N2(n));
                            %						[chi1,epsil1,k,spec,kk,speck,stats]=get_chipod_chi(freq,tp_power,abs(avg.fspd(n)),avg.nu(n),...
                            %							avg.tdif(n),avg.dTdz(n),'nsqr',avg.N2(n));
                            %catch
                            %	chi1=NaN;
                            %	epsil1=NaN;
                            %end
                            
                            avg.chi1(n)=chi1(1);
                            avg.eps1(n)=epsil1(1);
                            avg.KT1(n)=0.5*chi1(1)/avg.dTdz(n)^2;
                        end
                    else
                        
                    end
                    if ~mod(n,10)
                        waitbar(n/length(todo_inds),h);
                    end
                end
                delete(h)
                
                figure(5)
                subplot(131)
                
                plot(log10(avg.chi1),avg.P),axis ij
                xlabel('log10(avg chi)')
                subplot(132)
                plot(log10(avg.KT1),avg.P),axis ij
                xlabel('log10(avg Kt1)')
                subplot(133)
                plot(log10(abs(avg.dTdz)),avg.P),axis ij
                xlabel('log10(avg dTdz)')
                print('-dpng',[fig_path  'chi_' short_labs{up_down_big} '/cast_' cast_suffix 'avg.chi_KT_dTdz'])
                
                processed_file=[chi_processed_path 'chi_' short_labs{up_down_big} '/avg/avg_' ...
                    cast_suffix '_' short_labs{up_down_big} '.mat'];
                save(processed_file,'avg','ctd')
                
            end
        end
        %catch
        %2end
        
    end
end



%% Now plot up the results


figure(6)

subplot(131)
plot(log10(avg.chi1),avg.P),axis ij
subplot(132)
plot(log10(avg.KT1),avg.P),axis ij
subplot(133)
plot(log10(abs(avg.dTdz)),avg.P),axis ij

%%
chi_processed_path='../data/ttide/processed/';


clear big tmp

tfields={'chi1','eps1','chi2','eps2','KT1','KT2','datenum','P','N2','dTdz','fspd','T','S','P','theta','sigma',...
    'TP1var','TP2var'}
del_p=20;
p_vec=[del_p/2:del_p:7000];
n_profiles=150
for n=1:length(tfields)
    tmp.(tfields{n})=NaN*ones(length(p_vec),n_profiles);
end
tmp.lat=NaN*ones(1,n_profiles);
tmp.lon=NaN*ones(1,n_profiles);


big(1)=tmp;
big(2)=tmp;
badinds={[21 93],[52 84:n_profiles]}
try delete(h), catch, end
h=waitbar(0,'waiting')
a
for up_down_big=1%:2
    for a=7:154
        
        % 		cast_suffix=num2str(1000+a); cast_suffix=cast_suffix(2:4);
        cast_suffix_tmp=CTD_list(a).name;
        cast_suffix=cast_suffix_tmp(end-8:end-6);
        processed_file=[chi_processed_path 'chi_' short_labs{up_down_big} '/avg/avg_' ...
            cast_suffix '_' short_labs{up_down_big} '.mat'];
        if exist(processed_file) & ~ismember(a,badinds{up_down_big})
            load(processed_file)
            avg.chi1(isnan(avg.chi1))=0;
            avg.chi2(isnan(avg.chi2))=0;
            avg.eps1(isnan(avg.eps1))=0;
            avg.eps2(isnan(avg.eps2))=0;
            avg.KT1(isnan(avg.KT1))=0;
            avg.KT2(isnan(avg.KT2))=0;
            big(up_down_big).lat(a)=nanmean(ctd.lat);
            big(up_down_big).lon(a)=nanmean(ctd.lon);
            bad_KT=find((avg.dTdz./avg.N2)<300 | (avg.dTdz<1e-4));
            %			bad_chi=[]
            for c=5:6 %1:length(tfields)
                avg.(tfields{c})(bad_KT)=NaN;
            end
            
            for b=1:length(p_vec)
                tinds=find(avg.P>(p_vec(b)-del_p) & avg.P<(p_vec(b)+del_p));
                for c=1:length(tfields)
                    big(up_down_big).(tfields{c})(b,a)=nanmean(avg.(tfields{c})(tinds));
                end
            end
        else
            
        end
        waitbar(a/104,h);
    end
    
    big(up_down_big).lat=interp_missing_data(big(up_down_big).lat);
    big(up_down_big).lon=interp_missing_data(big(up_down_big).lon);
end

delete(h)
% pcolor(big(2).eps1),shading flat

if 0
    clf
    ranges=[34:38],cols='rbgmk';
    for a=1:4
        ix=ranges(a);
        subplot(121)
        plot((big(2).datenum(:,ix)-big(2).datenum(1,ix))*24,big(2).P(:,ix),cols(a))
        hold on
        subplot(122)
        plot((big(2).datenum(:,ix)-big(2).datenum(1,ix))*24,big(2).fspd(:,ix),cols(a))
        hold on
    end
end

%%
load ../bathymetry/cast_info.mat
d=2600;
good_inds=[1:86 88:94];

thechi=min(big(1).chi1,big(2).chi1);
thekt=(min(big(1).KT1,big(2).KT1)+max(big(1).KT1,big(2).KT1))/2;
theeps=max(big(1).eps1,big(2).eps1);
theT=min(big(1).T,big(2).T);
theS=min(big(1).S,big(2).S);
thep=max(big(1).P,big(2).P);
thelat=max(big(1).lat,big(2).lat);
tmp2=conv2(thechi,ones(3,1)/3,'same');
tmp3=conv2(thekt,ones(3,1)/3,'same');
tmp4=conv2(theeps,ones(3,1)/3,'same');
figure(111)
clf
subplot(311)
%pcolor(thelat(good_inds),thep(:,good_inds),theT(:,good_inds)),axis ij,caxis([0 10]),shading flat
pcolor(thelat(good_inds),thep(:,good_inds),theS(:,good_inds)),axis ij,caxis([34.2 35.5]),shading flat
hold on,
hh=area(cast.newlat(2:end),-cast.new_H(2:end),6020), set(hh,'facecolor',.75*[1 1 1],'linewidth',2)
ylim([0 d])
fix_fig2,jtext('Salinity',.01,1.07,'fontsize',14),my_colorbar([],[],'S [psu] ')
subplot(312)
pcolor(thelat(good_inds),thep(:,good_inds),log10(tmp2(:,good_inds))),axis ij,caxis([-11.5 -7]),shading flat
hold on,
hh=area(cast.newlat(2:end),-cast.new_H(2:end),6020), set(hh,'facecolor',.75*[1 1 1],'linewidth',2)
ylim([0 d])
fix_fig2,jtext('Thermal Dissipation Rate',.01,1.07,'fontsize',14),my_colorbar([],[],'log_{10} \chi [K^2/s] ')
xl=xlim;
subplot(313)
pcolor(thelat(good_inds),thep(:,good_inds),log10(tmp3(:,good_inds))),axis ij,caxis([-5 -2.5]),shading flat
hold on,
hh=area(cast.newlat(2:end),-cast.new_H(2:end),6020), set(hh,'facecolor',.75*[1 1 1],'linewidth',2)
ylim([0 d])
fix_fig2,jtext('Observed Turbulent Diffusivity ',.01,1.07,'fontsize',14),my_colorbar([],[],'log_{10} K_T [m^2/s] ')
set(gca,'xticklabelmode','auto')
%pcolor(thelat(good_inds),thep(:,good_inds),log10(tmp4(:,good_inds))),axis ij,caxis([-11 -8]),shading flat
set(gcf,'renderer','zbuffer')
xlabel('latitude'),ylabel('depth [m]')
% dual_print_pdf2('final_plot','same')

print('-dpng',[fig_path  'chi_' short_labs{up_down_big} '/cast_' cast_suffix 'chi'])




%%
figure
inds=find(~isnan(big(1).lat));
pcolor(log10(big(1).chi1(:,inds))),shading flat
caxis([-9 -7])
%%
if 0
figure(103)
subplot(211)
pcolor(big(1).lat,big(1).P,log10(big(1).chi1)),axis ij,caxis([-11 -7]),shading flat
subplot(212)
pcolor(big(1).lat,big(2).P,log10(big(2).chi1)),axis ij,caxis([-11 -7]),shading flat

%%
figure(104)
subplot(211)
pcolor(big(1).lat,big(1).P,log10(big(1).KT1)),axis ij,caxis([-5 -2]),shading flat
subplot(212)
pcolor(big(1).lat,big(2).P,log10(big(2).KT1)),axis ij,caxis([-5 -2]),shading flat


figure(105)
subplot(211)
pcolor(big(1).lat,big(1).P,log10(big(1).eps1)),axis ij,caxis([-10 -7]),shading flat
subplot(212)
pcolor(big(1).lat,big(2).P,log10(big(2).eps1)),axis ij,caxis([-10 -7]),shading flat


chi_tmp=min(big(1).chi1,big(2).chi1);
eps_tmp=min(big(1).eps1,big(2).eps1);
KT_tmp=min(big(1).KT1,big(2).KT1);


end



