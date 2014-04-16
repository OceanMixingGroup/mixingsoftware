function cmp = sea(vargin);
% cmp = sea(vargin);

%	@(#)GMT_sealand.cpt	1.1  03/19/99
%
% Colortable for ocean and land with break at sealevel
% Designed by W.H.F. Smith, NOAA
% COLOR_MODEL = HSV

if nargin==1
  len=vargin;
else
  len=length(colormap);
end;

X=[
-8000	0	0	0	
-7000	0	5	25
-6000	0	10	50
-5000	0	80	125	
-4000	0	150	200
-3000	86	197	184
-2000	172	245	168
-1000	211	250	211
    0	250	255	255
];

x=X(:,1);
rgb_ = X(:,2:4)/255;

newx=min(x)+(max(x)-min(x))*((1:len)/len);

cmp = interp1(x,rgb_,newx);



