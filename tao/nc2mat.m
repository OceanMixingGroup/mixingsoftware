function [data] = nc2mat(file)
% nc2mat reads in a netcdf file and saves all of the variables into a
% matlab strucutre
%
% It is specifically written to read in mooring data from TAO/PIRATA/RAMA,
% but can be used for other data sources also
%
% [data] = nc2mat(file)
% file = netcdf file directory and name (string)
% data = structure that contains all of the netcdf variables
%
% Sally Warner, November 2017

% get basic info about the file
ncdisp(file);
aa = ncinfo(file);
missingval = ncreadatt(file,'/','missing_value');

% read in all of the variables
for ii = 1:length(aa.Variables)
    try
        % use the name saved in the attributes
        varname = ncreadatt(file,aa.Variables(ii).Name,'name');
    catch
        % if no name in the attributes, use the variable name
        varname = aa.Variables(ii).Name;
    end
    % read in each variable
    disp(['reading in ' varname])
    data.(varname) = squeeze(double(ncread(file,aa.Variables(ii).Name)));
    
    %replace bad datapoints with NaN
    data.(varname)(data.(varname) >= missingval/10) = NaN;
end

% convert the time vector to datenum
if isfield(data,'time')
    origtime = data.time;
    starttimestring = ncreadatt(file,'time','units');
    starttime = datenum(starttimestring(end-18:end),'yyyy-mm-dd HH:MM:SS');
    if strcmp(starttimestring(1:5),'years')        
        data.time = starttime + datenum(origtime,0,0,0,0,0);
        disp(['time converted to datenum, start time = ' starttimestring])
    elseif strcmp(starttimestring(1:6),'months')
        data.time = starttime + datenum(0,origtime,0,0,0,0);
        disp(['time converted to datenum, start time = ' starttimestring])
    elseif strcmp(starttimestring(1:4),'days')
        data.time = starttime + datenum(0,0,origtime,0,0,0);
        disp(['time converted to datenum, start time = ' starttimestring])
    elseif strcmp(starttimestring(1:5),'hours')
        data.time = starttime + datenum(0,0,0,origtime,0,0);
        disp(['time converted to datenum, start time = ' starttimestring])
    elseif strcmp(starttimestring(1:7),'minutes')
        data.time = starttime + datenum(0,0,0,0,origtime,0);
        disp(['time converted to datenum, start time = ' starttimestring])
    elseif strcmp(starttimestring(1:7),'seconds')
        data.time = starttime + datenum(0,0,0,0,0,origtime);  
        disp(['time converted to datenum, start time = ' starttimestring])
    else
        disp('The time vector can''t be parsed')
    end
end

% create readme
data.filename = file;
data.netcdfinfo = aa;
data.readme = internal.matlab.imagesci.nc(file);


end

