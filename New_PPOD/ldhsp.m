function [ppod]=ldhsp()
% load a High-speed PPOD data file and convert 1 and 20 hz pressures
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
% Each second of data contains the following:
%   btype           uint32    0xEEEEEEEE for HSP
%   Armtime         uint32  Unix seconds
%   P1HzCycles      uint32  master clock cycles for 1Hz pressure
%   T1HzCycles      uint32  master clock cycles for 1Hz temperature
%   ClockFrequency  uint32  master clock measured frequency
%   P1Hzcount       uint16  input clock counts/64 for pressure
%   T1Hzcount       uint16  input clock counts/1024 for temp
%   axcount         uint16  Accelerometer x counts
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
    ppod.axcount = NaN*ones(1,nseconds);
    ppod.axcount = NaN*ones(1,nseconds);
    
    ppod.clock=NaN*ones(1,nseconds);
    ppod.ppd20=NaN*ones(1,nseconds*20);
    ppod.tpd20=NaN*ones(1,nseconds*20);
    ppod.pr20 = NaN*ones(1,nseconds*20);
    ppod.hcy = NaN*ones(1,nseconds*20);
    ppod.tm20 = NaN*ones(1,nseconds*20);  
    ppod.time20 = NaN*ones(1,nseconds*20);  
    ppod.pr1 = NaN*ones(1,nseconds);
    ppod.tm1 = NaN*ones(1,nseconds);
    hspack = zeros(1,20, 'uint32');
    
    hpdtemp =NaN*ones(1,20);
    hscount = NaN*ones(1,20);
    hscycles = NaN*ones(1,20);


    % now read the data from the file
	for ii=1:nseconds
        btype = fread(fid,1,'uint32=>double');
        Armtime = fread(fid,1,'uint32=>double');
        p1hzcycles = fread(fid,1,'uint32=>double');
        t1hzcycles = fread(fid,1,'uint32=>double');        
        clockcycles = fread(fid,1,'uint32=>double');
        p1hzcount = fread(fid,1,'uint16=>double');
        t1hzcount = fread(fid,1,'uint16=>double');

        axcount = fread(fid,1,'uint16=>double');
        aycount = fread(fid,1,'uint16=>double');
        azcount = fread(fid,1,'uint16=>double');
        dstate = fread(fid,1,'uint16=>double');
        spare = fread(fid,8,'uint16=>double');
        hspack=fread(fid,20,'*uint32');
        
        ppod.clock(ii) = clockcycles;  
        ppod.axcount(ii) = axcount;  
        ppod.aycount(ii) = aycount;  
        ppod.azcount(ii) = azcount;  

        ppod.Armtime(ii)=(Armtime)/86400+double(datenum(1970,1,1));
        ppd = (1.0e6 * p1hzcycles/clockcycles)/(64 *p1hzcount);
        ppod.ppd1(ii) = ppd;

        tpd = (1.0e6 * t1hzcycles/clockcycles)/(1024 *t1hzcount);
        ppod.tpd1(ii) = tpd; 

        % now put the high-speed 20Hz data into the HS pressure period
        % array
        hscount = double(hspack/(2^24))*64;
        hcy = double((bitand(hspack, (2^24-1))));
        hscycles =  double((bitand(hspack, (2^24-1))))./clockcycles;
        hpdtemp = 1.0e6*(hscycles )./ (hscount );
        ppod.ppd20(ii*20-19:ii*20)= hpdtemp(1:20);
        ppod.hcy(ii*20-19:ii*20)= hcy(1:20);
    end % for ii=1:nseconds
    shortpd20 = ppod.ppd20(1:100);
    % next, interpolate the temperature periods to get t periods at 20hz
    k = [1:0.050:nseconds+1-0.050];
    ppod.tpd20 = interp1( ppod.tpd1,k);
    %ppod.tpd20 = interp1( ppod.tpd1,k,'spline');

    ppod.time20 = interp1( ppod.Armtime,k);
    % convert period and temperature into pressures to be passed back
    [ppod.pr1 ppod.tm1] = convert_ppod6(ppheader, ppod.ppd1, ppod.tpd1);
    % now convert the 20 hx data
    [ppod.pr20 ppod.tm20] = convert_ppod6(ppheader, ppod.ppd20, ppod.tpd20);
fclose(fid);
plot(ppod.time20,ppod.pr20, ppod.Armtime,ppod.pr1);
kdatetick;
%datetick('x',15);
toc

% this algorithm takes about 37 seconds
end
