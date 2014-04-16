function fignum=drop_point(fnamein,fnameout)
% function drop-point

close  
fignum=droppoint

if nargin==0
    [fnamein,pathin]=uigetfile('*.dat','Input DATA file to load data FROM');
    [fnameout,pathout]=uiputfile('*.cal','Input CAL file to save data TO');
else
  pathout=pwd;
  pathin=pwd;
end 

%printdlg('-setup')

% first we load the raw data
xx=load([pathin filesep fnamein])
% next we determine how many channels are in this file
[m,n]=size(xx);
n_channels=n/2-1;  
% And the number of data points are as follows
allpoints=1:m;
validpoints=1:m;

% now parse out the header to get the circuit names and sensor names: 
circuit_names=textread([pathin filesep fnamein],'%s',n_channels+1, ...
                       'commentstyle','shell')
sensor_names=textread([pathin filesep fnamein],'%s',n_channels+1, ...
                      'commentstyle','shell','headerlines',2)
sensor_type=textread([pathin filesep fnamein],'%s',n_channels+1, ...
                     'commentstyle','shell','headerlines',4)

h=guidata(fignum);   
h.goto_next_circuit=0;
h.add_point=0;
h.regress_now=0;
h.drop_a_point=0;
h.regress_data=[];
h.regress_line=[];
guidata(fignum,h);
axes(h.data_axes)
isgood(1:(n_channels+1))=0;
for number=2:n_channels+1
  
  % first check to see if it is a valid set of points
if ~isnan(nanmean(xx(:,number)))
    %pause
if strcmp(sensor_type{number},'T')
    ydata=xx(:,1);
    ydat=('Temperature [C]')
    
else
    ydata=xx(:,n_channels+2);
    ydat=('Conductivity [S/m]')
end 
xdata=xx(:,number);
axes(h.data_axes)
allpoints=1:m;
validpoints=1:m;
dataplot=plot(xdata,ydata,'ro');

h=guidata(fignum);
h.regress_data=[];
    h.regress_line=[];
    h.ylabel=ydat;
    guidata(fignum,h);

%    baddata=[]
axis tight; xlims=xlim; xlim([min([-5 xlims(1)]) max([xlims 5])]); xlims=xlim;
set(h.circuit_name,'string',[sensor_type{number} '-' circuit_names{number}])
set(h.sensor_name,'string', sensor_names{number})
text(.1,.9,[sensor_type{number} '-' circuit_names{number} ', sensor ' ...
            sensor_names{number}],'units','normalized')

[coefs, rms]=doregression(xdata,ydata,validpoints,fignum,xlims)
rms_error(number)=rms;

h=guidata(fignum);,  h.goto_next_circuit=0;, guidata(fignum,h)
while h.goto_next_circuit==0        
  h=guidata(fignum);
  if h.regress_now==1
    h.regress_now=0;  
    guidata(fignum,h) 
    [coefs, rms]=doregression(xdata,ydata,validpoints,fignum,xlims)
    rms_error(number)=rms;
  end
  if h.add_point==1
    validpoints=add_point(allpoints,validpoints,xdata,ydata)
    h.add_point=0;  
    h.regress_data=[];
    h.regress_line=[];
    guidata(fignum,h) 
    delete(dataplot)
    badpoints=setdiff(allpoints,validpoints);
    dataplot=plot(xdata(validpoints),ydata(validpoints),'ro',xdata(badpoints),ydata(badpoints),'bo')
    xlim(xlims)
    %    xlim([-5 5])
    [coefs, rms]=doregression(xdata,ydata,validpoints,fignum,xlims)
    rms_error(number)=rms;
  end 
  if h.drop_a_point==1
    validpoints=drop_a_point(validpoints,xdata,ydata,fignum)
    h.drop_a_point=0; 
    h.regress_data=[];
    h.regress_line=[];
    guidata(fignum,h)
    delete(dataplot)
    badpoints=setdiff(allpoints,validpoints);
    dataplot=plot(xdata(validpoints),ydata(validpoints),'ro',xdata(badpoints),ydata(badpoints),'bo')
    xlim(xlims)
    %    xlim([-5 5])
    [coefs, rms]=doregression(xdata,ydata,validpoints,fignum,xlims)
    rms_error(number)=rms;
  end 
  pause(.02)
end 

    
    % Now we go on to the next circuit:
    tmp=[0 0 0 0];
    tmp(1:length(coefs))=coefs;
    all_coefs{number}=coefs;

  
%    out=questdlg('Save/Print this channel')
    out = 'yes';
    if strcmp(lower(out),'yes')
      axes(h.data_axes)
      title([pathin filesep fnamein '  '  date '  ' circuit_names{number} ...
             '_' sensor_names{number}]);
       mkdir(pathin,'jpeg');
       [dummy,thename,ext]=fileparts(fnamein);
       print('-djpeg90','-r100',[pathin filesep 'jpeg' filesep ...
                           circuit_names{number} '_' sensor_names{number} ...
		   '_' thename])
      isgood(number)=1;
    end
end 
end 


