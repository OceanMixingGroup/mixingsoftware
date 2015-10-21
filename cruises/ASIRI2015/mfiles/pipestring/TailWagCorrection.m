%%

head=90 % heading in deg (CW from North)
dhead_dt=5/120 % rate of change of heading deg/s
X=30 % distance (m) from heading gps to ADCP

% rotation velocity in ship coordinates
uv=-X*sind(dhead_dt) + 0*sqrt(-1)

% rotate to earth coordinates using heading
uv2=uv*exp(-i*head*pi/180)

u2=real(uv2) % u component of rotation
v2=imag(uv2) % v component of rotation

%% compute for some real data and compare to the translation u,v speeds

clear ; close all
addpath('/Volumes/scienceparty_share/mfiles/shared/')

 load('/Volumes/scienceparty_share/pipestring/mat/ADCP_ASIRI2015Aug005_000018_earth.mat')
%adcp.mtime(1)

%trange= [datenum(2015,8,28) datenum(2015,8,29)]
trange=[nanmin(xadcp.mtime) nanmax(xadcp.mtime)]
N=loadNavSpecTime(trange)
N.dnum_hpr(1)=nan;
N.dnum_ll(1)=nan;
%N.
%
dt=nanmean(diff(N.dnum_hpr))*86400; % dt in sec
%head2=unwrap(N.head,360);
dHdt=diffs(N.head)./dt;
ib=find(abs(diffs(N.head))>5);
dHdt(ib)=nan;
N.head(ib)=nan;
%D=datetime(N.dnum_hpr,'convertfrom','datenum');
D=N.dnum_hpr;
%
clear dydt dxdt uship vship
dydt=diff(N.lat)*111.18e3./(diff(N.dnum_ll)*24*3600);
dxdt=diff(N.lon)*111.18e3./(diff(N.dnum_ll)*24*3600).*cos(N.lat(1:end-1)*pi/180);
dydt=[dydt nan];
dxdt=[dxdt nan];
%
ig=find(~isnan(N.dnum_ll));
uship=interp1(N.dnum_ll(ig)+diffs(N.dnum_ll(ig))'/2,dxdt(ig),xadcp.mtime);
vship=interp1(N.dnum_ll(ig)+diffs(N.dnum_ll(ig))'/2,dydt(ig),xadcp.mtime);
%vship=interp1(N.dnum_ll(1:end-1)+diff(N.dnum_ll)/2,dydt,xadcp.mtime);
%D2=datetime(N.dnum_ll,'convertfrom','datenum');
D2=N.dnum_ll;
%

figure(1);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.05, 1,6);

axes(ax(1))
plot(D,N.head)
datetick('x')
%hold on
%plot(D,head2)
ylabel('heading [^o]')

axes(ax(2))
plot(D,dHdt)
%ylim(2*[-1 1])
grid on
gridxy
ylabel(['dH/dt [^o/s]'])

%
% now plot the 'rotational' speed
%
X=15 % distance from gyro to pipestem? 
ur=real( (-X*sind(dHdt) + 0*sqrt(-1))' .* exp(-i*N.head.*pi/180) );
vr=real( (-X*sind(dHdt) + 0*sqrt(-1))' .* exp(-i*N.head*pi/180) );
%

% uship,vship (translational speed)
axes(ax(3))
h2=plot(D2,dxdt+ur)
hold on
h1=plot(D2,dxdt)
grid on
gridxy
legend([h1 h2],'uship','uship2')
%ylabel(['dH/dt [^o/s]'])

axes(ax(4))
h2=plot(D2,dydt+vr)
hold on
h1=plot(D2,dydt,'linewidth',2)
%plot(D,ur)
%hold on
%plot(D,vr)
%ylim(1*[-1 1])
grid on
gridxy
legend([h1 h2],'vship','vship2')
%%
clear uv u0 v0
head_offset=85.5
uv=nadcp.vel1 + sqrt(-1)*nadcp.vel2;
u0=real(uv*exp(1i*pi*head_offset/180));
v0=imag(uv*exp(1i*pi*head_offset/180));
%%

axes(ax(5))
ezpc(xadcp.mtime,xadcp.config.ranges,u0)
%caxis(0.5*[-1 1])

axes(ax(6))
ezpc(xadcp.mtime,xadcp.config.ranges,v0)

linkaxes(ax,'x')

%%
% add ship velocity to get absolute water velcoity
clear u v u2 v2
u=u0+repmat(uship,size(u0,1),1);
v=v0+repmat(vship,size(u0,1),1);
%
ig=find(~isnan(D2));
uri=interp1(D2(ig),ur(ig),xadcp.mtime);
vri=interp1(D2(ig),vr(ig),xadcp.mtime);
u2=u0+repmat(uship+uri,size(u0,1),1);
v2=v0+repmat(vship+vri,size(u0,1),1);

%
figure(3);clf
ax = MySubplot2(0.15, 0.075, 0.02, 0.06, 0.1, 0.05, 1,7);

cl=0.5*[-1 1]

axes(ax(1))
plot(N.dnum_hpr,N.head)
cb=colorbar;killcolorbar(cb)

axes(ax(2))
ezpc(xadcp.mtime,xadcp.config.ranges,u)
ylim([0 60])
caxis(cl)
colorbar

axes(ax(3))
ezpc(xadcp.mtime,xadcp.config.ranges,u2)
ylim([0 60])
caxis(cl)
colorbar

axes(ax(4))
ezpc(xadcp.mtime,xadcp.config.ranges,u-u2)
ylim([0 60])
%caxis(cl)
colorbar


axes(ax(5))
ezpc(xadcp.mtime,xadcp.config.ranges,v)
ylim([0 60])
caxis(cl)
colorbar

axes(ax(6))
ezpc(xadcp.mtime,xadcp.config.ranges,v2)
ylim([0 60])
caxis(cl)
colorbar

axes(ax(7))
ezpc(xadcp.mtime,xadcp.config.ranges,v-v2)
ylim([0 60])
%caxis(cl)
colorbar

linkaxes(ax,'x')
%%
