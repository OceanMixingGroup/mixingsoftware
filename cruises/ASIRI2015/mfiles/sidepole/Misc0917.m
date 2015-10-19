
%%

clear ; close all

load('/Volumes/scienceparty_share/sidepole/mat/sentinel_1min_File3.mat')

%load('/Volumes/scienceparty_share/data/os150nb_uv.mat')
load('/Volumes/scienceparty_share/data/hdss_bin_all.mat')
%%

%idS=isin(S.datenum,[nanmin(V.dnum) nanmax(V.dnum)])
idH=isin(sonar.datenum,[nanmin(V.dnum) nanmax(V.dnum)])

figure(1);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.05, 1,4);

axes(ax(1))
ezpc(V.dnum,V.z,V.u)
hold on
%ezpc(S.datenum(idS),S.z,S.u(:,idS))
%ezpc(sonar.datenum(idH),sonar.depths,real(sonar.U(:,idH)))
ylim([0 80])
colorbar
caxis(0.75*[-1 1])
datetick('x')

axes(ax(2))
% ezpc(V.dnum,V.z,V.u)
% hold on
%ezpc(S.datenum(idS),S.z,S.u(:,idS))
ezpc(sonar.datenum(idH),sonar.depths,real(sonar.U(:,idH)))
ylim([0 80])
colorbar
caxis(0.75*[-1 1])
datetick('x')

axes(ax(3))
ezpc(V.dnum,V.z,V.v)
hold on
%ezpc(S.datenum(idS),S.z,S.u(:,idS))
%ezpc(sonar.datenum(idH),sonar.depths,real(sonar.U(:,idH)))
ylim([0 80])
colorbar
caxis(0.75*[-1 1])
datetick('x')

axes(ax(4))
% ezpc(V.dnum,V.z,V.u)
% hold on
%ezpc(S.datenum(idS),S.z,S.u(:,idS))
ezpc(sonar.datenum(idH),sonar.depths,imag(sonar.U(:,idH)))
ylim([0 80])
colorbar
caxis(0.75*[-1 1])
datetick('x')

colormap(bluered)

linkaxes(ax)
%%

subplot(212)
ezpc(V.dnum,V.z,V.v)
hold on
ezpc(S.datenum(idS),S.z,S.v(:,idS))
ylim([0 80])
colorbar
caxis(0.5*[-1 1])
colormap(bluered)
datetick('x')
%%