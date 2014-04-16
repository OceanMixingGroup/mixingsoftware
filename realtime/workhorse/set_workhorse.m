% set_workhorse
if strcmpi(prefix,'wh300');
    workhorsedir= '\\currents.wecoma\data\w1010c_moum\raw\wh300\we2010_';
    savedir= '\\masada\work\ttp10\adcp\';
    type_of_average = '';
    angle_offset=44.6;% ADCP angle offset in degrees for UHDAS 
    % and VmDas. This sign convention is opposit of my Matlab soft sign convention
    depth_offset=5; %
    ADCP_type='300';
    plotinfo.ylim = [0 200]; % m
    averagetime=30; % average time in seconds for binning UHDAS files
    waittime=30; % [sec] how long to wait before read *.mat file next time 
elseif strcmpi(prefix,'eq08');
    workhorsedir = '\\gamwy\work\eq08\workhorse150\';
    savedir= '\\schooner\work\eq08\workhorse150\';
    type_of_average = 'STA';
    angle_offset=3;% ADCP angle offset in degrees for my Matlab soft
    depth_offset=6; %
    ADCP_type='150';
    plotinfo.ylim = [0 150]; % m
    waittime=60; % [sec] how long to wait before read *.mat file next time 
elseif strfind(prefix,'os75');
    workhorsedir = '\\rigel\data\eq08\raw\os75\we2008_';
    savedir= '\\madmax\work\eq08\os75\';
%     type_of_average = 'STA';
    angle_offset=-42.6;% ADCP angle offset in degrees for UHDAS 
    % and VmDas. This sign convention is opposit of my Matlab soft sign
    % convention
    depth_offset=5; %
    ADCP_type='75';
    plotinfo.ylim = [0 800]; % m
    averagetime=30; % average time in seconds for binning UHDAS files
    waittime=100; % [sec] how long to wait before read *.mat file next time 
end
plotinfo.xlim =0.5;%0.3;  % days
plotinfo.clim =[-1 1]*0.5; % m/s....
plotinfo.clim2 =[-5 -2]; % m/s....
% plotinfo.waypt = [-124-10.05/60  46+17.198/60;
%                   -124-7.312/60  46+10.189/60]; % Columbia River line 1
plotinfo.waypt = [-122-23.504/60  47+27.506/60;
                  -122-23.322/60  47+26.495/60]; %  1002 & 0912 at TTP
% plotinfo.waypt = [-124.4375  44.532;
%                   -124.391  44.5515]; %  DE line on Stnewall
% plotinfo.waypt = [-124-16.155/60  46+21.862/60;
%                   -124-6/60  46+2.689/60]; %  Columbia River line 2
% plotinfo.waypt = [-124 -7/60  46 +20/60;
%                   -124 -21/60  46 +20/60]; % coordinates of the way points (Columbia River)
% plotinfo.waypt = [-122.05  34.72;
%                   -121.85  36.8]; % coordinates of the way points (Monterey bay)
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
% plotinfo.waypt = [-124-47/60  44+16.5/60;
%                  -124-54/60  43+50/60];  % coordinates of the way points LHB1-LHB7
plotinfo.clev=[-2000:500:-500 -200:10:0]; % topography levels

