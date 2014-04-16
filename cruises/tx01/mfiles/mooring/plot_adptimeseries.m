% plot adp time series

load c:\work\data\analysis\yaq01\matfiles\adp_timeseries
datelim=[datenum(2001,4,26,19,0,0),datenum(2001,4,26,22,20,0)]

figure(1);clf;orient tall

subplot(811),plot(adp.time,-adp.pressure);datetick
set(gca,'xticklabels','')
set(gca,'ylim',[-16 0],'xlim',datelim)
ylabel('P [dbar]')
title('Yaquina Bay - 26 April 2001')

subplot(812),plot(adp.time,adp.hdg);datetick
set(gca,'xticklabels','')
set(gca,'ylim',[0 90],'xlim',datelim)
ylabel('Heading')

subplot(813),plot(adp.time,adp.pitch);datetick
set(gca,'xticklabels','')
set(gca,'ylim',[-2 2],'xlim',datelim)
ylabel('pitch')

subplot(814),plot(adp.time,adp.roll);datetick
set(gca,'xticklabels','')
set(gca,'ylim',[-2 2],'xlim',datelim)
ylabel('roll')

subplot(815),plot(adp.time,adp.temp);datetick
set(gca,'xticklabels','')
set(gca,'ylim',[10.5 12.5],'xlim',datelim)
ylabel('T')

subplot(816),plot(adp.time,adp.mn_u);datetick
set(gca,'xticklabels','')
set(gca,'ylim',[-.5 .25],'xlim',datelim)
ylabel('u')

subplot(817),plot(adp.time,adp.mn_v);datetick
set(gca,'xticklabels','')
set(gca,'ylim',[-.75 0],'xlim',datelim)
ylabel('v')

subplot(818),plot(adp.time,adp.mn_w);datetick
set(gca,'ylim',[-.1 .1],'xlim',datelim)
ylabel('w')


figure(2);clf;orient tall
bins=2:1:11;

subplot(311),imagesc(adp.time,-bins,adp.u);datetick
ylabel('height above bottom')
set(gca,'xticklabel','','xlim',datelim)
caxis([-.5,.25])
title('Yaquina Bay - 26 April 2001')

subplot(312),imagesc(adp.time,-bins,adp.v);datetick
set(gca,'xticklabel','','xlim',datelim)
caxis([-.75,0])

subplot(313),imagesc(adp.time,-bins,adp.w);datetick
set(gca,'xlim',datelim)
caxis([-.1 .1])
