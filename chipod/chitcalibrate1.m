function chitcalibrate1(sbdir,unit,ttop,tbot,polinom_order)
% unit is chipod unit number(integer)
% ttop is top sensor ID, tbot is bottom sensor ID (strings)
% sbdir is a directory where seabird data are saved
% chipod data should be under sbdir\num2str(unit)\
%  modified to make sure it prints right figures from gui call
%  and not the figure of the gui itself
%
%  This version also uses only 2nd order polynomial fit
%  MJB  7/10/13


polinom_order=2;

% Load and plot data 
load([sbdir '\' num2str(unit) '_T']);

% chi.time(length(chi.time)) = []
%  chi.T2(length(chi.T1)) = []
% display(length(chi.time))
% display(length(chi.T1))
A = length(chi.time)/(length(chi.T1));
 display(A);
% if length(chi.time)==2*length(chi.T1)
if A == 2
    chi.time=chi.time(1:2:end);
end
coeff.T1=[0 0 0 0 0];
coeff.T2=[0 0 0 0 0];
tlims=[min(sbe.temp)-1 max(sbe.temp)+1];
% plot the data
fig1hdl = figure(1); clf;
s(1)=subplot(2,1,1);
plot(sbe.time,sbe.temp,'k.')
datetick
title('Seabird')
set(gca,'xlim',[sbe.time(1) sbe.time(end)])
s(2)=subplot(2,1,2);
hold on
plot(chi.time,chi.T1,'b.')
if isfield(chi,'T2')
    plot(chi.time,chi.T2,'r.')
end
kdatetick
if isfield(chi,'T2')
    legend(['T1: ' ttop],['T2: ' tbot],'location','best')
else
    legend(['T1: ' ttop],'location','best')
end
title(['Chipod ' num2str(unit)])
set(gca,'xlim',[sbe.time(1) sbe.time(end)])
linkaxes(s,'x')
print(fig1hdl,'-dpng','-r200',[sbdir '\' num2str(unit) 'seabird_T']);

% calibrate  top thermistor
clear cal
% cal.chiv = [3.077 3.205]
for ii=1:max(sbe.count)
    in=find(sbe.count==ii);
    sbt=sbe.temp(in);
    time=sbe.time(in);
    sze_in = size(in);
%     display(sze_in(:,2));
%calculates the time size of the plateau length and halves it. If its odd number then 
%converts into the preceeding even number. For Ex: if size = 75 
%then sze_in = 0.5*(75-1) = 37. 
    if mod(sze_in(:,2),2) == 0
        sze = 0.5*sze_in(:,2)
    else
        sze = 0.5*(sze_in(:,2)-1)
    end
    
% end

%  shrink in the time used by calculations by taking the last half of plateau
    good=find(time>time(sze) & time<time(end));
    time1=time(good);
    
    % find the Seabird  mean value over the shrunken interval
    cal.sbt(ii)=nanmean(sbt(good));
      % find the Chipod mean value over the shrunken interval
    cal.chiv1(ii)=nanmean(chi.T1(chi.time>time1(1) & chi.time<time1(10)));
end  
% cal.chiv1 = [3.079 3.239 3.393 3.542 3.679];

% display(cal.chiv1);
% display(cal.sbt);
good=find(~isnan(cal.chiv1));
if ~isempty(good)
    cal.chiv1=cal.chiv1(good);
    cal.sbt=cal.sbt(good);
end
v=min(cal.chiv1):0.01:max(cal.chiv1); 
p=polyfit(cal.chiv1,cal.sbt,polinom_order);
coeff.T1(1:polinom_order+1)=fliplr(p);

% coeff.T1=head.coef.T1;
fig3hdl = figure(3); clf;
subplot(3,1,1)

%assume polinom_order==2
    plot(v,coeff.T1(1)+coeff.T1(2).*v+coeff.T1(3).*v.^2,'b-')
    title(['Unit ' num2str(unit) ' T1 (' ttop '): ' num2str(coeff.T1(1)) ' + ' num2str(coeff.T1(2))...
        '\cdotV + ' num2str(coeff.T1(3)) '\cdotV^2'])

if ~isnan(v)
    set(gca,'ylim',tlims,'xlim',[min(v) max(v)]);
end
xlabel('V')
ylabel('Fit T')
subplot(3,1,2)
plot(cal.sbt,'k.','markersize',10)
hold on
%assume  polinom_order==2
    plot(coeff.T1(1)+coeff.T1(2).*cal.chiv1+coeff.T1(3).*cal.chiv1.^2,'b.','markersize',10)

legend('Seabird T','Chipod T1','location','best')
ylabel('T [\circC]')
subplot(3,1,3)
%assume polinom_order==2
    plot(coeff.T1(1)+coeff.T1(2).*cal.chiv1+coeff.T1(3).*cal.chiv1.^2-cal.sbt,'c.','markersize',10)

legend('Chipod T1 - Seabird T','location','best')
ylabel('T [\circC]')
print(fig3hdl,'-dpng','-r200',[sbdir '\' num2str(unit) 'T1cals']);
if isfield(chi,'T2')
clear cal
%refer to comments for T1 above for methodology used in calculations below.
%
for ii=1:max(sbe.count)
    in=find(sbe.count==ii);
    sbt=sbe.temp(in);
    time=sbe.time(in);
    sz_in = size(in);
    if mod(sz_in(:,2),2) == 0
        in_1 = 0.5*(sz_in(:,2));
        
    else
        in_1 = 0.5*(sz_in(:,2)-1);
    end
    
    good=find(time>time(in_1) & time<time(end));
    time1=time(good);
    cal.sbt(ii)=nanmean(sbt(good));
    cal.chiv2(ii)=nanmean(chi.T2(chi.time>time1(1) & chi.time<time1(10)));
end   
% cal.chiv2 = [3.057 3.188 3.311 3.427 3.536];
good=find(~isnan(cal.chiv2));
if ~isempty(good)
    cal.chiv2=cal.chiv2(good);
    cal.sbt=cal.sbt(good);
end
v=min(cal.chiv2):0.01:max(cal.chiv2) 
p=polyfit(cal.chiv2,cal.sbt,polinom_order);
coeff.T2(1:polinom_order+1)=fliplr(p);

fig4hdl = figure(4); clf;
subplot(3,1,1)
%assume polinom_order==2
    plot(v,coeff.T2(1)+coeff.T2(2).*v+coeff.T2(3).*v.^2,'r-')
    title(['Unit ' num2str(unit) ' T2 (' tbot '): ' num2str(coeff.T2(1)) ' + ' num2str(coeff.T2(2))...
        '\cdotV + ' num2str(coeff.T2(3)) '\cdotV^2'])

if ~isnan(v)
    set(gca,'ylim',tlims,'xlim',[min(v) max(v)]);
end
xlabel('V')
ylabel('Fit T')
subplot(3,1,2)
plot(cal.sbt,'k.')
hold on
%assume  polinom_order==2
    plot(coeff.T2(1)+coeff.T2(2).*cal.chiv2+coeff.T2(3).*cal.chiv2.^2,'r.','markersize',10)
legend('Seabird T','Chipod T2','location','best')
ylabel('T [\circC]')
subplot(3,1,3)
%assume polinom_order==2
    plot(coeff.T2(1)+coeff.T2(2).*cal.chiv2+coeff.T2(3).*cal.chiv2.^2-cal.sbt,'m.','markersize',10)
legend('Chipod T2 - Seabird T','location','best')
ylabel('T [\circC]')
print(fig4hdl,'-dpng','-r200',[sbdir '\' num2str(unit) 'T2cals']);
end
save([sbdir 'calcoeff' num2str(unit)],'coeff')