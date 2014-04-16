function [pr1 pr40]=ldconvpp6()
% load a ppod6 data file and convert 1 and 40 hz pressures
coder.extrinsic('uigetfile', 'sprintf', 'disp','fopen','fclose','textscan');
[raw_name,temp,filterindex]=uigetfile('*.*','Load Binary File');
filnam=[temp raw_name];
disp(sprintf('Reading header from %s',raw_name));
fid = fopen(filnam,'r');
% call the pp6header function to decode the header part of file
ppheader=pp6header(fid);
fseek(fid,0,'eof'); % move to end of file
pos2 = ftell(fid); % pos2 is overall length of file
fseek(fid,8192,'bof'); % fseek to just past the header
nseconds=floor((pos2-8192)/116); % number of full 116-byte one second blocks
disp(sprintf('%d seconds of data in the file',nseconds));
fosc = ppheader.OSFREQ;
% Each second of data contains the following:
%   btype	uint32    
%   msptime	uint32  Unix seconds
%   dstime	uint32  Unix seconds
%   spare	uint32  used for total bytes written
%   bdtemp	float32 board temperature in deg C
%   countoffset  uint32  Offset to add to high speed counts
%   syncint	uint16  number of high-speed samples in second (40)
%   dstate  uint16  data state machine index
%   ppd     float32 pressure period for 1Hz data
%   tpd     float32 temperature period for 1Hz data
%   40 x uint16   40 compressed counts (counts - 140,000)    
% initialize variables and allocate space at start, so Matlab doesn't waste
% time increasing the array sizes as data is read into arrays
% the ppod structure is built---but then discarded as we save only pressure
	ppod.p_us=NaN*ones(1,nseconds);
	ppod.t_us=NaN*ones(1,nseconds);
	ppod.msptime=NaN*ones(1,nseconds);
	ppod.ds=NaN*ones(1,nseconds);
	ppod.msp=NaN*ones(1,nseconds);
    ppod.pr1 = NaN*ones(1,nseconds);
	ppod.boardtemp=NaN*ones(1,nseconds);
    ppod.hsppd=NaN*ones(1,nseconds*40);
    ppod.hstpd=NaN*ones(1,nseconds*40);
    ppod.time40=NaN*ones(1,nseconds*40); 
    ppod.pr40=NaN*ones(1,nseconds*40); 
    htemp =NaN*ones(1,nseconds*40);
    hstemp=NaN*ones(1,40); 
    countoffset = 140000;
    % now read the data from the file
	for ii=1:nseconds
        btype = fread(fid,1,'uint32=>double');
        msptime = fread(fid,1,'uint32=>double');
        dstime = fread(fid,1,'uint32=>double');
        spare = fread(fid,1,'uint32=>double');
        bdtemp = fread(fid,1,'float32=>double');
        dummy = fread(fid,1,'uint32=>double');
        syncint = fread(fid,1,'uint16=>double');
        dstate = fread(fid,1,'uint16=>double');
        ppd= fread(fid,1,'float32=>double');
        tpd= fread(fid,1,'float32=>double'); 
        hstemp=fread(fid,40,'uint16=>double');
        hstemp = 140000 + hstemp;
        ppod.ds(ii)=dstime;
        ppod.boardtemp(ii)=bdtemp;        
        ppod.msptime(ii)=(msptime)/86400+double(datenum(1970,1,1));
        ppod.p_us(ii) = ppd(1);
        ppod.t_us(ii) = tpd(1);
        % now put the high-speed 40Hz data into the HS pressure period
        % array
        
        ppod.hsppd(ii*40-39:ii*40)= 1000000*(hstemp(1:40)./fosc)/704.0;
    end % for ii=1:nseconds
    % next, interpolate the temperature periods to get t periods at 40hz
    k = [1:0.025:nseconds+1-0.025];
    ppod.hstpd = interp1( ppod.t_us,k,'spline');
    ppod.time40 = interp1( ppod.msptime,k);
    % convert period and temperature into pressures to be passed back
    [ppod.pr1 ppod.boardtemp] = convert_ppod6(ppheader, ppod.p_us, ppod.t_us);
    % now convert the 40 hx data
    [ppod.pr40 htemp] = convert_ppod6(ppheader, ppod.hsppd, ppod.hstpd);
fclose(fid);
pr1 = ppod.pr1;
pr40 = ppod.pr40;
plot(ppod.time40,ppod.pr40, ppod.msptime,ppod.pr1);
datetick('x',15);

end
