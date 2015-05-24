%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% ReadRTI.m
%
% Read in RTI ensemble data.  Decode the data.
% The data will then be stored in the struct "Ensembles".
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Copyright 2011, Rowe Technology Inc. 
% All rights reserved.
% http://www.rowetechinc.com
% https://github.com/rowetechinc
% 
% Redistribution and use in source and binary forms, with or without modification, are
% permitted provided that the following conditions are met:
% 
%  1. Redistributions of source code must retain the above copyright notice, this list of
%      conditions and the following disclaimer.
%      
%  2. Redistributions in binary form must reproduce the above copyright notice, this list
%      of conditions and the following disclaimer in the documentation and/or other materials
%      provided with the distribution.
%      
%  THIS SOFTWARE IS PROVIDED BY Rowe Technology Inc. ''AS IS'' AND ANY EXPRESS OR IMPLIED 
%  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
%  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> OR
%  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
%  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
%  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
%  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
%  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%  
% The views and conclusions contained in the software and documentation are those of the
% authors and should not be interpreted as representing official policies, either expressed
% or implied, of Rowe Technology Inc.
% 
% Rico Castelo 
% rcastelo@rowetechinc.com
%
% HISTORY
% -----------------------------------------------------------------
% Date         Initials    Version    Comments
% -----------------------------------------------------------------
% 05/05/2015   RC          0.0.1      Initial Coding
%
%
%
% 
%
%%
clear;close all;clc

% Display a waitbar
% Not showing a waitbar will improve processing time
% 1 will display the waitbars
% 0 will not display any progress
isWaitbar = 1;

% File
%folder = 'C:\rti\Matlab';
%fullFileName = fullfile(folder, 'VT_20150218134057_00308.bin');
% fullFileName = fullfile(folder, 'B0000001.ens');

% Display a dialog to select a file
%fullFileName = uigetfile('*.*', 'Select an ensemble file');

folder='/Users/Andy/Dropbox/ARV/oregon_coast_2015_04_30/ADCP/A0000010/'
fullFileName=fullfile(folder,'01470000000000000000000000000175_A0000010_1.ENS')

% Open the file
fid = fopen(fullFileName);

% Read in the binary data
% Read in the entire file
[data,count] = fread(fid, inf);

% Close the file
fclose(fid);

% Ensemble header length and checksum length
HDRLEN = 32;

% List of ensemble indexes
ensIndexList = [];

% Ensemble ID
% 16 Bytes of 0xFF or 128
ensID = [128; 128; 128; 128; 128; 128; 128; 128; 128; 128; 128; 128; 128; 128; 128; 128];

% File Length
fileLength = length(data);

% Show progress
if isWaitbar
    h = waitbar(0, 'Finding Ensembles');
end

% Find all the ensembles by checking if they start with 16 0x80
for ensIdx = 1 : fileLength
    
    % Display progress
    if isWaitbar && rem(ensIdx,3000) == 0
        %fprintf(sprintf('%s%%3d%%%%', repmat('\b', 1, 4)), round(ensIdx/fileLength*100));
        waitbar(ensIdx/fileLength, h, sprintf('%d ensembles found',length(ensIndexList)));
    end
    
    % Check if it is the start of an ensemble
    if ensIdx + 15 < length(data)
        
        % Get the next 16 bytes to check for an ID
        idCheck = data(ensIdx+0:ensIdx+15);
        
        % Check for the ID
        if idCheck == ensID
            % Add the start of an ensemble to the list
            ensIndexList(end+1) = ensIdx;
        end
    end
end

%Show complete waitbar
if isWaitbar
    waitbar(fileLength, h, sprintf('%d ensembles found',length(ensIndexList)));
end

% Ensemble index for the ensemble struct array
ensIndex = 1;

% Number of ensembles found
numEnsFound = length(ensIndexList);

% Number of good ensembles
% These are ensembles that passed checksum
numGoodEns = 0;

% Reset waitbar
if isWaitbar
    waitbar(0, h, 'Processing ensembles...');
end

