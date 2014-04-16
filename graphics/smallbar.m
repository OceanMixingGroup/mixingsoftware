function h2=smallbar(h1,h2,del,shorter,cax)
% hcbar=smallbar(haxis,hcbar);
%  Make the colorbar referenced by hcbar smaller
%
% hcbar=smallbar(haxis,hcbar,dsize);
%  Make the colorbar dsize wide;
%
% hcbar=smallbar(haxis,hcbar,dsize,shorter);
%  Make the colorbar shorter by factor given by shorter.;
  
% $Date: 2008/01/31 20:22:46 $ $Author: aperlin $ $Revision: 1.1.1.1 $
% J.Nash sometime in the distant past

if nargin<=2
  del=[];
end
if isempty(del)
  del=0.4;
end;
  
if nargin<=3
  shorter=[];
end
if isempty(shorter)
  shorter=0.4;
end;

del=1-del;
p1=get(h1,'position');
p2=get(h2,'position');
del = p2(3)*del;
p1(3)=p1(3)+del;
p2(3)=p2(3)-del;
p2(1)=p2(1)+del;
if p1(3)>0 & p2(3)>0
  set(h2,'position',p2);
  set(h1,'position',p1);
end

if nargin>3
  p=get(h2,'position');
  oldp=p(4);
  p(4)=oldp*shorter;
  p(2)=p(2)+0.5*(oldp-p(4));
  set(h2,'position',p);
end;
