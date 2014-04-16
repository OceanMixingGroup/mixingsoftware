function varargout = Chitcal(varargin)
% CHITCAL MATLAB code for Chitcal.fig
%      CHITCAL, by itself, creates a new CHITCAL or raises the existing
%      singleton*.
%
%      H = CHITCAL returns the handle to a new CHITCAL or the handle to
%      the existing singleton*.
%
%      CHITCAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHITCAL.M with the given input arguments.
%
%      CHITCAL('Property','Value',...) creates a new CHITCAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Chitcal_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Chitcal_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Chitcal

% Last Modified by GUIDE v2.5 10-Jul-2013 14:15:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Chitcal_OpeningFcn, ...
                   'gui_OutputFcn',  @Chitcal_OutputFcn, ...
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


% --- Executes just before Chitcal is made visible.
function Chitcal_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Chitcal (see VARARGIN)

% Choose default command line output for Chitcal
handles.output = hObject;
handles.tempdata.sernum = 500;
handles.tempdata.upper = 'unknown';
handles.tempdata.lower = 'unknown';
handles.tempdata.path = '';
handles.tempdata.sbfilename = '';
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Chitcal wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Chitcal_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in PBSeabird.
function PBSeabird_Callback(hObject, eventdata, handles)
% hObject    handle to PBSeabird (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname,filterindex] = uigetfile('.mat','Seabird .mat file')
if filename ~= 0
    handles.tempdata.sbfilename = filename;
    handles.tempdata.pathname = pathname;
    cd(pathname);
    set(handles.EDSBDFile,'String',[pathname filename]);
else
    handles.tempdata.sbfilename =  0;
    handles.tempdata.pathname = 0;
end
display(handles.tempdata.sbfilename);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EDSernum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EDSernum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EDSernum_Callback(hObject, eventdata, handles)
% hObject    handle to EDSernum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EDSernum as text
sernum = str2double(get(hObject,'String'));

if isnan(sernum)
    set(hObject, 'String', '5xxx');
    errordlg('Input must be a number','Error');
end
handles.tempdata.sernum = sernum;
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in PBReduce.
function PBReduce_Callback(hObject, eventdata, handles)
% hObject    handle to PBReduce (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
top = handles.tempdata.upper
bottom = handles.tempdata.lower
sernum = handles.tempdata.sernum
%make_chiT_calibration_file('cpcal0709.mat',505,0);
filename = handles.tempdata.sbfilename;
display(sernum);
if ~isdir('chitcaldata')
    mkdir('chitcaldata');
end
try
    set(handles.TStatus,'string','Reading Seabird and Chipod files  then Writing summary file to chitcaldata'); 
    drawnow;
    make_chitcal_file(filename,sernum,0);
catch err1
   errordlg('Error while generating summary file!','Error'); 
   rethrow(err1)
end

try
    set(handles.TStatus,'string','Calculating coefficients and generating plots');
    drawnow;
    chitcalibrate1('chitcaldata',sernum, top,bottom,2);
    %Starts the chitcalibrate1 function to take the last 50% of the datapoints
    %of plateaus irrespective of the length of the plateau
catch err2
    errordlg('Error while computing coefficients!','Error');
    rethrow(err2)
end;
    set(handles.TStatus,'string','Ready');
    drawnow;
    
    % --- Executes during object creation, after setting all properties.
function EDTupper_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EDTupper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EDTupper_Callback(hObject, eventdata, handles)
% hObject    handle to EDTupper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.tempdata.upper = get(hObject,'String');
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function EDTlower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EDTlower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function EDTlower_Callback(hObject, eventdata, handles)
% hObject    handle to EDTlower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.tempdata.lower = get(hObject,'String');
% Update handles structure
guidata(hObject, handles);




function EDSBDFile_Callback(hObject, eventdata, handles)
% hObject    handle to EDSBDFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EDSBDFile as text
%        str2double(get(hObject,'String')) returns contents of EDSBDFile as a double


% --- Executes during object creation, after setting all properties.
function EDSBDFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EDSBDFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
