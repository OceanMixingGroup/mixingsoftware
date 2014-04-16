
%%  heading issues...
% the ADU heading is unbiased but spiky and noisy.  The gyro heading has
% biases.
adu = despike(bigtrim.ADUheading,10,0.05);
% now get lowpassed version over last hour
b = ones(60,1)/60;a=1;
good = find(~isnan(adu));
bad = find(isnan(adu));
adu(good) = filtfilt(b,a,adu(good));
adu = interp1(good,adu(good),1:length(adu));
gyro = bigtrim.heading+adu-filtfilt(b,a,bigtrim.heading);
% when averaged appropriately, adu is pretty good, so lets use that
% except when there is a NaN, then use gyro
adu = despike(bigtrim.ADUheading,10,0.05);
heading = adu;
heading(bad) = gyro(bad);

if 0
  % revert to along/across..
  phi = bigtrim.heading; 
  bigtrim.shipco = bigtrim.u.*repmat(exp(sqrt(-1)*phi),size(bigtrim.u,1),1);
  % across ship is real, along-ship is imag.
  if ~isfield(bigtrim,'oldu'); 
    bigtrim.oldu = bigtrim.u;
  end; 
  % use the new heading...
  phi =  heading+5*pi/180;
  bigtrim.u = bigtrim.shipco.*repmat(exp(-sqrt(-1)*(phi)),size(bigtrim.u,1),1);
end; 

ind= 7500:8500;
ind= 2300:2600;

if ~isfield(bigtrim,'oldship');
  bigtrim.oldship = bigtrim.ship;
end;
[dist,ang]=sw_dist([bigtrim.pcode_lat],[bigtrim.pcode_lon],'km');
time = bigtrim.time(1:end-1)+diff(bigtrim.time)/2;
ang = ang;
bigtrim.ship = interp1(time,dist*100.*exp(sqrt(-1)*ang*pi/180),bigtrim.time);



figure(12)
for an = [-3:3]
  an
  clf
  a(1)=subplot(3,1,1);
  imagesc(real(bigtrim.u.*exp(sqrt(-1)*an*pi/180)+repmat(bigtrim.ship,size(bigtrim.u,1),1)))
  caxis([-1 1]*0.3);
  a(2)=subplot(3,1,2);
  imagesc(imag(bigtrim.u.*exp(sqrt(-1)*an*pi/180)+repmat(bigtrim.ship,size(bigtrim.u,1),1)))
  caxis([-1 1]*0.3);
  a(3)=subplot(3,1,3);
  plot(bigtrim.heading);
  %set(a,'xlim',[1900 2200]);
  matchx(1);
  ppause;
end;
ppause

% ships velocity is best from this.  The sog given by the pcode appears
% bad...


figure(1)
plot(bigtrim.time(ind),heading(ind),bigtrim.time(ind),bigtrim.heading(ind),bigtrim.time(ind), ...
     adu(ind));
legend('Corrected Heading','Original Heading','ADU Heading');
kdatetick;

%% Mean Vels...
% take the mean over a region of data we know is OK.
bigtrim.meanvel = nanmean(bigtrim.u(10:30,:));
bigtrim.meanw = nanmean(bigtrim.w(10:30,:));

%% plot of sog...
figure(2);
subplot(3,1,1);
plot(bigtrim.time(ind),abs(bigtrim.meanvel(ind)),bigtrim.time(ind),abs(bigtrim.ship(ind)));
set(gca,'ylim',[0 7]);
kdatetick;
ylabel('|U| [m s^{-1}]');
legend('Sonar','Ship');

subplot(3,1,2);
plot(bigtrim.time(ind),angle(bigtrim.meanvel(ind))*180/pi+heading(ind)*180/pi,bigtrim.time(ind),angle(-bigtrim.ship(ind))*180/pi);
%set(gca,'ylim',[0 7]);
kdatetick;
ylabel('dir');
legend('Sonar','Ship');

