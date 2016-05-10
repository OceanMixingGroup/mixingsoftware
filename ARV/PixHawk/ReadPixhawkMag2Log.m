function M=ReadPixhawkMag2Log(thefile,Nskip)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function M=ReadPixhawkMag2Log(thefile)
%
% Read the Mag2 fields from a pixhawk IMU txt file into a Matlab structure.
%
% INPUT
% thefile : Name of IMU txt file to read
% Nskip   : # of lines to skip. Files are very large and take a long time to read every line.
%
% OUTPUT
% M : Structure w/ fields:
%   - magX,magY
%   - offX,offY
%   -
%   - dnum
%
% Dependencies:
%   - ParseMaglines.m
%
%---------------------
% 05/04/16 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

tstart=tic;

% open file
fileID = fopen(thefile,'r');
dnum_mag=[];
magX=[];
magY=[];
offX=[];
offY=[];

whline=1;
keepgoing=1;
iskip=0;

while keepgoing
    
    clear a
    % read next line in file
    a=fgetl(fileID);
    
    % if line isn't empty, read data from it
    if a~=-1
        
        %~~~~ read 'Mag2' line
        clear idMag
        idMag=strfind(a,'MAG2 ');
        
        % we have an ATT line
        if ~isempty(idMag)
            
            if iskip==0
                
                clear b c d e f
                [b,c,d,e,f]=ParseMAGline(a);
                dnum_mag=[dnum_mag b];
                magX=[magX c];
                magY=[magY d];
                offX=[offX e];
                offY=[offY f];
                
                % reset skip counter
                iskip=Nskip;
                
            else % skip line
                
                iskip=iskip-1;
                
            end % skip counter
            
        end % it's an ATT line
        
        whline=whline+1;
    else
        keepgoing=0
        disp('reached end of file')
    end
    
end % keepgoing


M=struct();
M.dnum=dnum_mag;
M.magX=magX;
M.magY=magY;
M.offX=offX;
M.offY=offY;
M.source=thefile;
M.Nskip=Nskip;
M.time_to_read=toc(tstart);
M.MakeInfo=['Made ' datestr(now) 'w/ ReadPixhawkMag2Log.m']


%%