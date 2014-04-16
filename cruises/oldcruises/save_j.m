for i=[106:106];
q.script.num=i;
q.script.prefix='ch98a';
q.script.pathname='e:\';
clear cal data

raw_load

cali_j

%do other stuff
idx=find(cal.P>15 & cal.P<35);
g=9.81;
az_g=-cal.AZ*g; % Body acceleration in m/s^2
sr=head.slow_samp_rate; % slow SR
fn=sr/2; % Nyquist
hpc=0.02; % highpass cutoff frequency
[bh,ah]=cheby2(5,40,hpc*head.irep.AZ/fn,'high');%chebyshev coeffs.
azf=filtfilt(bh,ah,az_g);
vaz=100*cumsum(azf-mean(azf(idx)))/(head.irep.AZ*head.slow_samp_rate); %velocity of vehicle
figure(1)
clf
subplot(151),plot(data.W,-cal.P,'b.','MarkerSize',.1);grid on
ylabel('Depth [m]')
xlabel('w [volts]')
%hold on
subplot(152),plot(cal.FALLSPD,-cal.P,'r.','MarkerSize',.1);grid on
xlabel('fall speed [cm/s]')
%hold on
subplot(153),plot(cal.T1,-cal.P,'c.','MarkerSize',.1);grid on
xlabel('temperature [C]')
%hold on
subplot(154),plot(vaz(1:head.irep.AZ:length(vaz)),-cal.P,'m.','MarkerSize',.1);grid on
xlabel('Vaz')
subplot(155),plot(cal.AY_TILT(1:head.irep.AY:length(cal.AY_TILT)),-cal.P,'g.','MarkerSize',.1);grid on
xlabel('Tilt')
%figure(2)
%plot((cal.FALLSPD).^2,data.W,'c.','MarkerSize',.1);grid on
%xlabel('fallspeed^2 [(cm/s)^2]')
%ylabel('w [volts]')
%hold on
%figure(3)
%plot(cal.T1,data.W,'m.','MarkerSize',.1);grid on
%xlabel('temperature [C]')
%ylabel('w [volts]')
%hold on
pause
end
