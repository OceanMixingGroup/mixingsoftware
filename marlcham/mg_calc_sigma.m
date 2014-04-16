function [cal head]=mg_calc_sigma(density_name,salt_name,temp_name,depth_name,cal,head)
% [CAL HEAD]=CALC_SIGMA(SIGMA_NAME,SALT_NAME,TEMP_NAME,DEPTH_NAME,CAL,HEAD)
% calculates the potential density (sigma_theta) at S,T,P referenced to the surface
% produces a field of CAL with name SIGMA_NAME containing the potential 
% density

s=cal.(upper(salt_name));
p=cal.(upper(depth_name));
t=cal.(upper(temp_name));
irep_s=head.irep.(upper(salt_name));
irep_t=head.irep.(upper(temp_name));
irep_p=head.irep.(upper(depth_name));

if irep_p ~= irep_t
  %t=decimate(t,irep_t/irep_p);
  %t=t(1:irep_t/irep_p:length(t));
  t=nanmedian(reshape(t,irep_t/irep_p,length(p)),1)';
end
if irep_p ~= irep_s
  %s=decimate(s,irep_s/irep_p);
  %s=s(1:irep_s/irep_p:length(s));
  s=nanmedian(reshape(s,irep_s/irep_p,length(p)),1)';
end
cal.(upper(density_name))=sw_pden(s,t,p,0);
head.irep.(upper(density_name))=irep_p;
