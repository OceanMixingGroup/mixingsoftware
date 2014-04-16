% function adcp=removebottom(adcp,percent);
%
function adcp=removebottom(adcp,percent);
P = repmat(adcp.depth(:,1),1,size(adcp.u,2));
R = repmat(mean(adcp.range),size(adcp.u,1),1);

bad = find(P>percent*R);
adcp.u(bad)=NaN;
adcp.v(bad)=NaN;
adcp.w(bad)=NaN;


