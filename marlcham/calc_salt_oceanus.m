function calc_salt_oceanus(salt_name,cond_name,temp_name,depth_name)
% function CALC_SALT(SALT_NAME,COND_NAME,TEMP_NAME,DEPTH_NAME)
% called like: CALC_SALT('S','C','T','P')
%
% This code is updated from calc_salt in January 2014. It now uses "cond"
% instead of "c" for conductivity. It also uses "t1" instead of "t".
% Changes were necessary because chameleon now write fields "cond" and "t1"
% instead of "c" and "t".
%
% calc_salt still uses "c" and "t"
%
% Overall this code is antiquated. In the processing for YQ14, in
% cali_realtime_oceanus, calc_salt is no longer called. It has been
% replaced by a simple call of sw_salt.
%
% update by Sally Warner, January 2014

global cal head
eval(['cond=cal.' upper(cond_name) ';,p=cal.' upper(depth_name) ... 
      ';,t1=cal.' upper(temp_name) ';,irep_c=head.irep.' upper(cond_name) ...
      ';,irep_t=head.irep.' upper(temp_name) ';,irep_p=head.irep.' ...
      upper(depth_name) ';']);
if mean(cond)<7
  error('Check to make sure that Conductivity is in Mmho/cm=mS/cm=10 S/m')
end
if irep_p ~= irep_t
 % t=decimate(t,irep_t/irep_p);
  t1=t1(1:irep_t/irep_p:length(t1));
end
if irep_p ~= irep_c
 % c=decimate(c,irep_c/irep_p);
  cond=cond(1:irep_c/irep_p:length(cond));
end
eval(['cal.' upper(salt_name) '=sw_salt(cond/sw_c3515,t1,p);']);
eval(['head.irep.' upper(salt_name) '=irep_p;']);
