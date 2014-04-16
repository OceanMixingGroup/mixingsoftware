% plot sonar spectra for u and v...

load MooringDeploy
depthr = [20 90];

u = real(sonar.u);
v= imag(sonar.u);

indepth = find(sonar.ranges(:,1)>=depthr(1) & sonar.ranges(:,1)<=depthr(:,2));
intime = find(sonar.time>=datenum(2004,1,19,18,0,0) & sonar.time<=datenum(2004,1,19,23,0,0)); 

subplot(4,1,1);
imagesc(sonar.time,sonar.ranges(:,1),u);
kdatetick;
caxis([-1 1]);
putonleft(title('U'));
hold on;
plot(sonar.time,0*sonar.time+depthr(1));
plot(sonar.time,0*sonar.time+depthr(2));

subplot(4,1,2);
imagesc(sonar.time,sonar.ranges(:,1),v);
kdatetick;
caxis([-1 1]);
putonleft(title('V'));
hold on;
plot(sonar.time,0*sonar.time+depthr(1));
plot(sonar.time,0*sonar.time+depthr(2));

subplot(4,1,3);
imagesc(sonar.time,sonar.ranges(:,1),log10(sonar.int));
kdatetick;
putonleft(title('V'));
hold on;
plot(sonar.time,0*sonar.time+depthr(1));
plot(sonar.time,0*sonar.time+depthr(2));

for i=1:length(indepth);
  subplot(4,1,4);
  [p,f] = fast_psd(u(indepth(i),intime),512,1);
  loglog(f,p);
  hold on;
  [p,f] = fast_psd(v(indepth(i),intime),512,1);
  loglog(f,p,'r');
  
end;
legend('U','V');

