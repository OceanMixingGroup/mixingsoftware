% calibrate_chipod_T
% run first make_chiT_calibration_file.m to create *.mat calibration file!
%
% loads summary calibration file (made with make_chiT_calibrating_file.m),
% which contains seabird ans chipod
% calibration data in two structures: chi & sb
% if black line on seabird temperature plot do not correspond to black data
% of the chipod (but rather to red lines),
% that means that wrong sensor is calibrated with wrong seabird.
% sb.t1 should be renamed to sb.t2 and the same is for all other sensors
% to do this set flag swith_names to 1
close all; clear all; fclose all;
%% input parameters
% unit=314; ttop='0610P'; tbot='0529';
% unit=328; ttop='08-29'; tbot='08-30';
% unit=120; ttop='0528'; tbot='0526';
% unit=316; ttop='06-23';
unit=317; ttop='06-27';
tlims=[5 25];
% directory where summary calibration file is saved
% sbdir='\\mserver\data\st08\calibration\ChiPodT\RenChiehT\';
sbdir='\\mserver\data\st08\calibration\ChiPodT\Glider_T\';
%% load and plot data
load([sbdir num2str(unit) '_T']);
switch_names=0;
polinom_order=3;
coeff.T1=[0 0 0 0 0];
coeff.T2=[0 0 0 0 0];
if switch_names
    sbt.time1=sb.time2;
    sbt.t1=sb.t2;
    sbt.count1=sb.count2;
    sbt.time2=sb.time1;
    sbt.t2=sb.t1;
    sbt.count2=sb.count1;
    sb=sbt;clear sbt
end
if ~isfield(sb,'t2')
    sb.time2=sb.time1;
    sb.t2=sb.t1;
    sb.count2=sb.count1;
end
% bad=find(chi.T1<1.1);
% chi.T1(bad)=NaN;
if strcmp(num2str(unit),'307')
    bad=find(chi.time<datenum(2007,2,10,22,56,08));
end
if strcmp(num2str(unit),'328')
    chi.time=makelen(chi.time,12*length(chi.time));
end
% chi.T1(bad)=NaN;
% bad=find(chi.T2<1.1);
% chi.T2(bad)=NaN;
% if strcmp(num2str(unit),'316')
%     bad=find(chi.time>datenum(2008,5,27,8,0,0));
%     chi.T1(bad)=NaN;
% end

% plot the data
figure(1), clf
s(1)=subplot(2,1,1);
plot(sb.time1,sb.t1,'k.')
datetick
title('Seabird')
set(gca,'xlim',[sb.time1(1) sb.time1(end)])
s(2)=subplot(2,1,2);
hold on
plot(chi.time,chi.T1,'k.')
if isfield(chi,'T2')
    plot(chi.time,chi.T2,'r.')
end
kdatetick
if isfield(chi,'T2')
    legend(['T1: ' ttop],['T2: ' tbot])
else
    legend(['T1: ' ttop])
