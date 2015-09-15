% calibrate_chameleon.m
%
% Many codes have been written to calibrate the chameleon, however, I'd
% rather write my own so I actually understand what's going on.

clear all

addpath('~/Dropbox/data/eq14/chameleon/mfiles/')
addpath('~/Dropbox/data/eq14/chameleon/mfiles/utilities/')
addpath('~/Dropbox/data/eq14/chameleon/mfiles/mproc/')

%% load

% load ctdall
% load('~/Dropbox/data/eq14/ctd/processed/ctdall_500m_downcasts.mat')
load('~/Dropbox/data/eq14/ctd/processed/allctd_500m_downcasts.mat')


% INDEX/CTD/CHAMELEON PAIRS (if possible, the last chameleon drop before the ctd)
ctdnames  = ['12'  ;'14'  ;'15'  ;'16'  ;'17'  ;'18'  ;'19'  ;'20'  ;...
             '21'  ;'22'  ;'23'  ;'24'  ;'25'  ;'26'  ;'27'  ;'28'  ;...
             '29'  ;'30'  ;'31'  ;'32'  ;'33'  ;'34'  ;'35'  ;'36'  ;...
             '37'  ;'38'  ;'39'  ;'40'  ;'41'  ;'42'  ;'43'  ;'44'  ;...
             '45'  ;'46'  ;'47'  ];
             
chamnames = ['0004';'0400';'0453';'0507';'0588';'0642';'0705';'0753';...
             '0754';'0794';'0873';'0957';'1040';'1135';'1301';'1405';...
             '1533';'1590';'1591';'1652';'1795';'1903';'2003';'2099';...
             '2196';'2301';'2390';'2479';'2581';'2670';'2761';'2853';...
             '2952';'3029';'3089'];
% note: chameleon casts between 1643 and 1844 were with a different
% instruments. This corresponds to index 20:21 here

for ii = 20:21 % 1:length(ctdnames)

    clear ctd chamvar P coeff
    
%%%%%%%%%% ctd %%%%%%%%%%%%%%
% directory where the ctd mat files are saved
% ctddatadir = '~/wdmycloud/mixing/data/EQ14/CTD/processed/';
ctddatadir = '~/Dropbox/data/eq14/ctd/processed/';

ctdfilename = ['CTD' ctdnames(ii,:) '.mat'];

load([ctddatadir ctdfilename])

eq14_cham_coef.ctdnum(ii) = str2num(ctdnames(ii,:));
eq14_cham_coef.ctdmat(ii,:) = [ctddatadir ctdfilename];



%%%%%%%%%% chameleon %%%%%%%%%%%%%%
% directory where the raw chameleon data is saved
% (note: do not touch a file that is currently being written, it will
% corrupt it.)
% chamdatadir = '~/wdmycloud/mixing/data/EQ14/Chameleon/raw/';
% chamdatadir = '/Volumes/Cham/raw/';
chamdatadir = '~/Dropbox/data/eq14/chameleon/raw/';

chamfilename = ['EQ14_' chamnames(ii,1) '.' chamnames(ii,2:4)];

eq14_cham_coef.chamnum(ii) = str2num(chamnames(ii,:));
eq14_cham_coef.chammat(ii,:) = [chamdatadir chamfilename];


clear head data cal q
clearvars -global head data cal q
global head data cal
[data,head] = raw_load_cham2([chamdatadir chamfilename]);

cali_realtime_oceanus_v3


%% first nan out the bad ctd data

clear ctdind1 ctdind2

ctdind1 = ctdall(ii).startind;
ctdind2 = ctdall(ii).endind;

% only need to do once
if ~exist('ctdind1') & ~exist('ctdind2')
    
    % use ginput to find the start and end of the CTD downcast
    hf1 = figure(1);
    clf
    plot(ctd.pressure)
    xlim([0 4000])
    ylim([-10 50])

    disp('choose the start of the ctd downcast')
    dummy = ginput(1);
    ctdind1 = round(dummy(1));

    xlim(length(ctd.pressure)/2+[-1 1]*5000)
    ylim(max(ctd.pressure)+[-100 20])

    disp('choose the end of the ctd downcast')
    dummy = ginput(1);
    ctdind2 = round(dummy(1));
    
    close(hf1)
    
