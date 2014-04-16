function make_Tnode_calibration_file(sbfile,unit,timecorr)
% makes calibration file for Chipod temperature from Seabird & Chipod data
% unit is chipod unit number(integer)
% sbfile is seabird data file
% Tnode data should be in the same directory as sbfile under \num2str(unit)\
% timecorr is time correction that should be applied to chipod data
% (in case that chipod clock was off)
% time is corrected as chi.time=chi.time+timecorr;
% timecorr is an optional parameter

if ~exist('timecorr','var')
    timecorr=0;
end
%% input parameters
% load and Seabird data
load(sbfile);
ii=find(sbfile=='\' | sbfile=='/');
if ~isempty(ii)
    filedir=sbfile(1:ii(end));
else
    filedir=[];
end
% load chipod data
Tdir=[filedir num2str(unit) '\'];
d2=dir(Tdir);
for i=3:length(d2)
    [data head]=raw_load_Tnode([Tdir d2(i).name]);
    if i==3
        node.T1=data.T1;
        node.T2=data.T2;
        node.T3=data.T3;
        node.T4=data.T4;
        node.time=data.datenum;
    else
        node.T1=[node.T1;data.T1];
        node.T2=[node.T2;data.T2];
        node.T3=[node.T3;data.T3];
        node.T4=[node.T4;data.T4];
        node.time=[node.time;data.datenum];
    end
end
% Chipod time correction
node.time=node.time+timecorr;
%% save the summary file
save([filedir 'Tnode_' num2str(unit)],'sbe','node')


