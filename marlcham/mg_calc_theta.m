function [cal head]=mg_calc_theta(theta_name,salt_name,temp_name,depth_name,cal,head)
% [CAL HEAD]=MG_CALC_THETA(THETA_NAME,SALT_NAME,TEMP_NAME,DEPTH_NAME,CAL HEAD)
% calculates potential temperature (theta) at S,T,P referenced to the surface
% 
% produces a field of CAL with name THETA_NAME containing the potential 
% temperature

eval(['s=cal.' upper(salt_name) ';,p=cal.' upper(depth_name) ... 
      ';,t=cal.' upper(temp_name) ';,irep_s=head.irep.' upper(salt_name) ...
      ';,irep_t=head.irep.' upper(temp_name) ';,irep_p=head.irep.' ...
      upper(depth_name) ';']);

if irep_p ~= irep_t
%  t=decimate(t,irep_t/irep_p);
  t=t(1:irep_t/irep_p:length(t));
end
if irep_p ~= irep_s  
%  s=decimate(s,irep_s/irep_p);
  s=s(1:irep_s/irep_p:length(s));
end
eval(['cal.' upper(theta_name) '=sw_ptmp(s,t,p,0);']);
eval(['head.irep.' upper(theta_name) '=irep_p;']);
