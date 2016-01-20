%%
clear; close all

filename='/Users/Andy/Google Drive/Deploy4/Processed Files/8/IMUlog.txt'

% try to figure out # lines in file
Nlines=linecount(filename)
Nlines=double(Nlines)
%

% open file
fileID = fopen(filename,'r');

keepgoing=1;
dnum=[];
magX=[];
magY=[];
%yaw=[];
tstart=tic

clc
if Nlines~=-1
    hb=waitbar(0)
end

whline=1
while keepgoing
    %for whline=1:Nlines
    %    whline;
    
    if Nlines~=-1
        waitbar(whline/Nlines,hb)
    end
    %%
    clear a
    % read next line in file
    a=fgetl(fileID);
    % if line isn't empty, read data from it
    if a~=-1
    idMAG=strfind(a,'MAG ');
    
    if ~isempty(idMAG)
        clear b c d
       [b,c,d]=ParseMAGline(a);
       dnum=[dnum b];
       magX=[magX c];
       magY=[magY d];
    end
   
    else
        keepgoing=0;
    end
    
    if iseven(whline/1000)
        disp(['At line ' num2str(whline)])
    end
    
    whline=whline+1;
end
%%