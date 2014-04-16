% plot_moored_adp
%
%

figure(11);clf
t1=input('enter start time:  ');
t2=input('enter final time:  ');
time_range=[t1 t2];
depth_range=[0 50];
vel_range=[-.6 .6];

subplot(311)
imagesc(adp.time,[1:3:75],adp.u);
set(gca,'ylim',[0 45])
set(gca,'ydir','normal')
set(gca,'xlim',time_range,'ylim',depth_range)
caxis(vel_range)
kdatetick2

subplot(312)
imagesc(adp.time,[1:3:75],adp.v);
set(gca,'ylim',[0 45])
set(gca,'ydir','normal')
set(gca,'xlim',time_range,'ylim',depth_range)
caxis(vel_range)
kdatetick2

subplot(313)
imagesc(adp.time,[1:3:75],adp.w);
set(gca,'ylim',[0 45])
set(gca,'ydir','normal')
set(gca,'xlim',time_range,'ylim',depth_range)
caxis([-.2 .2])
kdatetick2