function read_micrologger(fname)
% Read micrologger file corresponding to 
% airpod file. Function is called from raw_load_ppod.
% fname='\\mserver\data\Air_Ppod\Feb16_09\micrologger\tanktst2';
%
% reference time written unix time in seconds
% Column 1 is unix time in seconds in uint32.
% Column 2 is the internal sampling counter in uint16.  It has 160 'tics' 
% per second. On every tick the accelerometers are sampled. Every 8'th tic,
% the last 8 samples are averaged and sent to the output file.
%
% The last three columns are the averaged accelerometer samples in uint16.
% The X Y and Z axis notations are rather arbitrary and depend on the 
% mounting of the board. The values range from 0 to 4095 and correspond to 
% voltages of 0 to 3.3V. 

if nargin<1
    [raw_name,dirname]=uigetfile('*.*','Load Binary File');
    fname=[dirname raw_name];
end
fid = fopen(fname,'r');
% it takes too much time to read the data
% we should preallocate array to speed it up
% the file with 216008 entries is 2592096 bytes
% this is 12 bytes per line
% so we preallocate array acordingly to this proportion 
fseek(fid,0,'eof');
position = ftell(fid);
fseek(fid,0,'bof');
nlines=floor(position/12);
maxlines=1000000;

if nlines>maxlines
    for ii=1:floor(nlines/maxlines)
        nn=maxlines;
        micrologger=read_raw_file(fid,nn);
        save(sprintf('%s_%03d.mat',fname,ii),'micrologger')
    end
    nn=nlines-maxlines;
    micrologger=read_raw_file(fid,nn);
    save(sprintf('%s_%03d.mat',fname,ii+1),'micrologger')
else
    nn=nlines;
    micrologger=read_raw_file(fid,nn);
    save([fname '.mat'],'micrologger')
end
fclose(fid);


function micrologger=read_raw_file(fid,nn)
data=fread(fid,[6 nn],'uint16=>double');
tt=data(1,:)+data(2,:).*2^16;
% if data were saved as uint8, we'd have to convert it this way:
% tt=data(1,:)+data(2,:).*2^8+data(3,:).*2^16+data(4,:).*2^24;
dt=diff(tt);
% find location of bad bytes
bad=find(dt>1 | dt<0);
badpoints=0;
ngood=0;
while ~isempty(bad)
    ngood=ngood+bad(1); % number of good points so far
    badpoints=badpoints+1;
    if badpoints==1
        % cut good data before the bad location
        data=data(1:6,1:ngood);
        readlines=nn;
        % if bad entry starts in the place of ticks
        % we scrap the entire line
        if (data(3,end)-data(3,end-1))~=8 && (data(3,end)-data(3,end-1))~=-152
            data=data(:,1:end-1);
        end
    end
    % reposition to 1 line before the beginning of the bad data
    fseek(fid,-(readlines-bad(1)+1)*12,'cof');
    % read last good line
    tmp=fread(fid,12,'uint8');
    good=0;njunk=0;
    while ~good
        % read 4 bytes and compare 3rd & 4th bytes with corresponding byte
        % from the good line
        junk=fread(fid,4,'uint8');
        if junk(4)~=tmp(4) || junk(3)~=tmp(3)
            njunk=njunk+1;
            % bytes are different. go 3 bytes back and try again
            fseek(fid,-3,'cof');
        else 
            good=1;
            % ok, the bytes are identical
            % return 4 bytes back to read the good input again
            fseek(fid,-4,'cof');
        end
    end
    % skip bad bytes and read the rest
    readlines=nn-ngood-njunk;
    dat2=fread(fid,[6 readlines],'uint16=>double');
    tt=dat2(1,:)+dat2(2,:).*2^16;
    dt=diff(tt);
    bad=find(dt>1 | dt<0);
    if isempty(bad)
        data=[data dat2];
    else
        dat3=dat2(1:6,1:bad(1));
        data=[data dat3];
    end
    % if bad entry starts in the place of ticks
    % we scrap the entire line
    if (data(3,end)-data(3,end-1))~=8 && (data(3,end)-data(3,end-1))~=-152
        data=data(:,1:end-1);
    end
end
tt=data(1,:)+data(2,:).*2^16;
% convert to physical units
micrologger.time=datenum(1970,1,1)+tt/86400+data(3,:)/86400/160;
micrologger.acc=data(4:6,:)/4095*3.3;
