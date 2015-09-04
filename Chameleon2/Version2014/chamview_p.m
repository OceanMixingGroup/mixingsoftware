       function varargout = chamview_p(varargin)
% CHAMVIEW_P MATLAB code for chamview_p.fig
%      CHAMVIEW_P, by itself, creates a new CHAMVIEW_P or raises the existing
%      singleton*.
%
%      H = CHAMVIEW_P returns the handle to a new CHAMVIEW_P or the handle to
%      the existing singleton*.
%
%      CHAMVIEW_P('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHAMVIEW_P.M with the given input arguments.
%
%      CHAMVIEW_P('Property','Value',...) creates a new CHAMVIEW_P or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before chamview_p_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to chamview_p_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help chamview_p

% Last Modified by GUIDE v2.5 10-Feb-2014 10:41:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @chamview_p_OpeningFcn, ...
                   'gui_OutputFcn',  @chamview_p_OutputFcn, ...
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


% --- Executes just before chamview_p is made visible.
function chamview_p_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to chamview_p (see VARARGIN)
ax1 = gca;

% Choose default command line output for chamview_p
handles.output = hObject;
handles.tempdata.baudrate = 57600; %sets baudrate
handles.tempdata.commport = 4; %COM port number 
handles.tempdata.bytesreceived = 0;
handles.tempdata.commdev = 0;
handles.tempdata.outpath = '';
set(handles.stopbutton,'Enable','Off');
set(handles.pushbutton_selectnone,'Enable','Off');
set(handles.pushbutton_selectall,'Enable','Off');
set(handles.logbutton,'Enable','Off');
set(handles.gainoffset_panel,'Visible','off');
handles.tempdata.plotboxes = []; %Panel box for channels on the GUI
set(handles.pushbutton_pause,'Enable','Off');
wftemp = wf_init( ax1,50, -5,+5, 16, 5);
%setting up the channels panel on the GUI
set(handles.uipanel2, 'Units', 'pixels');
pnlpos = get(handles.uipanel2, 'Position');
pnltop = pnlpos(4);
hpos = 20;
vpos = pnltop - 10 ;
for ii = 1:16
    fieldstring = ['Chan' num2str(ii)];
    if ii == 9
        hpos = 120;
        vpos = pnltop - 10; 
    end
    
    vpos = vpos -25;
    uich1 = uicontrol(handles.uipanel2,...
        'Style','checkbox',...
        'BackgroundColor',wftemp.wfcolors(ii,:),...
        'String',fieldstring,...
        'Value',1,...
        'Position',[hpos vpos  80  20]);
        
    
    handles.tempdata.plotboxes(ii) = uich1;  
    set(handles.tempdata.plotboxes(ii),'Enable','off');
 
end
%setting channels 6,15 to zero as they have zero sample rates in the
%template
% set(handles.tempdata.plotboxes(15),'Value',0);
% set(handles.tempdata.plotboxes(1),'Value',0);
% set(handles.tempdata.plotboxes(15),'Enable','off');
% set(handles.tempdata.plotboxes(1),'Enable','off');

% set(handles.uipanel2,'Visible','on');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes chamview_p wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargouta = chamview_p_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure


varargout{1} = handles.output;


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in templatebutton.
function templatebutton_Callback(hObject, eventdata, handles)
% hObject    handle to templatebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% set(handles.headertext,'string','Chameleon_HDR_1');
global chidx;  %has the index of all virtual channels assigned from the header template
global virtual_ch;
global ch_asgn;
global gain;
global offset;
%Loading template and assigning channels names on the panel of GUi
[raw_name,temp,filterindex]=uigetfile('*.cht','Load Template File');
tmpfname=[temp raw_name];
[tmpl] = Cham2LoadTemplate(tmpfname);
[pathstr, name, ext] = fileparts(tmpfname);
hdrfname = fullfile(pathstr,[name, '.hdr']);
head = ReadCham2Header(hdrfname);
description = tmpl.description;
handles.tempdata.outpath = [];                                                     
handles.tempdata.head = head;
handles.tempdata.template = tmpl;
virtual_ch = handles.tempdata.template.virtualchannels;
set(handles.headertext,'String',raw_name);
set(handles.text13,'String',description);
set(handles.startbutton,'enable','on');
handles.tempdata.head.saildata = char(zeros(1,774));
% now fill in the checkbox labels with the channel names
set(handles.gainoffset_panel,'Visible','on');
for ii = 1:16
    sname = char(tmpl.chnames(ii,:));
    set(handles.tempdata.plotboxes(ii),'String', sname);
   
end
set(handles.popupmenu_channel,'String',tmpl.chnames);
chidx = {16};
gain = ones(1,size(tmpl.chnames,1));
offset = zeros(1,size(tmpl.chnames,1));
global tdat;
xchnums = tmpl.chnums(1:tmpl.virtualchannels);
for ii = 1:16
    chvect = find(xchnums==ii);
    chidx{ii} = chvect;
    if isempty(chvect)
        
        set(handles.tempdata.plotboxes(ii),'Enable','off');
        set(handles.tempdata.plotboxes(ii),'Value',0);
%         A(ii) = 0;
    else
        set(handles.tempdata.plotboxes(ii),'Enable','on');
%         A(ii) = ii
    end
 

end

% handles.tempdata.outpath = uigetdir('title','Select Output Data Directory');
handles.tempdata.outpath = 'C:\Users\mixing\Documents\chameleon2_test\chamviewpavan\data\';
handles.tempdata.head.startdepth = 0;
[out1,out2] = ChamFile(handles);
handles.tempdata.fname = [out1,'.',out2];

%%%%%%%%%%%%%%%%%%

%%%%GPS NOT USED NOW IN TESTING, USED ONLY WHEN THERE IS A GPS INPUT TO THE
%%%%COMPUTER. 
% serGPS=serial('COM1','BaudRate',4800);
% fopen(serGPS);
% [GPS_in] = ReadGarmin(serGPS);
% fclose(serGPS);
% delete(serGPS);
% clear serGPS;
% handles.tempdata.lat.start = strcat(num2str(GPS_in.lat),cell2mat(GPS_in.latdirRMC),'^^^^^^^^^^^^^^^^^^^');
% handles.tempdata.lon.start = strcat(num2str(GPS_in.lon),cell2mat(GPS_in.londirRMC),'^^^^^^^^^^^^^^^^^^^');
% handles.tempdata.head.starttime = strcat(num2str(GPS_in.date),num2str(GPS_in.timeRMC),'^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
% set(handles.textbox_lat,'String','Start Lat');
% set(handles.text_lon,'String','Start Lon');
% set(handles.text_date,'String','Start Date');
% set(handles.textbox_latitude,'String',handles.tempdata.lat.start(1:12));
% set(handles.text_longitude,'String',handles.tempdata.lon.start(1:12));
% set(handles.text_datetime,'String',handles.tempdata.head.starttime(1:12));
% sail = GPS_in.F(8:end);
% handles.tempdata.head.saildata(1:numel(sail)) = sail;

%%%%%%%%%%%%%%%%%%


% The chidx cells now each have a vector containing the indices within
% the packet that hold data for each channel.


WaterfallPlot(handles, [],-1);

handles.tempdata.chidx = chidx;

guidata(hObject,handles);
guidata(hObject,handles);

% --- Executes on button press in startbutton.
function startbutton_Callback(hObject, eventdata, handles)
    %this button starts LOGGING of the raw data when clicked on the GUI. 
    %the logging begins at the moment the button is pressed. This is
    %different from the "start viewing" button on the GUI. 
% hObject    handle to startbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global p1;
global t1;
p1 = 0;
t1 = now;
cla(handles.axes1);
set(handles.pushbutton_pause,'Enable','On');
set(handles.pushbutton_selectnone,'Enable','On');
% set(handles.tempdata.plotboxes,'Enable','on');
set(handles.stopbutton,'Enable','off');
%New template does not use channel 5,16 so have them disabled to avoid 'complications'
%Make sure to identify the channels in template whose samplerate = 0 and
%list them below to disable and deselect them. - Pavan
global stopbutt; 
% set(handles.stopbutton,'enable','on');
set(handles.startbutton,'enable','off');
set(handles.templatebutton,'enable','off');
set(handles.recordeddepth_textbox,'ForegroundColor','black');
set(handles.text13,'string','STARTED LOGGING FROM CHAMELEON');
set(handles.logbutton,'enable','on');
set(handles.logbutton,'BackgroundColor',[0.8,0.8,0.8]); %Grey color
set(handles.stopbutton,'BackgroundColor','red'); %red color
stopbutt = get(handles.stopbutton,'value');
 handles.tempdata.startspeed = now;
CollectAndProcess(hObject, handles);

set(handles.text13,'String','Halted');

return


% --- Executes on button press in stopbutton.
function stopbutton_Callback(hObject, eventdata, handles)
    %This button stops the LOGGING of data on the GUI at the point when the
    %button is clicked during the log.
% hObject    handle to stopbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% stopbutton = get(handles.stopbutton,'value');
global p2;
set(handles.templatebutton,'enable','on');
set(handles.text13,'string','LOGGING STOPPED');
set(handles.stopbutton,'enable','off');
set(handles.stopbutton,'BackgroundColor','red'); % Stop button is now Red 
set(handles.logbutton,'BackgroundColor',[0.8,0.8,0.8]); %Start Logging button is now Grey ;
set(handles.startbutton,'enable','on');
set(handles.pushbutton_selectnone,'Enable','On');
set(handles.pushbutton_selectall,'Enable','Off');
set(handles.logbutton,'enable','on');
set(handles.recordeddepth_textbox,'String',num2str(round(p2)));
set(handles.recordeddepth_textbox,'ForegroundColor','red');
global stopbutt
global runflag
% global runflag;
% cla(handles.axes1)
stopbutt = get(handles.stopbutton,'value');
handles.tempdata.endtime = now;

global outputrow
global times
global tstr
global tbytes
global out_row;
global firstgoodrow;

times1(1:out_row) = times(1:out_row)+handles.tempdata.starttime1;
% times(1:out_row) = times(1:out_row)+(handles.tempdata.endtime - handles.tempdata.tstr);
SaveData(handles,tbytes,handles.tempdata.startpath,out_row, times);
% SaveData(handles, tbytes,firstgoodrow,out_row, times);
set(handles.logbutton,'String','Start Logging');
set(handles.pushbutton_pause,'enable','on');
tbytes = zeros(200000,32);
out_row = 0;
%  3/15/13  Add array to hold time
times = zeros(200000,1);
% out_row = 0;
guidata(hObject,handles);




function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Ch1.


function CollectAndProcess(hObject, handles)
% this functon is called when the start button is pressed
% it continues until the stop button is pressed--which sets
% runflag to zero
global syncflag;
global runflag;
global tbytes;
global times;
global inputrow;
global ctick;
global out_row;
global firstgoodrow;
global t1;
global p1;
global p2;
global t2;



% initialize data for 3 plot axes plus time
% plotdata = zeros(501,16);
% plotlast = 501;
outputrow = 1;
% tbytes holds all the input data.  It is a global because
% the comm callback function puts data in the array.  Times is global
% for the same reason.
tbytes = zeros(200000,32);
%  3/15/13  Add array to hold time
times = zeros(200000,1);
syncflag = 0;
inputrow = 1;
commport = 'COM7';
ax1 = gca;
baudrate = handles.tempdata.baudrate;
sr = double(handles.tempdata.template.samplerate);
vc = double(handles.tempdata.template.virtualchannels);
pktinterval = 1.0/(sr/vc);
%   = (sr/vc)/5;
plotinterval =4;
% close the comm port if it is already open
CloseCommPort(commport);
s = OpenMyComm(commport, baudrate);
% % now find the channels which have their checkbox checked
wf1 = wf_init( ax1,10, -5,+5, 16, 10);
% LabelPlots(handles, pidx, numselected);
% % pidx is now an array that has only the indices of checked channels
% % use that data to label the y Axes of the plots
handles.tempdata.commdev = s;
for ii = 1:16
    % the return value for the 'value' property is either 1 or 0
                pcheck(ii) =1; 
%                  pcheck(ii) = get(handles.tempdata.plotboxes(ii),'value');
%                handles.tempdata.chidx
end;
pidx = find(pcheck);
numselected = size(pidx,2);
guidata(hObject,handles);
nextdraw = 50;
handles.tempdata.starttime = now;
WaitForSync(s);
if syncflag ~= 1 
    return
end
% global pidx

ctick = tic;
runflag = 1;
pkttime = 0;
% pcheck = zeros(1,16);

% global outputrow;
vtic = tic;
firstgoodrow = inputrow;
set(handles.text13,'String','Collecting Raw Counts');
while runflag == 1
   
    lastsync = 32767;
    if inputrow > outputrow
        % modify to not send whole plotdata as parameter
        % but just the necessary variables as input and output
        % if the last byte in packet is not one of sync bytes,
        % resynchronize.  Note that, after original sync, the serial
        % callback handler subtracts 32768 from input values, so we
        % now have to  check for 0 and 32767
        if  (tbytes(outputrow,32) ~= 0) && (tbytes(outputrow,32)~= 32767)
            syncflag = 0;
            inputrow = inputrow-1;
            WaitForSync(s);
        end
       
        
% pcheck is a 1x15 vector where the values are 1 or zero
%         pidx = find(pcheck);
%         if isempty(pidx)
%             cla;
%         end
        
        lastsync = tbytes(outputrow,32);
       
        [pdata]  =  ProcessInput(handles,tbytes(outputrow,1:32), pidx);
%         pdata  =  ProcessInput(handles,plotbytes', pidx);

        if ~isempty(pdata)
            pkttime= pkttime+pktinterval;
                   
        end
%         ppoints = plotlast;
        
        if outputrow > nextdraw
            % we can have anywhere from 1 to 15 boxes checked
            % we will plot up to 3---the first that occur in order
            %DrawTimePlot(handles,plotdata, ppoints, numselected);
            
%             DrawSmoothPlot(handles,plotdata, ppoints, numselected,pkttime);
        for jj = 1:16
            uich1 = handles.tempdata.plotboxes(jj);  
            wf1.wfchantoplot(1,jj) = get(uich1,'Value');
        end
            WaterfallPlot(wf1,pdata,pkttime);
%             vtoc = toc;
%             if (vtoc>20)
                
                    Pc = handles.tempdata.head.coefficients(11,:);
                    %retrieving the header coefficients of Pressure sensor
                    
                    p = 11;%array location of pressure channel
                    Pv = pdata(:,p);
                    P_depth = ((Pc(1)+Pv*Pc(2)))/1.47; %calculating the pressure depth in meters
                    handles.tempdata.depthend = P_depth; %updating the depth
                  
                    p2 = P_depth; %final depth
                    t2 = now; % time t2
                    dt = (t2-t1)*86500; %calculating dt, time differential in seconds
                    if dt>0.25 
                        
                        dp = (p2-p1);
                        fallspeed = dp/dt;
                        p1 = P_depth;
                        t1 = t2;
                        
                        set(handles.fallspeed_text,'String',num2str(round(fallspeed)));
                       
                    end
                    set(handles.text6, 'String', num2str(round(P_depth)));
                      handles.tempdata.head.enddepth = P_depth; 
                 
%             end
            LabelPlots(handles, pidx, numselected);
            drawnow;
            nextdraw = nextdraw + plotinterval;
        end
     
       
        outputrow = outputrow+1;
        out_row = outputrow;
    else
        % note, if there is never a pause in the loop, the functtion
        % uses 100% of the cpu on which it runs
        % with the pause, it uses about 20% of one cpu
        pause(0.05);
    end  % end of if inputrow > outputrow
    
    
    if mod(outputrow, 50) == 0
        set(handles.text13, 'String', num2str(outputrow));
        drawnow;
        
    end
    
end % end of while runflag == 1

fclose(s);
times(1:outputrow) = times(1:outputrow)+handles.tempdata.starttime;


function SaveData(handles,tbytes, firstrow, numrows, times)

    fullfilename = [handles.tempdata.outpath,'\','EQ14_',handles.tempdata.fname];
    handles.tempdata.head.filename = fullfilename;
    fid = fopen(sprintf('%s',fullfilename),'w');


%%%%%%%%%%
%%%GPS DATA NOT BEING USED DURING TEST, ONLY DURING DEPLOYMENT
% GPS=serial('COM1','BaudRate',4800);
% fopen(GPS);
% [GPS_in] = ReadGarmin(GPS);
% fclose(GPS);
% delete(GPS);
% clear GPS;
% handles.tempdata.lat.end = strcat(num2str(GPS_in.lat),cell2mat(GPS_in.latdirRMC));
% handles.tempdata.lon.end = strcat(num2str(GPS_in.lon),cell2mat(GPS_in.londirRMC));
% handles.tempdata.head.endtime = strcat(num2str(GPS_in.date),num2str(GPS_in.timeRMC),'^^^^^^^^^^^^^^^^');
% 
% % handles.tempdata.head.saildata(1:35) = F;
% set(handles.textbox_lat,'String','Stop Lat');
% set(handles.text_lon,'String','Stop Lon');
% set(handles.text_date,'String','Stop Date');
% set(handles.textbox_latitude,'String',handles.tempdata.lat.end(1:5));
% set(handles.text_longitude,'String',handles.tempdata.lon.end(1:5));
% set(handles.text_datetime,'String',handles.tempdata.head.endtime(1:20));
% sail2 = GPS_in.F(8:end);
% handles.tempdata.head.saildata(37:(36+numel(sail2))) = sail2;
%%%%%%%%%%


WriteCham2Header(fid,handles.tempdata.head);
set(handles.text_filename,'String',handles.tempdata.fname);
% global times;
    tbend = int32(handles.tempdata.template.virtualchannels) * int32(numrows-1);
    
%     fid =  fopen(sprintf('%s',fullfilename),'w+');
   tbytes = tbytes(firstrow:numrows-1,1:32);
    
    % this transpose will use some time and memory to make a copy of
    % the tbytes array. 
%     tstart = now;
%     handles.tempdata.outpath = 'C:\Users\mixing\Documents\chameleon2_test\chamviewpavan\data';
   

    xtbytes = tbytes';  % transpose so we can use linear addressing to extract data
    xtbytes = xtbytes+32768;
    tbsave = xtbytes(:,10:numrows-firstrow);
    %32768 is added because we had subtracted it earlier temp = temp -
    %32768. Since uint16 is in range of [0 65535] the negative counts would
    %be padded to zero, refer to email sent by pavan to Jim on 12/12/13.
       fwrite(fid,tbsave,'uint16');
%     fwrite(fid,tbytes,'uint16');
    fclose(fid);
%     tbytes = tbytes';
     
%     for ii=1:16
%         sname = char(handles.tempdata.template.chnames(ii,:));
%         sname = SubChar(sname, ' ', '_');
%         indices = handles.tempdata.chidx{ii};
%         if ~isempty(indices) % don't save channels with no data
%             isize = size(indices,2);
%             offset = int32(indices(1));
%             skip = int32(handles.tempdata.template.virtualchannels/isize);
%             data.(sname) = tbytes(offset:skip:tbend);
%         end;
%     end
%     data.times = times(1:numrows-1)';
%     save(fullfilename,'data');
%     guidata(hObject,handles);
  
function s = OpenMyComm(commport, baudrate)
s = serial(commport,'BaudRate',baudrate);
s.BytesAvailableFcnMode = 'byte';
s.InputBufferSize = 4096;
s.BytesAvailableFcnCount = 64;  % 64 bytes is 32 16-bit words
s.BytesAvailableFcn = @Commcallback;
fopen(s);



    
function Commcallback(obj,event)
% function called when buffer has 64 bytes available
global tbytes;
global times;
global ctick;
global syncflag;
global inputrow;
global plotbytes;

persistent temp;
temp = zeros(32,1);

if syncflag   
    % read 64 bytes as 32 16-bit unsigned integers
    temp = fread(obj,32, 'uint16');
    % correct for the offset binary nature of data and
    % convert to integers in range -32768 to +32767
    temp = temp -32768;
    % store the result in the tbytes global array
    tbytes(inputrow,1:32) = temp(1:32);
    % get the elapsed time since start of ctick timer
    % and store in the times global variable
    times(inputrow,1) = toc(ctick) ;  
    % increment the inputrow global variable.  The main
    % routine watches this variable to see when new data
    % has arrived.
    inputrow = inputrow+1;

end
% if there was no sync, don't read the data.

% if syncflag
%     temp = fread(obj,32, 'uint16');
%     temp = temp -32768;
% %     if (temp == 0)
% %         display(temp)
% %     end
% %     display(1);
%     tbytes(inputrow,1:32) = temp(1:32);
%     times(inputrow,1) = toc(ctick);
%     plotbytes = temp;
%  inputrow = inputrow+1;
% end
%  
    


function WaitForSync(serial)
%  this function is called from CollectAndProcess
%  It reads the serial port until it finds sync bytes
%  then reads enough serial data so that the next word
%  to be received will be the first word of the next packet
global syncflag
global pldt
syncflag = 0;
tdat = zeros(1,128);
sync = 0;
syncidx = 0;
[tdat count] = fread(serial,128,'uint16');
if count == 0
  h = errordlg('No Data Arriving! Make sure the Power Supply is turned on','Comm Port Error');   
  return;
end
for ii = 1:64
    if ((tdat(ii)< 50000) && (tdat(ii+32)== 65535)) 
        sync = 1;
        syncidx = ii;
    end
end

if sync == 0  % started on odd byte, so read one to get on even 
    tdat = fread(serial,1);
    % now search for sync once again
    tdat = fread(serial,128,'uint16');
    for ii = 1:64
        if ((tdat(ii)< 50000) && (tdat(ii+32)== 65535)) 
            sync = 1;
            syncidx = ii;
        end
    end   

end

% now read enough bytes to get synced at start of read
% so last integer of each packet is sync
if syncidx > 0
 tdat = fread(serial,syncidx, 'uint16');   
end

% now read 64 unsigned integers 
tdat = fread(serial,64, 'uint16');
%disp(tdat(1));
%disp(tdat(33));
if sync == 1
    syncflag = 1;
else
     h = errordlg('Sync Sequence not found','Synchronization Error')  ;
end
% pldt = tdat;

function CloseCommPort(commport)
% Check to see if commport is already open.
% If so, close it and clear the data structure;
out1=[];
out1 = instrfind('Port',commport);
if ~isempty(out1 )
    fclose(out1);
    clear('out1');
end

function newnames = SubChar(names, inchar, newchar);
for ii = 1:length(names)
    if names(ii)==inchar
        names(ii)=newchar;
    end
end

newnames = names;

function WaterfallPlot(wfstruct,pdata,time)
% global pidx;
    persistent nextrow;
%     nextrow = 1;
    persistent wdata;
    persistent wtime;
    persistent cval;
    persistent pxlim;
    persistent emode;
    persistent ylcount;
global gain;
global offset;

    if time < 0  %  reset the persistent variables
        wdata = [];  % make the array empty, so next call initializes
        wtime = [];
        emode = 0;
        ylcount = 0;       
        nextrow = 1;
        return
    end
    if isempty(pxlim) 
        pxlim = wfstruct.wfxlim;
    end
%     pdata(1,:) = [];
    
    
    
    datarows = wfstruct.wfnumrows;
    maxchannels = wfstruct.wfchannels; 
  %pressure channel coefficients


%     wftimespan = 10;
%     wfplotrate = 5;
    if isempty(wdata)
        wdata = zeros(datarows,maxchannels);
    end
    if isempty(wtime)
        wtime = zeros(datarows,1);    
    end;
    % calculate number of rows of data to plot
    winheight = wfstruct.wftimespan * wfstruct.wfplotrate; 
    %winheight can be non-integer for odd values of timespan
    winheight = floor(winheight);
     
    set(gca,'XTickMode','auto');  % let Matlab decide on tick marks

    if nextrow > winheight
    % move time down one
        wtime(1:winheight-1,1)= wtime(2:winheight,1);
        % move the data array down 1 and add new data at end
        wdata(1:winheight-1,1:maxchannels) = wdata(2:winheight,1:maxchannels);    
        nextrow = nextrow-1;
    end
    wtime(nextrow) = time;
%     wtime(nextrow+1) = time;
    wdata(nextrow,1:maxchannels) = pdata(1,1:maxchannels);
%     wdata(nextrow+1,1:maxchannels) = pdata(2,1:maxchannels);
    if nextrow < winheight;
          ystart = wtime(1);
          yend =  wtime(1)+wfstruct.wftimespan;
    else
          ystart = wtime(1);
          yend = wtime(winheight);
    end
%     wfchantoplot = pidx;
    axes(wfstruct.wfaxes);% set the axes for our plot as current axes
    cla;  %clears axes before startup
    %  call the xlim function only when the limits are changed from
     %  the gui.  xlim can suck a lot of CPU time.
%      if wfstruct.wfxlim ~= pxlim
%         pxlim = wfstruct.wfxlim;
%         xlim(pxlim);   % set x and y plot limits 
%     end
xlim(pxlim);
%     xlim([wfstruct.wfxlim]);    %  x and y plot limits 
%     mymap = hsv(maxchannels);
% If called for every plot line, ylim() can take 25% of the plot
    % time.   However, if it is called too seldom, the vertical scroll
    % will seem jerky.
    ylimfrequency = 1;  % for max smoothness, but sloweest
    ylcount = ylcount+1;
    if ylcount >= ylimfrequency
     ylim([ystart yend]); 
     ylcount = 1;
    end
%     ylim([ystart yend]);
%     jj = 30


    for jj = 1:maxchannels 
%        mymap = colormap;  % get the current color map
%         cval = mymap(jj,:);  % specify the color
            cval = wfstruct.wfcolors(jj,:);  % specify the color
%         plot each line with appropriate color
        if wfstruct.wfchantoplot(1,jj) 
%         if wfchantoplot(1,jj) 
%             line((wdata(1:nextrow,jj).*wfstruct.wfgain(jj))+wfstruct.wfoffset(jj), ...
              line((wdata(1:nextrow,jj).*gain(jj))+offset(jj), ...
             wtime(1:nextrow,1), 'Color',cval, 'LineWidth',1.5); 
        end;
              
    end
     if(emode == 0)
        ls=findall(wfstruct.wfaxes,'Type', 'line');
        set(ls, 'EraseMode', 'none');
        ls2 = handle(ls(2));
        emode = 1;
    end
    if nextrow <  winheight+1
        nextrow = nextrow+1;
 
    end

function [pdat] = ProcessInput(handles,tdata,pidx)
% add the proper values from rowdata to structure plotdata
% this version extracts only the first value in the row for each
% specified channel.  The channels specified are in pidx.
% pidx can contain from 0 to 15 elements, but we will plot
% up to three of the lowest channels

% 'indices' has the indices of the words in the packet that belong
% to a particular channel.

% Note that if pdata is not persistent, there is a new allocation
% of memory each time the function is called (about 50 times per second).
persistent pdata;
numselected = size(pidx,2);
% numselected = min(numselected,1);
% note that scale factor has to be larger than 5/32768 to account
% for the 5K ohm series resistor on input to the ADC
scalefactor = (5.025/32768.0);
pdata = zeros(1,16);  %  just in case no channels are selected


 for ii = 1:16   
% for ii = 1:numselected
    indices = handles.tempdata.chidx{pidx(ii)};
    if isempty(indices)
        newvalue = 0;
    else
        index = indices(1);   % select only the first data for this channel
        newvalue = tdata(1,index);        
    end

    pdata(1,ii) = newvalue*scalefactor;    


end

pdat = pdata;
% for g = 1:numselected
% if numselected > 0
%     indices = handles.tempdata.chidx{pidx(g)};
%     index = indices(1);
%     newvalue = tdata(index);
%     pdata(pidx(g),pidx) = newvalue*scalefactor;
% 
% end
% end
% pdat = pdata;



function LabelPlots( handles, pidx, numselected)
if numselected > 0
    idx = pidx(1);
    sname = char(handles.tempdata.template.chnames(idx,:));
    ylabel(handles.axes1,sname);
end
if numselected > 1
    idx = pidx(2);
    sname = char(handles.tempdata.template.chnames(idx,:));
    ylabel(handles.axes1,sname);
end
if numselected > 2
    idx = pidx(3);
    sname = char(handles.tempdata.template.chnames(idx,:));
    ylabel(handles.axes1,sname);
end


% --- Executes on button press in pushbutton_selectall.
function pushbutton_selectall_Callback(hObject, eventdata, handles)
    %selects all the channels on the panel of the GUI when button is
    %pressed thus enabling the display of all the channel points on the
    %plot/graph
% hObject    handle to pushbutton_selectall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.pushbutton_selectall,'Enable','Off');
set(handles.pushbutton_selectnone,'Enable','On');

%Each cell has a vector which
% contains the indices of the packet element that belong to that channel.
% disable any checkboxes for channels with no data collected
for mm = 1:16
%     chvect = find(xchnums==mm);
%     chidx{mm} = chvect;
    if isempty(handles.tempdata.chidx{mm})
        set(handles.tempdata.plotboxes(mm),'Value',0);
        set(handles.tempdata.plotboxes(mm),'Enable','off');
    else
        set(handles.tempdata.plotboxes(mm),'Value',1);
        set(handles.tempdata.plotboxes(mm),'Enable','on');
    end
 

end
guidata(hObject,handles);
% set(handles.tempdata.plotboxes,'Value',1);

% set(handles.tempdata.plotboxes(1),'Value',0);
% set(handles.tempdata.plotboxes(15),'Value',0);

% --- Executes on button press in pushbutton_selectnone.
function pushbutton_selectnone_Callback(hObject, eventdata, handles)
    %deselects all the channels on the GUI. No channels' data is displayed
    
% hObject    handle to pushbutton_selectnone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.pushbutton_selectall,'Enable','On');
set(handles.pushbutton_selectnone,'Enable','Off');


set(handles.tempdata.plotboxes,'Value',0);
% set(wf1.wfchantoplot,'Value',0);
guidata(hObject,handles);

% --- Executes on button press in logbutton.
function logbutton_Callback(hObject, eventdata, handles)
    %This button starts logging the data from the moment it is pressed. 
% hObject    handle to logbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.stopbutton,'enable','on');
set(handles.logbutton,'enable','off');
set(handles.pushbutton_pause,'enable','off');
set(handles.logbutton,'String',handles.tempdata.fname);
set(handles.logbutton,'BackgroundColor','green'); %Start Button color set to green
set(handles.stopbutton,'BackgroundColor',[0.8 0.8 0.8]); %Start Button color set to red
set(handles.recordeddepth_textbox,'ForegroundColor','black');
global inputrow;
[out1,out2] = ChamFile(handles);
handles.tempdata.fname = [out1,'.',out2];
set(handles.logbutton,'string',handles.tempdata.fname);
handles.tempdata.startpath = inputrow;
handles.tempdata.starttime1 = now;
guidata(hObject,handles);

% --- Executes on button press in pushbutton_pause.
function pushbutton_pause_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global runflag;
runflag = 0;
set(handles.startbutton,'enable','on');
set(handles.logbutton,'enable','off');
set(handles.recordeddepth_textbox,'ForegroundColor','black');
% set(handles.stopbutton,'enable','off');
WaterfallPlot(handles, [],-1)
guidata(hObject,handles);


% --- Executes on selection change in popupmenu_channel.
function popupmenu_channel_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_channel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_channel


% --- Executes during object creation, after setting all properties.
function popupmenu_channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_gain_Callback(hObject, eventdata, handles)
% hObject    handle to edit_gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_gain as text
%        str2double(get(hObject,'String')) returns contents of edit_gain as a double


% --- Executes during object creation, after setting all properties.
function edit_gain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_offset_Callback(hObject, eventdata, handles)
% hObject    handle to edit_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_offset as text
%        str2double(get(hObject,'String')) returns contents of edit_offset as a double


% --- Executes during object creation, after setting all properties.
function edit_offset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_set.
function pushbutton_set_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global gain;
global offset;
gn = get(handles.popupmenu_channel,'value');
gain(gn) = str2num(get(handles.edit_gain,'string'));
offset(gn) = str2num(get(handles.edit_offset,'string'));



% --- Executes on button press in pushbutton_reset.
function pushbutton_reset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global gain;
global offset;

set(handles.edit_gain,'string',num2str(1));
set(handles.edit_offset,'string',num2str(0));
gain = ones(1,16);
offset = zeros(1,16);
