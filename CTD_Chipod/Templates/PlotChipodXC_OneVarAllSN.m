function ax=PlotChipodXC_OneVarAllSN(XC,ChiInfo,whvar,SNlist)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% General function to plot one variable (of dT/dz,N2,chi,eps, KT) for each SN
% , from structure 'XC' of chipod profiles.
%
%
%---------------------
% 05/24/16 - A. Pickering - apickering@coas.oregonstate.edu
% 06/16/16 - AP - Fix xlims if some chipods don't have data
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

if ~exist('SNlist','var')
    SNlist=ChiInfo.SNs;
end

whsens='T1';

if strcmp(whvar,'N2')
    cl=[-7 -3.5];
    cbstr='log_{10}N^2 [s^{-2}]';
elseif strcmp(whvar,'dTdz')
    cl=[-4 -1];
    cbstr='log_{10}dT/dz [Cm^{-1}]';
elseif strcmp(whvar,'chi')
    cl=[-11 -5];
    cbstr='log_{10}\chi';
elseif strcmp(whvar,'eps')
    cl=[-11 -5];
    cbstr='log_{10}\epsilon';
elseif strcmp(whvar,'KT')
    cl=[-8 -1];
    cbstr='log_{10}K_T';
end
Nsns=length(SNlist);

figure(1);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.1, 0.05, 0.02, 0.06, 0.1, 0.02, 1,Nsns);

xls=[];

for iSN=1:Nsns
    
    try
        
        whSN=SNlist{iSN};
        castdir=ChiInfo.(whSN).InstDir;
        
        axes(ax(iSN))
        ezpc(XC.([whSN '_' castdir '_' whsens]).lat,XC.([whSN '_' castdir '_' whsens]).P,log10(XC.([whSN '_' castdir '_' whsens]).(whvar)) );
        hold on
        caxis(cl)
        cb=colorbar;
        cb.Label.String=cbstr;
        cb.Label.FontSize=14;
        hold on
        plot(XC.([whSN '_' castdir '_' whsens]).lat,0,'kp')
        ylabel([whSN ' ' castdir ],'fontsize',14)
        xls=[xls nanmin(XC.([whSN '_' castdir '_' whsens]).lat) nanmax(XC.([whSN '_' castdir '_' whsens]).lat)];
    catch
        axes(ax(iSN))
        cb=colorbar;killcolorbar(cb)
        ylabel([whSN ' ' castdir ],'fontsize',16)
    end
    
end % iSN

xlfinal=[nanmin(xls) nanmax(xls)];
for iax=1:length(ax)
    axes(ax(iax))
    xlim(xlfinal)
end
xlabel('Latitude','fontsize',16)
linkaxes(ax)

%%