%pwp_InspectOutput  Inspect output of matlab PWP run
%
%
% Run after readoutput.m or 
% load saved output of readoutput

%load pwp_ed4_out

fluxtimeM = time; % Adjustment for matlab yearday
ind = tstart:tstop;

figure

subplot(3,1,1)
plot(fluxtimeM(ind),taux(ind))
hold on
plot(fluxtimeM(ind),tauy(ind),'r')
datetick('x',6,'keepticks','keeplimits')
axis tight
grid
legend('\tau_x','\tau_y',0)
ylabel('N/m^2')


subplot(3,1,2)
plot(fluxtimeM(ind),thf(ind)+rhf(ind))
datetick('x',6,'keepticks','keeplimits')
axis tight
grid
legend('Q_{net}')
ylabel('W/m^2')

subplot(3,1,3)
plot(fluxtimeM(ind),temp(:,1))
hold on
plot(ztimetemp1n(ind),ztemp1n(ind,1),'r')
axis tight
grid
legend('Model SST','Obs SST (interpd)')
ylabel('^\circC')
datetick('x',6,'keepticks','keeplimits')


figure
contourf(ztimetemp1n(ind),zdepthtemp1n(1:15),ztemp1n(ind,1:15)',[27.5:.25:30.])
shading flat
set(gca,'ydir','reverse')
hold on
scatter(ztimetemp1n(ind(1))+0.*zdepthtemp1n,zdepthtemp1n,'yo','filled')
%datetick('x',6,'keepticks','keeplimits')
title('Observed temperature')
caxis([27.5 30])
colorbar
gregaxd(ztimetemp1n(ind),1)


figure
contourf(time(ind),z(1:40),temp(:,1:40)',[27.5:.25:30.])
shading flat
set(gca,'ydir','reverse')
title('Modeled temperature')
caxis([27.5 30])
colorbar
gregaxd(time(ind),1)




figure
contourf(ztimetemp1n(ind),zdepthtemp1n(1:20),ztemp1n(ind,1:20)',[24.5:.25:30.])
shading flat
set(gca,'ydir','reverse')
hold on
scatter(ztimetemp1n(ind(1))+0.*zdepthtemp1n,zdepthtemp1n,'yo','filled')
%datetick('x',6,'keepticks','keeplimits')
title('Observed temperature')
%caxis([27.5 30])
colorbar
gregaxd(ztimetemp1n(ind),1)


figure
contourf(time(ind),z(1:90),temp(:,1:90)',[24.5:.25:30.])
shading flat
set(gca,'ydir','reverse')
title('Modeled temperature')
%caxis([27.5 30])
colorbar
gregaxd(time(ind),1)
