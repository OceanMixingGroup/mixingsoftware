%~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% ParsePixhawkLogs.m
%
% Script to parse txt logs from Pixhawk for IMU, compass data.
%
% Logs are converted from .BIN to txt with a python script.
%
% Dependencies:
% ParseATTlines.m
% ParseATTlines.m
% ParseMAGline.m
%
%-----------------
% 11/25/15 - A.Pickering - Initial coding
% 11/29/15 - AP - Nick updated processing (still only works on his Linux
% machine) for log files. Now there are 'IMUlog.txt' files that contain
% only the 'ATT', 'IMU', and 'Mag' lines from the logs, so reading them should be
% faster. 'ATT' contains heading/pitch/roll, and IMU contains (I think) raw
% outputs from the accelerometers etc.. So i'm hoping that the ATT values
% are calibrated and I can just use those.
%   -Reading them into Matlab still takes a long time; IMUlog 5 from Deploy 4
%   is 176MB (about 1 hour of data), and took ~9 mins to parse with this script.
%   -Trying to skip some lines since data is sampled much faster than we need
%   (~100hz?). Order is ATT,IMU,IMU2,MAG,MAG2,ATT.
%   - Need to read 'MAG' lines; ATT 'yaw' is same as gps heading (moving
%   heading, not instantaneous heading).
% 11/30/15 - AP - Replace some of line parsing with functions, working on
% reading mag lines also.
% 12/01/15 - AP - Add 'MAG2' lines
%~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear; close all

addpath /Users/Andy/Cruises_Research/mixingsoftware/ARV/PixHawk/

%datadir='/Users/Andy/Desktop/4'
datadir='/Users/Andy/Google Drive/Deploy4/Processed Files/5'

filename=fullfile(datadir,'IMUlog.txt')

%filename='/Users/Andy/Google Drive/Deploy4/Processed Files/8/IMUlog.txt'

% try to figure out # lines in file
Nlines=linecount(filename)
Nlines=double(Nlines)
%

% open file
fileID = fopen(filename,'r');
%
keepgoing=1;

Nskip=30 % # lines to skip
iskip_att=0;
iskip_mag=0;
iskip_mag2=0;

dnum_att=[];
roll=[];
pitch=[];
yaw=[];

dnum_mag=[];
magX=[];
magY=[];
offX=[];
offY=[];

dnum_mag2=[];
magX2=[];
magY2=[];
offX2=[];
offY2=[];
%%
tstart=tic

clc
if Nlines~=-1
    hb=waitbar(0)
end

whline=1
while keepgoing
    
    if Nlines~=-1
        waitbar(whline/Nlines,hb)
    end
    
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
        
        
        
        %~~~~ read 'MAG' line
        idMAG=strfind(a,'MAG ');
        
        if ~isempty(idMAG)
            
            
            if iskip_mag==0
                
                clear b c d e f
                [b,c,d,e,f]=ParseMAGline(a);
                dnum_mag=[dnum_mag b];
                magX=[magX c];
                magY=[magY d];
                offX=[offX e];
                offY=[offY f];
                
                % reset skip counter
                iskip_mag=Nskip;
                
            else
                iskip_mag=iskip_mag-1;
            end %skip counter
            
        end   % MAG line
        
        
        %~~~~ read 'MAG2' line
        idMAG2=strfind(a,'MAG2 ');
        
        if ~isempty(idMAG2)
            
            
            if iskip_mag2==0
                
                clear b c d e f
                [b,c,d,e,f]=ParseMAGline(a);
                dnum_mag2=[dnum_mag2 b];
                magX2=[magX2 c];
                magY2=[magY2 d];
                offX2=[offX2 e];
                offY2=[offY2 f];
                
                % reset skip counter
                iskip_mag2=Nskip;
                
            else
                iskip_mag2=iskip_mag2-1;
            end %skip counter
            
        end   % MAG line
        
        whline=whline+1;
    else
        keepgoing=0
        disp('reached end of file')
    end
    
    if iseven(whline/1000)
        disp(['At line ' num2str(whline)])
    end
    
    if length(dnum_att)~=length(yaw) || length(dnum_att)~=length(roll) || length(dnum_att)~=length(pitch)
        error('error')
    end
    
    
end
TE=toc(tstart)/60
disp(['took ' num2str(TE) ' mins '])

%%

figure(1);clf

subplot(311)
plot(dnum_att,roll)
datetick('x')
%xlabel(datestr(floor(nanmin(dnum))))
ylabel('Roll')
grid on

subplot(312)
plot(dnum_att,pitch)
datetick('x')
%xlabel(datestr(floor(nanmin(dnum))))
ylabel('Pitch')
grid on

subplot(313)
plot(dnum_att,yaw)
datetick('x')
xlabel(datestr(floor(nanmin(dnum_att))))
ylabel('yaw')
grid on

%% save the mat data

% ATT
A=struct();
A.pitch=pitch;
A.roll=roll;
A.yaw=yaw;
A.dnum=dnum_att;
A.filename=filename;
A.MakeInfo=['Made ' datestr(now) 'w/ ParsePixhawkLogs.m']

% MAG
M=struct();
M.dnum=dnum_mag;
M.magX=magX;
M.magY=magY;
M.offX=offX;
M.offY=offY;
M.filename=filename;
M.MakeInfo=['Made ' datestr(now) 'w/ ParsePixhawkLogs.m']

% MAG2
M2=struct();
M2.dnum=dnum_mag2;
M2.magX=magX2;
M2.magY=magY2;
M2.offX=offX2;
M2.offY=offY2;
M2.filename=filename;
M2.MakeInfo=['Made ' datestr(now) 'w/ ParsePixhawkLogs.m']


%save([filename(1:end-4) '.mat'],'A','M','M2')

%%
