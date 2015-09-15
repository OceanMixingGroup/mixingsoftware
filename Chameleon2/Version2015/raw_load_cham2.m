function [data,head]=raw_load(q)

% function [data,head]=raw_load(q)
% function RAW_LOAD reads in the binary chameleon/marlin files and makes 
% matlab variables that can be saved in matlab format.  The three main
% variables are head, data.
%
% RAW_LOAD may be called in three ways:
% [data,head]=raw_load(q); returns data and header info into 
% the variables data and head
%         or the deprecated use:
% global data head q
% raw_load; 
% RAW_LOAD then returns data into the global variables data, head,
% and irep.  Globals can get confusing, so try this has only been
% included for backwards compatability.  
%
% If the structured variable q exists and is global, or if it is sent
% as an argument to RAW_LOAD, then RAW_LOAD works in script mode such
% that:   
% q.script.prefix is the file prefix; 
%   i.e. q.script.prefix = 'hm00';
% q.script.num is the file number (an integer) 
%   i.e. q.script.num = 1540;
% q.script.pathname as the pathname
%   i.e. q.script.pathname = 'c:/rawdata/HOME/marlin/marlin/';
%
% If q is not supplied, then a GUI will query for the file to load.
  
% $Revision: 1.2 $ $Date: 2009/11/13 23:29:01 $ $Author: aperlin $
% Originally J. Nash, July 1998.     
    
if nargin==1
  %  global data head
elseif nargout<2
  % if no output arguments, assume that we want the globalized
  % version.  
  global data head q
else
  q=[];
end 

data=[];
head=[];

if isempty(q);
  [raw_name,temp]=uigetfile('*.*','Load Binary File');
  raw_name=[temp raw_name];
  if raw_name==0
    error('File not found')
    return
  end
  q.script.prefix='fake';
elseif isstr(q)
  raw_name=q;
  q.script.prefix='fake';
