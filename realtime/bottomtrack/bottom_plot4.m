% function fig = bottom_plot4(night)
% function fig = bottom_plot4(night)
% 
% This routine runs a semi real-time display of the ships position
% and the Marlin position.  It requires a number of files to run
% properly - see the notes in the source code (>> type
% bottom_plot4).  
%
% The routine can be run on two computers at once, allowing both the
% lab and the bridge to see where Marlin is located.  The input
% parameter lab = 1 means that the display is controlled by this
% instance of the routine, whereas lab=0 means that it is not.
% lab=0 also gives a more simple display.
%
% night = 1 gives a colour scheme that is darker so the bridge
% crew's night vision is not impared.
%
% SEE ALSO: make_southmooringsurvey.m, read_bottom_out.m
  
% J. Klymak 8Dec2000.
  
% Usage Notes:
%
% In order to run, bottom_plot4 needs four structures of
% information filled, "survey", "track", "bottom", and "plotinfo".
%
% "survey":
% This structure is read in during the subroutine set_up_survey.
% It comes froma  file names "survey.mat" which must be prepared
% before calling bottom_plot4.m.  Examples of how these are made
% are in the subdirectory "surveydata".  The structure has
% the following elements:
%  survey = 
%    bathyfile: 'kaenabathy'               % this is the name of
%                                            the file which has the
%                                            bathymetry which we
%                                            contour on the plot.
%         name: 'southmooringsurvey'       % This can be anything,
%                                            but uniqueness
%                                            prevents confusion.
%          lon: [-158.5653 -158.5180]      % A survey is a single
%          lat: [21.5238 21.6982]            straight line between
%                                            two points, specified here. 
%          
%            x: [-1.6392e+007 -1.6387e+007]% They are converted to
%            y: [2.3933e+006 2.4126e+006]    x and y in meters
%       cenlat: 21.6110                    % central latitude of
%                                            the survey for the
%                                            mercator projection.
%        angle: 1.3235                     % angle in rads. from
%                                            east of the survey, 
%                                            positive is to the north
%      heading: 14.1669                    % heading in degrees
%                                            from north. positive
%                                            is to the east.
%     stations: [1x1 struct]               % see below....

%       lonlim: [-158.8000 -158.3500]      % nominal plotting limits
%       latlim: [21.5000 21.7200]            can be overuled by
%                                            where the ship in
%      cvminor: [1x41 double]              % for the contour plot           
%      cvmajor: [-4000 -3000 -2000 -1000 0]  of depths.  In meters.
%
% The substructure "stations" is a structure with the position of
% stations we may want to plot on the screen:
%   survey.stations = 
%    lon: [-158.5417 -158.4639]
%    lat: [21.6110 21.8000]
%    col: [2x3 double]                    % col is the color to
%                                           plot the station.
%
% "bathy":
%  This is not a structure, but is a file that is read that
%  contains a matrix with the elements: "lon","lat", and "depth".
%  This matrix describes the bathymetry near the survey site, and
%  comes from somewhere like Smith and Sandwell.
%
% "track": 
%  This structure is read in at the same time as the survey
%  structure (and is saved in the same *.mat file).  It contains
%  any accurate track data you feel you have collected:
% 
%  track = 
%            depths: [1x279157 double]
%               lon: [1x279157 double]
%               lat: [1x279157 double]
%
% "bottom": 
%  This structure is the bread and butter of this routine.  It
%  contains the "real-time" information collected from Marlin and
%  the ship.  These two data streams are merged and created by Ray
%  on the computer that runs BottomAvoid, and written to a file
%  every second or so in a file called bottom.out.  The routine
%  read_bottom_out.m reads this file from the BottomAvoid computer
%  every five seconds or so and updates the MatLab plot.
%  bottom = 
%              time: [1x27388 double]   % the GPS time using MatLab datenum 
%               lat: [1x27388 double]   % decimal lat
%               lon: [1x27388 double]   % decimal lon
%           shipsog: [1x27388 double]   % decimal shipsog
%         shipdepth: [1x27388 double]   % ship's depth
%          shiphead: [1x27388 double]   % ship's heading (degrees
%                                       % from north, positive east).
%       MarlinSpeed: [1x27388 double]   % Speed of Marlin
%       MarlinDepth: [1x27388 double]   % Depth of Marlin
%    OAdisttobottom: [1x27388 double]   % Dist to bottom from Bottom Avoid.
%
% "plotinfo":
%  This structure is too big to list here, but basically has all
%  the handles to the various features in the plot.  There is a
%  plotinfo file written by the lab computer, read by the bridge
%  computer, every update which has four items:
%  plotinfo.zup, plotinfo.zdown, plotinfo.lleft, and
%  plotinfo.lright.  These items control the depth display
%  parameters.
  
