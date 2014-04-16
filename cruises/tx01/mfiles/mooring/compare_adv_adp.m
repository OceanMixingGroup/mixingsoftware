% plot_advtimeseries
%
load c:\work\data\analysis\yaq01\matfiles\adp_timeseries
load c:\work\data\analysis\yaq01\matfiles\adv_timeseries

datelim=[datenum(2001,4,26,19,0,0),datenum(2001,4,26,22,20,0)];

figure(1);clf;orient tall

adp.uu=adp.u(1:3,:);
adp.vv=adp.v(1:3,:);
adp.ww=adp.w(1:3,:);

subplot(411),plot(adv.time,-adv.velx/100,'y',adp.time,100*adp.uu);grid;datetick
ylabel('V_x [cm/s]')
set(gca,'xticklabel','','xlim',datelim,'ylim',[-50 25])
title('Yaquina Bay - 26 April 2001   ADVO(y), ADP([bins(1:3)]) ')

subplot(412),plot(adv.time,adv.vely/100,'y',adp.time,100*adp.vv);grid;datetick
ylabel('V_y [cm/s]')
set(gca,'xticklabel','','xlim',datelim,'ylim',[-75 0])

subplot(413),plot(adv.time,adv.velz/100,'y',adp.time,100*adp.ww);grid;datetick
ylabel('V_z [cm/s]')
set(gca,'xticklabel','','xlim',datelim,'ylim',[-20 20])

% compute speed
adv.spd=sqrt((adv.velx).^2 + (adv.vely).^2 + (adv.velz).^2);
adp.spd=sqrt((adp.uu).^2 + (adp.vv).^2 + (adp.ww).^2);

subplot(414),plot(adv.time,adv.spd/100,'y',adp.time,100*adp.spd,'r');grid;datetick
set(gca,'xlim',datelim,'ylim',[0 80])
ylabel('Speed [cm/s]')