function varargout = PTempCal4(varargin)
% PTEMPCAL4 MATLAB code for PTempCal4.fig
%      ptempcal4, by itself, creates a new PTEMPCAL4 or raises the existing
%      singleton*.
%
%      H = PTEMPCAL4 returns the handle to a new PTEMPCAL4 or the handle to
%      the existing singleton*.
%
%      PTEMPCAL4('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PTEMPCAL4.M with the given input arguments.
%
%      PTEMPCAL4('Property','Value',...) creates a new PTEMPCAL4 or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PTempCal4_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PTempCal4_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PTempCal4

% Last Modified by GUIDE v2.5 18-Sep-2013 18:24:59
global stopflag;

stopflag = 0;

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PTempCal4_OpeningFcn, ...
                   'gui_OutputFcn',  @PTempCal4_OutputFcn, ...
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

% --- Executes just before PTempCal4 is made visible.
function PTempCal4_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PTempCal4 (see VARARGIN)

% Choose default command line output for PTempCal4
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initialize_gui(hObject, handles, false);

% UIWAIT makes PTempCal4 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PTempCal4_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function EDStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EDStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EDStart_Callback(hObject, eventdata, handles)
% hObject    handle to EDStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EDStart as text
%        str2double(get(hObject,'String')) returns contents of EDStart as a double
tstart = str2double(get(hObject, 'String'));
if isnan(tstart)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

% Save the new EDStart value
handles.tempdata.tstart = tstart;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function EDEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EDEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EDEnd_Callback(hObject, eventdata, handles)
% hObject    handle to EDEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EDEnd as text
%        str2double(get(hObject,'String')) returns contents of EDEnd as a double
tend = str2double(get(hObject, 'String'));
if isnan(tend)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

% Save the new EDEnd value
handles.tempdata.tend = tend;
guidata(hObject,handles)



% --- Executes on button press in BTStart.
function BTStart_Callback(hObject, eventdata, handles)
% hObject    handle to BTStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stopflag;
disp(handles.tempdata);
disp(handles);
PTCal8_rex(hObject, eventdata, handles);
if stopflag
	disp('Calibration halted by user.');   
else
    disp('Calibration complete.');
end
fclose all;



% --- Executes on button press in BTStop.
function BTStop_Callback(hObject, eventdata, handles)
% hObject    handle to BTStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stopflag;
%initialize_gui(gcbf, handles, true);
stopflag = 1;  % Tempcal function must check this global and exit if 1



% --------------------------------------------------------------------
function initialize_gui(fig_handle, handles, isreset)
% If the tempdata field is present and the BTStop flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to BTStop the data.
if isfield(handles, 'tempdata') && ~isreset
    return;
end

handles.tempdata.tstart = 34;
handles.tempdata.tend  = 8;
handles.tempdata.datadir = pwd;
% handles.tempdata.tcurrent = 30;
handles.tempdata.chan1 = '';
handles.tempdata.chan2 = '';
handles.tempdata.chan3 = '';
handles.tempdata.chan4 = '';
set(handles.EDStart, 'String', handles.tempdata.tstart);
set(handles.EDEnd,  'String', handles.tempdata.tend);
% set(handles.EDCurrent,  'String', handles.tempdata.tcurrent);



% Update handles structure
guidata(handles.figure1, handles);


function EDCurrent_Callback(hObject, eventdata, handles)
% hObject    handle to EDCurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EDCurrent as text
%        str2double(get(hObject,'String')) returns contents of EDCurrent as a double


% --- Executes during object creation, after setting all properties.
function EDCurrent_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EDSlope_Callback(hObject, eventdata, handles)
% no action---not editable


function EDSlope_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PBDir.
function PBDir_Callback(hObject, eventdata, handles)
% hObject    handle to PBDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dir = uigetdir;
% Save the new datadir value
handles.tempdata.datadir = dir;
set(handles.EDDir,'String',dir);
guidata(hObject,handles)


function EDDir_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function EDDir_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EDchan1_Callback(hObject, eventdata, handles)
% hObject    handle to EDchan1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EDchan1 as text
%        str2double(get(hObject,'String')) returns contents of EDchan1 as a double
chan1 = get(hObject, 'String');

% Save the new EDStart value
handles.tempdata.chan1 = chan1;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function EDchan1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EDchan1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EDchan2_Callback(hObject, eventdata, handles)
% hObject    handle to EDchan2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EDchan2 as text
%        str2double(get(hObject,'String')) returns contents of EDchan2 as a double
chan2 = get(hObject, 'String');

% Save the new EDStart value
handles.tempdata.chan2 = chan2;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function EDchan2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EDchan2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EDchan3_Callback(hObject, eventdata, handles)
% hObject    handle to EDchan3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EDchan3 as text
%        str2double(get(hObject,'String')) returns contents of EDchan3 as a double
chan3 = get(hObject, 'String');

% Save the new EDStart value
handles.tempdata.chan3 = chan3;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function EDchan3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EDchan3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EDchan4_Callback(hObject, eventdata, handles)
% hObject    handle to EDchan4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EDchan4 as text
%        str2double(get(hObject,'String')) returns contents of EDchan4 as a double
chan4 = get(hObject, 'String');

% Save the new EDStart value
handles.tempdata.chan4 = chan4;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function EDchan4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EDchan4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EDesttime_Callback(hObject, eventdata, handles)
% hObject    handle to EDesttime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EDesttime as text
%        str2double(get(hObject,'String')) returns contents of EDesttime as a double


% --- Executes during object creation, after setting all properties.
function EDesttime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EDesttime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
