function [z_s , M_s, F_M_s, D, H, eta] = sigma_layer_interp(Z,M,N_l)
%% [z_s , M_s, F_M_s, D, H, eta] = sigma_layer_interp(Z,M,N_l) interpolates M, which is given in z-coordinates Z on a 
%  certain number of sigma layers N_l and returns the z-coordinate hights
%  of the sigma layer z_s the interpolated matrix M_s and the non-nan-watercolumn heights D(t)
%  F_M_s = is M_s*d_sigma for instance the volume fluxes in case of
%  velocities through a certain sigma layer
% NOTE!!! 1. Dimension of M shell be time, and size(Z)=size(M)


D=nan(size(M,1),1);
eta=D;
H=D;

M_s = nan(size(M,1),N_l);
F_M_s = M_s;
z_s = M_s;


for t=1:size(M,1)
    m_t = M(t,:);
    z_t = Z(t,:);
    innan = find(~isnan(m_t));
    if(length(innan)>3)

        dz = diff(z_t(innan(2:3)));

        H(t) = -z_t(innan(1))+dz*.5;
        eta(t) = z_t(innan(end))+dz*.5;
        D(t)  =  H(t)+eta(t);

        ds = D(t)/N_l;

        % exeption for finer-sigma-resolution than dz
        if(ds<dz) % to avoid nan in the final matrix sp
            H(t)=-z_t(innan(1));
            eta(t) = z_t(innan(end));
            D(t) = H(t)+eta(t);
            ds = D(t)/N_l;
        end

        z_s(t,:) = (-H(t)+ds*.5):ds:(eta(t)-ds*.5);
        M_s(t,:) = interp1(z_t, m_t, z_s(t,:));
        F_M_s(t,:) = interp1(z_t, m_t, z_s(t,:))*ds;
    end
    
end

%% to get rid of nans
xarray = 1:size(M_s,1);
for l=1:size(M_s,2)
    inan = find(isnan(M_s(:,l)));
    innan = find(~isnan(M_s(:,l)));
    
    M_s(inan,l)=interp1(xarray(innan),M_s(innan,l),xarray(inan),'nearest');
    F_M_s(inan,l)=interp1(xarray(innan),M_s(innan,l),xarray(inan),'nearest');
    
    %% if still nan on the edges find closest values
    inan = find(isnan(M_s(:,l)));
    if(~isempty(inan))
        for j=1:length(inan)
            [~,i] = min(abs(innan-inan(j)));
            M_s(inan(j),l) = M_s(innan(i),l);
            F_M_s(inan(j),l) = F_M_s(innan(i),l);
        end
    end
end



end