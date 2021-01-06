function head = ReadCham2Header( fname )
% ReadCham2Header is a function to read and interpret a chameleon
% Header from a file
%   The function accepts a file name and returns the header data structure

% the first two bytes tell us how many sensors there can be, and
% how many channels there can be...  This is new as of May 2002,
% old files will have maxsensors =50;
fid=fopen(fname,'r','ieee-le');
F=fread(fid,2,'uchar');
head.maxsensors=F(1);
head.numberchannels=F(2);

F=fread(fid,2,'char');
head.thisfile=fname;
head.version=F;

F=fread(fid,16,'char');
head.instrument=space(char(F'));
head.baudrate=fread(fid,1,'int32=>double');
head.samplerate=fread(fid,1,'float32=>double');
head.num_sensors=fread(fid,1,'int16=>double');
% note that the num_sensors can be less than the max (usually 16) if
% not all sensor slots are equipped with sensors
% The following loads in all of the sensor calibrations
% sensor_id = {'none','13-14C','04-04','13-14C','432','none','525','92-47','66','0404','0404','0404','08-01','0404','none','none'};
head.sensor_index = [];
head.sensor_id=char(zeros(16,12));
for ii=1:head.num_sensors
  sensorname=fread(fid,12,'char=>char');
  
  % do all the required character substitutions
  sensorname = AdjustNames(sensorname);

  head.sensor_name(ii,1:12)=char(sensorname(1:12)); 
  currentName =  regexprep(char(sensorname(:)'),'[^\w'']','')';
  %regexprep removes whitespaces and punctutation from a char array.
  %deblank function does not seem to work in 2016 matlab. pvutukur
  %04/20/2017
  
  head.sensor_index.(currentName) = ii;
  %dynamic field assignment "setfield" has become outdated pvutukur
  %04/20/17
 %   head.sensor_index=setfield(head.sensor_index, deblank(char(sensorname(:))),ii);
  clear currentName;
 F=fread(fid,10,'char');
%   head.module_num(ii,:)=space(char(F'));
  head.module_num(ii,:)=space(char(F'));
  head.filter_freq(ii,1)=fread(fid,1,'float32=>double');
  F=fread(fid,4,'int16=>double');
  head.das_channel_num(ii,1)=F(1);
  head.offset(ii,1)=F(2);
  F(3)=max(1,F(3));
  head.modulas(ii,1)=F(3);
  head.num_probes(ii,1)=F(4);
  F=fread(fid,12,'char');
%   head.sensor_id(ii,:)=space(char(F'));
head.sensor_id(ii,:)=space(char(F'));
% head.sensor_id(ii,1:numel(sensor_id{:,ii})) = sensor_id{:,ii};
  F=fread(fid,5,'float32=>double');
  head.coefficients(ii,:)=F';
end

% the new program handles only files generated since 2010
% and does not try to cope with all the earlier variants
% channum is used throughout the rest of the program...

% the new number of channels and maxsensors are calculated as 2^n
  head.numberchannels=2.^head.numberchannels;
  channum=head.numberchannels;
  head.maxsensors = 2.^head.maxsensors;

% There is maxsensors of space in the file, but have only read in
% num_sensors of info so lets read in the rest....
F=fread(fid,66*(head.maxsensors-head.num_sensors),'char');

% calculate the sample rates....
slow_samp_rate=head.samplerate/channum;
head.slow_samp_rate=head.samplerate/channum;

% read the saildata....
F=fread(fid,774,'char');
head = Getsaildata(head,F);  
% this is a local function, defined below...

F=fread(fid,14,'char');
head.filename=space(char(F'));
head.startdepth=fread(fid,1,'float32=>double');
head.enddepth=fread(fid,1,'float32=>double');
F=fread(fid,78,'char');
head.comments=space(char(F'));
F=fread(fid,20,'char');
head.starttime=space(char(F'));
F=fread(fid,20,'char');
head.endtime=space(char(F'));

end

function goodnames = AdjustNames(names)
  % Must change all primes "'" to "P" because matlab doesn't like T' 
  % but can deal with TP, etc, etc.
  names = SubChar(names, '''','P');
  names = SubChar(names, '-','_');
%   names = SubChar(names, '1','J');
  names = SubChar(names, '/','B');
  names = SubChar(names, '+','P');
  names = SubChar(names, '(','_');
  names = SubChar(names, 0,' ');

  names=upper(names);
  goodnames = names;
end

function newnames = SubChar(names, inchar, newchar);
% do a character substitution in instrument names
for ii = 1:length(names)
    if names(ii)==inchar
        names(ii)=newchar;
    end
end

newnames = names;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function head = Getsaildata(head,F);
head.saildata=space(char(F'));
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

sail1=head.saildata(37:end-1);
pos = find(sail1==',');
if length(pos)>=4
  head.time.end=sail1(1:pos(1)-1);
  if length(head.time.end)<9
    head.time.end = [head.time.end '.000'];
  end;
  head.lat.end=sail1(pos(1)+1:pos(2)-1);
  head.lon.end=sail1(pos(3)+1:pos(4)-1);
else  head.time.end='';
  head.lat.end='';
  head.lon.end='';
end;
end
%%%%% Done with saildata %%%%%%%%%%%%%%%%%%%

