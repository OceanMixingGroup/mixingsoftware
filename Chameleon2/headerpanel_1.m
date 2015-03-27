function varargout = headerpanel_1(varargin)
% HEADERPANEL_1 MATLAB code for headerpanel_1.fig
%      HEADERPANEL_1, by itself, creates a new HEADERPANEL_1 or raises the existing
%      singleton*.
%
%      H = HEADERPANEL_1 returns the handle to a new HEADERPANEL_1 or the handle to
%      the existing singleton*.
%
%      HEADERPANEL_1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HEADERPANEL_1.M with the given input arguments.
%
%      HEADERPANEL_1('Property','Value',...) creates a new HEADERPANEL_1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before headerpanel_1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to headerpanel_1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help headerpanel_1

% Last Modified by GUIDE v2.5 10-Nov-2013 15:42:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @headerpanel_1_OpeningFcn, ...
                   'gui_OutputFcn',  @headerpanel_1_OutputFcn, ...
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


% --- Executes just before headerpanel_1 is made visible.
function headerpanel_1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to headerpanel_1 (see VARARGIN)

% Choose default command line output for headerpanel_1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes headerpanel_1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = headerpanel_1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.headerpanel,'visible','off');
set(handles.displaybutton,'enable','on');
% set(handles.closebutton,'enable','off');
set(handles.uitable1,'visible','off');
 set(handles.popupmenu_temp2,'enable','off')
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in displaybutton.
function displaybutton_Callback(hObject, eventdata, handles)
% hObject    handle to displaybutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.headerpanel,'visible','on');
set(handles.displaybutton,'enable','off');
% set(handles.closebutton,'enable','on');
set(handles.uitable1,'visible','on');


% --- Executes on selection change in popupmenu_instrument.
function popupmenu_instrument_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_instrument (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_instrument contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_instrument


% --- Executes during object creation, after setting all properties.
function popupmenu_instrument_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_instrument (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in pushbutton_apply.
function pushbutton_apply_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.headerpanel,'visible','off');
set(handles.displaybutton,'enable','on');
% set(handles.closebutton,'enable','off');
guidata(hObject,handles);

% --- Executes on selection change in popupmenu_temp1.
function popupmenu_temp1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_temp1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_temp1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_temp1
% set(handles.popupmenu_temp2,'enable','off');
Temp_value = get(handles.popupmenu_temp1,'Value')
% set(handles.popupmenu_temp2,'visible','on');
switch Temp_value
    case 1
        set(handles.popupmenu_temp2,'enable','off');
        guidata(hObject,handles);
    case 2
        set(handles.popupmenu_temp2,'enable','on');
       
        set_string = {'select sensor 2';'T2';'T3';'T4'};
        set(handles.popupmenu_temp2,'string',set_string);
        guidata(hObject,handles);
    case 3
        set(handles.popupmenu_temp2,'enable','on');
        set_string = {'select sensor 2';'T1';'T3';'T4'};
        set(handles.popupmenu_temp2,'string',set_string,'FontSize',10);
        guidata(hObject,handles);
        
    case 4
        set(handles.popupmenu_temp2,'enable','on');
        set_string = {'select sensor 2';'T1';'T2';'T4'};
        set(handles.popupmenu_temp2,'string',set_string,'FontSize',10);
        guidata(hObject,handles);
    case 5
        set(handles.popupmenu_temp2,'enable','on');
       set_string = {'select sensor 2';'T1';'T2';'T3'};
        set(handles.popupmenu_temp2,'string',set_string,'FontSize',10);
        guidata(hObject,handles);
    
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function popupmenu_temp1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_temp1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_shear.
function popupmenu_shear_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_shear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_shear contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_shear


% --- Executes during object creation, after setting all properties.
function popupmenu_shear_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_shear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_pitot.
function popupmenu_pitot_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_pitot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_pitot contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_pitot


% --- Executes during object creation, after setting all properties.
function popupmenu_pitot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_pitot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu.
function popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu


% --- Executes during object creation, after setting all properties.
function popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_temp2.
function popupmenu_temp2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_temp2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_temp2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_temp2


% --- Executes during object creation, after setting all properties.
function popupmenu_temp2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_temp2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
