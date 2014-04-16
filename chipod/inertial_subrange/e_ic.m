function ec=e_ic(chi_fit,pt,f,f1,f2,N2,dTdz,cal,gamma,Ct)
warning('off')
% pc=2*pi*chi_fit.*Ct.*(nanmean(N2).*chi_fit/2/gamma/nanmean(dTdz).^2)^(-1/3).*(2*pi*f./nanmean(cal.fspd)).^(1/3)./nanmean(cal.fspd);
pc=(2*pi)^(4/3)*Ct.*(2*gamma*nanmean(dTdz).^2/nanmean(N2))^(1/3).*chi_fit^(2/3).*nanmean(cal.fspd)^(-4/3).*f.^(1/3);
ec=integrate(f1,f2,f,(log10(pt./pc)).^2);