function [data,head]=mg_raw_load(q)
% function MG_RAW_LOAD reads in the binary chameleon/marlin files and makes 
% matlab variables which can be saved in matlab format.  The three main
% variables are head, data.
%
% [data,head]=mg_raw_load(q); returns data and header info into 
%
% q.script.prefix is the file prefix
% q.script.num is the file number (an integer) 
% q.script.pathname as the pathname
%
% i.e. 
% q.script.pathname='c:/rawdata/Home/Marlin/Marlin/'
% q.script.prefix='hm00'
% q.script.num=200;
% [data,head]=mg_raw_load(q)
%
% loads the raw data from c:/rawdata/home/marlin/marlin/hm000.200.
    
% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:47 $ $Author: aperlin $



if isempty(q);
  [raw_name,temp]=uigetfile('*.*','Load Binary File');
  head.pathname=temp;
  if raw_name==0
    error('File not found')
    return
  end
else 
  raw_name=[q.script.prefix sprintf('%5.3f',q.script.num/1000)];
  head.pathname=q.script.pathname;
end

fid=fopen([head.pathname raw_name],'r','ieee-le');
if fid==-1
  disp(['ERROR: ' head.pathname raw_name ' not found']) 
  error('check q.script.pathname, q.script.prefix and q.script.num')
end
F=fread(fid,1,'int32');
head.thisfile=raw_name;
head.version=F;
% head.version=space(setstr(F'));
F=fread(fid,16,'char');
head.instrument=space(setstr(F'));
head.baudrate=fread(fid,1,'int32');
head.samplerate=fread(fid,1,'float32');
head.num_sensors=fread(fid,1,'int16');
% The following loads in all of the sensor calibrations
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
  [I,J]=find(head.sensor_name=='-');
  for j=1:length(I)
    head.sensor_name(I(j),J(j))='_';
  end
  [I,J]=find(head.sensor_name(:,1)=='1');
  for j=1:length(I)
    head.sensor_name(I(j),J(j))='J';
  end
  [I,J]=find(head.sensor_name=='/');
  for j=1:length(I)
    head.sensor_name(I(j),J(j))='B';
  end
   [I,J]=find(head.sensor_name=='+');
  for j=1:length(I)
    head.sensor_name(I(j),J(j))='P';
  end
  clear I J j
  eval(['head.sensor_index.' deblank(upper(head.sensor_name(i,:))) '=i;'])
  F=fread(fid,10,'char');
  head.module_num(i,:)=space(setstr(F'));
  head.filter_freq(i,1)=fread(fid,1,'float32');
  F=fread(fid,4,'int16');
  head.das_channel_num(i,1)=F(1);
  head.offset(i,1)=F(2);
  F(3)=max(1,F(3));
  head.modulas(i,1)=F(3);
  head.num_probes(i,1)=F(4);
  F=fread(fid,12,'char');
  head.sensor_id(i,:)=space(setstr(F'));
  F=fread(fid,5,'float32');
  head.coefficients(i,:)=F';
end
if (head.num_sensors-32)
   F=fread(fid,66*16-66*(head.num_sensors),'char');
   F=fread(fid,1830-66*16,'char');
   channum=32;
else
  F=fread(fid,774,'char');
  channum=64;
end
slow_samp_rate=head.samplerate/channum;
head.slow_samp_rate=head.samplerate/channum;
head.saildata=space(setstr(F'));

%Bill
% parse out GPS data
sail1=head.saildata(1:35);
% in general, the GGA string is not necessarily fixed length. 
pos = find(sail1==',');
if ~isempty(pos)
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
if ~isempty(pos)
  head.time.end=sail1(1:pos(1)-1);
  if length(head.time.end)<9
    head.time.end = [head.time.end '.000'];
  end;
  head.lat.end=sail1(pos(1)+1:pos(2)-1);
  head.lon.end=sail1(pos(3)+1:pos(4)-1);
else
  head.time.end='';
  head.lat.end='';
  head.lon.end='';
end;
  
% head.time.start=head.saildata(1:10);
% head.lat.start=head.saildata(12:22);
% head.lon.start=head.saildata(24:35);
% head.time.end=head.saildata(37:46);
% head.lat.end=head.saildata(48:58);
% head.lon.end=head.saildata(60:71);
%%

F=fread(fid,14,'char');
head.filename=space(setstr(F'));
head.startdepth=fread(fid,1,'float32');
head.enddepth=fread(fid,1,'float32');
F=fread(fid,78,'char');
head.comments=space(setstr(F'));
F=fread(fid,20,'char');
head.starttime=space(setstr(F'));
F=fread(fid,20,'char');
head.endtime=space(setstr(F'));
Data=fread(fid,[channum,inf],'uint16');
if strcmp(lower(head.instrument(1:3)),'mar') & head.num_sensors-32
   Data=((Data/32768)-1)*5;
else
   Data=((Data/32768)-1)*4.5;
end
fclose(fid);
% this makes each sensor into a column vector.
for i=1:head.num_sensors
  if head.modulas(i,1)==1
    eval(['data.' upper(deblank(head.sensor_name(i,:))) '(:,1)=Data(' num2str(head.offset(i)+1) ',:)'';']);
  else
    eval(['data.' upper(deblank(head.sensor_name(i,:))) '=reshape(Data(' num2str(head.offset(i)+1) ':'...
	  num2str(floor(channum/head.modulas(i,1))) ':channum,:),' num2str(length(Data) ...
	  *head.modulas(i,1)) ',1);']);
  end
  eval(['head.irep.' upper(deblank(head.sensor_name(i,:))) '=head.modulas(i,1);'])
  eval(['head.coef.' upper(deblank(head.sensor_name(i,:))) '=head.coefficients(i,:);'])
end

if 0
  test=abs(data.SYNC)<.1 | abs(data.SYNC-4.5)<.1;
  d=diff(data.SYNC);
  d=[d ; -d(end)];
  test=test & abs(d)>1;
  %test=1;
  if any(test==0)
    mm=min(find(test==0))-1;
    data.P(mm*head.irep.P+1:end)=[];
    data.S1(mm*head.irep.S1+1:end)=[];
    data.S2(mm*head.irep.S2+1:end)=[];
    data.W(mm*head.irep.W+1:end)=[];
    data.T(mm*head.irep.T+1:end)=[];
    data.TP(mm*head.irep.TP+1:end)=[];
    data.C(mm*head.irep.C+1:end)=[];
    data.AX(mm*head.irep.AX+1:end)=[];
    data.AY(mm*head.irep.AY+1:end)=[];
    data.AZ(mm*head.irep.AZ+1:end)=[];
    data.SCAT(mm*head.irep.SCAT+1:end)=[];
    data.SYNC(mm*head.irep.SYNC+1:end)=[];
  end
end;

% disp(['pressure length = ' num2str(length(data.P))]);
clear Data F fid i raw_name channum temp temp2
