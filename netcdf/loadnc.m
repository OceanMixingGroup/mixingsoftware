function [ A ] = loadnc( filename )
% load in all data from a netcdf file
% put ncdisp into the readme
% fix the time vector into datenum
%
% A = loadnc(filename)
%
% filename = full path to netcdf file
% A = structure with all netcdf variables
%
% S. Warner Dec 2017



% find all variable names

A.info = ncinfo(filename);
for ii = 1:length(A.info.Variables)
    vars{ii} = A.info.Variables(ii).Name;
end

% determine if there is a time vector
yntime = 0;
clear timeind
for ii = 1:length(vars)
    if strcmp(char(vars(ii)),'time')
        yntime = 1;
        timeind = ii;
    elseif strcmp(char(vars(ii)),'TIME')
        yntime = 1;
        timeind = ii;
    elseif strcmp(char(vars(ii)),'Time')
        yntime = 1;
        timeind = ii;
    end
end

% find the start time
if yntime == 1
    starttimestring = ncreadatt(filename,char(vars(timeind)),'units');
    try
        starttimedatenum = datenum(starttimestring(end-18:end));
    catch
        starttimedatenum = datenum(starttimestring([end-19:end-10 end-8:end-1]),...
            'yyyy-mm-ddHH:MM:SS');
    end
    time = double(ncread(filename,char(vars(timeind))));    
    if strcmp(starttimestring(1:4),'year')
        A.time = starttimedatenum + datenum(time,0,0,0,0,0);
    elseif strcmp(starttimestring(1:5),'month')
        A.time = starttimedatenum + datenum(0,time,0,0,0,0);
    elseif strcmp(starttimestring(1:4),'days')
        A.time = starttimedatenum + datenum(0,0,time,0,0,0);
    elseif strcmp(starttimestring(1:4),'hour')
        A.time = starttimedatenum + datenum(0,0,0,time,0,0);
    elseif strcmp(starttimestring(1:6),'minute')
        A.time = starttimedatenum + datenum(0,0,0,0,time,0);
    elseif strcmp(starttimestring(1:6),'second')
        A.time = starttimedatenum + datenum(0,0,0,0,0,time);
    end
end
    


% load in the rest of the variables
for ii = 1:length(vars)
    if ii ~= timeind   
%         units = ncreadatt(filename,char(vars(ii)),'units');
        clear shortname
        try
            shortname = ncreadatt(filename,char(vars(ii)),'name');
        catch
            shortname = char(vars(ii));
        end 
        clear longname
        try
            longname = ncreadatt(filename,char(vars(ii)),'long_name');
        catch
            longname = char(vars(ii));
        end 
        
        % look if data is quality or source data
        clear q s
        q = strfind(lower(longname),'quality');
        s = strfind(lower(longname),'source');
        
        if isempty(q) & isempty(s)
            A.(shortname) = squeeze(double(ncread(filename,char(vars(ii)))));
            A.(shortname)(A.(shortname) > 1e30) = NaN;
        end
    end
end






end

