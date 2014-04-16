% make_chiT_calibration_file
% makes summary calibration file for Chipod temperature 
% sensor calibration
%% input parameters
clear all
% Chipod unit number
unit=318;
% directory where seabird data are saved
sbdir='\\mserver\Data\chipod\tao_may08\calibration\Temp_03_24_08\';
% directory where Chipod raw calibration files are saved
chidir=[sbdir '\' num2str(unit) '\'];
% Seabird file names. There could be one or two seabird files
fname(1)={'3_21_08_6UP.log'};
% fname(2)={'7_19chiBottom.log'};
%% load raw data and make two data structures
% load seabird data
if length(fname)==1
    sb=read_seabird_for_chiTcalibration([sbdir char(fname(1))]);
elseif length(fname)==2
    sb=read_seabird_for_chiTcalibration([sbdir char(fname(1))],[sbdir char(fname(2))]);
end
% load chipod data
d=dir(chidir);
for i=3:length(d)
    [data head]=raw_load_chipod([chidir d(i).name]);
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
% seabird time correction
% dt=datenum(0,0,0,16,01,30);
dt=0;
sb.time1=sb.time1-dt;
%% save the summary file
save([sbdir num2str(unit) '_T'],'sb','chi')