out=questdlg('Save the data?')
if strcmp(lower(out),'yes')
[pathout filesep fnameout]
  fid=fopen([pathout filesep fnameout],'a');
  for number=2:n_channels+1
    if isgood(number)
      fprintf(fid,'\n')
      fprintf(fid,'%s \t %s \t %s \t %0.6g \t %0.6g \t %0.6g \t %0.6g \t %s \t %s \t RMS= \t %s \t %s \t %s \n', ...
	  circuit_names{number}, sensor_names{number},...
	  sensor_type{number}, all_coefs{number}, ...
	  date, num2str(number-2), rms_error(number), [pathin filesep fnamein])
%      sprintf('%s \t %s \t %s \t %0.6g \t %s \t %s \t %s \t %s ', ...
%	  circuit_names{number}, sensor_names{number},...
%	  sensor_type{number}, all_coefs{number}, ...
%	  date, num2str(number-2), [pathin filesep fnamein])
    end
    end
fclose(fid)
end
close(fignum)   

function validpoints=drop_a_point(validpoints,xdata,ydata,fignum)
  h = guidata(fignum); 
  set(h.rms_axes,'hittest','off');
  
  [x,y]=ginput(1);
  the_error=((x-xdata(validpoints))/diff(xlim)).^2+((y- ydata(validpoints))/ ...
                                                    diff(ylim)/2).^2; 
                                         
  % the diff(ylim) is to normalize the axes, the factor of 2 is for the aspect ratio of the plot. 
  [dummy,ind]=min(the_error);
  validpoints=setdiff(validpoints,validpoints(ind))
  set(h.rms_axes,'hittest','on');
return;  

function validpoints=add_point(allpoints,validpoints,xdata,ydata,fignum)
if length(allpoints)==length(validpoints)
warning('Can''t add a point back in')
return
end
[x,y]=ginput(1)
droppedpoints=setdiff(allpoints,validpoints);
the_error=((x-xdata(droppedpoints))/diff(xlim)).^2+((y- ...
						  ydata(droppedpoints))/diff(ylim)/2).^2; % the diff(ylim) is to normalize the axes, the factor of 2 is for the aspect ratio of the plot. 
[dummy,ind]=min(the_error);
droppedpoints=setdiff(droppedpoints,droppedpoints(ind))
validpoints=setdiff(allpoints,droppedpoints)


function [coefs, rms_error]=doregression(xdata,ydata,validpoints,fignum,xlims)

         h=   guidata(fignum);
	 delete(h.regress_data);
	 axes(h.rms_axes)
	 hold off
	 poly_order=str2num(get(h.poly_order,'string'))
	 % check to make sure the polynomial order is in range.
	 if poly_order<0 | poly_order>3
	   poly_order=3;
	 end
	 tmp=[0:poly_order];
	 the_coefs=ones(size(xdata(validpoints)))*tmp;
	 % the following is the way to regress
	 toregress=(xdata(validpoints)*ones(size(tmp))).^the_coefs;
	 b=regress(ydata(validpoints),toregress);
%	 regressed_ydata=ones(size(xdata(validpoints)))*b* ...
%	     toregress;
	 regressed_ydata=sum(ones(size(xdata(validpoints)))*b'.*toregress,2)
	 errors=ydata(validpoints)-regressed_ydata;
	 rms_error=std(errors);
	 plot(xdata(validpoints),errors,'rx-')
	 xlim(xlims),ylabel(['RMS ' h.ylabel]),xlabel('Voltage')
	 yl=str2num(get(h.ylims,'string'))
	 ylim([-yl yl])
num2str(rms_error,3)
	 the_text=['RMS ERROR = ' num2str(rms_error,3) ...
	     ',     COEFS = [ ' num2str(b',3) ']'];
	 h.regress_data=text(.1,.1,the_text,'units','normalized');
	 
axes(h.data_axes)
hold on
delete(h.regress_line);
h.regress_line=plot(xdata(validpoints),regressed_ydata);
ylabel([h.ylabel])
thecoefs=num2str(b,3);
hold off
guidata(fignum,h);
% the final output is:
coefs=b';

function varargout = droppoint(varargin)
% DROPPOINT Application M-file for droppoint.fig
%    FIG = DROPPOINT launch droppoint GUI.
%    DROPPOINT('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 20-Sep-2002 00:53:42

if (nargin == 0 | nargin==2) % LAUNCH GUI

    
    
fig = openfig('droppoint','reuse');
%	fig = openfig('droppoint')

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

	if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    catch
		disp(lasterr);
    end

end


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.



% --------------------------------------------------------------------
function varargout = poly_order_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.poly_order.
disp('poly_order Callback not implemented yet.')


% --------------------------------------------------------------------
function varargout = pushbutton5_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.pushbutton5.
disp('pushbutton5 Callback not implemented yet.')


% --------------------------------------------------------------------
function varargout = pushbutton6_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.pushbutton6.
disp('pushbutton6 Callback not implemented yet.')


% --------------------------------------------------------------------
function goto_next_circuit = pushbutton8_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.pushbutton8.

goto_next_circuit=1;
%varargout{1}=1;
%disp('pushbutton8 Callback not implemented yet.')
%return
