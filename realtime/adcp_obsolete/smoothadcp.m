function adcpout = smoothadcp(adcp,tsmooth,spike);
% tsmooth is in seconds.  time is in days...
tsmooth = tsmooth/(24*3600);
if length(adcp.time)>1
  nspike = floor(tsmooth/median(diff(adcp.time)))
else
  nspike=1;
end;
if isinf(nspike)
  nspike=1;
end;

tbin = min(adcp.time)-0.5*tsmooth:tsmooth:max(adcp.time)+0.5*tsmooth;
adcpout.time = tbin(1:end-1)+0.5*mean(diff(tbin));
adcp.ubt = despike(adcp.ubt,nspike,spike);
adcp.vbt = despike(adcp.vbt,nspike,spike);
adcp.wbt = despike(adcp.wbt,nspike,spike);
% block average
adcpout.ubt = bindata1d(tbin,adcp.time,adcp.ubt);
adcpout.vbt = bindata1d(tbin,adcp.time,adcp.vbt);
adcpout.wbt = bindata1d(tbin,adcp.time,adcp.wbt);
for i=1:4
  adcpout.range(i,:) = bindata1d(tbin,adcp.time,adcp.range(i,:));
end;
%keyboard;
adcpout.heading = bindata1d(tbin,adcp.time,adcp.heading);

for i=1:size(adcp.u,1)
  adcp.u(i,:) = despike(adcp.u(i,:),nspike,spike);
  adcp.v(i,:) = despike(adcp.v(i,:),nspike,spike);
  adcp.w(i,:) = despike(adcp.w(i,:),nspike,spike);
  % block average
  adcpout.u(i,:) = bindata1d(tbin,adcp.time,adcp.u(i,:));
  adcpout.v(i,:) = bindata1d(tbin,adcp.time,adcp.v(i,:));
  adcpout.w(i,:) = bindata1d(tbin,adcp.time,adcp.w(i,:));  
  adcpout.inten1(i,:) = bindata1d(tbin,adcp.time,adcp.inten1(i,:));  
  adcpout.inten2(i,:) = bindata1d(tbin,adcp.time,adcp.inten2(i,:));  
  adcpout.inten3(i,:) = bindata1d(tbin,adcp.time,adcp.inten3(i,:));  
  adcpout.inten4(i,:) = bindata1d(tbin,adcp.time,adcp.inten4(i,:));   
end;
adcpout.depth = adcp.depth;

return;
  

