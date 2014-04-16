function calc_sigma(density_name,salt_name,temp_name,depth_name)
% function CALC_SIGMA(SIGMA_NAME,SALT_NAME,TEMP_NAME,DEPTH_NAME)
% called like: CALC_SIGMA('sigma','S','T','P')

global cal head
eval(['s=cal.' upper(salt_name) ';,p=cal.' upper(depth_name) ... 
      ';,t=cal.' upper(temp_name) ';,irep_s=head.irep.' upper(salt_name) ...
      ';,irep_t=head.irep.' upper(temp_name) ';,irep_p=head.irep.' ...
      upper(depth_name) ';']);

if irep_p ~= irep_t
%  t=decimate(t,irep_t/irep_p);
  t=t(1:irep_t/irep_p:length(t));
end
if irep_p ~= irep_c
%  c=decimate(c,irep_c/irep_p);
  c=c(1:irep_c/irep_p:length(c));
end
eval(['cal.' upper(density_name) '=sw_pden(s,t,p);']);
eval(['irep.head.' upper(density_name) '=irep_p;']);
