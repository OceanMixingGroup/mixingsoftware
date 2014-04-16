function [eps_h,eps_v,theta_r2,I_fact,spec_ratio_h,spec_ratio_v,...
        noise_lev,P_ver_omega,omega,theta] = calc_adv_epsilon(U,V,W,nfft);

% function [eps_h,eps_v,theta_r2,I_fact,spec_ratio,noise_lev] = ...
%     calc_adv_epsilon(U,V,W);
% Calculate Epsilon from vertical and horizontal spectra per 
% Trowbridge and Elgar 2001, (Turbulence Measurements in the Surf Zone)
sr = 10;
%--------------------------------------------------
U_m = nanmean(U');   V_m = nanmean(V'); 
U_mean = sqrt(U_m.^2 + V_m.^2);
U_std = sqrt( (nanstd(U'))^2 + (nanstd(V'))^2 );

[theta,theta_r2] = get_princ_axis(U,V);

I_fact = calc_I(U_mean,U_std,theta);
alpha_K = 1.5;    % Empirical Kolmogorov Constant


% get spectra
[power_u,fre_u]=fast_psd(U,nfft,sr);
[power_v,fre_v]=fast_psd(V,nfft,sr);
[power_w,fre_w]=fast_psd(W,nfft,sr);

P_hor = power_u + power_v;
P_ver = power_w; 

% Convert to frequency in radians/s spectra
omega = 2*pi*fre_u;
P_hor_omega = P_hor / (2*pi);
P_ver_omega = P_ver / (2*pi);

ind_noise = find(fre_u>=3 & fre_u<=5);
noise_lev = geomean(P_hor_omega(ind_noise));

% Determine if spectra is dominated by noise band. 
fre_lim_low = [0.35 0.75];
ind_min = find(fre_u >= fre_lim_low(1) & fre_u <= fre_lim_low(2));
% spec_min = geomean(P_hor_omega(ind_min));
% spec_ratio = spec_min / noise_lev;
spec_ratio_v = geomean(P_ver_omega(ind_min)) / ...
    geomean(P_ver_omega(ind_noise));

spec_ratio_h = geomean(P_hor_omega(ind_min)) / ...
    geomean(P_hor_omega(ind_noise));

Q_plot=0;
if Q_plot==1
    
    figure(2)
    clf
    loglog(omega,P_hor_omega,'b',omega,(21/12)*P_ver_omega,'r',...
        omega,P_hor_omega-noise_lev,'k')
    axis([2*pi*[0.25 5.5] 1e-8 1e-4]) 
    XL = get(gca,'xlim');
    hold on
    loglog(XL,noise_lev*[1 1],'k')
    YL = get(gca,'ylim');
    loglog(2*pi*[3 3],YL,'k')
    loglog(2*pi*[5 5],YL,'k')
    xlabel('\omega [rad s^{-1}]')
    ylabel('P [(m s^{-1})^2 / (rad s^{-1}]')
    legend('P_{uu}+P_{v v}','(21/12)*P_{ww}','P_{uu}+P_{v v}-noise',3)
    title('Comparison of horizontal and vertical spectra: Noise band computed over 3-5 Hz')
    
    figure(3)
    clf
    loglog(omega,(12/21) * (omega.^(5/3)) .* (P_hor_omega - noise_lev),'b',...
             omega,(omega.^(5/3)) .* P_ver_omega,'r')
   
    set(gca,'xlim',2*pi*[1e-1 1e1],'ylim',[1e-7 2e-4])
    legend('(12/21)* \omega^{5/3}* (P_{uu}+P_{vv}-noise)','\omega^{5/3}*P_{ww}',3)
    hold on
    YL = get(gca,'ylim');
    loglog(0.6*2*pi*[1 1],YL,'k',2*2*pi*[1 1],YL,'k')
    xlabel('\omega [rad s^{-1}]')
    temp =  title('Comparison of horizontal and vertical spectra scaled by \omega^{5/3}: Eps calculation Integration Band 0.6-2 Hz');
    set(temp,'fontsize',10)    
 
end




% Estimate Epsilon from horizontal spectra %-------------------
fre_lim = [1 2];
temp = omega.^(5/3) .* (P_hor_omega - noise_lev);
ind = find(fre_u >= fre_lim(1) & fre_u <= fre_lim(2));
ind_zero = find(temp(ind) >0);
if ~isempty(ind_zero)
    C = geomean(temp(ind(ind_zero)));

    if C > 0
        eps_h = (C * (55/21) /(alpha_K * U_mean.^(2/3) * I_fact) ).^ (3/2);    
    else
        eps_h = NaN;
    end
else
    eps_h = NaN;
end

% Estimate epsilon from vertical spectra
temp = omega.^(5/3) .* P_ver_omega;
ind_zero = find(temp(ind) >0);
if ~isempty(ind_zero)
    C = geomean(temp(ind(ind_zero)));

    if C > 0
        eps_v = (C*(55/12)/(alpha_K*U_mean.^(2/3)*I_fact)).^(3/2);
    else
        eps_v = NaN;
    end
else
    eps_v = NaN;
end    
    
