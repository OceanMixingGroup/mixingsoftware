% plot_advtimeseries
%

datelim=[datenum(2001,4,26,19,0,0),datenum(2001,4,26,22,20,0)];

figure(1);clf;orient tall

subplot(411),plot(adv.time,adv.ampx,adv.time,adv.ampy,adv.time,adv.ampz);grid;datetick
legend('ampx','ampy','ampz')
ylabel('amplitude')
title('Yaquina Bay - 26 April 2001   ADVO')
set(gca,'xticklabel','','xlim',datelim)

subplot(412),plot(adv.time,-adv.velx/100);grid;datetick
ylabel('V_x [cm/s]')
set(gca,'xticklabel','','xlim',datelim,'ylim',[-50 25])

subplot(413),plot(adv.time,adv.vely/100);grid;datetick
ylabel('V_y [cm/s]')
set(gca,'xticklabel','','xlim',datelim,'ylim',[-75 0])

subplot(414),plot(adv.time,adv.velz/100);grid;datetick
ylabel('V_z [cm/s]')
set(gca,'xlim',datelim,'ylim',[-20 20])

