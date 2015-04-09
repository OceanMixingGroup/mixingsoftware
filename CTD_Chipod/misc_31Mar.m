%%
%
% misc_31Mar.m
%
% Starting to work on processing JOIS chipod data. Will try to use data
% from RBR instead of CTD.
%
%
%
%%

clear ; close all

chi_data_path='/Volumes/LENOVO/jois'

load('/Volumes/LENOVO/jois/RBR/050651.mat')

whprof=10

data2=prof_dn{whprof}
data2.datenum=data2.time;

time_range=[min(data2.datenum) max(data2.datenum)];

for up_down_big=1%:2
    % load chipod data
    short_labs={'dn_1006'};
    big_labs={'Ti DownLooker'};
    
    switch up_down_big
        case 1
            % Specify uplooker path JRM
            chi_path=fullfile(chi_data_path,'1006')
            az_correction=-1; % -1 if the Ti case is pointed down or up
            suffix='A1006';
            isbig=0;
            cal.coef.T1P=0.097;
            is_downcast=1;
        case 2
            % Specify downlooker JRM
            chi_path=fullfile(chi_data_path,'1013')
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
        case 4
            % another downlooker
            chi_path=fullfile(chi_data_path,'1010')
            az_correction=1;
            suffix='A1010';
            isbig=0;
            cal.coef.T1P=0.097;
            is_downcast=1;
    end
end
%
chidat=load_chipod_data(chi_path,time_range,suffix,isbig);
%%
% low-passed p
data2.p_lp=conv2(medfilt1(data2.P),hanning(30)/sum(hanning(30)),'same');
data2.dpdt=gradient(data2.p_lp,nanmedian(diff(data2.datenum*86400)));
data2.dpdt(data2.dpdt>10)=mean(data2.dpdt); % JRM added to remove large spike spikes in dpdt

% high-passed dpdt
data2.dpdt_hp=data2.dpdt-conv2(data2.dpdt,hanning(750)/sum(hanning(750)),'same');
data2.dpdt_hp(abs(data2.dpdt_hp)>2)=mean(data2.dpdt_hp); % JRM added to remove large spike spikes in dpdt_hp

%~ AP - compute chipod w by integrating z-accelertion?
%chidat.AZ_hp=filter_series(chidat.AX,100,'h.02');
tmp=az_correction*9.8*(chidat.AZ-median(chidat.AZ)); tmp(abs(tmp)>10)=0;
tmp2=tmp-conv2(tmp,hanning(3000)/sum(hanning(3000)),'same');
w_from_chipod=cumsum(tmp2*nanmedian(diff(chidat.datenum*86400)));

% here's the plot:
figure(1);clf
ax1= subplot(211)
plot(data2.datenum,data2.dpdt_hp,'b',chidat.datenum,w_from_chipod,'r'),hold on
legend('ctd dp/dt','w_{chi}','orientation','horizontal','location','best')
title(['Profile ' num2str(whprof)],'interpreter','none')
ylabel('w [m/s]')
datetick('x')
grid on

% find profile inds (ctd profile 'starts' at 10m )
ginds=get_profile_inds(data2.P,10);

% find time offset between ctd and chipod data (by matching w)
offset=TimeOffset(data2.datenum(ginds),data2.dpdt_hp(ginds),chidat.datenum,w_from_chipod);

% apply correction to chipod time
chidat.datenum=chidat.datenum+offset; % JRM TimeOffset is not working right ??
chidat.time_offset_correction_used=offset;
chidat.fspd=interp1(data2.datenum,-data2.dpdt,chidat.datenum);

ax2=subplot(212)
plot(data2.datenum,data2.dpdt_hp,'b',chidat.datenum,w_from_chipod,'g')
legend('ctd dp/dt','corrected w_{chi}','orientation','horizontal','location','best')
grid on
datetick('x')
ylabel('w [m/s]')

linkaxes([ax1 ax2])

%%
%%% Now we'll calibrate T by comparison to the CTD.
cal.datenum=chidat.datenum;
cal.P=interp1(data2.datenum,data2.p_lp,chidat.datenum);
cal.T_CTD=interp1(data2.datenum,data2.T,chidat.datenum);
cal.fspd=chidat.fspd;

[cal.coef.T1,cal.T1]=get_T_calibration(data2.datenum(ginds),data2.T(ginds),chidat.datenum,chidat.T1);

% check if T calibration is ok
clear out2 err pvar
out2=interp1(chidat.datenum,cal.T1,data2.datenum(ginds));
err=out2-data2.T(ginds);
pvar=100* (1-(nanvar(err)/nanvar(data2.T(ginds))) );
if pvar<50
    disp('Warning T calibration not good')
    fprintf(fileID,' *T calibration not good* ')
end
%

%%% And now we apply our calibration for DTdt.
cal.T1P=calibrate_chipod_dtdt(chidat.T1P,cal.coef.T1P,chidat.T1,cal.coef.T1);

if isbig
    % big chipods have 2 sensors?
    [cal.coef.T2,cal.T2]=get_T_calibration(data2.datenum(ginds),data2.t1(ginds),chidat.datenum,chidat.T2);
    cal.T2P=calibrate_chipod_dtdt(chidat.T2P,cal.coef.T2P,chidat.T2,cal.coef.T2);
else
    cal.T2=cal.T1;
    cal.T2P=cal.T1P;
end
%%
do_timeseries_plot=1;
if do_timeseries_plot
    
    xls=[min(data2.datenum(ginds)) max(data2.datenum(ginds))];
    figure(2);clf
    agutwocolumn(1)
    wysiwyg
    clf
    
    h(1)=subplot(411);
    plot(data2.datenum(ginds),data2.T(ginds),chidat.datenum,cal.T1,chidat.datenum,cal.T2-.5)
    ylabel('T [\circ C]')
    xlim(xls)
    datetick('x')
    %                    title(['Cast ' cast_suffix ', ' big_labs{up_down_big} '  ' datestr(time_range(1),'dd-mmm-yyyy HH:MM') '-' datestr(time_range(2),15) ', ' CTD_list(a).name],'interpreter','none')
    legend('CTD','chi','chi2-.5','location','best')
    grid on
    
    h(2)=subplot(412);
    plot(data2.datenum(ginds),data2.P(ginds));
    ylabel('P [dB]')
    xlim(xls)
    datetick('x')
    grid on
    
    h(3)=subplot(413);
    plot(chidat.datenum,cal.T1P-.01,chidat.datenum,cal.T2P+.01)
    ylabel('dTdt [K/s]')
    xlim(xls)
    datetick('x')
    grid on
    
    h(4)=subplot(414);
    plot(chidat.datenum,chidat.fspd)
    ylabel('fallspeed [m/s]')
    xlim(xls)
    ylim(3*[-1 1])
    datetick('x')
    xlabel(['Time on ' datestr(time_range(1),'dd-mmm-yyyy')])
    grid on
    
    linkaxes(h,'x');
    orient tall
    pause(.01)
    
    %  print('-dpng','-r300',[fig_path  'chi_' short_labs{up_down_big} '/cast_' cast_suffix '_T_P_dTdz_fspd.png']);
end

%% up to now, same as other processing script. Now is part where we would load 1m CTD data and compute N2 and dTdz.

% for this arctic data, we might actually need to use the CTD data because
% density and N^2 are probably affected by salinity, and RBR only has
% temperature...



%%