subplot(3,1,3);
plot(bigtrim.time(ind),abs(bigtrim.meanvel(ind))-abs(bigtrim.ship(ind)));
set(gca,'ylim',[-1 1]);
kdatetick;
ylabel('\Delta abs(U) [m s^{-1}]');

%% Heading error?
% If the ADU really does not have a heading dependant error, then this
% should just be a single rotation.

for an = [-3:3]
  an
  % remove the old heading and add the 
  u = bigtrim.u*exp(sqrt(-1)*an*pi/180);
  newmeanu = nanmean(u(10:30,:));
  
  bigtrim.U = u+repmat(bigtrim.ship,size(bigtrim.u,1),1);
  
  % plot and see how the heading calc is going
  figure(3);clf
  agutwocolumn(0.9);wysiwyg;
  subplot(6,1,1);
  plot(bigtrim.time(ind),heading(ind)*180/pi-an);
  kdatetick;
  subplot(6,1,2);
  plot(bigtrim.time(ind),abs(nanmean(u(10:30,ind)))-abs(bigtrim.ship(ind)));
  kdatetick;
  
  subplot(3,1,2);
  uu = real(u);
  vv =imag(u);
  plot(bigtrim.time(ind),-nanmean(uu(10:30,ind)));hold on;
  plot(bigtrim.time(ind),-nanmean(vv(10:30,ind)),'r');
  % the correction applied is very slight and does not account for what
  % we are seeing....
  plot(bigtrim.time(ind),-real(bigtrim.meanvel(ind)),'col',[1 1 1]*0.4);
  plot(bigtrim.time(ind),real(bigtrim.ship(ind)),'b');hold on;
  plot(bigtrim.time(ind),imag(bigtrim.ship(ind)),'m');hold on;
  legend('Sonar U','Sonar V','Ship U','Ship V');
  
  kdatetick;
  
  subplot(3,1,3);
  plot(bigtrim.time(ind),nanmean(uu(10:30,ind))+real(bigtrim.ship(ind)));hold on;
  plot(bigtrim.time(ind),nanmean(vv(10:30,ind))+imag(bigtrim.ship(ind)),'r');
  legend('Sonar U-Ship U','Sonar V-Ship V');
  set(gca,'ylim',[-1 1]);
  kdatetick;
  ppause;
end;


ang = atan2(imag(newmeanu),real(newmeanu));
shipang = atan2(imag(-bigtrim.ship),real(-bigtrim.ship));
figure(4);
clf
b=ones(1,30)/30;a=1;
subplot(2,1,1);
plot(bigtrim.time,180*(ang-shipang)/pi,bigtrim.time,gappy_filter(b,a,180*(ang-shipang)/pi,10));
kdatetick;
ylabel('\Delta Vel Dir');

subplot(2,1,2);
plot(bigtrim.time,180*(shipang)/pi,bigtrim.time,180*(ang)/pi);


figure(7)
u = bigtrim.u.*repmat(exp(sqrt(-1)*(+heading-2*bigtrim.heading-0*pi/180)), ...
                        size(bigtrim.u,1),1);
meanvel = nanmean(real(u(10:30,:)))+sqrt(-1)*nanmean(imag(u(10:30,:)));

br2 = nanmean(real(meanvel(7750:8050))')+sqrt(-1)* ...
      nanmean(imag(meanvel(7750:8050))');

plot(cumsum(meanvel(ind))*10,'k'); hold on;
plot(-cumsum(bigtrim.ship(ind)-br2)*10,'b')
plot(-cumsum(bigtrim.ship(ind))*10,'g')
plot(-cumsum(bigtrim.oldship(ind)-br2)*10,'r')

return;

%b = ones(1,30)/30;a=1;
%bigtrim.U = filtfilt(b,a,bigtrim.U')';

subplot(3,1,2);
imagesc(real(bigtrim.U));
caxis([-1 1]);

subplot(3,1,3);
imagesc(imag(bigtrim.U));
caxis([-1 1]);