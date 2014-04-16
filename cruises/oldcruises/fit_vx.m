% fits vx to adp speed 

load d:\data\m99b\marlin\mat_files\marlin_vx_4371_4456;
load d:\data\m99b\adp\mat_files\adp_timeseries_tow15

% subsample vx
vx1=vx(1:4:end);

% compute speeds
speed_u=sqrt(mn_up_u.^2+mn_up_v.^2);
speed_d=sqrt(mn_dn_u.^2+mn_dn_v.^2);
speed=(speed_u+speed_d)/2;

% screen for NaNs
id=find(isnan(vx1)==0 & isnan(speed)==0);

% fit
[p,s]=polyfit(speed,vx1,1);
vf=polyval(p,speed);

% plot
fiugre(1)
plot(speed,vx1,'m.',speed,vf);
