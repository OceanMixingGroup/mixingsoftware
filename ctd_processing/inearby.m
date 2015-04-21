  function k = inearby(ibad, inearm, inearp, n);
% function k = inearby(ibad, inearm, inearp, n);
%
% k = indices at/near ibad
%
ibadm=ibad-inearm;
ibadp=ibad+inearp;
k=unique([ibad(:); ibadm(:); ibadp(:)]);
k(find(k<1)) = [];
k(find(k>n)) = [];


