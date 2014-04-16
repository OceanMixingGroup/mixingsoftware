% set_adcp.m
%###### THESE PARAMETERS SHOULD BE AJUSTED FOR EVERY CRUISE ######

%###### PARAMETERS FOR PROCESSING ################################
adcppath='\\Atlantic\tgtall\adcp\T132\'; % path to raw adcp data
savepath='\\Zeppelin\data\work\realtime\adcp\'; % path where to save (or read) processed adcp *.mat files
prefix='t132'; % cruise number
year=2001;
%#################################################################
plotinfo.ylim = [0 150]; % m
plotinfo.xlim =0.3;  % days
plotinfo.clim =[-1 1]*0.8; % m/s....
% plotinfo.waypt = [-124-20/60  45+0.5/60;
%                   -124-2.5/60  45+0.5/60]; % coordinates of the way points (CH line)
% plotinfo.waypt = [-125  44+13.5/60;
%                 -124-8.8/60     44+13.5/60]; % coordinates of the way points (CP line)
% plotinfo.waypt = [-124-59.5/60  44+11.5/60;
%                 -124-39/60  44+11.5/60]; % coordinates of the way points HB1-HB2
% plotinfo.waypt = [-124-59.5/60  44+6.5/60;
%                 -124-39/60  44+6.5/60]; % coordinates of the way points HB3-HB4
% plotinfo.waypt = [-124-59.5/60  44+1.5/60;
%                  -124-39/60  44+1.5/60];  % coordinates of the way points HB5-HB6
% plotinfo.waypt = [-124-59.5/60  43+56.95/60;
%                  -124-39/60  43+56.95/60];  % coordinates of the way points HB7-HB8
% plotinfo.waypt = [-124-59.5/60  43+51.5/60;
%                  -124-39/60  43+51.5/60];  % coordinates of the way points HB9-HB10
plotinfo.waypt = [-124-47/60  44+16.5/60;
                 -124-54/60  43+50/60];  % coordinates of the way points LHB1-LHB7
plotinfo.clev=[-2000:500:-500 -200:20:0]; % topography levels
waittime=180; % [sec] how long to wait before read *.mat file next time 

%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%$$$$$$$$$ ANGLE OFFSET $$$ DO NOT APPLY UNLESS YOU ARE SURE!!! $$$$$$$
angle_offcet=2;
%&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&