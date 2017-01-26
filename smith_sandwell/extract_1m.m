% Function EXTRACT_1M	Read bathymetry data from Sandwell Database
%      [image_data,vlat,vlon] = extract_1m(region,iopt)
%
% Original Author: Catherine de Groot-Hedlin, chedlin@ucsd.edu
%                  August 21, 2007 revised for 1-minute grid.
%				   October 25, 2007, uncomment 2nd fopen command if using PC windows
%
% program to get bathymetry from topo_10.1.img  (Smith and Sandwell bathymetry)
%  (values are even numbered if interpolated, odd-numbered if from a ship sounding)
% WARNING 1: change DatabasesDir to the correct one for your machine
% WARNING 2: uncomment 2nd fopen command if using PC windows
% code is a conglomeration of many codes originally written by others
%
% latitudes must be between -80.738 and 80.738;
%	input:
%		region =[south north west east];
%               iopt = 1 for bathymetry (default)
%		               2 for ship tracks
%	output:
%		image_data
%                (for iopt = 1) - matrix of sandwell bathymetry/topography
%                (for iopt = 2) - matrix of ones and zeros, where 1 represents
%                    a ship location, 0 represents a depth based on interpolation
%		vlat - vector of latitudes associated with image_data
%      	vlon - vector of longitudes
%
function  [image_data,vlat,vlon] = mygrid_sand(region,iopt)

% DatabasesDir = '/export/home/plume/cdh/airforce/sandwell.d';
% DatabasesDir = '/net/plume2/cdh2/sandwell.d';
%DatabasesDir = '/Users/Andy/Cruises_Research/Data/SmithSandwell/';
DatabasesDir='/'

% determine the requested region
blat = region(1);
tlat = region(2);
wlon = region(3);
elon = region(4);

% Setup the parameters for reading Sandwell data
db_res         = 1/60;		% 1 minute resolution
db_loc         = [-80.738 80.738 0.0 360-db_res];
db_size        = [17280 21600];
nbytes_per_lat = db_size(2)*2;	% 2-byte integers
image_data     = [];

% Determine if the database needs to be read twice (overlapping prime meridian)
if ((wlon<0)&(elon>=0))
    wlon      = [wlon           0];
    elon      = [360-db_res  elon];
end

% Calculate number of "records" down to start (latitude) (0 to db_size(1)-1)
% (mercator projection)
rad=pi/180;arg1=log(tan(rad*(45+db_loc(1)/2)));
arg2=log(tan(rad*(45+blat/2)));
iblat = fix(db_size(1) +1 - (arg2-arg1)/(db_res*rad));

arg2=log(tan(rad*(45+tlat/2)));
itlat = fix(db_size(1) +1 - (arg2-arg1)/(db_res*rad));

if (iblat < 0 ) | (itlat > db_size(1)-1)
    errordlg([' Requested latitude is out of file coverage ']);
end

% Go ahead and read the database
for i = 1:length(wlon);
    
    
    % Open the data file
    fid = fopen([DatabasesDir '/topo_10.1.img'], 'r','b'); % AP 26 Oct 2010
    %	fid = fopen([DatabasesDir '/topo_10.1.img'], 'r');
    % for those using PC windows use the following line instead of the one above.
    %   fid = fopen([DatabasesDir '/topo_9.1.img'], 'r', 'ieee-be');
    if (fid < 0)
        errordlg(['Could not open database: ' DatabasesDir '/topo_6.2.img'],'Error');
    end
    
    % Make sure the longitude data goes from 0 to 360
    if wlon(i) < 0
        wlon(i) = 360 + wlon(i);
    end
    
    if elon(i) < 0
        elon(i) = 360 + elon(i);
    end
    
    % Calculate the longitude indices into the matrix (0 to db_size(1)-1)
    iwlon(i) = fix((wlon(i)-db_loc(3))/db_res);
    ielon(i) = fix((elon(i)-db_loc(3))/db_res);
    if (iwlon(i) < 0 ) | (ielon(i) > db_size(2)-1)
        errordlg([' Requested longitude is out of file coverage ']);
    end
    
    % allocate memory for the data
    data = zeros(iblat-itlat+1,ielon(i)-iwlon(i)+1);
    
    % Skip into the appropriate spot in the file, and read in the data
    disp('Reading in bathymetry data');
    for ilat = itlat:iblat
        offset = ilat*nbytes_per_lat + iwlon(i)*2 ;
        status = fseek(fid, offset, 'bof');
        data(iblat-ilat+1,:)=fread(fid,[1,ielon(i)-iwlon(i)+1],'integer*2');
    end
    
    % close the file
    fclose(fid);
    
    % put the two files together if necessary
    if (i>1)
        image_data = [image_data data];
        vlon=[vlon-360 db_res*((iwlon(i)+1:ielon(i)+1)-0.5)];
    else
        image_data = data;
        vlon=db_res*((iwlon(i)+1:ielon(i)+1)-0.5);
    end
end

% Determine the coordinates of the image_data
vlat=zeros(1,iblat-itlat+1);
arg2 = log(tan(rad*(45+db_loc(1)/2.)));
for ilat=itlat:iblat;
    arg1 = rad*db_res*(db_size(1)-ilat+0.5);
    term=exp(arg1+arg2);
    vlat(iblat-ilat+1)=2*atan(term)/rad -90;
end
% now choose between bathymetry and ship track
if iopt==2
    image_data=mod(image_data,2);
end

return		% skip the plottting section
% to plot it up
if iopt ==2
    imagesc(vlon,vlat,image_data),axis('xy'),colormap(1-gray)
    title('ship track soundings')
else
    imagesc(vlon,vlat,image_data),axis('xy'),colormap(jet),colorbar('vert')
    title('Smith and Sandwell bathymetry')
end
xlabel('longitude'),ylabel('latitude')