end

    % nan out the junk at the beginning and the upcast
    indbad = [1:ctdind1 ctdind2:length(ctd.pressure)];
    ctd.temp1(indbad) = NaN;
    ctd.temp2(indbad) = NaN;
    ctd.cond1(indbad) = NaN;
    ctd.cond2(indbad) = NaN;
    ctd.sigma1(indbad) = NaN;
    ctd.sigma2(indbad) = NaN;
    ctd.sal1(indbad) = NaN;
    ctd.sal2(indbad) = NaN;

    



%% make a figure to compare CTD to chameleon

torc = 'COND';  % options are: 'T1', 'T2', 'COND'
switch torc
    case 'T1'
        ctdvar1 = ctd.temp1;
        ctdvar2 = ctd.temp2;
        chamvar = data.T1;
        xlab = 'ctd temperature [^oC]';

    case 'T2'
        ctdvar1 = ctd.temp1;
        ctdvar2 = ctd.temp2;
        chamvar = data.T2;
        xlab = 'ctd temperature [^oC]';

    case 'COND'
        ctdvar1 = ctd.cond1;
        ctdvar2 = ctd.cond2;
        chamvar = data.COND;
        xlab = 'ctd conductivity [seimans m^{-1}]';
end




y1 = 0;
y2 = 200;

figure(2)
clf
% set(gcf,'position',[877          53         981        1053])
set(gcf,'position',[485          53         981        1053])

ax(1) = subplot(121);
plot(ctdvar1,ctd.pressure)
hold on
plot(ctdvar2,ctd.pressure)
axis ij
ylim([0 200])
xlabel(xlab)
ylabel('pressure [dbar]')

ax(2) = subplot(122);
plot(chamvar,cal.P);
axis ij
ylim([0 200])
xlabel(['chameleon ' torc ' [volts]'])
ylabel('pressure [dbar]')

linkaxes(ax,'y')

% choose some points in the two schemes to link up
ylim([0 30])

% disp('choose some matching temperatures (preferably in mixed layers)')
% disp('choose the ctd temp/cond FIRST, then the corresponding chameleon temp')
% dummy1 = ginput;

ylim([0 200])
disp('choose some matching temperatures (preferably in mixed layers)')
disp('choose the ctd temp/cond FIRST, then the corresponding chameleon temp')
dummy2 = ginput;


% ctdtemps = [dummy1(1:2:end,1); dummy2(1:2:end,1)];
% chamvolts = [dummy1(2:2:end,1); dummy2(2:2:end,1)];

ctdtemps = dummy2(1:2:end,1);
chamvolts = dummy2(2:2:end,1);

disp('cham volts (col 1) vs ctd temps/cond (col 2)')
disp([chamvolts ctdtemps])


% calculate the coefficients

P = polyfit(chamvolts,ctdtemps,2);
coeff = fliplr(P);
if length(coeff) == 3
    coeff(4) = 0;
end


% % P = polyfit(chamvolts,ctdtemps,1);
% % coeff = fliplr(P);
% % if length(coeff) == 3
% %     coeff(4) = 0;
% % elseif length(coeff) == 2
% %     coeff(3) = 0;
% %     coeff(4) = 0;
% % end


% make a plot showing the fit
xx = linspace(min(chamvolts),max(chamvolts),100);
yy = calibrate_polynomial(xx,coeff);
figure(4)
clf
plot(chamvolts,ctdtemps,'ro','markersize',8)
hold on
plot(xx,yy,'k')
xlabel('volts')
ylabel('COND [seimans m^{-1}]')
title({['CTD\_' ctdnames(ii,:) '\_vs\_cham\_' chamnames(ii,:)];...
    ['y = ' num2str(coeff(1),4) ' + ' num2str(coeff(2),4) 'x']})
export_fig(['~/Dropbox/data/eq14/chameleon/figures/'...
            'compare_T_C_S_to_CTD/calibaration_fit_CTD_' ctdnames(ii,:) ...
            '_vs_cham_' chamnames(ii,:) '.png'],'-r200')


