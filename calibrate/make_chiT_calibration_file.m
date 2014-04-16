function make_chiT_calibration_file_new(sbfile,unit,timecorr)
% makes calibration file for Chipod temperature from Seabird & Chipod data
% unit is chipod unit number(integer)
% sbfile is seabird data file
% chipod data should be in the same directory under \num2str(unit)\
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
ii=find(sbfile=='\' | sbfile=='/');if~isempty(ii);ii=ii(end);end
% load chipod data
if~isempty(ii)
    chidir=[sbfile(1:ii) '\' num2str(unit) '\'];
else
    chidir=[num2str(unit) '\'];
end    
d2=dir(chidir);
for i=3:length(d2)
    [data head]=raw_load_chipod([chidir d2(i).name]);
    if i==3
        chi.T1=data.T1;
        chi.T2=data.T2;
        chi.time=data.datenum;
    else
        chi.T1=[chi.T1;data.T1];
        chi.T2=[chi.T2;data.T2];
        chi.time=[chi.time;data.datenum];
    end
end
% Chipod time correction
chi.time=chi.time+timecorr;
%% save the summary file
save([sbfile(1:ii) '\' num2str(unit) '_T'],'sbe','chi')


