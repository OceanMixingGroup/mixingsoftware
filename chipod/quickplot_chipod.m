close all
clear all

[data head]=raw_load_chipod

plot(data.T1,'b')
hold on
plot(data.T1P(1:2:end),'b')
plot(data.T2,'c')
plot(data.T2P(1:2:end),'c')
plot(data.W2,'r')
plot(data.W3,'r')
plot(data.AX,'m')
plot(data.AY,'y')
plot(data.AZ,'k')
plot(data.P,'Color',[1 .5 0])

figure
plot(data.CMP);