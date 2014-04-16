function varargout = TNoiseCal2(varargin)
% TNOISECAL2 MATLAB code for TNoiseCal2.fig
%      TNOISECAL2, by itself, creates a new TNOISECAL2 or raises the existing
%      singleton*.
%
%      H = TNOISECAL2 returns the handle to a new TNOISECAL2 or the handle to
%      the existing singleton*.
%
%      TNOISECAL2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TNOISECAL2.M with the given input arguments.
%
%      TNOISECAL2('Property','Value',...) creates a new TNOISECAL2 or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TNoiseCal2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TNoiseCal2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TNoiseCal2

% Last Modified by GUIDE v2.5 06-Aug-2013 09:35:27
% Changed plot limits because the old mwmcc driver though the DAQ
% was 12-bit and all the voltage values came back 16 times too large!
global stopflag;

stopflag = 0;

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TNoiseCal2_OpeningFcn, ...
                   'gui_OutputFcn',  @TNoiseCal2_OutputFcn, ...
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

% --- Executes just before TNoiseCal2 is made visible.
function TNoiseCal2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TNoiseCal2 (see VARARGIN)

% Choose default command line output for TNoiseCal2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initialize_gui(hObject, handles, false);

% UIWAIT makes TNoiseCal2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TNoiseCal2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function initialize_gui(fig_handle, handles, isreset)
% If the tempdata field is present and the BTStop flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to BTStop the data.
if isfield(handles, 'tempdata') && ~isreset
    return;
end
handles.tempdata.chipod = '';
handles.tempdata.ampboard = '';

handles.tempdata.fmin = 2.5;
handles.tempdata.fmax  = 40;
handles.tempdata.nsamples = 20000;
handles.tempdata.nfft = 1024;
handles.tempdata.samplerate = 400;

handles.tempdata.whitenoise = rand(1,100000);
handles.tempdata.diffnoise = rand(1,100000);
handles.tempdata.datadir = '';

set(handles.EDChipod, 'String', handles.tempdata.chipod);
set(handles.EDAmpboard, 'String', handles.tempdata.ampboard);
set(handles.EDFmin, 'String', handles.tempdata.fmin);
set(handles.EDFmax,  'String', handles.tempdata.fmax);
set(handles.EDNsamples, 'String', handles.tempdata.nsamples);

set(handles.EDNfft,  'String', handles.tempdata.nfft);
set(handles.EDSamplerate,  'String', handles.tempdata.samplerate);
handles.topplot = subplot(2,1,1,'replace');
handles.botplot = subplot(2,1,2,'replace');
% Update handles structure
guidata(handles.figure1, handles);



function EDChipod_Callback(hObject, eventdata, handles)
% hObject    handle to EDChipod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EDChipod as text
%        str2double(get(hObject,'String')) returns contents of EDChipod as a double
chipod = get(hObject,'String')%returns contents of EDChipod as text

% Save the new EDChipod value
handles.tempdata.chipod  = chipod;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function EDChipod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EDChipod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EDAmpboard_Callback(hObject, eventdata, handles)
% hObject    handle to EDAmpboard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

amp = get(hObject,'String');%returns contents of EDAmp as text

% Save the new edampboard value
handles.tempdata.ampboard  = amp;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function EDAmpboard_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EDAmpboard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% these functions handle changes in the acquisition setting part of GUI

function EDNsamples_Callback(hObject, eventdata, handles)
% hObject    handle to EDNsamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

nsamples = str2double(get(hObject, 'String'));
if isnan(nsamples)
    set(hObject, 'String', handles.tempdata.nsamples);  % set last valid
    errordlg('Input must be a number','Error');
end
% Save the new NSamples value
handles.tempdata.nsamples = nsamples;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function EDNsamples_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function EDFmin_Callback(hObject, eventdata, handles)

% Hints: get(hObject,'String') returns contents of EDFmin as text
%        str2double(get(hObject,'String')) returns contents of EDFmin as a double
fmin = str2double(get(hObject, 'String'));
if isnan(fmin)
    set(hObject, 'String', handles.tempdata.fmin);
    errordlg('Input must be a number','Error');
end
% Save the new EDStart value
handles.tempdata.fmin = fmin;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function EDFmin_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EDFmax_Callback(hObject, eventdata, handles)

% Hints: get(hObject,'String') returns contents of EDFmax as text
%        str2double(get(hObject,'String')) returns contents of EDFmax as a double
fmax = str2double(get(hObject, 'String'));
if isnan(fmax)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