%load bottom_plot
global h

% master or not?
%if nargin<1
%  night=1;
%end;
if ~exist('night','var')
night = 1;  
end;

surveypath =  '..\surveydata';
% this is where survey data is stored.  See make_*survey.m for how
% to make a survey file....

bathypath =   '..\bathydata';
% this is where we are storing bathymetry data.  

bottomfname = '\\seagoer\DATA\BottomAvoidHm02\Bottom.out';
% Where the bottom track data from the Serial streams is stored.

fname_plotinfo='\\hecate\data\bottomtrackcomputer\m_files\bottominfo.txt';
% This is where info for the plots are stored.  

% depth difference between Marlin and the bottom at which a warning is
% spit out....
DEPTHWARN=50;

% colors:
if night
  axesbackcol = [1 1 1]*0.0;
  cautioncolor = [1 0 1]*0.4;
  backcol = [1 1 1]*0.0;
  forecol=[1 1 0]*0.4;
  trackcolor=[1 1 0]*.4;
else
  axesbackcol = [1 1 1];
%  backcol = [1 1 1]*0.2;
  backcol = [1 1 1]*0.6;
  forecol=[0 0 0];
  cautioncolor = [1 0 1];
  trackcolor=[1 1 1]*.1;
end;

% set some plotinfo stuff:
plotinfo.mdepth=[];
plotinfo.along=[];

changesurvey=1;
h0 = figure(24);
clf
set(h0,'units','pixels')
pos=[10    90   1024*0.9   672*0.9]
set(h0,'defaultaxescolor',forecol);
set(h0,'defaultaxesxcolor',forecol);
set(h0,'defaultaxesycolor',forecol);
set(h0,'defaultaxeszcolor',forecol);
set(h0,'defaulttextcolor',forecol);
set(h0,'backingstore','on','doublebuffer','on',...
       'menu','none','interrupt','off');

% set a bunch of dimensions in normalized units...
% There is a main axis upper left:
depthpos = [0.09 0.25 0.58 0.68];
pospos = [0.68 2/5 0.3 0.3];

%%%%% AXES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(h0,'Color',backcol, ...
	'FileName','Q:\LABVIEW\Zelman\BottomTrack\bottom_plot.m', ...
       'position',pos,...
       'Tag','Fig1', ...
       'ToolBar','none');
plotinfo.fig=h0;
h1 = axes('Parent',h0, ...
	'Units','normal', ...
	'CameraUpVector',[0 1 0], ...
	'Color',axesbackcol, ...
	'Position',depthpos);
plotinfo.depthaxes=h1;
h1 = axes('Parent',h0, ...
          'Units','normal', ...
          'CameraUpVector',[0 1 0], ...
          'Color',axesbackcol, ...
          'Position',pospos);
plotinfo.posaxes=h1;

%%%% BOTTOM READOUTS (6) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nlabs=6;
x0=0.01;
dx = 0.15;
ddx=(1-2*x0-dx*nlabs)/(nlabs-1);
y0 = 0.072;
dy=0.1;
for i = 1:nlabs
  hbotread(i) =  uicontrol('Parent',h0,...
        'Units','normal', ...
	'BackgroundColor',backcol, ...
	'ListboxTop',0, ...
	'fontsize',30,...
        'fontweight','bold',...
	'Position',[x0+(i-1)*(dx+ddx) y0 dx dy], ...
	'Style','text',...
	'String','',...
	'foregroundcol',forecol);
end;
% assign pointers...
plotinfo.bottom_depth = hbotread(1);
plotinfo.marlin_depth = hbotread(2);
plotinfo.depthdiff    =  hbotread(3);
plotinfo.marlinOA    =  hbotread(4);
plotinfo.marlinspeed    =  hbotread(5);
plotinfo.marlinspeedknt    =  hbotread(6);
%%%%% BOTTOM READOUT LABELS (6) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labs = {'Bottom Depth [m]','Marlin Depth [m]', 'Depth Diff [m]', ...
	'OA Range [m]', 'Marlin Speed [m/s]','Marlin Speed [kts]'};
y0 = y0-(18/25)*dy-0.01;
for i = 1:nlabs
  hbotlabs(i) =  uicontrol('Parent',h0,...
        'Units','normal', ...
	'BackgroundColor',backcol, ...
	'ListboxTop',0, ...
	'fontsize',18,...					   
	'Position',[x0+(i-1)*(dx+ddx) y0 dx dy], ...
	'Style','text',...
	'String',labs{i},...
	'foregroundcol',forecol);
end;

