function [dnum , magX , magY, offX , offY]=ParseMAGline(a)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function [dnum , magX , magY, offX , offY]=ParseMAGline(a)
%
% Parse 'MAG' lines from Pixhawk log files
%
% a is line from txt file that contains 'MAG'
%
%------------------
% 11/30/15 - A. Pickering
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear dnum idMX idMY idMZ magX magY idox idoy idoz
dnum=datenum(a(1:22));
idMX=strfind(a,'MagX :');
idMY=strfind(a,', MagY :');
idMZ=strfind(a,', MagZ :');

idox=strfind(a,', OfsX :');
idoy=strfind(a,', OfsY :');
idoz=strfind(a,', OfsZ :');

magX=str2double(a(idMX+6:idMY-1));
magY=str2double(a(idMY+8:idMZ-1));

offX=str2double(a(idox+8 : idoy-1));
offY=str2double(a(idoy+8 : idoz-1));


%
%%