function ChipodTcalibrationV2
% GUI for Chipod T calibration using Microcat Seabird37. 
% calls runTcalibrationV2.m 
% $Revision: 1.2 $ $Date: 2011/07/29 23:35:09 $ $Author: aperlin $	
% A. Perlin, December 2010

%  Create and then hide the GUI as it is being constructed.
clear all;close all;fclose all;
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end
extradata.Trange=[0 0];
extradata.npts=10;
temp=get(0,'ScreenSize');

fh = figure('Visible','on','Position',[1,temp(4)-0.9*temp(4),...
    0.95*temp(3),0.9*temp(4)]);
set(fh,'Menubar','none','color',[1 1 1])
set(fh,'UserData',extradata)


ph = uipanel('Parent',fh,'Title','Temperature Range',...
    'Position',[.1 .7 .25 .2],'Fontsize',10,'BackgroundColor',[1 1 1],...
    'BorderWidth',0,'BackgroundColor',[1 1 1]);
eth1 = uicontrol(ph,'Style','edit','String','',...
    'Units','normalized','Position',[.1 .6 .4 .3],'Fontsize',10,...
    'BackgroundColor',[1 1 1],'callback',@tempstart);
eth2 = uicontrol(ph,'Style','edit','String','',...
    'Units','normalized','Position',[.1 .2 .4 .3],'Fontsize',10,...
    'BackgroundColor',[1 1 1],'callback',@tempstop);

pts = uipanel('Parent',fh,'Title','Number of points',...
    'Position',[.4 .7 .25 .2],'Fontsize',10,'BackgroundColor',[1 1 1],...
    'BorderWidth',0,'BackgroundColor',[1 1 1]);
epts = uicontrol(pts,'Style','edit','String','',...
    'Units','normalized','Position',[.1 .6 .4 .3],'Fontsize',10,...
    'BackgroundColor',[1 1 1],'callback',@npoints);

hstart = uicontrol('Style','pushbutton','String','Start',...
    'Units','normalized','Position',[.7,.75,.25,.1],...
    'Fontsize',14,'Fontweight','Bold',...
    'callback',{@runTCalibrationV2});
        
align([ph,pts,hstart],'Center','Middle');
% Assign the GUI a name to appear in the window title.
set(fh,'Name','T Calibration')
% % Move the GUI to the center of the screen.
% movegui(fh,'center')
% Make the GUI visible.
set(fh,'Visible','on');
%% GUI functions
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
    function npoints(source,eventdata)
        hb=get(source,'Parent');
        hfig=get(hb,'Parent');
        extradata=get(hfig,'UserData');
        extradata.npts=str2num(get(source,'String'));
        set(hfig,'UserData',extradata);
    end

end
