function smallbar2(h1,h2,del,s)
if nargin==2
  del=.03;
end
p1=get(h1,'position');
p2=get(h2,'position');
p1(3)=p1(3)+del;
p2(3)=del/2;
p2(1)=p2(1)+del;
if p1(3)>0
set(h2,'position',p2);
set(h1,'position',p1);
end

%if nargin==4
%h=text;
%set(h,'string',s,'rot',90,'units','normal','position',[p2(1)-del/2 p2(2)+p2(4)/2])
%end