% figure(2)
% subplot(121)
% hold on

switch torc
    case 'T1'
        cal.T1newcal = calibrate_polynomial(data.T1,coeff);
        cal.T1newcoeffs = coeff
%         plot(cal.T1newcal,cal.P,'k')
        eq14_cham_coef.T1coeff(ii,1:4) = coeff;
    case 'T2'
        cal.T2newcal = calibrate_polynomial(data.T2,coeff);
        cal.T2newcoeffs = coeff
%         plot(cal.T2newcal,cal.P,'k')
        eq14_cham_coef.T2coeff(ii,1:4) = coeff;
    case 'COND'
        cal.CONDnewcal = calibrate_polynomial(data.COND,coeff);
        cal.CONDnewcoeffs = coeff
%         plot(cal.CONDnewcal,cal.P,'k')
        eq14_cham_coef.CONDcoeff(ii,1:4) = coeff;
        
        sal = sw_salt(cal.CONDnewcal/(sw_c3515/10),cal.T1,cal.P);
end



switch torc
    case 'T1'

    case 'T2'

    case 'COND'

        figure(3)
        
        clf
%         set(gcf,'position',[ 877          53         981        1053])
        set(gcf,'position',[485          53         981        1053])

        ax(1) = subplot(131);
        plot(ctd.temp1,ctd.pressure,'k','linewidth',2)
        hold on
        plot(ctd.temp2,ctd.pressure,'k','linewidth',2)
        plot(cal.T1,cal.P,'color',nicecolor('bc'),'linewidth',2)
        plot(cal.T2,cal.P,'r','linewidth',2)
        axis ij
        ylim([0 200])
        xlabel('TEMP [^oC]')
        ylabel('pressure [dbar]')
        legend('CTD T1','CTD T2','CHAM T1','CHAM T2','location','southoutside')
        legend boxoff

        ax(2) = subplot(132);
        plot(ctd.cond1,ctd.pressure,'k','linewidth',2)
        hold on
        plot(ctd.cond2,ctd.pressure,'k','linewidth',2)
        plot(cal.COND,cal.P,'color',nicecolor('bc'),'linewidth',2)
        plot(cal.CONDnewcal,cal.P,'r','linewidth',2)
        axis ij
        ylim([0 200])
        xlabel('COND [seimans m^{-1}]')
%         ylabel('pressure [dbar]')
        title({'TEMPERATURE, CONDUCTIVITY, SALINITY';['CTD ' ...
            ctdnames(ii,:) ', CHAM ' chamnames(ii,:)]})
        legend('CTD C1','CTD C2','CHAM COND OLD','CHAM COND NEW','location','southoutside')
        legend boxoff

        ax(3) = subplot(133);
        plot(ctd.sal1,ctd.pressure,'k','linewidth',2)
        hold on
        plot(ctd.sal2,ctd.pressure,'k','linewidth',2)
        plot(cal.SAL,cal.P,'color',nicecolor('bc'),'linewidth',2)
        plot(sal,cal.P,'r','linewidth',2)
        axis ij
        ylim([0 200])
        xlabel('SALINITY [psu]')
%         ylabel('pressure [dbar]')
        legend('CTD SAL1','CTD SAL2','CHAM SAL OLD','CHAM SAL NEW','location','southoutside')
        legend boxoff
        title(['y = ' num2str(coeff(1),4) ' + ' num2str(coeff(2),4) 'x'])
        xlim([34 36])

        linkaxes(ax,'y')
        
        export_fig(['~/Dropbox/data/eq14/chameleon/figures/'...
            'compare_T_C_S_to_CTD/recalibrated_CTD_' ctdnames(ii,:) ...
            '_vs_cham_' chamnames(ii,:) '.png'],'-r200')

end





%% save the coefficients
clear cham_coef
cham_coef.ctdnum = eq14_cham_coef.ctdnum(ii);
cham_coef.ctdmat = eq14_cham_coef.ctdmat(ii,:);
cham_coef.chamnum = eq14_cham_coef.chamnum(ii);
cham_coef.chammat = eq14_cham_coef.chammat(ii,:);
cham_coef.CONDcoeff = eq14_cham_coef.CONDcoeff(ii,:);

