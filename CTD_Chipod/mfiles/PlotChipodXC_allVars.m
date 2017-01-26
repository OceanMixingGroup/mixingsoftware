function ax=PlotChipodXC_allVars(XC,whSN,castdir,whsens,xvar)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% General function to plot dT/dz,N2,chi,eps,and KT for one chipod, from sructure 'XC' of chipod
% profiles.
%
% INPUT
% - XC : Structure made w/  Make_Combined_Chi_Struct_Template.m
% - whSN
% - castdir : 'up' or 'down'
% - whsens : 'T1' or 'T2'
% - xvar : 'dnum' or 'lat'
%
% OUPUT
% - ax : Axes handles to plot
%
%---------------------
% 01/05/16 - A. Pickering - apickering@coas.oregonstate.edu
% 06/13/16 - AP - Add 'whsens' to inputs.
%          - AP - Simplify code w/ X
%          - AP - Add xvar to inputs
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

%yl=[0 5500];

if isstruct(castdir)
    castdir=castdir.(whsens);
end

% Save some typing later on...
X=XC.([whSN '_' castdir '_' whsens]);

% Reversing lat and dnum messes up plots; eventually should sort
X.dnum(find(diffs(X.dnum)<0)+1)=nan;
X.lat(find(diffs(X.dnum)<0)+1)=nan;

figure(1);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.1, 0.05, 0.02, 0.06, 0.1, 0.02, 1,5);

axes(ax(1))
ezpc(X.(xvar),X.P,real(log10(X.N2) ));
hold on
cb=colorbar;
cb.Label.String='log_{10}N^2 [s^{-2}]';
cb.Label.FontSize=14;
hold on
plot(X.(xvar),0,'kp')
ylim([0 nanmax(X.P)])
xtloff
title([XC.Name  ' \chi -pod ' whSN ' ' castdir 'casts'])%,'interpreter','none')
SubplotLetterMW('N^2');

%
axes(ax(2))
ezpc(X.(xvar),X.P,real(log10(X.dTdz)));
hold on
xtloff
ylim([0 nanmax(X.P)])
SubplotLetterMW('dT/dz');
cb=colorbar;
cb.Label.String='log_{10}dT/dz [Cm^{-1}]';
cb.Label.FontSize=14;

%
axes(ax(3))
ezpc(X.(xvar),X.P,log10(X.chi));
ylim([0 nanmax(X.P)])
caxis([-11 -6])
xtloff
ylabel('Pressure [db]')
SubplotLetterMW('chi');
cb=colorbar;
cb.Label.String='log_{10}\chi';
cb.Label.FontSize=14;

%
axes(ax(4))
ezpc(X.(xvar),X.P,log10(X.eps));
ylim([0 nanmax(X.P)])
cb=colorbar;
cb.Label.String='log_{10}\epsilon [Wkg^{-1}]';
cb.Label.FontSize=14;
caxis([-11 -6])
xtloff
SubplotLetterMW('eps');

%
axes(ax(5))
ezpc(X.(xvar),X.P,log10(X.KT));
ylim([0 nanmax(X.P)])
cb=colorbar;
cb.Label.String='log_{10}K_T';
cb.Label.FontSize=14;
caxis([-8 0])
hold on
xlabel(xvar,'fontsize',16)
SubplotLetterMW('K_T');
if strcmp(xvar,'dnum')
    datetick('x')
end

linkaxes(ax)

