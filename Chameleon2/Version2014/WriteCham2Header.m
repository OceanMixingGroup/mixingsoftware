function WriteCham2Header( fid, head)
% WriteCham2Header writes out the Matlab header structure as a binary
% file with a total length of 2000 bytes.
%   The function accepts a file id and  the header data structure
%   the corresponding fread commands are left as comments

% the first two bytes tell us how many sensors there can be, and
% how many channels there can be...  This is new as of May 2002,
% old files will have maxsensors =50;
%fid=fopen(fname,'r','ieee-le');
%F=fread(fid,2,'uchar');
%head.maxsensors=F(1);
%head.numberchannels=F(2);
% for some unknown reason, the maxsensors and numberchannels
% values were stored as log2(n)
% we'll force the values to 4 and 5 for now (for 16 and 32, respectively)
fwrite(fid,4, 'uchar');
fwrite(fid,5, 'uchar');

%F=fread(fid,2,'char');
%head.thisfile=fname;
%head.version=F;
fwrite(fid, head.version,'uchar');

%F=fread(fid,16,'char');
%head.instrument=space(setstr(F'));
fwrite(fid, head.instrument,'char');

%head.baudrate=fread(fid,1,'int32=>double');
fwrite(fid,head.baudrate, 'int32');
%head.samplerate=fread(fid,1,'float32=>double');
fwrite(fid, head.samplerate, 'float32');

%head.num_sensors=fread(fid,1,'int16=>double');
fwrite(fid,head.num_sensors,'int16');
% note that the num_sensors can be less than the max (usually 16) if
% not all sensor slots are equipped with sensors
% The following loads in all of the sensor calibrations
%head.sensor_index=[];
for ii=1:head.num_sensors;
  %sensorname=fread(fid,12,'char=>char');
  fwrite(fid,head.sensor_name(ii,1:12), 'char');
  % do all the required character substitutions
 % sensorname = AdjustNames(sensorname);

  %head.sensor_name(ii,1:12)=char(sensorname(1:12));  
 % head.sensor_index=setfield(head.sensor_index, deblank(char(sensorname(:))),ii);
 % F=fread(fid,10,'char');
  fwrite(fid,head.module_num(ii,:),'char');
  %head.module_num(ii,:)=space(setstr(F'));
  %head.filter_freq(ii,1)=fread(fid,1,'float32=>double');
  fwrite(fid,head.filter_freq(ii,1),'float32');
  %F=fread(fid,4,'int16=>double');
  %head.das_channel_num(ii,1)=F(1);
  fwrite(fid,head.das_channel_num(ii,1),'int16');
  %head.offset(ii,1)=F(2);
  fwrite(fid,head.offset(ii,1),'int16');
  %F(3)=max(1,F(3));
  %head.modulas(ii,1)=F(3);
  fwrite(fid,head.modulas(ii,1),'int16');
  %head.num_probes(ii,1)=F(4);
  fwrite(fid,head.num_probes(ii,1),'int16');
  % F=fread(fid,12,'char');
  %head.sensor_id(ii,:)=space(setstr(F'));
  fwrite(fid,head.sensor_id(ii,:),'char');
  %F=fread(fid,5,'float32=>double');
  %head.coefficients(ii,:)=F';
  fwrite(fid,head.coefficients(ii,:),'float32');
end

% the new program handles only files generated since 2010
% and does not try to cope with all the earlier variants
% channum is used throughout the rest of the program...

% the new number of channels and maxsensors are calculated as 2^n
%  head.numberchannels=2.^head.numberchannels;
  channum=head.numberchannels;
%  head.maxsensors = 2.^head.maxsensors;

% There is maxsensors of space in the file, but have only read in
% num_sensors of info so lets read in the rest....
%F=fread(fid,66*(head.maxsensors-head.num_sensors),'char');
if(head.maxsensors-head.num_sensors > 0)
    fwrite(fid, 66*(head.maxsensors-head.num_sensors),'char');
end;
% calculate the sample rates....
%slow_samp_rate=head.samplerate/channum;
%head.slow_samp_rate=head.samplerate/channum;

% read the saildata....
%F=fread(fid,774,'char');
fwrite(fid, head.saildata(1:774),'char');
% head = Getsaildata(head,F);  
% this is a local function, defined below...

%F=fread(fid,14,'char');
%head.filename=space(setstr(F'));
fwrite(fid, head.filename(1:14),'char');
%head.startdepth=fread(fid,1,'float32=>double');
fwrite(fid, head.startdepth,'float32');
%head.enddepth=fread(fid,1,'float32=>double');
fwrite(fid, head.enddepth, 'float32');
%F=fread(fid,78,'char');
fwrite(fid, head.comments, 'char');
%head.comments=space(setstr(F'));
%F=fread(fid,20,'char');
% head.starttime=head.starttime;

fwrite(fid,head.starttime(1:20),'char');
%F=fread(fid,20,'char');
% head.endtime=head.endtime;

fwrite(fid,head.endtime(1:20),'char');
% fwrite(fid,head.lat.start(1:6),'char');
% fwrite(fid,head.lon.start(1:6),'char');
% fwrite(fid,head.lat.end(1:6),'char');
% fwrite(fid.head.lon.end(1:6),'char');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function head = Getsaildata(head,F);
head.saildata=space(setstr(F'));
% parse out GPS data
sail1=head.saildata(1:35);
% in general, the GGA string is not necessarily fixed length. 
pos = find(sail1==',');
if length(pos)>=4
  head.time.start=sail1(1:pos(1)-1);
  if length(head.time.start)<9
    head.time.start = [head.time.start '.000'];
  end;
  head.lat.start=sail1(pos(1)+1:pos(2)-1);
  head.lon.start=sail1(pos(3)+1:pos(4)-1);
else
  head.time.start='';
  head.lat.start='';
  head.lon.start='';
end;

sail2=head.saildata(37:end-1);
pos = find(sail2==',');
if length(pos)>=4
  head.time.end=sail2(1:pos(1)-1);
  if length(head.time.end)<9
    head.time.end = [head.time.end '.000'];
  end;
  head.lat.end=sail2(pos(1)+1:pos(2)-1);
  head.lon.end=sail2(pos(3)+1:pos(4)-1);
else  head.time.end='';
  head.lat.end='';
  head.lon.end='';
end;
end
%%%%% Done with saildata %%%%%%%%%%%%%%%%%%%

