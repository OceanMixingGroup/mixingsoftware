function [iso]=get_isopycnal(ts,tf,cham,density)
%function[iso_depth]=get_isopycnal(ts,tf,cham,density)
%
% find depth of density in summary file
% in time interval [ts,tf]
% 


ipx=find(cham.time >= ts & cham.time <= tf);
dep=[];

for i=ipx;
    % find depth of density surface
    good=~isnan(cham.SIGMA(:,i));
    zz=interp1(cham.SIGMA(good,i),cham.depth(good)',density);
    dep=[dep zz'];
end
iso.profno=cham.castnumber(ipx);
iso.depth=dep;
iso.dens=density;
iso.time=cham.time(ipx);
iso.lat=cham.lat(ipx);
iso.lon=cham.lon(ipx);

%[c,h]=contour(chamgrid.time,-chamgrid.depth,chamgrid.dens,[1023,1024,1025]);
%set(h,'edgecolor','b')
%set(gca,'visible','off')