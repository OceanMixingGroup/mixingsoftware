function head=calc_dynamic_z(avg,head);
inds=find(avg.P>5.25 & avg.P<56.25);
bins=diff(avg.P(inds));
%size(bins)
if length(inds)>1
%size(inds)
  ind2=inds(1:(length(inds)-1));
%  size(ind2)
  head.dynamic_gz=sum(bins'./(1000.+avg.SIGMA(ind2)')).*10000;
%eval(['head.dynamic_gz=sum(bins''./(1000.+avg.SIGMA(ind2)'')).*10000;','head.dynamic_gz=NaN;']);
else
  head.dynamic_gz=NaN;
end
