function ax=PlotChipodXC_OneVarAllSN(XC,ChiInfo,whvar,xvar,SNlist)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% General function to plot one variable (of dT/dz,N2,chi,eps, KT) for each SN
% , from structure 'XC' of chipod profiles.
%
%
%
%
%---------------------
% 05/24/16 - A. Pickering - apickering@coas.oregonstate.edu
% 06/16/16 - AP - Fix xlims if some chipods don't have data
% 07/08/16 - AP - Plot T2 also for 'big' chipods
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

if ~exist('xvar','var')
    xvar='lat';
end

if ~exist('SNlist','var')
    SNlist=ChiInfo.SNs;
end

% Check if we have any 'big' chipods
bc=[];
for iSN=1:length(ChiInfo.SNs);
    bc=[bc ChiInfo.(ChiInfo.SNs{iSN}).isbig];
end

ibig=find(bc==1)
Nbig=length(ibig)

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

whsens='T1';

% Get x-axis limits
xls=[]
for iSN=1:Nsns
    try
        whSN=SNlist{iSN};
        castdir=ChiInfo.(whSN).InstDir;
        if isstruct(castdir)
            castdir=ChiInfo.(whSN).InstDir.(whsens);
        end
        xls=[xls nanmin(XC.([whSN '_' castdir '_' whsens]).(xvar)) nanmax(XC.([whSN '_' castdir '_' whsens]).(xvar))];
    end
end

xl=[nanmin(xls) nanmax(xls)];

figure(1);clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.1, 0.05, 0.02, 0.06, 0.1, 0.02, 1,Nsns+Nbig );

whax=1

for iSN=1:Nsns
    
    clear whsens whSN castdir
    
    try
        
        whsens='T1';
        whSN=SNlist{iSN};
        castdir=ChiInfo.(whSN).InstDir;
        
        if isstruct(castdir)
            castdir=ChiInfo.(whSN).InstDir.(whsens);
        end
                
        axes(ax(whax))
        ezpc(XC.([whSN '_' castdir '_' whsens]).(xvar),XC.([whSN '_' castdir '_' whsens]).P,log10(XC.([whSN '_' castdir '_' whsens]).(whvar)) );
        hold on
        plot(XC.([whSN '_' castdir '_' whsens]).(xvar),0,'kp')
        caxis(cl)
        cb=colorbar;
        cb.Label.String=cbstr;
        cb.Label.FontSize=14;
        hold on
        ylabel([whSN ' ' castdir ],'fontsize',14)
        xlim(xl)
        if strcmp(xvar,'dnum')
            datetick('x','keeplimits')
        end
        
        grid on

    catch
        
        axes(ax(whax))
        cb=colorbar;killcolorbar(cb)
        ylabel([whSN ' ' castdir ],'fontsize',16)
        xlim(xl)

    end
    
    whax=whax+1
    
    if ChiInfo.(whSN).isbig==1
        
        try
            
            whsens='T2';
            whSN=SNlist{iSN};
            castdir=ChiInfo.(whSN).InstDir;
            
            if isstruct(castdir)
                castdir=ChiInfo.(whSN).InstDir.(whsens);
            end
                        
            axes(ax(whax))
            ezpc(XC.([whSN '_' castdir '_' whsens]).(xvar),XC.([whSN '_' castdir '_' whsens]).P,log10(XC.([whSN '_' castdir '_' whsens]).(whvar)) );
            hold on
            plot(XC.([whSN '_' castdir '_' whsens]).(xvar),0,'kp')
            caxis(cl)
            cb=colorbar;
            cb.Label.String=cbstr;
            cb.Label.FontSize=14;
            hold on
            ylabel([whSN ' ' castdir ],'fontsize',14)
            xlim(xl)
            if strcmp(xvar,'dnum')
                datetick('x','keeplimits')
            end
            
            grid on

        catch
            
            axes(ax(whax))
            cb=colorbar;killcolorbar(cb)
            ylabel([whSN ' ' castdir ],'fontsize',16)
            xlim(xl)

        end
        
        whax=whax+1
        
    end % isbig
    
end % iSN

if strcmp(xvar,'lat')
    xlabel('Latitude','fontsize',16)
elseif strcmp(xvar,'dnum')
    xlabel('Dnum','fontsize',16)
end

linkaxes(ax)

%%