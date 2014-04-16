function [cal head]=mg_calc_salt(salt_name,cond_name,temp_name,depth_name,cal,head)
% [CAL HEAD]=MG_CALC_SALT(SALT_NAME,COND_NAME,TEMP_NAME,DEPTH_NAME,CAL,HEAD)
% 
c=cal.(upper(cond_name));
p=cal.(upper(depth_name));
t=cal.(upper(temp_name));
irep_c=head.irep.(upper(cond_name));
irep_t=head.irep.(upper(temp_name));
irep_p=head.irep.(upper(depth_name));

if mean(c)<10
  disp('Check to make sure that Conductivity is in Mmho/cm=mS/cm=10 S/m')
end
if irep_p ~= irep_t
 % t=decimate(t,irep_t/irep_p);
 % t=t(1:irep_t/irep_p:length(t));
 t=nanmedian(reshape(t,irep_t/irep_p,length(p)),1)';
end
if irep_p ~= irep_c
 % c=decimate(c,irep_c/irep_p);
 % c=c(1:irep_c/irep_p:length(c));
 t=nanmedian(reshape(c,irep_c/irep_p,length(p)),1)';
end
cal.(upper(salt_name))=sw_salt(c/sw_c3515,t,p);
head.irep.(upper(salt_name))=irep_p;
