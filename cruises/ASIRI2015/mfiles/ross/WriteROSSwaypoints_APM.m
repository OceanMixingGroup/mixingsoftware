function fid=WriteROSSwaypoints_APM(lon,lat)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function fid=WriteROSSwaypoints_APM(lon,lat)
%
% Write a text file with waypoints in Mission Planner format to send to
% ROSS. ** For APM planner (slightly different format than Mission planner)
%
% INPUT
% lon,lat : Waypoints in decimal deg format (ie 45.55)
%
% OUTPUT
% fid - ID for text file with waypoints.
%
% I think that the first positon is set as 'HOME' in mission planner
%
% 08/22/15 - A. Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

lon=lon(:);
lat=lat(:);

if length(lon)~=length(lat)
    error('lon and lat not same size')
end

Npoints=length(lon)

filepath=pwd;
txtfname='RossWayPoints.txt';
fid= fopen(fullfile(filepath,txtfname),'w');

fprintf(fid,['QGC WPL 110' ])
%
a=1;
fprintf(fid,['\n0\t 1\t 0\t 16\t 0\t 5\t 0\t 0\t'...
      sprintf('%0.5f',lat(a)) '\t' sprintf('%0.5f',lon(a)) '\t 0\t 1 ']);

for a=2:Npoints
    %fprintf(fid,['\n' num2str(a-1) '\t 0\t 3\t 16\t 0\t 0\t 0\t 0\t ' num2str(lat(a)) '\t ' num2str(lon(a)) '\t 100 \t 1 ']);
    fprintf(fid,['\n'  num2str(a-1) '\t 0\t 3\t 16\t 0\t 5\t 0\t 0\t' ...
         sprintf('%0.5f',lat(a)) '\t' sprintf('%0.5f',lon(a)) '\t 20\t 1 ']);
        
end

fclose(fid)

%%