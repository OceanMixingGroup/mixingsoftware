%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% VelocityCurtain_ROSS_squirt.m
%
% Make awesome 'curtain plots' of velocity sections for the 'Squirt' transects 
% with Revelle and ROSS! Thanks Emily for example code (/scratch/CurtainPlot.m) 
% that got me started.
%
% 09/08/15 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

%saveplots=1

% load Revelle HDSS data
load('/Volumes/scienceparty_share/data/hdss_bin_all.mat')

% load station names and times
load('/Volumes/scienceparty_share/FCTD/FCTD_scratch/fctd_names.mat')


% load sidepole ADCP data
load('/Volumes/scienceparty_share/data/sentinel_1min.mat')

%%
% choose a section

saveplots=1
close all;

for whsec=[1] %23%25
    
    clear F idNid idH idR
    F=fctd_names(whsec)
    
    if strcmp(F.name,'jet1')
        % load ROSS ADCP data for 1st transect
        load('/Volumes/scienceparty_share/ROSS/Deploy1/adcp/mat/Deploy1_adcp_proc_smoothed.mat')
    elseif strcmp(F.name,'jet2')
        % load ROSS ADCP data for 1st transect
        load('/Volumes/scienceparty_share/ROSS/Deploy2/adcp/mat/Deploy2_adcp_proc_smoothed.mat')
    end
    
    % find indices of data in that time range
    idH=isin(sonar.datenum,[F.st F.et]);    
    idR=isin(vel.dnum,[F.st F.et]);
    idV=isin(V.dnum,[F.st F.et]);
    
    % plot HDSS
    clear lat lon z u
    lat=sonar.lat(idH);
    lon=sonar.lon(idH)+.2*ones(size(sonar.lon(idH)));
    z=sonar.depths;
    u=real(sonar.U(:,idH));
    v=imag(sonar.U(:,idH));
    surf(repmat(lat,length(z),1),repmat(lon,length(z),1),repmat(z,1,length(lat)),v)
    hold on
    hRev=plot3(lat,lon,zeros(size(lat)),'m')    
    
      % plot sidepole
%     clear lat lon z u
%     lat=V.lat(idV);
%     lon=V.lon(idV)+.2*ones(size(V.lon(idV)));
%     z=V.z;
%     u=V.u(:,idV);
%     v=V.v(:,idV);
%     surf(repmat(lat,length(z),1),repmat(lon,length(z),1),repmat(z,1,length(lat)),v)
%     hold on
    %hRev=plot3(lat,lon,zeros(size(lat)),'m')    
    
    if ~isempty(idR)
    % plot ROSS
    clear lat lon z u
    lat=vel.lat(idR);lat=lat(:)';
    lon=vel.lon(idR);lon=lon(:)';
    z=vel.z(:);
    u=vel.u(:,idR);
    v=vel.v(:,idR);
    surf(repmat(lat,length(z),1),repmat(lon,length(z),1),repmat(z,1,length(lat)),v)
        hRoss=plot3(lat,lon,zeros(size(lat)),'k')
    end
    
end

view([-82.5 46])
view([-72.5 20])

shading flat
set(gca,'ZDir','reverse')
zlabel('Depth [m]')
xlabel('latitude')
ylabel('longitude')
%ylim([89.5 89.8])
zlim([0 60])
colorbar
colormap(bluered)
caxis(0.5*[-1 1])

title([F.name ' (Revelle offset for viewing)'])
legend([hRev hRoss],'Revelle','Ross','location','best')

if saveplots==1
%print(['/Volumes/scienceparty_share/figures/ADCP/ROSS_Revelle_' F.name '_v'],'-dpng')
print(['/Volumes/scienceparty_share/ROSS/Deploy1/figures/ROSS_Revelle_' F.name '_v'],'-dpng')
end

%%
title('Nidhi/Revelle 140kHz /ROSS v')
%print('/Volumes/scienceparty_share/figures/ADCP/VelocityCurtain_Revelle_u','-dpng')
%print('/Volumes/scienceparty_share/figures/ADCP/VelocityCurtain_Revelle_v_view2','-dpng')
print('/Volumes/scienceparty_share/figures/ADCP/VelocityCurtain_3Ships_v_view2','-dpng')
%%