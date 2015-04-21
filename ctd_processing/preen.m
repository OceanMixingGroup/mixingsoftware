function xp=preen(x,xmin,xmax)
%function xp=preen(x,xmin,xmax) eliminates values of x outside the range
%defined by xmin and xmax in favor of interpolated values.
%

count=[1:length(x)]';
ii=find(x < xmin | x > xmax | imag(x) ~= 0);
x(ii)=[];
cp=count;
count(ii)=[];
xp=interp1q(count,x,cp);
