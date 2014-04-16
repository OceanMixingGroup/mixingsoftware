function [ppod]=readppod5(filenam)
% Read a PPOD5 data file and convert to pressure and time structure

fid = fopen(filenam,'r');
% call the pp6header function to decode the header part of file
ppheader=pp6header(fid);
fseek(fid,0,'eof'); % move to end of file
pos2 = ftell(fid); % pos2 is overall length of file
fseek(fid,8192,'bof'); % fseek to just past the header
%tic;
headeroffset = 8192;
epoch=double(datenum(1970,1,1)); %reference time - times written in seconds since epoch
% Each second of data contains the following:
%   btype	uint32    
%   msptime	uint32  Unix seconds
%   dstime	uint32  Unix seconds
%   spare	uint32  used for total bytes written
%   bdtemp	float32 board temperature in deg C
%   countoffset  uint32  Offset to add to high speed counts
%   syncint	uint16  number of high-speed samples in second (40)
%   dstate  uint16  data state machine index
%   ptpd    float32 120 sets of interleaved pressure and temperature period values  
% initialize variables and allocate space at start, so Matlab doesn't waste
% time increasing the array sizes as data is read into arrays
    % now read the data from the file
    % reset to position of first msptime
    line = 1;
    sync = 0;
    pdcounter = 0;
    fseek(fid,0,'eof'); % move to end of file
    pos2 = ftell(fid); % pos2 is overall length of file
    fseek(fid,8192,'bof'); % move to just past the header
    nblocks=floor((pos2-8192)/984); % number of full 120 sec blocks
    ntail=floor((mod((pos2-8192),984)-24)/8); % number of measurements in the last block
    % negative ntail messes things up, so make sure it isn't less than 0
    ntail = max(ntail,0);
    % initialize variables and allocate space
    ppod.ppd1=NaN*ones(1,nblocks*120+ntail);
    ppod.tpd1=NaN*ones(1,nblocks*120+ntail);
    ppod.msptime=NaN*ones(1,nblocks*120+ntail);
    ppod.ds=NaN*ones(1,nblocks);
    ppod.msp=NaN*ones(1,nblocks);
    ppod.boardtemp=NaN*ones(1,nblocks*120+ntail);
    for ii=1:nblocks
        btype = fread(fid,1,'uint32=>double');
        msptime = fread(fid,1,'uint32=>double');
        dstime = fread(fid,1,'uint32=>double');
        spare = fread(fid,1,'uint32=>double');
        bdtemp = fread(fid,1,'float32=>double');
        syncint = fread(fid,1,'uint16=>double');
        dstate = fread(fid,1,'uint16=>double');
        % now read all 120 sets of interleaved pressure and temp periods
        ppdtpd= fread(fid,240,'float32=>double');
        % now separate out pressure and temp periods and add to vectors
        ppod.ppd1(ii*120-119:ii*120)=ppdtpd(1:2:end);
        ppod.tpd1(ii*120-119:ii*120)=ppdtpd(2:2:end);
        % add msp times to vector and correct for epoch offset and offset
        % from the start of the 120-second block. Also convert from
        % seconds to days, which is matlab time unit
        ppod.msptime(ii*120-119:ii*120)=(msptime+[0:119])/86400+epoch;
        
        ppod.msp(ii)=msptime; % save the original msp time at block start
        ppod.ds(ii)=dstime; % save the ds3232 time at block start
        ppod.boardtemp(ii*120-119:ii*120)=bdtemp;
    end % for ii=1:nblocks
    % now make up a vector with interpolated DS3232 time
    ppod.dstime=interp1([1:120:nblocks*120-119],ppod.ds,[1:nblocks*120],'linear','extrap');
    % now read the last unfinished block
    if ntail>0
        btype = fread(fid,1,'uint32=>double');
        msptime = fread(fid,1,'uint32=>double');
        dstime = fread(fid,1,'uint32=>double');
        spare = fread(fid,1,'uint32=>double');
        bdtemp = fread(fid,1,'float32=>double');
        syncint = fread(fid,1,'uint16=>double');
        dstate = fread(fid,1,'uint16=>double');
        % this time we can only read ntail * 2 words of data
        ppdtpd1= fread(fid,ntail*2,'float32=>double');
        ppod.ppd1(ii*120+1:ii*120+ntail)=ppdtpd(1:2:(ntail*2)-1);
        ppod.tpd1(ii*120+1:ii*120+ntail)=ppdtpd(2:2:(ntail*2));
        ppod.msp(ii)=msptime;
        ppod.ds(ii)=dstime;
        ppod.msptime(ii*120+1:ii*120+ntail)=(msptime+[0:ntail-1])/86400+epoch;
        ppod.boardtemp(ii*120+1:ii*120+ntail)=bdtemp;
    end % if ntail>0
    ppod.dstime(end+1:length(ppod.msptime))=ppod.dstime(end)+...
        [1:length(ppod.msptime)-length(ppod.dstime)]*mean(diff(ppod.dstime));
    ppod.dstime=ppod.dstime/86400+epoch;
    ppod.msp=ppod.msp/86400+epoch;
    ppod.ds=ppod.ds/86400+epoch;
    ppod.readme=char('boardtemp is CPU temperature',...
        'ppd1 is pressure  period in microseconds',...
        'tpd1 is temperature in microseconds',...
        'p is absolute pressure in psi',...
        't is temperature in C',...
        'msp is msp time saved at the beginning of each block',...
        'ds is accurate RTC time saved at the beginning of each block',...
        'msptime is based on msp time (this time drifts) interpolated inside each block',...
        'dstime is updated with an accurate RTC and interpolated inside each block',...
        'dstime should be used for analysis');


   % convert period and temperature into pressures to be passed back
    [ppod.pr1 ppod.tm1] = convert_ppod6(ppheader, ppod.ppd1, ppod.tpd1);
   % toc  % used for performance measurement
    fclose(fid);


end
