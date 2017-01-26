function gust_calibrate(sbdir,unit,ttop,polinom_order)
% unit is gust unit number(integer)
% ttop is top sensor ID, tbot is bottom sensor ID (strings)
% sbdir is a directory where seabird data are saved
% gust data should be under sbdir\unit\
%  modified to make sure it prints right figures from gui call
%  and not the figure of the gui itself
%
%  This version also uses only 2nd order polynomial fit
%  MJB  7/10/13


polinom_order=2;

% Load and plot data 
load([sbdir '\' unit '_T.mat']);

% gst.time(length(gst.time)) = []
%  gst.T2(length(gst.T)) = []
% display(length(gst.time))
% display(length(gst.T))
A = length(gst.time)/(length(gst.T));
%  display(A);
% if length(gst.time)==2*length(gst.T)

coeff.T=[0 0 0 0 0];
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
plot(gst.time,gst.T,'b.')

datetick

    legend(['T: ' ttop],'location','best')

title(['GusT ' unit])
set(gca,'xlim',[sbe.time(1) sbe.time(end)])
linkaxes(s,'x')
print(fig1hdl,'-dpng','-r200',[sbdir '\' unit 'seabird_T']);

% calibrate  top thermistor
clear cal
% cal.gstv = [3.077 3.205]
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
        sze = 0.5*sze_in(:,2);
    else
        sze = 0.5*(sze_in(:,2)-1);
    end
    
% end

%  shrink in the time used by calculations by taking the last half of plateau
    good=find(time>time(sze) & time<time(end));
    time1=time(good);
    
    % find the Seabird  mean value over the shrunken interval
    cal.sbt(ii)=nanmean(sbt(good));
      % find the gust mean value over the shrunken interval
    cal.gstv1(ii)=nanmean(gst.T(gst.time>time1(1) & gst.time<time1(10)));
end  
% cal.gstv1 = [1.261 1.436 1.607 1.776 1.94 2.101 2.257 2.409 2.556];

% display(cal.gstv1);
% display(cal.sbt);
good=find(~isnan(cal.gstv1));
if ~isempty(good)
    cal.gstv1=cal.gstv1(good);
    cal.sbt=cal.sbt(good);
end
v=min(cal.gstv1):0.01:max(cal.gstv1); 
p=polyfit(cal.gstv1,cal.sbt,polinom_order);
coeff.T(1:polinom_order+1)=fliplr(p);

% coeff.T=head.coef.T;
fig3hdl = figure(3); clf;
subplot(3,1,1)

%assume polinom_order==2
    plot(v,coeff.T(1)+coeff.T(2).*v+coeff.T(3).*v.^2,'b-')
    title(['Unit ' unit ' T (' ttop '): ' num2str(coeff.T(1)) ' + ' num2str(coeff.T(2))...
        '\cdotV + ' num2str(coeff.T(3)) '\cdotV^2'])

if ~isnan(v)
    set(gca,'ylim',tlims,'xlim',[min(v) max(v)]);
end
xlabel('V')
ylabel('Fit T')
subplot(3,1,2)
plot(cal.sbt,'k.','markersize',10)
hold on
%assume  polinom_order==2
    plot(coeff.T(1)+coeff.T(2).*cal.gstv1+coeff.T(3).*cal.gstv1.^2,'b.','markersize',10)

legend('Seabird T','gust T','location','best')
ylabel('T [\circC]')
subplot(3,1,3)
%assume polinom_order==2
    plot(coeff.T(1)+coeff.T(2).*cal.gstv1+coeff.T(3).*cal.gstv1.^2-cal.sbt,'c.','markersize',10)

legend('gust T - Seabird T','location','best')
ylabel('T [\circC]')
print(fig3hdl,'-dpng','-r200',[sbdir '\' unit 'Tcals']);


save([sbdir 'calcoeff' unit],'coeff')