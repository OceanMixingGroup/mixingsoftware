% chipod_checkout

figure(61);clf;clear hax
hax(1)=subplot(311);
plot(data.datenum(1:2:end),data.T1);hold on
plot(data.datenum(1:2:end),data.T2,'r');
ylabel('T')
kdatetick

hax(2)=subplot(312);
plot(data.datenum,data.T1P);hold on
plot(data.datenum,data.T2P,'r');
ylabel('TP')
kdatetick

hax(3)=subplot(313);
plot(data.datenum(1:20:end),data.CMP)
ylabel('CMP')
kdatetick
linkaxes(hax,'x')

figure(62);clf
subplot(311)
plot(data.datenum(1:2:end),data.P);hold on
ylabel('P')
kdatetick

subplot(312)
plot(data.datenum(1:2:end),data.AX);hold on
plot(data.datenum(1:2:end),data.AY,'r');
plot(data.datenum(1:2:end),data.AZ,'b');
ylabel('Acc')
kdatetick

subplot(313)
plot(data.datenum(1:2:end),data.DP1);hold on
plot(data.datenum(1:2:end),data.DP2,'r');
plot(data.datenum(1:2:end),data.DP3,'b');
ylabel('DP')
kdatetick

figure(63);clf
plot(data.datenum(1:20:end),data.VA);hold on
plot(data.datenum(1:20:end),data.VD,'r')
ylabel('voltages')
kdatetick
