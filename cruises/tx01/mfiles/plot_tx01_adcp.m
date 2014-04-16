%   plot_tx01_adcp 
%
figure(26);clf

vel_range=[-.5 .5];
depth_range=[5.5 90];

iadcp=input('enter adcp frequency:  ');
adcp_str=num2str(iadcp);
tstart=input('enter start time:  ');
tend=input('enter end time:  ');
time_str=datestr(tstart,0);

% make naming strings
mnt=time_str(16:17);
hr=time_str(13:14);
dy=time_str(1:2);
mn=time_str(4:6);

time_range=[tstart-datenum(2000,0,0),tend-datenum(2000,0,0)];

if iadcp == 150
    fname=(['\\ladoga\data\cruises\tx01\adcp',adcp_str,'\mat\t',adcp_str,'030']);
    eval(['load ',fname])
    adcp=rotateby(adcp,-1.2);
elseif iadcp == 300
    fname=(['\\ladoga\data\cruises\tx01\adcp',adcp_str,'\mat\t',adcp_str,'019']);
    eval(['load ',fname])
    adcp=rotateby(adcp,-2.49);
end

% reference velocities

adcp=subtractbt(adcp);
adcp=removebottom(adcp,0.85);
%subplot(211)
pcolor(adcp.time-datenum(2000,0,0),adcp.depth(:,1),adcp.u)
%pcolor(adcp.lon,adcp.depth(:,1),adcp.u)
shading flat
colormap(redblue)
caxis(vel_range)
set(gca,'ylim',depth_range)
set(gca,'xlim',time_range)
set(gca,'tickdir','out')
axis ij
kdatetick2
title([adcp_str,' kHz'])

%load \\ladoga\data\cruises\tx01\adcp150\mat\t150004
% reference velocities
%adcp=subtractbt(adcp);
%adcp=removebottom(adcp,0.85);
%subplot(212)
%pcolor(adcp.time-datenum(2000,0,0),adcp.depth(:,1),adcp.u)
%pcolor(adcp.lon,adcp.depth(:,1),adcp.u)
%shading interp
%caxis(vel_range)
%set(gca,'ylim',depth_range)
%set(gca,'xlim',time_range)
%axis ij
%kdatetick2
%title('150 kHz')