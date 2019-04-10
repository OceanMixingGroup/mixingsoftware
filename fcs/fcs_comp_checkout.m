%Script to run the checkout file of FCS to check the sensor voltage levels when it ready for shipping or 
%deployment
%This runs [comp] = raw_load_solo() and plots the compressed sensor comp

%Pavan Vutukur 05/14/18

[comp] = comp_load_solo();
figure(1)
ax(1) = subplot(4,1,1);
plot(comp.time,comp.t1Mean,comp.time,comp.t2Mean);
legend('T1','T2')
title('T: Temperature Sensor MEAN');
ylabel('volts');
datetick;

ax(2) = subplot(4,1,2);
plot(comp.time,comp.t1PVar,comp.time,comp.t2PVar);
legend('T1P','T2P');
title('TP: Temperature Differentiator Signal VARIANCE');
ylabel('volts');
datetick;

ax(3) = subplot(4,1,3);
plot(comp.time,comp.wMean,'green');
title('W: Pitot Sensor MEAN');
ylabel('volts');
datetick;

ax(4) = subplot(4,1,4);
plot(comp.time,comp.s1Var,comp.time,comp.s2Var);
legend('S1','S2');
title('Shear sensor signals VARIANCE');
ylabel('volts');
datetick;
linkaxes(ax,'x');

figure(2)
bx(1) = subplot(4,1,1);
plot(comp.time,comp.axMean,'red')
title('AX: Accelerometer MEAN')
ylabel('Volts')
datetick;

bx(2) = subplot(4,1,2);
plot(comp.time,comp.ayMean,'blue')
title('AY: Accelerometer MEAN')
ylabel('volts')
datetick;

bx(3) = subplot(4,1,3);
plot(comp.time,comp.azMean,'green')
title('AZ: Accelerometer MEAN')
ylabel('volts')
datetick;


bx(4) = subplot(4,1,4);
plot(comp.time,comp.pMean,'k');
title('P: Pressure sensor MEAN')
ylabel('volts')
datetick;
linkaxes(bx,'x');

figure(3)
cx(1) = subplot(3,1,1);
plot(comp.time,comp.headingMean,'red')
title('Compass: Heading Angle MEAN')
ylabel('Angle in Deg')
datetick;

cx(2) = subplot(3,1,2);
plot(comp.time,comp.pitchMean,'blue')
title('Compass: Pitch Angle MEAN') 
ylabel('Angle in Deg')
datetick;

cx(3) = subplot(3,1,3);
plot(comp.time,comp.rollMean,'k')
title('Compass: Roll Angle MEAN')
ylabel('Angle in Deg')
datetick;
linkaxes(cx,'x');


figure(4)
dx(1) = subplot(4,1,1);
plot(comp.time,comp.t1Var,comp.time,comp.t2Var);
legend('T1','T2')
title('T: Temperature Sensor VARIANCE');
ylabel('volts');
datetick;

dx(2) = subplot(4,1,2);
plot(comp.time,comp.t1PAmplitudes,comp.time,comp.t2PAmplitudes);
legend('T1P','T2P');
title('TP: Temperature Differentiator Signal AMPLITUDES');
ylabel('volts');
datetick;

dx(3) = subplot(4,1,3);
plot(comp.time,comp.wVar,'green');
title('W: Pitot Sensor VARIANCE');
ylabel('volts');
datetick;

dx(4) = subplot(4,1,4);
plot(comp.time,comp.s1Amplitudes,comp.time,comp.s2Amplitudes);
legend('S1','S2');
title('Shear sensor signals AMPLITUDES');
ylabel('volts');
datetick;
linkaxes(dx,'x');



