
%%

ross_lon=84.2000390   
ross_lat=13.4748315

ship_lon=84+(10.794/60)
ship_lat=13+(26.690/60)


[RANGE,AF,AR]=dist([ship_lat ross_lat],[ship_lon ross_lon])

disp(['Ross is ' num2str(RANGE/1000) 'km away from ship at a bearing of ' num2str(AF) ' deg'])
% computes the ranges RANGE between
%%
