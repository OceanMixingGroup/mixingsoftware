function cmp = land(vargin);
% cmp = land(vargin);
% 

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


X=[-6000   255     0.6     1       -5500   240     0.6     1       
-5500   240     0.6     1       -5000   225     0.6     1
-5000   225     0.6     1       -4500   210     0.6     1      
-4500   210     0.6     1       -4000   195     0.6     1
-4000   195     0.6     1       -3500   180     0.6     1       
-3500   180     0.6     1       -3000   165     0.6     1
-3000   165     0.6     1       -2500   150     0.6     1       
-2500   150     0.6     1       -2000   135     0.6     1
-2000   135     0.6     1       -1500   120     0.6     1       
-1500   120     0.6     1       -1000   105     0.6     1
-1000   105     0.6     1       -500    90      0.6     1       
-500    90      0.6     1       0       75      0.6     1
0       60      0.35    1       500     40      0.35    1       
500     40      0.35    1       1000    20      0.35    1
1000    20      0.35    1       1500    0       0.35    1       
1500    0       0.35    1       2000    345     0.3     1
2000    345     0.3     1       2500    330     0.25    1       
2500    330     0.25    1       3000    315     0.2     1        ] ;
[M,N]=size(X);
X(:,5)=X(:,5)-10;
X = reshape(X',N/2,M*2)';
x=X(:,1);
in = find(x>=0);
x=x(in);
hsv_ = X(in,2:4);
hsv_(:,1)=hsv_(:,1)/255;
hsv_=hsv2rgb(hsv_);
newx=min(x)+(max(x)-min(x))*((0:len-1)/len);

cmp = interp1(x,hsv_,newx);


