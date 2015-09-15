% process_currents_oceanus.m
%
% originally make_workhorse_uhdas.m by Sasha Perlin. Rrwritten for the 
% RV Oceanus by Sasha in March 2013 
%
% Updated and commented by sjw, January 2014, from RV Oceanus
%
% The purpose of this code is to load the raw ADCP files collected by the
% workhorse300 (wh300) and Ocean Surveyor 75 (os75) ADCPs on board the RV
% Oceanus. These files are then processed and saved. Another function
% called show_currents_oceanus then plots the data.
%
% This code is meant to be called by make_currents_timer_oceanus
%
% This code makes use of a few functions from UHDAS+CODAS processing
% system such as "dirs," "get_xfraw," "restruct_ap," etc.
% 
% updated by SJW in November 2014 to include the os150




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define paths
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set_currents is where all of the important paths and plotting parameters
% are defined.
set_currents_oceanus

% add some of the paths to the files in uh_programs which is where the
% UHDAS+CODAS mfiles are saved. Do not just add this whole directory
% because it will put functions in the matlab file path that we do not want
% there permanently.
add_uhpaths(adcppathname)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define parameters that do not need to be changed ON OCEANUS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define angle offset in degrees for UHDAS and VmDas. (This sign convention
% is the opposite of Sasha's matlab software sign convention.)
wh300angle_offset=53.4;     % WH300 angle offset in degrees for UHDAS 
os75angle_offset=-43.4;     % OS75 angle offset in degrees for UHDAS
os150angle_offset=46.9;     % OS150 angle offset in degrees for UHDAS

% Define scale factors. Sasha commented: "more typical is 1.003-1.005;
% watertrack indicates more but that makes me nervous,
% so being slightly conservative.  will check previous cruise."
wh300_scalefactor = 1;
os75_scalefactor = 1; 
os150_scalefactor=1; 
   
% Define other parameters such as for the transducer (xducer)
xducer300_dx = 1.128891;% (dx=starboard, dy=fwd)
xducer75_dx = 0.43;
xducer150_dx = 1; 
xducer_dy = -31.007850;
depth_offset=5; %
averagetime=60;%seconds



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check current state of raw and processed files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% make a list of the raw files (using dirs, which is among the uh_programs files)
wh300filelist=dirs([wh300dir  '*.raw'],'fullfile',1);
os75filelist=dirs([os75dir  '*.raw'],'fullfile',1);
if os150exist == 1
    os150filelist=dirs([os150dir  '*.raw'],'fullfile',1);
end

% make a list of the processed files
wh300matlist=dir([wh300matdir  '*.mat']);
os75matlist=dir([os75matdir  '*.mat']);
if os150exist == 1
    os150matlist=dir([os150matdir  '*.mat']);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% process the raw data from the workhorse 300
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ynprocesswh300 == 1

disp(['processing WH300 at ' datestr(now)])

% determine the raw files that have datenums that are later than the last
% processed .mat file

if ~isempty(wh300matlist)

        clear processfiles mm lasttime
        lasttime = wh300matlist(end).datenum;
        mm = 1;
    for kk = 1:length(wh300filelist)
        if wh300filelist(kk).datenum >= lasttime
            processfiles(mm) = kk;
            mm = mm+1;
        end
    end
    if mm == 1
        processfiles = 0;
        disp(['no files to be processed for wh300 at ' datestr(now)])
    end
    
else 
    processfiles = 1:length(wh300filelist);
end

% loop through starting at the first raw file that has yet to be processed
if processfiles ~= 0
for ii=processfiles
    
    % get_xfraw loads in the raw data and rotates everything to earth 
    % coordinates. (/uh_programs/matlab/rawadcp/utils/get_xfraw)
    data=get_xfraw_sjw(wh,wh300filelist(ii).name,'h_align',wh300angle_offset,...
        'beamangle',20,'scalefactor',wh300_scalefactor,'h_corrang',h_corrang);
    
    % loop through both the data using the bottom tracking and not using
    % the bottom tracking.
    for jj=1:2
        if jj==1
            use_bottom=0;
            dname1=wh300matdir;
            dname2=wh300matdir1min;
        else
            use_bottom=1;
            dname1=wh300matdirbt;
            dname2=wh300matdir1minbt;
        end
        
        % restruct_ap: Reshapes the data into one structure with vel, amp, 
        % cor, pg, temperature, etc. Sasha (aka "ap") added a section that 
        % takes into account the misalignment of the transducer and the 
        % GPS antenna using some slick trigonometry. 
        % (/uh_programs/matlab/rawadcp/utils/restruct_ap)
        [data,config]=restruct_ap(wh,data,'dx',xducer300_dx,'dy',xducer_dy,...
            'use_bottom',use_bottom);
        
        % Rename a number of the variables within the structure "data" and
        % save a new structure "adcp" and get the names of all of those
        % fields within the structure adcp.
        adcp=uhdastosci(data);
        fields=fieldnames(adcp);
        
        % correct depth and bottom-depth data if incorrect
        adcp.depth=adcp.depth+depth_offset;
        adcp.bottom(adcp.bottom<=0)=NaN;
        adcp.bottom=adcp.bottom+depth_offset;
        adcp.readme=char('Depth is relative to sea surface');
        
        % save the single-ping workhorse data
        save([dname1 wh300filelist(ii).name(end-19:end-4)],'adcp')
        
        % Use "databin" to calculate 1 minute averages of the data
        dt=mean(diff(adcp.time))*3600*24;
        npoints=round(averagetime/dt);
        warning off
        for iii=1:length(fields)-2
            for kk=1:size(adcp.(char(fields(iii))),1)
                adc.(char(fields(iii)))(kk,:)=databin...
                    ([1:npoints:length(adcp.time)+npoints],...
                    [1:length(adcp.time)],adcp.(char(fields(iii)))(kk,:));
            end
        end
        adc.depth=adcp.depth;
        adc.cfg=adcp.cfg;
        adc.readme=adcp.readme;
        adcp=adc;
        
        % save the 1 minute workhorse data
        save([dname2 wh300filelist(ii).name(end-19:end-4)],'adcp')
    end
    
    % clear important variables before moving on to the Ocean Surveyor
    clear data config adcp adc
end
end

else
    disp('no data from WH300')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% process the raw data from the Ocean Surveyor 75
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ynprocessos75 == 1
    
disp(['processing OS75 at ' datestr(now)])

% determine the raw files that have datenums that are later than the last
% processed .mat file

if ~isempty(os75matlist)

        clear processfiles mm lasttime
        lasttime = os75matlist(end).datenum;
        mm = 1;
    for kk = 1:length(os75filelist)
        if os75filelist(kk).datenum >= lasttime
            processfiles(mm) = kk;
            mm = mm+1;
        end
    end
    if mm == 1
        processfiles = 0;
        disp(['no files to be processed for os75 at ' datestr(now)])
    end
    
else 
    processfiles = 1:length(os75filelist);
end

% loop through starting at the first raw file that has yet to be processed
if processfiles ~= 0
for ii=processfiles
    
% %     %%%% Narrowband processing %%%%

% %     (sjw note) The Narrowband processing was all commented out when I
% %     received this code. I assume it was commented out long before the 
% %     code was finished because Sasha
% %     calls "restruct" rather than his rewritten "restruct_ap." It needs
% %     to be thoroughly checked before it is uncommented and used for
% %     processing.

% % %     data=get_xfraw(os,os75filelist(ii).name,'h_align',os75angle_offset,'scalefactor',os75_scalefactor);
% % %     [data,config]=restruct(os,data);
%         data=get_xfraw_sjw(os,os75filelist(ii).name,'h_align',os75angle_offset,...
%              'scalefactor',os75_scalefactor,'h_corrang',h_corrang);
%     adcp=uhdastosci(data);
%     fields=fieldnames(adcp);
%     adcp.depth=adcp.depth+depth_offset;
%     adcp.bottom(adcp.bottom<=0)=NaN;
%     adcp.bottom=adcp.bottom+depth_offset;
%     adcp.readme=strvcat('Depth is relative to sea surface');
%     save([os75matdir os75filelist(ii).name(end-19:end-4) 'nb'],'adcp')
%     dt=mean(diff(adcp.time))*3600*24;
%     npoints=round(averagetime/dt);
%     warning off
%     for iii=1:length(fields)-2
%         for kk=1:size(adcp.(char(fields(iii))),1)
%             adc.(char(fields(iii)))(kk,:)=databin...
%                 ([1:npoints:length(adcp.time)+npoints],...
%                 [1:length(adcp.time)],adcp.(char(fields(iii)))(kk,:));
%         end
%     end
%     adc.depth=adcp.depth;
%     adc.cfg=adcp.cfg;
%     adc.readme=adcp.readme;
%     adcp=adc;
%     save([os75matdir1min os75filelist(ii).name(end-19:end-4) 'nb'],'adcp')
%     clear data config adcp adc
    
    

%     %%%% Broadband processing %%%%

    % get_xfraw loads in the raw data and rotates everything to earth 
    % coordinates. (/uh_programs/matlab/rawadcp/utils/get_xfraw)
%     data=get_xfraw(os,os75filelist(ii).name,'h_align',os75angle_offset,...
%         'second_set',0,'scalefactor',os75_scalefactor);
    data=get_xfraw_sjw(os,os75filelist(ii).name,'h_align',os75angle_offset,...
        'second_set',0,'scalefactor',os75_scalefactor,'h_corrang',h_corrang);
    
    % loop through both the data using the bottom tracking and not using
    % the bottom tracking.
    for jj=1:2
        if jj==1
            use_bottom=0;
            dname1=os75matdir;
            dname2=os75matdir1min;
        else
            use_bottom=1;
            dname1=os75matdirbt;
            dname2=os75matdir1minbt;
        end
        
        % restruct_ap: Reshapes the data into one structure with vel, amp, 
        % cor, pg, temperature, etc. Sasha (aka "ap") added a section that 
        % takes into account the misalignment of the transducer and the 
        % GPS antenna using some slick trigonometry. 
        % (/uh_programs/matlab/rawadcp/utils/restruct_ap)
        [data,config]=restruct_ap(os,data,'dx',xducer75_dx,'dy',xducer_dy,'use_bottom',use_bottom);
        
        % Rename a number of the variables within the structure "data" and
        % save a new structure "adcp" and get the names of all of those
        % fields within the structure adcp.
        adcp=uhdastosci(data);
        fields=fieldnames(adcp);
        
        % correct depth and bottom-depth data if incorrect
        adcp.depth=adcp.depth+depth_offset;
        adcp.bottom(adcp.bottom<=0)=NaN;
        adcp.bottom=adcp.bottom+depth_offset;
        adcp.readme=char('Depth is relative to sea surface');
        
         % save the single-ping ocean surveyor broadband data
        save([dname1 os75filelist(ii).name(end-19:end-4) 'bb'],'adcp')
        
        % Use "databin" to calculate 1 minute averages of the data
        dt=mean(diff(adcp.time))*3600*24;
        npoints=round(averagetime/dt);
        warning off
        for iii=1:length(fields)-2
            for kk=1:size(adcp.(char(fields(iii))),1)
                adc.(char(fields(iii)))(kk,:)=databin...
                    ([1:npoints:length(adcp.time)+npoints],...
                    [1:length(adcp.time)],adcp.(char(fields(iii)))(kk,:));
            end
        end
        adc.depth=adcp.depth;
        adc.cfg=adcp.cfg;
        adc.readme=adcp.readme;
        adcp=adc;
        
        % save the 1 minute ocean surveyor broadband data
        save([dname2 os75filelist(ii).name(end-19:end-4) 'bb'],'adcp')
    end
    
    % clear important variables before moving on to the Ocean Surveyor
    clear data config adcp adc
end
end

else
    disp('no data from OS75')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% process the raw data from the Ocean Surveyor 150
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ynprocessos150 == 1

if os150exist == 1
disp(['processing OS150 at ' datestr(now)])

% determine the raw files that have datenums that are later than the last
% processed .mat file

if ~isempty(os150matlist)

        clear processfiles mm lasttime
        lasttime = os150matlist(end).datenum;
        mm = 1;
    for kk = 1:length(os150filelist)
        if os150filelist(kk).datenum >= lasttime
            processfiles(mm) = kk;
            mm = mm+1;
        end
    end
    if mm == 1
        processfiles = 0;
        disp(['no files to be processed for os150 at ' datestr(now)])
    end
    
else 
    processfiles = 1:length(os150filelist);
end

% loop through starting at the first raw file that has yet to be processed
if processfiles ~= 0
for ii=processfiles
    

%     %%%% Broadband processing %%%%

    % get_xfraw loads in the raw data and rotates everything to earth 
    % coordinates. (/uh_programs/matlab/rawadcp/utils/get_xfraw)
%     data=get_xfraw(os,os150filelist(ii).name,'h_align',os150angle_offset,...
%         'second_set',0,'scalefactor',os150_scalefactor);
    data=get_xfraw_sjw(os,os150filelist(ii).name,'h_align',os150angle_offset,...
        'second_set',0,'scalefactor',os150_scalefactor,'h_corrang',h_corrang);
    
    
    % loop through both the data using the bottom tracking and not using
    % the bottom tracking.
    for jj=1:2
        if jj==1
            use_bottom=0;
            dname1=os150matdir;
            dname2=os150matdir1min;
        else
            use_bottom=1;
            dname1=os150matdirbt;
            dname2=os150matdir1minbt;
        end
        
        % restruct_ap: Reshapes the data into one structure with vel, amp, 
        % cor, pg, temperature, etc. Sasha (aka "ap") added a section that 
        % takes into account the misalignment of the transducer and the 
        % GPS antenna using some slick trigonometry. 
        % (/uh_programs/matlab/rawadcp/utils/restruct_ap)
        [data,config]=restruct_ap(os,data,'dx',xducer75_dx,'dy',xducer_dy,'use_bottom',use_bottom);
        
        % Rename a number of the variables within the structure "data" and
        % save a new structure "adcp" and get the names of all of those
        % fields within the structure adcp.
        adcp=uhdastosci(data);
        fields=fieldnames(adcp);
        
        % correct depth and bottom-depth data if incorrect
        adcp.depth=adcp.depth+depth_offset;
        adcp.bottom(adcp.bottom<=0)=NaN;
        adcp.bottom=adcp.bottom+depth_offset;
        adcp.readme=char('Depth is relative to sea surface');
        
         % save the single-ping ocean surveyor broadband data
        save([dname1 os150filelist(ii).name(end-19:end-4) 'bb'],'adcp')
        
        % Use "databin" to calculate 1 minute averages of the data
        dt=mean(diff(adcp.time))*3600*24;
        npoints=round(averagetime/dt);
        warning off
        for iii=1:length(fields)-2
            for kk=1:size(adcp.(char(fields(iii))),1)
                adc.(char(fields(iii)))(kk,:)=databin...
                    ([1:npoints:length(adcp.time)+npoints],...
                    [1:length(adcp.time)],adcp.(char(fields(iii)))(kk,:));
            end
        end
        adc.depth=adcp.depth;
        adc.cfg=adcp.cfg;
        adc.readme=adcp.readme;
        adcp=adc;
        
        % save the 1 minute ocean surveyor broadband data
        save([dname2 os150filelist(ii).name(end-19:end-4) 'bb'],'adcp')
    end
    
    % clear important variables before moving on to the Ocean Surveyor
    clear data config adcp adc
end
end
end

else
    disp('no data from OS150')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END OF PROCESSING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% remove all of the paths that were added at the beginning to avoid
% possible conflicts with functions that have the same name
rm_uhpaths(adcppathname)


disp(['done processing at ' datestr(now)])
disp(' ')