% Go through all the indexed ensembles
for x = 1 : numEnsFound
    % Display progress
    if isWaitbar && rem(x,10) == 0
        waitbar(x/numEnsFound, h, sprintf('Processing ensemble %d ', x));
    end
    
    % Get the index to the next ensemble
    index = ensIndexList(x);
    
    % Verify the next index is outside the vector
    if (index + HDRLEN) < length(data)
        
        % Ensemble Number
        ensNum = typecast(uint8(data(index+16:index+19)),'uint32');
        
        % 1's Complement Ensemble Number
        ensNumInv = typecast(uint8(data(index+20:index+23)),'uint32');
        
        % Payload size
        payloadSize = typecast(uint8(data(index+24:index+27)),'uint32');
        
        % 1's Complement Payload size
        payloadSizeInv = typecast(uint8(data(index+28:index+31)),'uint32');
        
        % Verify the ensemble number and payload size
        if ensNum == bitcmp(ensNumInv,'uint32') && payloadSize == bitcmp(payloadSizeInv,'uint32')
            
            ensStart = index + HDRLEN;                                      % Index to start of ensemble
            ensEnd = index + HDRLEN + payloadSize;							% Index to end of ensemble
            
            % Get the checksum, the last 4 bytes after the payload
            % The last 2 bytes should be 0x00
            checksum = typecast(uint8(data(ensEnd:ensEnd+3)),'uint32');
            
            % Get the payload of the data
            payload = data(ensStart:ensEnd-1);
            
            % Calculate the checksum of the data
            crc = uint16(0);
            for n = 1:length(payload)
                
                % crc = (ushort)((byte)(crc >> 8) | (crc << 8));
                bs1 = uint8(bitshift(crc, -8));
                bs2 = uint16(bitshift(crc, 8));
                crc = bitxor(uint16(bs1), bs2);
                
                % crc ^= payload[i];
                crc = bitxor(crc, payload(n));
                
                % crc ^= (byte)((crc & 0xff) >> 4);
                sVal = uint8(bitshift(bitand(crc, 255), -4));
                crc = bitxor(crc, uint16(sVal));
                
                % crc ^= (ushort)((crc << 8) << 4);
                s1Val = bitshift(crc, 8);
                s2Val = bitshift(s1Val, 4);
                crc = bitxor(uint16(crc), uint16(s2Val));
                
                % crc ^= (ushort)(((crc & 0xff) << 4) << 1);
                aVal = bitand(crc, 255);
                s3Val = bitshift(aVal, 4);
                s4Val = bitshift(s3Val, 1);
                crc = bitxor(uint16(crc), uint16(s4Val));
            end
            
            % Finds ensembles roughly 1 per second
            if crc == checksum
                
                % Increment the number of good ensembles
                numGoodEns = numGoodEns + 1;
                
                % Clear the previous ensemble data
                clear E000001;
                clear E000002;
                clear E000003;
                clear E000004;
                clear E000005;
                clear E000006;
                clear E000007;
                clear E000008;
                clear E000009;
                clear E000010;
                clear E000011;
                clear E000014;
                
                % Initialize the struct array
                if(ensIndex == 1)
                    % Create an ensemble
                    Ensembles = struct();
                end
                
                % Set ensemble number
                Ensembles(ensIndex).EnsNum = ensNum;
                
                % Load the payload
                fileID = fopen('ens.mat','w');
                fwrite(fileID, payload);
                fclose(fileID);
                load('ens.mat');
                
                % Set the ensemble data
                % Beam Velocity Data
                % Bins x Beams
                if exist('E000001', 'var')
                    Ensembles(ensIndex).BeamVel = E000001;
                end
                
                % Instrument Velocity Data
                % Bins x Beams
                if exist('E000002', 'var')
                    Ensembles(ensIndex).InstrVel = E000002;
                end
                
                % Earth Velocity Data
                % Bins x Beams
                if exist('E000003', 'var')
                    Ensembles(ensIndex).EarthVel = E000003;
                end
                
                % Amplitude Data
                % Bins x Beams
                if exist('E000004', 'var')
                    Ensembles(ensIndex).Amplitude = E000004;
                end
                
                % Correlation Data
                % Bins x Beams
                if exist('E000005', 'var')
                    Ensembles(ensIndex).Correlation = E000005;
                end
                
                % Good Beam Pings Data
                % Bins x Beams
                if exist('E000006', 'var')
                    Ensembles(ensIndex).GoodBeamPings = E000006;
                end
                
                % Good Earth Pings Data
                % Bins x Beams
                if exist('E000007', 'var')
                    Ensembles(ensIndex).GoodEarthPings = E000007;
                end
                
                % Ensemble Data
                % N x 1
                if exist('E000008', 'var')
                    Ensembles(ensIndex).Ensemble = E000008;
                end
                
                % Ancillary Data
                % N x 1
                if exist('E000009', 'var')
                    Ensembles(ensIndex).Ancillary = E000009;
                end
                
                % Bottom Track Data
                % N x 1
                if exist('E000010', 'var')
                    Ensembles(ensIndex).BottomTrack = E000010;
                end
                
                % NMEA Data
                % N x 1
                if exist('E000011', 'var')
                    Ensembles(ensIndex).NMEA = E000011;
                end
                
                % Profile Engineering Data
                % N x 1
                if exist('E000012', 'var')
                    Ensembles(ensIndex).ProfileEng = E000012;
                end
                
                % Bottom Track Engineering Data
                % N x 1
                if exist('E000013', 'var')
                    Ensembles(ensIndex).BottomTrackEng = E000013;
                end
                
                % System Settings Data
                % N x 1
                if exist('E000014', 'var')
                    Ensembles(ensIndex).SystemSettings = E000014;
                end
                
                % Range Tracking Data
                % (3x number of beams + 1) x 1
                if exist('E000015', 'var')
                    Ensembles(ensIndex).RangeTracking = E000015;
                end
                
                % Gage Height Data
                % N x 1
                if exist('E000016', 'var')
                    Ensembles(ensIndex).GageHeight = E000016;
                end
                
                % Increment for the next struct
                ensIndex = ensIndex + 1;
            end
        end
    end
end

if isWaitbar
    close(h);
end

% Display the final results
sprintf('%d ensembles found', numGoodEns)

% Cleanup
% Clear the data we do not need
clear E000001;
clear E000002;
clear E000003;
clear E000004;
clear E000005;
clear E000006;
clear E000007;
clear E000008;
clear E000009;
clear E000010;
clear E000011;
clear E000012;
clear E000013;
clear E000014;
clear E000015;
clear E000016;
clear data;
clear payload;
clear s1Val;
clear s2Val;
clear s3Val;
clear s4Val;
clear sVal;
clear aVal;
clear bs1;
clear bs2;
clear checksum;
clear count;
clear crc;
clear ensEnd;
clear ensIdx;
clear ensIndex;
clear ensID;
clear ensIndexList;
clear ensNum;
clear ensNumInv;
clear ensStart;
clear fid;
clear fileID;
clear fileLength;
clear h;
clear index;
clear numEnsFound;
clear payloadSize;
clear payloadSizeInv;
clear x;
clear n;
clear folder;
clear fullFileName;
clear HDRLEN;
clear idCheck;