end
title(['Chipod ' num2str(unit)])
set(gca,'xlim',[sb.time1(1) sb.time1(end)])
linkaxes(s,'x')
print('-dpng','-r200',[sbdir '\' num2str(unit) 'seabird_T']);

%% calibrate
clear cal
for i=1:max(sb.count1)
    in=find(sb.count1==i);
    sbt=sb.t1(in);
    time=sb.time1(in);
%     good=find(time>time(1)+1/24/12 & time<time(end)-1/24/12);
    good=find(time>time(1)+1/24/10 & time<time(end)-1/24/12);
    time=time(good);
    cal.sbt(i)=nanmean(sbt(good));
    cal.chiv(i)=nanmean(chi.T1(find(chi.time>time(1) & chi.time<time(end))));
end  
good=find(~isnan(cal.chiv));
if ~isempty(good)
    cal.chiv=cal.chiv(good);
    cal.sbt=cal.sbt(good);
end
v=min(cal.chiv):0.01:max(cal.chiv); 
p=polyfit(cal.chiv,cal.sbt,polinom_order);
coeff.T1(1:polinom_order+1)=fliplr(p);
% coeff.T1=head.coef.T1;
figure(3),clf
subplot(3,1,1)
plot(v,coeff.T1(1)+coeff.T1(2).*v+coeff.T1(3).*v.^2+coeff.T1(4).*v.^3,'k-')
if ~isnan(v)
    set(gca,'ylim',tlims,'xlim',[min(v) max(v)]);
end
xlabel('V')
ylabel('Fit T')
title(['Unit ' num2str(unit) ' T1 (' ttop '): ' num2str(coeff.T1(1)) ' + ' num2str(coeff.T1(2))...
    '\cdotV + ' num2str(coeff.T1(3)) '\cdotV^2 + ' num2str(coeff.T1(4)) '\cdotV^3'])
subplot(3,1,2)
plot(cal.sbt,'b.')
hold on
plot(coeff.T1(1)+coeff.T1(2).*cal.chiv+coeff.T1(3).*cal.chiv.^2+coeff.T1(4).*cal.chiv.^3,'r.')
legend('Seabird T','Chipod T1','location','best')
ylabel('T [\circC]')
subplot(3,1,3)
plot(coeff.T1(1)+coeff.T1(2).*cal.chiv+coeff.T1(3).*cal.chiv.^2+coeff.T1(4).*cal.chiv.^3-cal.sbt,'b.')
legend('Chipod T1 - Seabird T','location','best')
ylabel('T [\circC]')
print('-dpng','-r200',[sbdir '\' num2str(unit) 'T1cals']);
if isfield(chi,'T2')
clear cal
for i=1:max(sb.count2)
    in=find(sb.count2==i);
    sbt=sb.t2(in);
    time=sb.time2(in);
    good=find(time>time(1)+1/24/12 & time<time(end)-1/24/12);
    time=time(good);
    cal.sbt(i)=nanmean(sbt(good));
    cal.chiv(i)=nanmean(chi.T2(find(chi.time>time(1) & chi.time<time(end))));
end    
good=find(~isnan(cal.chiv));
if ~isempty(good)
    cal.chiv=cal.chiv(good);
    cal.sbt=cal.sbt(good);
end
v=min(cal.chiv):0.01:max(cal.chiv); 
p=polyfit(cal.chiv,cal.sbt,polinom_order);
coeff.T2(1:polinom_order+1)=fliplr(p);

figure(4),clf
subplot(3,1,1)
plot(v,coeff.T2(1)+coeff.T2(2).*v+coeff.T2(3).*v.^2+coeff.T2(4).*v.^3,'k-')
if ~isnan(v)
    set(gca,'ylim',tlims,'xlim',[min(v) max(v)]);
end
xlabel('V')
ylabel('Fit T')
title(['Unit ' num2str(unit) ' T2 (' tbot '): ' num2str(coeff.T2(1)) ' + ' num2str(coeff.T2(2))...
    '\cdotV + ' num2str(coeff.T2(3)) '\cdotV^2 + ' num2str(coeff.T2(4)) '\cdotV^3'])
subplot(3,1,2)
plot(cal.sbt,'b.')
hold on
plot(coeff.T2(1)+coeff.T2(2).*cal.chiv+coeff.T2(3).*cal.chiv.^2+coeff.T2(4).*cal.chiv.^3,'r.')
legend('Seabird T','Chipod T2','location','best')
ylabel('T [\circC]')
subplot(3,1,3)
plot(coeff.T2(1)+coeff.T2(2).*cal.chiv+coeff.T2(3).*cal.chiv.^2+coeff.T2(4).*cal.chiv.^3-cal.sbt,'b.')
legend('Chipod T2 - Seabird T','location','best')
ylabel('T [\circC]')
print('-dpng','-r200',[sbdir '\' num2str(unit) 'T2cals']);
end
save([sbdir 'calcoeff' num2str(unit)],'coeff')
