function arrow3(v,x0,radius,l,scale,ntet,c)
% function arrow3( V , X0 , R , L , Scale , N )
%
%          DRAW A 3-D ARROW (as a segment plus a cone)
%
% V   vector to be represented as an arrow
% X0  point where vector start -            (default [0 0 0])
% R   arrow width  (cone radius) (in units of V)
%                                           (default 0.2)
% L   arrow length (cone height) (in units of V)
%     if L>1 the segment is not plotted     (default 0.3)
% Scale is to scale the vector              (default 1)
% N   is the resolution (number of lines to draw a cone)
%                                           (default 12)
%
if nargin<2 x0=[0 0 0]; end
if nargin<3 radius=0.2; end
if nargin<4 l=0.3; end
if nargin<5 scale=1; end
if nargin<6 ntet=12; end
if nargin<7 c=[1 1 1]; end
%create circle normal to vector v
V=norm(v);
salpha=v(3)/V;calpha=sqrt(v(1)*v(1)+v(2)*v(2))/V;
sbeta=0;cbeta=1;
if calpha~=0,sbeta=v(2)/V/calpha;cbeta=v(1)/V/calpha;end
tet=(0:pi/ntet:2*pi)';ct=radius*V*cos(tet);st=radius*V*sin(tet);
x(:,1)=+ct*salpha*cbeta+st*sbeta;
x(:,2)=+ct*salpha*sbeta-st*cbeta;
x(:,3)=-ct*calpha;
ntet2=2*ntet;
%graphic tools
v=v*scale;x=x*scale;
p=x0+v;
%b=axis;d(1:3)=b(2:2:6)-b(1:2:5);d=d/max(d);c=d;
for i=1:3,x(:,i)=x0(i)+(1-l)*v(i)+c(i)*x(:,i);end
if l<1, 
plot3(x(:,1),x(:,2),x(:,3),'b-',[p(1)*ones(ntet,1) x(1:2:ntet2,1)]',...
   [p(2)*ones(ntet,1) x(1:2:ntet2,2)]',[p(3)*ones(ntet,1) x(1:2:ntet2,3)]',...
   'b-',[x0(1) p(1)],[x0(2) p(2)],[x0(3) p(3)],'g-');
else
plot3(x(:,1),x(:,2),x(:,3),'b-',[p(1)*ones(ntet,1) x(1:2:ntet2,1)]',...
   [p(2)*ones(ntet,1) x(1:2:ntet2,2)]',[p(3)*ones(ntet,1) x(1:2:ntet2,3)]',...
   'b-');
end

