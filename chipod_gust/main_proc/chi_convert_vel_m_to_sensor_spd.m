function [spd_time, spd] = chi_convert_vel_m_to_sensor_spd(vel_m, data)
%% [spd_time, spd] = chi_convert_vel_m_to_sensor_spd(vel_m, data)
%     This function converts mooring velocities (u,v) into 
%     speeds passed the FP7 senaor for chipod processing
%
%     INPUT
%        vel_m    : structure containing u,v,time
%        data     : calibrated chipod/gust structure
%
%     OUTPUT
%        spd_time : time array for the sensor speed (dt = 1s)
%        spd      : speed passed senor in [m/s]
%
%   created by: 
%        Johannes Becherer
%        Tue Jan 10 16:49:54 PST 2017

% find spd field in mooring data;
if ~isfield(vel_m, 'spd')
   vel_m.spd = abs(vel_m.u + 1i*vel_m.v);
end


% interplate on common time step
   u   = interp1(vel_m.time, vel_m.u, data.time, 'linear','extrap');
   v   = interp1(vel_m.time, vel_m.v, data.time, 'linear','extrap');
   spd = interp1(vel_m.time, vel_m.spd, data.time, 'linear','extrap');

   cmp = angle(interp1(data.time_cmp, exp(1i*data.cmp/180*pi), data.time, 'linear','extrap'));




% Simple assuption chipod is perfectly stired in the flow
  %velx = -spd; % current comming opposed the sensor
  %vely = zeros(size(velx));

% more sophisticated use compass
  velx = u.*sin(cmp) + v.*cos(cmp); 
  vely = u.*cos(cmp) + v.*sin(cmp); 


% speed data
spd      = sqrt( (data.a_vel_x-velx).^2 +(data.a_vel_y -vely).^2 +data.a_vel_z.^2 );
   % note that the original routine also tokk rotation into acount as rate of change of compass

spd_time = data.time;

% stuff from get_chipod_cals.m

%   % here we compute fall speed using compass as yaw and
%   % low-passed pitch and roll (the closest to we can get without rate sensors):
%   % (components of current in Chipod coordinate system)
%   % calculate low-freq rotations from accelerometer data
%   cal=calc_lp_rotations(cal,head);
%   
%   % Remove gravitational part from acceleration measurements
%   cal.roll=cal.rlp;cal.roll=fillgap(cal.roll,1);
%   cal.pitch=cal.plp;cal.pitch=fillgap(cal.pitch,1);
%   cal=remove_gravitation(cal,head);
%   [time itime]=unique(cal.time_acc(1:head.samplerate(head.sensor_index.AX)/head.slow_samp_rate:end)-1/86400);

%   cmp=exp(sqrt(-1)*cal.CMP(itime)*pi/180);
%   cmpu=real(cmp); cmpv=imag(cmp);
%   cmpu=interp1(time,cmpu,cal.time_acc,'linear','extrap');
%   cmpv=interp1(time,cmpv,cal.time_acc,'linear','extrap');
%   CMP_fast=atan2(cmpv,cmpu)*180/pi;

%   cal.cur_x=cal.cur_u.*sind(CMP_fast)+cal.cur_v.*cosd(CMP_fast);
%   cal.cur_y=-cal.cur_u.*cosd(CMP_fast)+cal.cur_v.*sind(CMP_fast);
%   r1tip=1.818*2.54/100;% distance from cable to shorter sensor tip
%   ra=3.3*0.0254;% distance from accelerometer package to cable 
%   dyawdt=gradient(-CMP_fast*pi/180,1/head.samplerate(head.sensor_index.AX));dyawdt=deglitch(dyawdt,30,2);dyawdt=fillgap(dyawdt,1);
%   if isnan(dyawdt(1)); dyawdt(1)=dyawdt(2);end
%   if isnan(dyawdt(end)); dyawdt(end)=dyawdt(end-1);end
%   cal.r1omega=(ra+r1tip)*dyawdt;
%   cal.AX=fillgap(cal.AX);
%   cal.AY=fillgap(cal.AY);
%   cal.AZ=fillgap(cal.AZ);
%   [disp,vel]=integrate_acc(cal,head,hpf_cutoff);
%   cal.velz=vel.z;
%   cal.vely=vel.y;
%   cal.velx=vel.x;
%   cal.dispz=disp.z;
%   cal.dispy=disp.y;
%   cal.dispx=disp.x;

%   % where are the sensors relativde to the cabel
%    %   r1tip=1.818*2.54/100;% distance from cable to shorter sensor tip
%    %   ra=3.3*0.0254;% distance from accelerometer package to cable 
%    %   dyawdt=gradient(cal.yaw*pi/180,1/head.samplerate(head.sensor_index.R1));
%    %   dyawdt=deglitch(dyawdt,30,2);
%    %   dyawdt=fillgap(dyawdt,1);
%    %   cal.r1omega=(ra+r1tip)*dyawdt;


%   % calculate fallspeed
%  %cal.fspd=sqrt((cal.velx-cal.cur_x).^2+(cal.vely-(cal.cur_y+cal.r1omega)).^2+cal.velz.^2);




