function [dnum,pitch,roll,yaw]=ParseATTlines(a)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function [dnum,pitch,roll,yaw]=ParseATTlines=(a)
%
% Parse 'ATT' lines from Pixhawk log files
%
% a is line from txt file that contains 'ATT'
%
%------------------
% 11/30/15 - A. Pickering
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear dnum idR idP idY
idR=strfind(a,' Roll');
idR2=strfind(a,', DesPitch');
idP=strfind(a,' Pitch :');
idP2=strfind(a,', DesYaw');

idY=strfind(a,' Yaw');
idY2=strfind(a,', ErrRP');

if ~isempty(idR) && ~isempty(idP) && ~isempty(idY)
    
    dnum=datenum(a(1:22));
    
    roll=str2double(a(idR+8 : idR2-1) );
    
    pitch= str2double(a(idP+8 : idP2-1) );
    
    yaw= str2double(a(idY+6 : idY2-1) );
    
else
    return
end

%%