else
  if ~ismember(q.script.pathname(end),['/','\']);
    q.script.pathname = [q.script.pathname '/'];
  end;
  raw_name=[q.script.pathname  q.script.prefix sprintf('%5.3f',q.script.num/1000)];
end
% this is just to make some logic below work...

fid=fopen([raw_name],'r','ieee-le');
if fid==-1
  warning([raw_name ...
    ' not found check q.script.pathname, q.script.prefix and q.script.num']);
  data=[];
  return;
  
end

% the first two bytes tell us how many sensors there can be, and
% how many channels there can be...  This is new as of May 2002,
% old files will have maxsensors =50;
F=fread(fid,2,'uchar');
head.maxsensors=F(1);
head.numberchannels=F(2);

F=fread(fid,2,'char');
head.thisfile=raw_name;
head.version=F;

F=fread(fid,16,'char');
head.instrument=space(setstr(F'));
head.baudrate=fread(fid,1,'int32=>double');
head.samplerate=fread(fid,1,'float32=>double');
head.num_sensors=fread(fid,1,'int16=>double');

% The following loads in all of the sensor calibrations
head.sensor_index=[];
for i=1:head.num_sensors;
  F=fread(fid,12,'char');
  temp=space(setstr(F'));, head.sensor_name(i,:)='            ';
  temp2= min(find(temp==32));
  head.sensor_name(i,1:temp2)=temp(1:temp2);
  % Must change all primes "'" to "P" because matlab doesn't like T' 
  % but can deal with TP
  [I,J]=find(head.sensor_name=='''');
  for j=1:length(I)
    head.sensor_name(I(j),J(j))='P';
  end
  % Matlab doesn't like T-1
  [I,J]=find(head.sensor_name=='-');
  for j=1:length(I)
    head.sensor_name(I(j),J(j))='_';
  end
%   [I,J]=find(head.sensor_name(:,1)=='1');
%   for j=1:length(I)
%     head.sensor_name(I(j),J(j))='J';
%   end
  [I,J]=find(head.sensor_name=='/');
  for j=1:length(I)
    head.sensor_name(I(j),J(j))='B';
  end
   [I,J]=find(head.sensor_name=='+');
  for j=1:length(I)
    head.sensor_name(I(j),J(j))='P';
  end
  [I,J]=find(head.sensor_name=='(');
  for j=1:length(I)
    head.sensor_name(I(j),J(j))='_';
  end
  clear I J j
  head.sensor_name(i,:)=upper(head.sensor_name(i,:));
  sensorname=deblank(upper(head.sensor_name(i,:)));  
  head.sensor_index=setfield(head.sensor_index, ...
                             deblank(char(head.sensor_name(i,:))),i);
  F=fread(fid,10,'char');
  head.module_num(i,:)=space(setstr(F'));
  head.filter_freq(i,1)=fread(fid,1,'float32=>double');
  F=fread(fid,4,'int16=>double');
  head.das_channel_num(i,1)=F(1);
  head.offset(i,1)=F(2);
  F(3)=max(1,F(3));
  head.modulas(i,1)=F(3);
  head.num_probes(i,1)=F(4);
  F=fread(fid,12,'char');
  head.sensor_id(i,:)=space(setstr(F'));
  F=fread(fid,5,'float32=>double');
  head.coefficients(i,:)=F';
end

% Figure out the # of channels.  Before May 3rd 2002 we guessed via
% the number of sensors.  After may 3rd it is 2^ the first char in the
% file. 
% channum is used throughout the rest of the program...


if (strcmp(lower(q.script.prefix(1:4)),'yq01') | ...
    strcmp(lower(q.script.prefix(1:4)),'yq02') | ... 
    strcmpi(lower(head.instrument(1:6)),'ukitik'))
  % There was one day, May 2 2002, where neither convention was
  % used...
  head.maxsensors=16;
  head.numberchannels=64;
  channum=64;
elseif head.maxsensors==50
  % Pre 2 May 2002 logic...
  if (head.num_sensors<=16)
    head.maxsensors=16;
    channum=32;
  elseif (head.num_sensors<=32) 
    head.maxsensors=32;
    channum=64;
  else
    head.maxsensors=64;
    channum=256;
  end
  head.numberchannels = channum;
else
  head.numberchannels=2.^head.numberchannels;
  channum=head.numberchannels;
  head.maxsensors = 2.^head.maxsensors;
end;

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
head.filename=space(setstr(F'));
head.startdepth=fread(fid,1,'float32=>double');
head.enddepth=fread(fid,1,'float32=>double');
F=fread(fid,78,'char');
head.comments=space(setstr(F'));
F=fread(fid,20,'char');
head.starttime=space(setstr(F'));
F=fread(fid,20,'char');
head.endtime=space(setstr(F'));
% F = fread(fid,10,'char')
% now read the data...
% F = fread(fid,6,'char');
% head.lat.start = space(setstr(F'));
% 
% F = fread(fid,6,'char');
% head.lon.start = space(setstr(F'));
% 
% F = fread(fid,6,'char');
% head.lat.end = space(setstr(F'));
% 
% F = fread(fid,6,'char');
% head.lon.end = space(setstr(F'));

Data=fread(fid,[channum,inf],'uint16=>double');
fclose(fid);

% Convert counts to volts...
voltrange = 5.0;
Data=((Data/32768)-1)*voltrange;

% Makes data for each sensor into column vectors.
head.irep=[];head.coef=[];
for i=1:head.num_sensors
  fieldname=deblank(upper(head.sensor_name(i,:)));
  % each channel is a row of Data.  Each sensor can have data from
  % more than one channel, the number is given by
  % channum/head.modulas(i);   
  ind = head.offset(i)+1:floor(channum/head.modulas(i,1)):channum;
 
  dat = Data(ind,:);
  
  dat=dat(:);
  head.irep=setfield(head.irep,fieldname,head.modulas(i,1));
  data = setfield(data,fieldname,dat);
 
  head.coef=setfield(head.coef,fieldname,head.coefficients(i,:));
end

data = rmfield(data,'NONE'); %removes the unused channels
% data.NONE = data.P*0;
% data.GND = data.P*0;
data = rmfield(data,'GND'); %removes the unused channels
return;

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
return;
%%%%% Done with saildata %%%%%%%%%%%%%%%%%%%

