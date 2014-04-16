function pointcolor(x,y,z,c,hs,vs);
%pointcolor(x,y,z,c,hs,vs);
%
%POINTCOLOR - G.Avicola 
%was annoyed that there wasn't any way to plot points in 3d space with
%a color axis.  
%x,y,z,and c, are 1xn arrays of coords (x,y,z) and the fourth axis which is
%translated to a colorscale.
%hs and vs are the 'size' of the points - such that if you are using
%widely varying axes (e.g. km on x and meters on z), you can define the
%elipticity of the points to make them viewable from any angle.


hs=hs/2;
vs=vs/2;
L=length(x);


x1(1,:)=x-hs;
x1(2,:)=x+hs;
x1(3,:)=x+hs;
x1(4,:)=x-hs;

y1(1,:)=y-hs;
y1(2,:)=y-hs;
y1(3,:)=y+hs;
y1(4,:)=y+hs;

z1(1,:)=z;
z1(2,:)=z;
z1(3,:)=z;
z1(4,:)=z;

x2(1,:)=x;
x2(2,:)=x;
x2(3,:)=x;
x2(4,:)=x;

y2(1,:)=y-hs;
y2(2,:)=y-hs;
y2(3,:)=y+hs;
y2(4,:)=y+hs;

z2(1,:)=z+vs;
z2(2,:)=z-vs;
z2(3,:)=z-vs;
z2(4,:)=z+vs;

x3(1,:)=x-hs;
x3(2,:)=x+hs;
x3(3,:)=x+hs;
x3(4,:)=x-hs;

y3(1,:)=y;
y3(2,:)=y;
y3(3,:)=y;
y3(4,:)=y;

z3(1,:)=z+vs;
z3(2,:)=z+vs;
z3(3,:)=z-vs;
z3(4,:)=z-vs;

patch(x1,y1,z1,[c c c c]');
patch(x2,y2,z2,[c c c c]');
patch(x3,y3,z3,[c c c c]');

