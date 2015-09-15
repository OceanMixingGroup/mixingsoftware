function adcp = uhdastosci(radcp)
% function adcp = uhdastosci(fname);
% translates uhdas data output to our standards.
%
% adcp = uhdastosci(radcp);

  
for kk=1:4
    radcp.bt.range(kk,:)=deglitch(radcp.bt.range(kk,:),30,2);
end
adcp.vel1=radcp.vel1;
adcp.vel2=radcp.vel2;
adcp.vel3=radcp.vel3;
adcp.vel4=radcp.vel4;
if isfield(radcp,'cor1')
    adcp.cor1=radcp.cor1;
    adcp.cor2=radcp.cor2;
    adcp.cor3=radcp.cor3;
    adcp.cor4=radcp.cor4;
end
adcp.amp1=radcp.amp1;
adcp.amp2=radcp.amp2;
adcp.amp3=radcp.amp3;
adcp.amp4=radcp.amp4;
adcp.u = radcp.uabs;
adcp.v = radcp.vabs;
adcp.w = radcp.wmeas;
adcp.e = radcp.emeas;
adcp.heading=radcp.heading;
adcp.cog=radcp.cog;
adcp.lon=radcp.lon;
adcp.lat=radcp.lat;
adcp.bt_vel1=radcp.bt.vel(1,:);
adcp.bt_vel2=radcp.bt.vel(2,:);
adcp.bt_vel3=radcp.bt.vel(3,:);
adcp.bt_vel4=radcp.bt.vel(4,:);
adcp.bottom=nanmean(radcp.bt.range,1);
adcp.heading=radcp.heading;
adcp.pitch=radcp.pitch;
adcp.roll=radcp.roll;
adcp.uship=radcp.uship;
adcp.vship=radcp.vship;
adcp.temperature=radcp.temperature;
adcp.soundspeed=radcp.soundspeed;
adcp.time=datenum(radcp.config.yearbase,0,radcp.corr_dday+1);
adcp.depth=radcp.depth;
adcp.cfg = radcp.config;

 