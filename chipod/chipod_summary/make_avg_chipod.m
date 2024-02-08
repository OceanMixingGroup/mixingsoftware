% make_chipod524_avg
function make_avg_chipod(chipod,mooring_loc,summary_loc)
%MAKE_AVG_CHIPOD Make summary 1 HR file for chipod
%
%In the mooring_loc folder location save the raw chipod data using folder tree template
%located at \\ganges\work\chipod_gust\foldertree\unit unit is the chipod
%serial #

%summary_loc is the location where the summary files will be saved

%Example function declaration 
%make_avg_chipod(1119,'\\ganges\data\chipod\tao19_140\data\','\\ganges\data\chipod\tao19_140\quick_summary\');

%Pavan Vutukur Ocean Mixing Group OSU 05/21/2020

pathname=[mooring_loc,num2str(chipod),'\raw\']; %path name of raw files
nm=dir([pathname,'*.',num2str(chipod)]); %lists only raw files of chipod
clear avg out data head;
avg.T1=[]; avg.T2=[]; avg.time=[]; avg.W=[];avg.WP=[];avg.P=[];
avg.AX=[];avg.AY=[];avg.AZ=[];avg.T1P=[];avg.T2P=[];avg.CMP=[];
avg.V = []; avg.Va = [];
tic;
for inm = 1:length(nm)
    try
    [data,head]=raw_load_chipod([pathname,nm(inm).name]); %raw_load_chipod
    display([num2str(inm) ' out of ' num2str(length(nm))]); % to display file progress in command window
    out=quick_avg_noadcp(data,head); %function to run 1hr summary
    avg.time=[avg.time out.time]; %concatenation of 1hr averages
    avg.W=[avg.W out.W];
    avg.Va=[avg.Va out.Va]; % WP is analog voltage with offset
    avg.T1=[avg.T1 out.T1];
    avg.T2=[avg.T2 out.T2];
    avg.P=[avg.P out.P];
    avg.AX=[avg.AX out.AX];
    avg.AY=[avg.AY out.AY];
    avg.AZ=[avg.AZ out.AZ];
    avg.T1P=[avg.T1P out.T1P];
    avg.T2P=[avg.T2P out.T2P];        
    avg.CMP=[avg.CMP out.CMP];
    avg.V = [avg.V out.V]; %digital voltage recorded in chipod
%     save([summary_loc,num2str(chipod),'_quick_summary.mat'],'avg');
     
    catch
        fprintf('\nSkipping processing due to error in File %s \n',nm(inm).name);
    end
    toc;
end
    
    avg.chipod = chipod;
    avg.mooring = mooring_loc;
    avg.sensor_id.T1 = head.sensor_id(1,:);
    avg.sensor_id.T2 = head.sensor_id(9,:);
   %save summary file
    save([summary_loc,num2str(chipod),'_quick_summary.mat'],'avg');


%plot_quick_avg(524)