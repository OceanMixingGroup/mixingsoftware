% set_nbadcp
rawdir = '\\revelle_svr\workdsk2\adcp\';
% rawdir = 'e:\adcp\';
todir = '\\neva\data\ct03\pingdata';
% todir = 'f:\ct03\pingdata';
matdir = '\\neva\work\ct03\pingdata\mat2\';
% matdir = 'g:\ct03\pingdata\mat\';
xlatedir='c:\work\nbadcp\';
workdir='f:\ct03\pingdata\trans\'; % working directory.
                           % Directory where transferred filer are to be put.
                           % Must be mupped!
transdir='\\neva\data\ct03\pingdata\trans\'; % it is the same directory as workdir
prefix='ct03';
year=2003;
timeshift=8; % difference between GMT time and NBADCP computer time
plotinfo.ylim = [0 180]; % m
% plotinfo.xlim =0.3;  % days
plotinfo.clim =[-1 1]*0.8; % m/s....
plotinfo.waypt = [-124-20/60  45+0.5/60;
                  -124-2.5/60  45+0.5/60]; % coordinates of the way points (CH line)
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
plotinfo.clev=[-2000:500:-500 -200:20:0]; % topography levels
waittime=300; % [sec] how long to wait before read *.mat file next time 
