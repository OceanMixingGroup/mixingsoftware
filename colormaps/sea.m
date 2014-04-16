function cmp = sea(vargin);
% cmp = sea(vargin);
%
% The seaward half of the Smith and Sandwell Colormap.
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

X=[
-7000	290	0.45	0.85	-6500	265	0.45	0.85
-6500	265	0.40	0.90	-6000	240	0.40	0.90
-6000	240	0.40	0.90	-5500	220	0.40	0.90
-5500	220	0.40	0.90	-5000	199	0.40	0.90
-5000	199	0.40	0.90	-4500	175	0.40	0.95
-4500	175	0.40	0.95	-4000	150	0.45	0.95
-4000	150	0.45	0.95	-3500	125	0.45	0.95
-3500	125	0.45	0.95	-3000	99	0.45	0.95
-3000	99	0.45	0.95	-2500	75	0.45	0.95
-2500	75	0.45	0.95	-2000	50	0.45	0.95
-2000	50	0.45	0.95	-1500	25	0.45	0.95
-1500	25	0.45	0.95	-500	10	0.35	0.85
-500	0	0.25	0.85	0	0	0.25	0.80
0	195	0.35	0.70	200	160	0.40	0.70
200	160	0.40	0.70	400	125	0.45	0.70
400	125	0.45	0.70	600	99	0.45	0.80
600	99	0.45	0.80	1000	75	0.45	0.80
1000	75	0.45	0.80	1500	50	0.35	0.90
1500	50	0.35	0.90	3500	25	0.10	1.00
3500	25	0.05	1	7000	0	0.00	1.00
];
[M,N]=size(X);
X(:,1)=X(:,1)+10;
X = reshape(X',N/2,M*2)';
x=X(:,1);
in = find(x<=0);
x=x(in);
hsv_ = X(in,2:4);
hsv_(:,1)=hsv_(:,1)/256;
hsv_=hsv2rgb(hsv_);
newx=min(x)+(max(x)-min(x))*((1:len)/len);

cmp = interp1(x,hsv_,newx);




