function varargout = gain_offset(varargin)
% GAIN_OFFSET MATLAB code for gain_offset.fig
%      GAIN_OFFSET, by itself, creates a new GAIN_OFFSET or raises the existing
%      singleton*.
%
%      H = GAIN_OFFSET returns the handle to a new GAIN_OFFSET or the handle to
%      the existing singleton*.
%
%      GAIN_OFFSET('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GAIN_OFFSET.M with the given input arguments.
%
%      GAIN_OFFSET('Property','Value',...) creates a new GAIN_OFFSET or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gain_offset_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gain_offset_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gain_offset

% Last Modified by GUIDE v2.5 04-Feb-2014 11:24:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gain_offset_OpeningFcn, ...
                   'gui_OutputFcn',  @gain_offset_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gain_offset is made visible.
function gain_offset_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gain_offset (see VARARGIN)

% Choose default command line output for gain_offset
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gain_offset wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gain_offset_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function [grp] = incrementdecrement(lblhdl, initval, varargin)
%INCREMENTDECREMENT create a button group for incrementing/decrementing a value.
%   INCREMENTDECREMENT is a custom button group that simplifies the creation of
%   the "inc/dec" arrows that are commonly used in GUIs.
%
%   INCREMENTDECREMENT(INITVAL) creates the button group and sets the initial

% Create the button group, which will contain the inc/dec buttons.
grp = uibuttongroup(varargin{:});

% Get sizing info for the buttons.
set(grp, 'Units', 'Points')
pos = get(grp, 'Position');
height = pos(4)/2;
posup = [-1 height-1 pos(3) height];
posdn = [-1 -1       pos(3) height];

% Create the buttons.
hup = uicontrol('Style', 'PushButton', 'Parent', grp);
hdn = uicontrol('Style', 'PushButton', 'Parent', grp);

% Resize the buttons to fill the group.
set(hup, 'Units', 'Points', 'Position', posup);
set(hdn, 'Units', 'Points', 'Position', posdn);

% From http://www.mathworks.com/matlabcentral/newsreader/view_thread/51230.
set(hup, 'String', '<html>&#x25B2;</html>', 'FontSize', height/1.5);
set(hdn, 'String', '<html>&#x25BC;</html>', 'FontSize', height/1.5);

% Initalize the counter.
set(grp, 'UserData', initval);

% Set the callbacks.
set(hup, 'Callback', @inc);
set(hdn, 'Callback', @dec);

% Define the callbacks.
    function inc(varargin)
        set(grp, 'UserData', get(grp, 'UserData') + 1);
        set(lblhdl, 'Value', get(grp, 'UserData'));
        set(lblhdl, 'String', num2str(get(grp, 'UserData')));
    end

    function dec(varargin)
        set(grp, 'UserData', get(grp, 'UserData') - 1);
        set(lblhdl, 'Value', get(grp, 'UserData'));
        set(lblhdl, 'String', num2str(get(grp, 'UserData')));
    end
end
