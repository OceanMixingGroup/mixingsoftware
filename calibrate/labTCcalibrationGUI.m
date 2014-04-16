function labTCcalibrationGUI
% GUI for labTCcalibration
% Calls function labTCcalibration.m
% this is based on legacy interface, which currently is only supported in
% 32-bit Matlab
% $Revision: 1.2 $ $Date: 2013/01/15 18:38:06 $ $Author: aperlin $	
% A. Perlin, September 2010

%  Create and then hide the GUI as it is being constructed.
close all
extradata.numcal='1';
extradata.caldir='';
extradata.Trange=[0 0];
extradata.circuits={};
extradata.sensors={};
extradata.type={};
temp=get(0,'ScreenSize');

fh = figure('Visible','on','Position',[1,temp(4)-0.6*temp(4),...
    0.4*temp(3),0.6*temp(4)]);
set(fh,'Menubar','none','color',[1 1 1])
set(fh,'UserData',extradata)

bgh1 = uibuttongroup('Parent',fh,'Title','Number of Calibrations',...
    'Position',[.1 .7 .25 .2]);
rbh1 = uicontrol(bgh1,'Style','radiobutton','String','1',...
    'Units','normalized','Position',[.1 .6 .3 .22],'Fontsize',10,...
    'BackgroundColor',[1 1 1]);
rbh2 = uicontrol(bgh1,'Style','radiobutton','String','2',...
    'Units','normalized','Position',[.1 .2 .3 .22],'Fontsize',10,...
    'BackgroundColor',[1 1 1]);
set(bgh1,'SelectionChangeFcn',@numcal);
set(bgh1','children',[rbh1;rbh2])
% set(bgh1,'SelectedObject',[1]);
set(bgh1,'Visible','on','Fontsize',10,'BorderWidth',0,...
    'BackgroundColor',[1 1 1]);

bgh2 = uibuttongroup('Parent',fh,'Title','Calibration Direction',...
    'Position',[.4 .7 .25 .2]);
rbhU = uicontrol(bgh2,'Style','radiobutton','String','Heating',...
    'Units','normalized','Position',[.1 .6 .5 .22],'Fontsize',10,...
    'BackgroundColor',[1 1 1]);
rbhD = uicontrol(bgh2,'Style','radiobutton','String','Cooling',...
    'Units','normalized','Position',[.1 .2 .5 .22],'Fontsize',10,...
    'BackgroundColor',[1 1 1]);
set(bgh2,'SelectionChangeFcn',@caldir);
set(bgh2,'children',[rbhU;rbhD])
set(bgh2,'SelectedObject',[]);
set(bgh2,'Visible','on','Fontsize',10,'BorderWidth',0,...
    'BackgroundColor',[1 1 1]);

ph = uipanel('Parent',fh,'Title','Temperature Range',...
    'Position',[.7 .7 .25 .2],'Fontsize',10,'BackgroundColor',[1 1 1],...
    'BorderWidth',0,'BackgroundColor',[1 1 1]);
eth1 = uicontrol(ph,'Style','edit','String','',...
    'Units','normalized','Position',[.1 .6 .4 .3],'Fontsize',10,...
    'BackgroundColor',[1 1 1],'callback',@tempstart);
eth2 = uicontrol(ph,'Style','edit','String','',...
    'Units','normalized','Position',[.1 .2 .4 .3],'Fontsize',10,...
    'BackgroundColor',[1 1 1],'callback',@tempstop);

dat =  {' ', ' ', 'T';
    ' ', ' ', 'T';
    ' ', ' ', 'T';
    ' ', ' ', 'T';
    ' ', ' ', 'T';
    ' ', ' ', 'T';
    ' ', ' ', 'T';
    ' ', ' ', 'T'};
columnname =   {'Circuit', 'Sensor','Type'};
columnformat = {'char', 'char', {'T', 'C'}};
columneditable =  [true true true]; 
t = uitable('Units','normalized','Position',...
            [0.27 0.27 0.447 0.38], 'Data', dat, ... 
            'ColumnName', columnname,'Fontsize',10,...
            'ColumnFormat', columnformat,'ColumnWidth',{65},...
            'ColumnEditable', columneditable,...
            'CellEditCallback',@tableedit);

hstart = uicontrol('Style','pushbutton','String','Start',...
    'Units','normalized','Position',[.3,.1,.4,.1],...
    'Fontsize',14,'Fontweight','Bold',...
    'callback',{@labTCcalibration});
        
align([bgh1,bgh2,ph,hstart,t],'Center','None');
align(hstart,'HorizontalAlignment','Center')
% Assign the GUI a name to appear in the window title.
set(fh,'Name','T & C Calibration')
% % Move the GUI to the center of the screen.
% movegui(fh,'center')
% Make the GUI visible.
set(fh,'Visible','on');

    function numcal(source,eventdata)
        hfig=get(source,'Parent');
        extradata=get(hfig,'UserData');
        aa=get(source,'Children');
        if get(source,'SelectedObject')==aa(1)
            extradata.numcal='1';
        elseif get(source,'SelectedObject')==aa(2)
            extradata.numcal='2';
        end
        set(hfig,'UserData',extradata);
    end
    function caldir(source,eventdata)
        hfig=get(source,'Parent');
        extradata=get(hfig,'UserData');
        aa=get(source,'Children');
        if get(source,'SelectedObject')==aa(1)
            extradata.caldir='UP';
        elseif get(source,'SelectedObject')==aa(2)
            extradata.caldir='DN';
        end
        set(hfig,'UserData',extradata);
    end
    function tempstart(source,eventdata)
        hb=get(source,'Parent');
        hfig=get(hb,'Parent');
        extradata=get(hfig,'UserData');
        extradata.Trange(1)=str2num(get(source,'String'));
        set(hfig,'UserData',extradata);
    end
    function tempstop(source,eventdata)
        hb=get(source,'Parent');
        hfig=get(hb,'Parent');
        extradata=get(hfig,'UserData');
        extradata.Trange(2)=str2num(get(source,'String'));
        set(hfig,'UserData',extradata);
    end
    function tableedit(source,eventdata)
        hfig=get(source,'Parent');
        extradata=get(hfig,'UserData');
        data=get(source,'Data');
        extradata.circuits=data(:,1);
        extradata.sensors=data(:,2);
        extradata.type=data(:,3);
        set(hfig,'UserData',extradata);
    end
end
