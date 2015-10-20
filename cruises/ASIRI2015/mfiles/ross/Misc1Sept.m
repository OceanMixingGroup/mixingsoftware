
%%

clear ; close all

load('/Volumes/scienceparty_share/ROSS/Deploy1/adcp/mat/Deploy1_adcp_proc_smoothed.mat')

%%


%%


cl=1.5*[-1 1];
yl=[0 60];

figure(2);clf
agutwocolumn(1)
wysiwyg

subplot(211)
ezpc(vel.dnum,vel.z,vel.u)
datetick('x')
caxis(cl)
colorbar
ylim(yl)
title('Ross abs. Velocities ')
ylabel('depth [m]')
SubplotLetterMW('u')

subplot(212)
ezpc(vel.dnum,vel.z,vel.v)
caxis(cl)
colorbar
ylim(yl)
SubplotLetterMW('v')
ylabel('depth [m]')
datetick('x')
xlabel(['time on ' datestr(floor(vel.dnum(1)))])

colormap(bluered)

%
% tm=nanmean(chain.T,2);
% tm=tm(~isnan(tm));
%
hold on
plot(chain.time,chain.depth(end,:),'k')
%contour(chain.time,chain.depth,chain.T,29.07,'k')
shg
%%