% Save the new EDFmax value
handles.tempdata.fmax = fmax;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function EDFmax_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EDNfft_Callback(hObject, eventdata, handles)

% Hints: get(hObject,'String') returns contents of EDNfft as text
%        str2double(get(hObject,'String')) returns contents of EDNfft as a double
nfft = str2double(get(hObject, 'String'));
if isnan(nfft)
    set(hObject, 'String', handles.tempdata.nfft);
    errordlg('Input must be a number','Error');
end

% Save the new EDFmax value
handles.tempdata.nfft = nfft;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function EDNfft_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EDSamplerate_Callback(hObject, eventdata, handles)

% Hints: get(hObject,'String') returns contents of EDSamplerate as text
%        str2double(get(hObject,'String')) returns contents of EDSamplerate as a double
samplerate = str2double(get(hObject, 'String'));
if isnan(samplerate)
    set(hObject, 'String', handles.tempdata.samplerate);
    errordlg('Input must be a number','Error');
end
% Save the new EDFmax value
handles.tempdata.samplerate = samplerate;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function EDSamplerate_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in BTDirectory.
function BTDirectory_Callback(hObject, eventdata, handles)

datadir = uigetdir('');  %  call standard dialog
% Save the new data directory value
handles.tempdata.datadir  = datadir;
guidata(hObject,handles);

% --- Executes on button press in BTStart.
function BTStart_Callback(hObject, eventdata, handles)
% hObject    handle to BTStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stopflag;
disp(handles.tempdata.datadir);

%  collect the data, then execute analysis function
 subplot(handles.topplot);
 cla;
 subplot(handles.botplot);
 cla;
title('COLLECTING DATA');
nsamples = handles.tempdata.nsamples;
sr = handles.tempdata.samplerate;
[handles.tempdata.whitenoise, handles.tempdata.diffnoise] = NoiseDAQ(sr,nsamples,handles)

title('');
CalculateXfer(hObject, eventdata, handles);
if stopflag
	disp('Calibration halted by user.');   
else
    disp('Calibration complete.');
end
fclose all;


% calculate the transfer function
function CalculateXfer(hObject, eventdata, handles)
%   t_xfr_fcn_from_noise
%   computes dc and differentiator gain from data obtained 
%   using A signal generator noise source
%   column 1 in data file - noise source
%   column 2 in data file - TC out
%
%   gains are computed over the frequency range freq_range
%   In two forms: 1. mean gain over the range.
%   This coefficient is used if \phi_{out}/\phi_{white noise} is flat
%   In this case this coefficient should be in second place in 
%   head.coef.TP, and third and forth place should be zero: [1 mg 0 0 1] 
%   2. functional fit over the range in form 10^(c1*log10(f)+c0).
%   This coefficient is used if \phi_{out}/\phi_{white noise} is not flat
%   In this case these coefficient should be in third and forth place in 
%   head.coef.TP, and second coefficient should be one: [1 1 c0 c1 1] 
%
%   datadir - path to the directory in which
%   sr - sample rate; usually 1000 or 4000 (sr=4000; or sr=1000;)
%   $Revision: 1.0.0.0 $  $Date: 2013/07/02  $

% datadir='\\baltic\data2\chipod\tao_may08\calibration\Tdiff\C\';

