function [ allppod ] = longloadppod()
% This function gets file names with a standard dialog and 
% calls the appropriate readppod function,  concatenating 
% the 1Hz pressure and temperature data and returning a structure
% with time, pressure, and temperature.
%
% As of 9/16/13, it only handles PPOD firmware version 5 and 6
% (the latest versions for Air PPODS and HSPPODS.
%
% The file input dialog allows the selection of multiple 
% files. If your data directory contains files other than 
% PPOD binary files, you should sort by type and select 
% only the raw binary files.
%
% MJB 9/16/13
%
% Updated to handle single file selection and to skip past unreadable
% files---for example, when a .mat file is in the directory.
% The program still assumes that all the files in the directory are
% of the same type----PPOD5 or HSPPOD
% The program also displays the file name and starting date for the data.
% This is helpful if the program that saved the files didn't build the
% starting date into the file name.
% MJB  9/17/13


    [raw_name,tpath,filterindex]=uigetfile('*.*','PPOD Data File(s)','MultiSelect','on');
    % with MultiSelect on, when multiple files are selected the file names
    % will be in a cell array.  If only a single file is selected, the file
    % name is a standard string and cannot be used like a cell array.
    if iscellstr(raw_name)
        fullfilename=[tpath raw_name{1,1}];  
        nfiles = length(raw_name);
    else
        fullfilename = [tpath raw_name];
        nfiles = 1;
    end

    % Call FindPPODVersion to get the firmware version
    % only versions 5 and 6 are valid at this time
    
    version = FindPPODVersion(fullfilename);
    if version == 0
        display('Unable to decode this file.  Only PPOD5 and PPOD6 files are allowed!');
        allppod = [];
        return 
    end

    allppod.dstime = [];
    allppod.pr1 = [];
    allppod.tm1 = [];
    % at this time, we ignore all the other fields in a ppod file
    for ii = 1:nfiles
        if iscellstr(raw_name)
            fullfilename=[tpath raw_name{1,ii}];
            shortname = raw_name{1,ii};
        else
            fullfilename = [tpath raw_name];
            shortname = raw_name;
        end
        
        %tic;
        switch version
            case 5
                try
                    ppod = readppod5(fullfilename);  
                    % readpppod5 returns structure elements as 1 column x n rows
                    % we transpose those elements to make the allppod structure
                    % contain column vectors
                    allppod.dstime = vertcat(allppod.dstime, ppod.dstime');
                    allppod.pr1 = vertcat(allppod.pr1, ppod.pr1');
                    allppod.tm1 = vertcat(allppod.tm1, ppod.tm1'); 
                catch 
                    disp('File read error');
                end

            case 6
                try
                    ppod = readppod6(fullfilename);
                    allppod.dstime = vertcat(allppod.dstime, ppod.dstime);
                    allppod.pr1 = vertcat(allppod.pr1, ppod.pr1);
                    allppod.tm1 = vertcat(allppod.tm1, ppod.tm1);                
                catch
                    disp('File read error');
                end
        end
        s1 = sprintf('Read data from %s   ',shortname);
        s2 = datestr(ppod.dstime(1), 'mm/dd/yy HH:MM');
        disp([s1 s2]);           
        
        % the following may help with debugging and performance analysis
        % toc    % for measuring elapsed time for reading file
    end
    
    plot(allppod.dstime,allppod.pr1);
    %datetick('x',23);
    kdatetick2;
    title('PPOD Pressure (PSI)');
end

function version = FindPPODVersion(fullfilename)
    % call the pp6header function to decode the header part of file
    % the pp6 header function works both with PPOD5--the latest Air PPOD,
    % and PPOD6, the high-speed ppod.  Note that while the headers
    % are the same PPOD5 and PPOD6 (HSPPOD) have different data formats.   
    fid = fopen(fullfilename,'r');
    try
        ppheader=pp6header(fid); 
    catch
        display('Error decoding header');
        version = 0;
        return;
    end
    fclose(fid);
    version = 0;
    k = strfind(ppheader.firmware, '5.0'); 
    if ~isempty(k)
        version = 5;
    end
    k = strfind(ppheader.firmware, '1.0HS');
    if ~isempty(k)
        version = 6;
    end;
end
