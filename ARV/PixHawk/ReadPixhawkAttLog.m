function A=ReadPixhawkAttLog(thefile,Nskip)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function ATT=ReadPixhawkAttLog(thefile)
%
% Read the ATT fields from a pixhawk IMU txt file into a Matlab structure.
%
% INPUT
% thefile : Name of IMU txt file to read
% Nskip   : # of lines to skip. Files are very large and take a long time to read every line. 
%
% OUTPUT
% A : Structure w/ fields:
%   - pitch
%   - roll
%   - yaw
%   - dnum
%
% Dependencies:
%   - ParseATTlines.m
%
%---------------------
% 05/04/16 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

tstart=tic;

% open file
fileID = fopen(thefile,'r');
dnum_att=[];
roll=[];
pitch=[];
yaw=[];

whline=1;
keepgoing=1;
iskip_att=0;

while keepgoing
    
    %     if Nlines~=-1
    %         waitbar(whline/Nlines,hb)
    %     end
    
    clear a
    % read next line in file
    a=fgetl(fileID);
    
    % if line isn't empty, read data from it
    if a~=-1
        
        %~~~~ read 'ATT' line
        clear idATT
        idATT=strfind(a,'ATT {');
        
        % we have an ATT line
        if ~isempty(idATT)
            
            if iskip_att==0
                
                clear b c d e
                [b,c,d,e]=ParseATTlines(a);
                dnum_att=[dnum_att b];
                pitch=[pitch c];
                roll=[roll d];
                yaw=[yaw e];
                
                % reset skip counter
                iskip_att=Nskip;
            else % skip line
                iskip_att=iskip_att-1;
            end % skip counter
        end % it's an ATT line
        
        whline=whline+1;
    else
        keepgoing=0
        disp('reached end of file')
    end
    
end % keepgoing


% ATT
A=struct();
A.pitch=pitch;
A.roll=roll;
A.yaw=yaw;
A.dnum=dnum_att;
A.source=thefile;
A.Nskip=Nskip;
A.time_to_read=toc(tstart);
A.MakeInfo=['Made ' datestr(now) 'w/ ReadPixhawkAttLog.m']


%%