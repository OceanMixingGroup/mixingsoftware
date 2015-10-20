%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% MakeTriangleRoss.m
%
%
% 09/14/15 - A.Pickering
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

% whoi mooring location
W.lon=89+(27.28/60)
W.lat=18 + (0.5/60)

% south
S1.lat=18 +(3/60)
S1.lon=89 + (27/60)

% NW
S2.lat=18 +(5/60)
S2.lon=89 + (25.5/60)

% NE
S3.lat=18 +(5/60)
S3.lon=89 + (28.5/60)

figure(1);clf
plot(S1.lon,S1.lat,'kd','markersize',10)
hold on
plot(S2.lon,S2.lat,'kd','markersize',10)
plot(S3.lon,S3.lat,'kd','markersize',10)
grid on

plot(W.lon,W.lat,'ms','markersize',12)

%[range,A12,A21]=dist(lat,long,argu1,argu2);

theta1=27.17
theta0=62.83
dd=1.5
[R1.lon,R1.lat,a21] = m_fdist(S1.lon,S1.lat,180,dd*1e3/sind(theta1))
[R2.lon,R2.lat,a21] = m_fdist(S2.lon,S2.lat,-theta0,dd*1e3/sind(theta1))
[R3.lon,R3.lat,a21] = m_fdist(S3.lon,S3.lat,theta0,dd*1e3/sind(theta1))

%plot(R1.lon,R1.lat,'rp','markersize',15)
plot(R2.lon,R2.lat,'rp','markersize',15)
plot(R3.lon,R3.lat,'rp','markersize',15)
%plot([R1.lon R2.lon R3.lon R1.lon],[R1.lat R2.lat R3.lat R1.lat],'r')

% cut off at bottom to stay away from WHOI mooring
R1a.lon=89.4567;
R1a.lat=18.0302;
R1b.lon=89.4433;
R1b.lat=18.0302;

plot([R1b.lon R2.lon R3.lon R1a.lon R1b.lon],[R1b.lat R2.lat R3.lat R1a.lat R1b.lat],'b')

plot(89.4567,18.0302,'rp','markersize',15)
plot(89.4433,18.0302,'rp','markersize',15)



ylim([18 18.1])
map_aspectratio(gca)

%%

[range,A12,A21]=dist([S2.lat S3.lat],[S2.lon S3.lon])
[range,A12,A21]=dist([S3.lat S1.lat],[S3.lon S1.lon])
%%
[range,A12,A21]=dist([S1.lon S2.lon],[S1.lat S2.lat]);
rangeS1=range/1e3

[range,A12,A21]=dist([S2.lon S3.lon],[S2.lat S3.lat]);
rangeS2=range/1e3

[range,A12,A21]=dist([S3.lon S1.lon],[S3.lat S1.lat]);
rangeS3=range/1e3

dTotS=rangeS1+rangeS2+rangeS3
tRoundS=dTotS*1e3/1/60/60

[range,A12,A21]=dist([R1b.lon R2.lon],[R1b.lat R2.lat]);
rangeR1=range/1e3

[range,A12,A21]=dist([R2.lon R3.lon],[R2.lat R3.lat]);
rangeR2=range/1e3

[range,A12,A21]=dist([R3.lon R1a.lon],[R3.lat R1a.lat]);
rangeR3=range/1e3

[range,A12,A21]=dist([R1a.lon R1b.lon],[R1a.lat R1b.lat]);
rangeR4=range/1e3

dTot=rangeR1+rangeR2+rangeR3+rangeR4

Tround=dTot*1e3/1.6/60/60
%%

%WriteROSSwaypoints_APM([R1b.lon R
