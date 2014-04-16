function [ppod]=fastldhsp1hz()
% load a High-speed PPOD data file and convert only hz pressures
% uses the faster algorithm with fread and skips

[raw_name,temp,filterindex]=uigetfile('*.HSP','Load Binary File');
filnam=[temp raw_name];
disp(sprintf('Reading header from %s',filnam));
fid = fopen(filnam,'r');
% call the pp6header function to decode the header part of file
ppheader=pp6header(fid);
fseek(fid,0,'eof'); % move to end of file
pos2 = ftell(fid); % pos2 is overall length of file
fseek(fid,8192,'bof'); % fseek to just past the header
nseconds=floor((pos2-8192)/128); % number of full 128-byte one second blocks
disp(sprintf('%d seconds of data in the file',nseconds));
tic;
fosc = ppheader.OSFREQ;
headeroffset = 8192;
% Each second of data contains the following:
%   btype           uint32    0xEEEEEEEE for HSP
%   Armtime         uint32  Unix seconds
%   P1HzCycles      uint32  master clock cycles for 1Hz pressure
%   T1HzCycles      uint32  master clock cycles for 1Hz temperature
%   ClockFrequency  uint32  master clock measured frequency
%   P1Hzcount       uint16  input clock counts/64 for pressure
%   T1Hzcount       uint16  input clock counts/1024 for temp
%   axcount         uint16  Accelerometer x counts
%   aycount         uint16  Accelerometer y count
%   azcount         uint16  Accelerometer z count
%   dstate          uint16  collections tate machine state
%   spare[8]        uint16  unsused spare words
%   20 x uint32     40 compressed counts and cycles   
% initialize variables and allocate space at start, so Matlab doesn't waste
% time increasing the array sizes as data is read into arrays
% the ppod structure is built---but then discarded as we save only pressure
	ppod.Armtime=NaN*ones(1,nseconds);
	ppod.ppd1=NaN*ones(1,nseconds);
    ppod.tpd1=NaN*ones(1,nseconds);
    ppod.axcount = NaN*ones(1,nseconds);
    ppod.aycount = NaN*ones(1,nseconds);
    ppod.azcount = NaN*ones(1,nseconds);
    
    ppod.clock=NaN*ones(1,nseconds);
 
    ppod.pr1 = NaN*ones(1,nseconds);
    ppod.tm1 = NaN*ones(1,nseconds);

    dateoffset = double(datenum(1970,1,1));
    % now read the data from the file
    % reset to position of first Armtime
    fseek(fid,headeroffset+4,'bof');
        Armtime = fread(fid,nseconds,'uint32=>double',128-4);
    fseek(fid,headeroffset+8,'bof');
        p1hzcycles = fread(fid,nseconds,'uint32=>double',128-4);
    fseek(fid,headeroffset+12,'bof'); 
        t1hzcycles = fread(fid,nseconds,'uint32=>double',128-4);  
    fseek(fid,headeroffset+16,'bof');  
        ppod.clock = fread(fid,nseconds,'uint32=>double', 128-4);
    fseek(fid,headeroffset+20,'bof');
        p1hzcount = fread(fid,nseconds,'uint16=>double', 128-2);
    fseek(fid,headeroffset+22,'bof');
        t1hzcount = fread(fid,nseconds,'uint16=>double', 128-2);
    fseek(fid,headeroffset+24,'bof');
        ppod.axcount = fread(fid,nseconds,'uint16=>double', 128-2);
    fseek(fid,headeroffset+26,'bof');
        ppod.aycount = fread(fid,nseconds,'uint16=>double', 128-2);
    fseek(fid,headeroffset+28,'bof');
        ppod.azcount = fread(fid,nseconds,'uint16=>double', 128-2);
          
        ppod.Armtime=(Armtime./86400+dateoffset);
        ppd = (1.0e6 .* p1hzcycles./ppod.clock)./(64 .*p1hzcount);
        ppod.ppd1 = ppd;

        tpd = (1.0e6 .* t1hzcycles./ppod.clock)./(1024 .*t1hzcount);
        ppod.tpd1 = tpd; 


   % convert period and temperature into pressures to be passed back
    [ppod.pr1 ppod.tm1] = convert_ppod6(ppheader, ppod.ppd1, ppod.tpd1);

fclose(fid);
plot(ppod.Armtime,ppod.pr1);
kdatetick;
%datetick('x',15);
toc

% this algorithm takes about 37 seconds
end
