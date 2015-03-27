function [data]=loadmini8()
% load am 8-channel minilogger data file
% 10/18/14 MJB  Fix file name and time array length
[raw_name,temp,filterindex]=uigetfile('*.*','Load Binary File');
filnam=[temp raw_name];
disp(sprintf('Reading data from %s',raw_name));
%  use full file name rather than raw_name
fid = fopen(filnam,'r');
fseek(fid,0,'eof'); % move to end of file
pos2 = ftell(fid); % pos2 is overall length of file
frewind(fid); % move back to beginning of file
% each second of data has 800 16-bit words of data and one 16-byte time
% record  or 1616 bytes

nseconds=floor((pos2)/1616); % number of one second blocks
disp(sprintf('%d seconds of data in the file',nseconds));
trec.sync = 0;
trec.sernum = 0;
trec.time = 0;
data = [];
syncword = 0;
scount = 0;
while syncword ~= 65535
    syncword = fread(fid,1,'uint16');
    scount = scount+1;
    if scount > 850
        schar = fread(fid,'uchar');
        scount = 0;
    end;
end;

fseek(fid,-2,'cof');
dout = zeros(100*(nseconds-1),8);
dblock = zeros(100,8);
%dout = [];
dtemp = zeros(100,8);
disp('sync found at ');
syncpos = ftell(fid);
disp(ftell(fid));
yidx = 1;


% if ftell(fid) == 160000 the first complete second is at file start
if syncpos == 1600
    fseek(fid, 0, 'bof');
    dblock  = fread(fid,800,'uint16'); 
    dblock = reshape(dblock,8,100)';
    dout(yidx:yidx+99, 1:8)= dblock;
    yidx = yidx+100;    
end
errcount = 0;

% now read the rest of the data

for ii= 1:nseconds-1
    trec.sync = fread(fid,1,'uint16');
    trec.sernum = fread(fid,1,'uint16');
    trec.time = fread(fid,1,'uint32');

    ex1 = fread(fid,1,'uint32');
    ex2 = fread(fid,1,'uint32');
    time(ii+1,1)=trec.time;
    if trec.sync ~= 65535
        disp('sync error at ');
        disp(ii);
        errcount = 1;
        break;
    end;

    dblock  = fread(fid,800,'uint16'); 
    dblock = reshape(dblock,8,100)';
    dout(yidx:yidx+99, 1:8)= dblock;
    yidx = yidx+100;
%
end;
%  now put in the starting time for the file as first time block -1
time1 = time(2,1)-1;
disp('read complete');
if errcount == 0
    data.ch1 = (dout(:,1)/65536)*4.096;
    data.AX = (dout(:,2)/65536)*4.096;
    data.AY = (dout(:,3)/65536)*4.096;
    data.AZ = (dout(:,4)/65536)*4.096;
    data.T1 = (dout(:,5)/65536)*4.096;
    data.T2 = (dout(:,6)/65536)*4.096;
    data.T3 = (dout(:,7)/65536)*4.096;
    data.T4 = (dout(:,8)/65536)*4.096;
    
end;

%  now put the times into structure and convert to matlab times
starttime=(time1)/86400+double(datenum(1970,1,1));
hundredthsecond = 0.01 * 1/86400;  % matlab counts time in days
xtime = (0.0:hundredthsecond:(nseconds-0.01)/86400)';% transpose to make column vector
xtime = xtime + starttime;
% make sure time record is only as long as data
tlen = size(data.ch1,1);
data.time = xtime(1:tlen,1);
fclose(fid);
% % % plot channel 7   You may want to change the channel for other sensors
% % plot(data.time, data.ch7);
% % kdatetick2;
% % xlabel('Collection date and time');
% % ylabel('ADC counts');

end