%%%%% RIGHT HAND SIDE INFORMATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
y0 = 0.25
dy = 0.08;
x0 = 0.71;
dx = 0.065;
ddx=0.001;
nlabs = 4;
lab={'Head:','None','Spd:','None'};
for i = 1:nlabs-1
  headread(i) =  uicontrol('Parent',h0,...
                           'Units','normal', ...
                           'BackgroundColor',backcol, ...
                           'ListboxTop',0, ...
                           'fontsize',14,...					   
                           'Position',[x0+(i-1)*(dx+ddx) y0 dx dy], ...
                           'Style','text',...
                           'String',lab{i},...
                           'foregroundcol',forecol);
  
end;
headread(nlabs) =  uicontrol('Parent',h0,...
                             'Units','normal', ...
                             'BackgroundColor',backcol, ...
                             'ListboxTop',0, ...
                             'fontsize',14,...
                             'Position',[x0+(nlabs-1)*(dx+ddx) y0-dy 1.3*dx 2*dy], ...
                             'Style','text',...
                             'String','None',...
                             'foregroundcol',forecol);

plotinfo.shiphead = headread(2);
plotinfo.spdlog = headread(4);

%%%%%% INFO IN THE UPPER RIGHT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Ship's pos, upper rigth
dy = 0.08;
dx = 0.085;
x0 = 0.78;
y0 = 0.72;
posstr={'Lon','Lat','Time','None','None','None'};
for i=1:2
  for j=1:3 
    num = (i-1)*3+j;
    posread(num) =  uicontrol('Parent',h0,...
                              'Units','normal', ...
                              'BackgroundColor',backcol, ...
                              'ListboxTop',0, ...
                              'fontsize',14,...
                              'Position',[x0+(i-1)*(dx+ddx) y0+(j-1)*dy ...
                        dx+(i-1)*dx*0.5 dy], ...
                              'Style','text',...
                              'String',posstr{num},...
                              'foregroundcol',forecol);
  end;
end;
plotinfo.lon=posread(4);
plotinfo.lat=posread(5);
plotinfo.time=posread(6);

%%%%% AXES LIMITS GUIS %%%%%%%%%%%%%%%%%%%%%%%%%%

pos = get(plotinfo.depthaxes,'pos');
x0 = pos(1)+pos(3)+0.01;
dy = 0.03;
ddy=0.0045;
y0 = 0.7;
contstr={'left [km]','1','right [km]','1',...
	 'below [m]','100','above [m]','100'};
for i=1:8
  if ((floor(i/2))*2 ~=i)
    contread(i) =  uicontrol('Parent',h0,...
			     'Units','normal', ...
			     'BackgroundColor',backcol, ...
			     'ListboxTop',0, ...
			     'fontsize',12,...
			     'Position',[x0 y0+(i-1)*(dy+ddy) dx dy], ...
			     'Style','text',...
			     'String',contstr{i},...
			     'foregroundcol',forecol);
  else
    contread(i) =  uicontrol('Parent',h0,...
			     'Units','normal', ...
			     'BackgroundColor',axesbackcol, ...
			     'ListboxTop',0, ...
			     'fontsize',12,...
			     'Position',[x0 y0+(i-1)*(dy+ddy) dx dy], ...
			     'Style','edit',...
			     'String',contstr{i},...
			     'foregroundcol',forecol);    
  end;
end;

plotinfo.lleft = contread(2);
plotinfo.lright = contread(4);
plotinfo.zdown = contread(6);
plotinfo.zup = contread(8);

% button for switching surveydata...

contread(i+1) =  uicontrol('Parent',h0,...
                         'Units','normal', ...
                         'BackgroundColor',axesbackcol, ...
                         'ListboxTop',0, ...
                         'fontsize',12,...
                         'Position',[0.1 0.9 0.13 0.05],...
                         'Style','pushbutton',...
                         'String','Change Surveyfile',...
                         'Callback','swapsurveyfile',...
                          'foregroundcol',forecol,...
                           'fontsize',7);
contread(i+2) =  uicontrol('Parent',h0,...
                         'Units','normal', ...
                         'BackgroundColor',axesbackcol, ...
                         'ListboxTop',0, ...
                         'fontsize',12,...
                         'Position',[0.5 0.9 0.13 0.05],...
                         'Style','pushbutton',...
                         'String','Night/Day',...
                         'Callback','night=mod(night+1,2);bottom_plot4',...
                          'foregroundcol',forecol,...
                           'fontsize',7);
                       

%%%%%%%%%%% DONE SETTING UP AXES  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%% CONTROL LOOP   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

plotinfo.surveyname='';
oldtime = -1e6;
set_up_survey
while 1
  for i=1:2
    update_plot;
    for i=1:5
      pause(1);
    end;
  % pause(1);
  end;
end;

%%%%%%%%%%%%%%% DONE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%