warning off;
datadir = handles.tempdata.datadir;
mkdir([datadir '\xndata\']);
mkdir([datadir '\xnfigs']);

freq_range=[handles.tempdata.fmin handles.tempdata.fmax];
% freq_range=[4 20];
nfft=handles.tempdata.nfft;
sr=handles.tempdata.samplerate;
%return;
pp.xlm=[.1 1000];
pp.figpos=[300 100 800 800];
pp.figpappos=[.25 1.5 8 8];
pp.ylm1=[1e-7 1e-1];
pp.ylm2=[1e-3 1];

fn=([datadir '\xndata\' handles.tempdata.chipod '.mat' ]);
disp(['Saving data to' fn]);

save(fn,'-struct', 'handles','tempdata');
        %dat=load(fn);
       % fn(fn=='_')='-';

       output = handles.tempdata.diffnoise;
       white_noise = handles.tempdata.whitenoise;

        
        [pout,f]=fast_psd(output,nfft,sr);
        [pwn,f]=fast_psd(white_noise,nfft,sr);

       % figure(89+i0);clf;
        %set(gcf,'position',pp.figpos,'paperposition',pp.figpappos)
        set(gcf,'position',pp.figpos)
      
        set(gcf,'PaperPositionMode','auto')
        % checking for similarity to LTSpice
        % the following give a plot similar to a differentiator in LTSpice
        %pout = sqrt(pout./pwn);
        subplot(handles.topplot)

        loglog(f,pout,'r',f,pwn,'k');grid
        legend('\Phi_{output}','\Phi_{white noise}','location','best')
        title([fn])
        xlabel('frequency [Hz]')
        ylabel('data as sampled [V^2/Hz]')
        xlim(pp.xlm),ylim(pp.ylm1)
        set(gca,'xtick',10.^[-3:4])
        
        subplot(handles.botplot)
        %clf;
        % find differentiator gain
   % This gives downward slope even with simple RC differentiator
        pTPg=(pout./pwn)./(2*pi*f).^2;
 
       
        % calculate mean differentiator gain over freq_range
        infr=f>freq_range(1)& f<freq_range(2);
        mean_diff_gain=nanmean(sqrt(pTPg(infr))); 
        % fit differentiator gain wit a function over freq_range
%         dg1=polyfit(f(infr),pTPg(infr),1);
%         dg2=polyfit(f(infr),log10(pTPg(infr)),1);
        dg3=polyfit(log10(f(infr)),log10(pTPg(infr)),1);

          loglog(f,sqrt(pTPg),'k');hold on
          
%         loglog(f,sqrt(dg1(1).*f+dg1(2)),'g');
%         loglog(f,sqrt(10.^(dg2(1).*f+dg2(2))),'m');
        loglog(f,sqrt(10.^(dg3(1).*log10(f)+dg3(2))),'b')
        plot([15 15],pp.ylm2,'k-',[freq_range(1) freq_range(1)],pp.ylm2,'k--',...
            [freq_range(2) freq_range(2)],pp.ylm2,'k--')
        grid,set(gca,'xtick',10.^[-3:4]),xlim(pp.xlm),ylim(pp.ylm2)
        xlabel('frequency [Hz]')
%         legend('(pTPg)^{1/2}=(\Phi_{output}/\Phi_{white noise})^{1/2}/(2\pi\cdotf)',...
%             ['Fit to pTPg over (' num2str(freq_range(1)) '-' num2str(freq_range(2)) 'Hz): a_1*f+a_0'],...
%             ['Fit to pTPg over (' num2str(freq_range(1)) '-' num2str(freq_range(2)) 'Hz): 10^{b_1*f+b_0}'],...
%             ['Fit to pTPg over (' num2str(freq_range(1)) '-' num2str(freq_range(2)) 'Hz): 10^{c_1*log_{10}f+c_0}'],...
%             'location','southwest')
        legend('(pTPg)^{1/2}=(\Phi_{output}/\Phi_{white noise})^{1/2}/(2\pi\cdotf)',...
            ['Fit to pTPg over (' num2str(freq_range(1)) '-' num2str(freq_range(2)) 'Hz): 10^{c_1*log_{10}f+c_0}'],...
            'location','northeast')
        text(0.02,0.15,['mean diff gain(' num2str(freq_range(1)) '-' num2str(freq_range(2)) 'Hz)=',num2str(mean_diff_gain)],...
            'units','normalized','BackgroundColor','white')
%         text(0.65,0.74,['a_1=' num2str(dg1(1)) ', a_0=' num2str(dg1(2))],'units','normalized')
%         text(0.65,0.81,['b_1=' num2str(dg2(1)) ', b_0=' num2str(dg2(2))],'units','normalized')
        text(0.02,0.08,['c_1=' num2str(dg3(1)) ', c_0=' num2str(dg3(2))],'units','normalized',...
            'BackgroundColor','white')
        ylabel('(\Phi_{output}/\Phi_{white noise})^{1/2}/(2\pi\cdotf)')
        bs=0;
        figname = [datadir '\xnfigs\' handles.tempdata.chipod '.png'];
        disp('Printing figure.');
        print('-dpng','-r300',figname);
        
        



function EDProgress_Callback(hObject, eventdata, handles)
% hObject    handle to EDx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EDx as text
%        str2double(get(hObject,'String')) returns contents of EDx as a double

% --- Executes during object creation, after setting all properties.
function EDProgress_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EDx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function EDx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EDx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
