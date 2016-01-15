function ax=PlotChipodXC_allVars(XC,whSN,castdir)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% General function to plot dT/dz,N2,chi,eps,and KT for one chipod, from sructure 'XC' of chipod
% profiles.
%
%---------------------
% 01/05/16 - A. Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%


%yl=[0 5500];

figure(1);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.1, 0.05, 0.02, 0.06, 0.1, 0.02, 1,5);

axes(ax(1))
ezpc(XC.([whSN '_' castdir]).lat,XC.([whSN '_' castdir]).P,log10(XC.([whSN '_' castdir]).N2) )
hold on
cb=colorbar;
cb.Label.String='log_{10}N^2 [s^{-2}]';
cb.Label.FontSize=14;
hold on
plot(XC.([whSN '_' castdir]).lat,0,'kp')
%    xlim(xl)
%    ylim(yl)
xtloff
title([XC.Name  ' \chi -pod ' whSN ' ' castdir 'casts'])
SubplotLetterMW('N^2')

%
axes(ax(2))
ezpc(XC.([whSN '_' castdir]).lat,XC.([whSN '_' castdir]).P,log10(XC.([whSN '_' castdir]).dTdz))
hold on
%    xlim(xl)
%    ylim(yl)
xtloff
SubplotLetterMW('dT/dz');
cb=colorbar;
cb.Label.String='log_{10}dT/dz [Cm^{-1}]';
cb.Label.FontSize=14;

%
axes(ax(3))
ezpc(XC.([whSN '_' castdir]).lat,XC.([whSN '_' castdir]).P,log10(XC.([whSN '_' castdir]).chi))
hold on
caxis([-11 -7])
%    xlim(xl)
%    ylim(yl)
xtloff
ylabel('Pressure [db]')
SubplotLetterMW('chi');
cb=colorbar;
cb.Label.String='log_{10}\chi';
cb.Label.FontSize=14;

%
axes(ax(4))
ezpc(XC.([whSN '_' castdir]).lat,XC.([whSN '_' castdir]).P,log10(XC.([whSN '_' castdir]).eps))
hold on
cb=colorbar;
cb.Label.String='log_{10}\epsilon [Wkg^{-1}]';
cb.Label.FontSize=14;
caxis([-11 -6])
%    xlim(xl)
%    ylim(yl)
xtloff
SubplotLetterMW('eps');

%
axes(ax(5))
ezpc(XC.([whSN '_' castdir]).lat,XC.([whSN '_' castdir]).P,log10(XC.([whSN '_' castdir]).KT))
cb=colorbar;
cb.Label.String='log_{10}K_T';
cb.Label.FontSize=14;
caxis([-8 -1])
hold on
%    xlim(xl)
%    ylim(yl)
xlabel('Latitude','fontsize',16)
SubplotLetterMW('K_T');

linkaxes(ax)

