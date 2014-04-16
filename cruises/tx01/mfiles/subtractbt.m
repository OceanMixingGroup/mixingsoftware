% function adcp=subtractbt(adcp);
%
% correct adcp velocities by subtracting bottom-tracked velocity
% use for Thompson data ct01a
function adcp=subtractbt(adcp);

  ubt = adcp.ubt;
  vbt=adcp.vbt;
  
  bad = find(isnan(ubt));
  ubt(bad) =-adcp.navu(bad);
  bad = find(isnan(vbt));
  vbt(bad) = -adcp.navv(bad);
  
adcp.u = adcp.u-ones(size(adcp.u,1),1)*ubt;
adcp.v = adcp.v-ones(size(adcp.u,1),1)*vbt;

%adcp. = adcp.u-ones(size(adcp.u,1),1)*adcp.ubt;
% also do the depth...
