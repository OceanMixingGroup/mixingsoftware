figure

m_proj('mercator','longitudes',[84 84.4],'latitudes',[13.2 13.6])
m_grid('box','fancy')
hold on


lat=[13.505 13.435264,13.371424,13.36073,13.324096,13.324634];
lon=[84.237 84.173882,84.115501,84.105683,84.08279,84.084602];
time=[6.23,4,2,1,12,11];

hold on

for i=1:5
    m_plot(lon(i),lat(i),'xk');
    m_text(lon(i)+0.005,lat(i),num2str(time(i)));
end

% % projected for 8am
% lat_new=lat(1)+ 1.1*(lat(1)-lat(2));
% lon_new=lon(1)+ 1.1*(lon(1)-lon(2));
% 
% m_plot(lon_new,lat_new,'xr');
% m_text(lon_new+0.005,lat_new,'8-proj');

% ship position
lat_ship=13+ 31.67/60;lon_ship=84+ 16.13/60;
m_plot(lon_ship,lat_ship,'ob');

% m_plot(84.295,13.508,'or');

hold on
m_plot(lon_ross,lat_ross,'or');