save(['~/Dropbox/data/eq14/chameleon/processed/fixed_salinity/conductivity_coefficients_ctd'...
    ctdnames(ii,:) '_vs_cham_' chamnames(ii,:) '.mat'],'cham_coef')

pause

cl

end


%% combine the calibration coefficients

clear cham_coef cond
coefdir = '~/Dropbox/data/eq14/chameleon/processed/fixed_salinity/';
ddcoef = dir([coefdir 'conductivity*']);

for ii = 1:length(ddcoef)
        load([coefdir ddcoef(ii).name])
        cond.ctdnum(ii) = cham_coef.ctdnum;
        cond.ctdmat(ii,:) = cham_coef.ctdmat;
        cond.chamnum(ii) = cham_coef.chamnum;
        cond.chammat(ii,:) = cham_coef.chammat;
        cond.coef(ii,1:4) = cham_coef.CONDcoeff;
end




%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
break

%%


%% make a figure to compare salinities

clear 

%%%%%%%%%% ctd %%%%%%%%%%%%%%
% directory where the ctd mat files are saved
ctddatadir = '~/wdmycloud/mixing/data/EQ14/CTD/processed/';

ctdfilename = 'CTD12.mat';
ctd12 = load([ctddatadir ctdfilename]);

ctdfilename = 'CTD14.mat';
ctd14 = load([ctddatadir ctdfilename]);

ctdfilename = 'CTD15.mat';
ctd15 = load([ctddatadir ctdfilename]);

ctdfilename = 'CTD16.mat';
ctd16 = load([ctddatadir ctdfilename]);


%%%%%%%%%% chameleon %%%%%%%%%%%%%%
% directory where the raw chameleon data is saved
% (note: do not touch a file that is currently being written, it will
% corrupt it.)
champrocdir = '~/Dropbox/data/eq14/chameleon/processed/mat/';

champrocname = 'EQ14_00010.mat';
cham010 = load([champrocdir champrocname]);

champrocname = 'EQ14_00400.mat';
cham400 = load([champrocdir champrocname]);

champrocname = 'EQ14_00453.mat';
cham453 = load([champrocdir champrocname]);

champrocname = 'EQ14_00507.mat';
cham507 = load([champrocdir champrocname]);

%%%%% plot

figure(10)
clf
set(gcf,'position',[219         398        1607         627])

ax(1) = subplot(141);
plot(ctd12.ctd.sal1,ctd12.ctd.pressure)
hold on
plot(ctd12.ctd.sal2,ctd12.ctd.pressure)
plot(cham010.avg.SAL,cham010.avg.P,'k','linewidth',2)
axis ij
ylabel('pressure [dbar]')
xlabel('salinity [psu]')
title('CTD 12, CHAM 010')

ax(2) = subplot(142);
plot(ctd14.ctd.sal1,ctd14.ctd.pressure)
hold on
plot(ctd14.ctd.sal2,ctd14.ctd.pressure)
plot(cham400.avg.SAL,cham400.avg.P,'k','linewidth',2)
axis ij
ylabel('pressure [dbar]')
xlabel('salinity [psu]')
title('CTD 14, CHAM 400')

ax(3) = subplot(143);
plot(ctd15.ctd.sal1,ctd15.ctd.pressure)
hold on
plot(ctd15.ctd.sal2,ctd15.ctd.pressure)
plot(cham453.avg.SAL,cham453.avg.P,'k','linewidth',2)
axis ij
ylabel('pressure [dbar]')
xlabel('salinity [psu]')
title('CTD 15, CHAM 453')

ax(4) = subplot(144);
plot(ctd16.ctd.sal1,ctd16.ctd.pressure)
hold on
plot(ctd16.ctd.sal2,ctd16.ctd.pressure)
plot(cham507.avg.SAL,cham507.avg.P,'k','linewidth',2)
axis ij
ylabel('pressure [dbar]')
xlabel('salinity [psu]')
title('CTD 16, CHAM 507')

linkaxes(ax,'y')

ylim([0 200])





