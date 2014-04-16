function h=plot_topo(fname,clev);

load(fname)

[c,hh]=contour(topo.lon,topo.lat,topo.depth,clev);
set(hh,'edgecolor',[1 1 1]*0.6,'linewidth',0.7);
hold on;

[c,hh]=contour(topo.lon,topo.lat,topo.depth,[0 0]);
set(hh,'edgecolor',[1 1 1]*0,'linewidth',1.5);

set(gca,'dataaspectratio',[1 cos(median(topo.lat(:))*pi/180) 1]);