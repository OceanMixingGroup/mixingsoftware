% This file reads in the binary chameleon/marlin files and makes 
% matlab variables which can be saved in matlab format.  The three main
% variables are head, data and irep.
%
% Note: to use this as a script, define:
% q_script.prefix as the prefix
% q_script.num as the number (an integer) 
% head.pathname as the pathname
%
% This is an example:
% q_script.prefix='mtest'
% head.pathname='/home/puck/data/marlin/data_test/'
% for i=1:2    
% q_script.num=i
% qv_load
% end
%
% To run qv with a GUI, make sure that no variable q_script exists, and type
% qv

if ~exist('q_script','var')
  [raw_name,head.pathname]=uigetfile('*0.*','Load Binary File');
  if raw_name==0
    error('File not found')
    return
  end
else 
  raw_name=[q_script.prefix sprintf('%5.3f',q_script.num/1000)];
end
fid=fopen([head.pathname raw_name],'r','ieee-le');
F=fread(fid,1,'int32')
head.version=F;
% head.version=qv_space(setstr(F'));
F=fread(fid,16,'char');
head.instrument=qv_space(setstr(F'));
head.baudrate=fread(fid,1,'int32');
head.samplerate=fread(fid,1,'float32');
slow_samp_rate=head.samplerate/32;
head.num_sensors=fread(fid,1,'int16');
% The following loads in all of the sensor calibrations
for i=1:head.num_sensors;
  F=fread(fid,12,'char');
  head.sensor_name(i,:)=qv_space(setstr(F'));
  % Must change all primes "'" to "P" because matlab doesn't like T' 
  % but can deal with TP
  [I,J]=find(head.sensor_name=='''');
  for j=1:length(I)
    head.sensor_name(I(j),J(j))='P';
  end
  [I,J]=find(head.sensor_name=='-');
  for j=1:length(I)
    head.sensor_name(I(j),J(j))='_';
  end
  clear I J j
  F=fread(fid,10,'char');
  head.module_num(i,:)=qv_space(setstr(F'));
  head.filter_freq(i,1)=fread(fid,1,'float32');
  F=fread(fid,4,'int16');
  head.das_channel_num(i,1)=F(1);
  head.offset(i,1)=F(2);
  F(3)=max(1,F(3));
  head.modulas(i,1)=F(3);
  head.num_probes(i,1)=F(4);
  F=fread(fid,12,'char');
  head.sensor_id(i,:)=qv_space(setstr(F'));
  F=fread(fid,5,'float32');
  head.coef(i,:)=F';
end
 F=fread(fid,796-8-14,'char');
  head.saildata=qv_space(setstr(F'));
 F=fread(fid,14,'char');
  head.filename=qv_space(setstr(F'));
 head.startdepth=fread(fid,1,'float32');
 head.enddepth=fread(fid,1,'float32');
 F=fread(fid,78,'char');
 head.comments=qv_space(setstr(F'));
 F=fread(fid,20,'char');
 head.starttime=qv_space(setstr(F'));
 F=fread(fid,20,'char');
 head.endtime=qv_space(setstr(F'));
 Data=fread(fid,[32,inf],'uint16');
 Data=((Data/32768)-1)*4.5;
  fclose(fid);
 % this makes each sensor into a column vector.
for i=1:head.num_sensors
  if head.modulas(i,1)==1
    eval(['data.' deblank(head.sensor_name(i,:)) '(:,1)=Data(' num2str(head.offset(i)+1) ',:)'';']);
  else
    eval(['data.' deblank(head.sensor_name(i,:)) '=reshape(Data(' num2str(head.offset(i)+1) ':'...
	  num2str(floor(32/head.modulas(i,1))) ':32,:),' num2str(length(Data) ...
	  *head.modulas(i,1)) ',1);']);
  end
eval(['irep.' deblank(head.sensor_name(i,:)) '=head.modulas(i,1);'])
eval(['coef.' deblank(head.sensor_name(i,:)) '=head.coef(i,:);'])
end
  clear Data
% now create a calibrated vector for pressure 
% because this will be used for plotting.
% also make a vector which is eight times as long for
% use with irep=8 vectors
if any(strcmp('P',fieldnames(data)))
  p=qv_calp(data.P,head.coef(find(head.sensor_name(:,1)=='P'),:))*0.689476;
  % note that the 0.689476 gives the conversion from psi to db
  p8=interp8(p,8);
% first filter the series, and then differentiate to get fspd in cm/s
  [q.butter(1:3) q.butter(4:6)]=butter(2,.002);
    data.fspd=100*[0 ; diff(filtfilt(q.butter(1:3),q.butter(4:6),(p8)))]*slow_samp_rate*8;
else
  eval(['p=1:length(data.' deblank(head.sensor_name(1,:)) ')/head.modulas(1);'])
  p8=interp8(p,8);
end
if ~exist('q','var')
q.display_series=[2:size(head.sensor_name,1)];
elseif ~any(strcmp(fieldnames(q),'display_series'))
q.display_series=[2:size(head.sensor_name,1)];
end
  q.series=head.sensor_name;
q.nser=size(q.series,1);
eval(['y_axis=(1:(length(data.' deblank(q.series(1,:)) ')/irep.' deblank(q.series(1,:)) '))''/slow_samp_rate;']);
q.yaxis_label='time (sec)';
global mins maxs
mins.y=min(y_axis);
maxs.y=max(y_axis);
y_axis8=interp8(y_axis,8);
last_y=[mins.y maxs.y];
