clc
close all
clear all
% fname = 'C:\Users\mixing\Documents\chameleon2_test\chamviewpavan\dn11a0.001';
hname = 'C:\Users\mixing\Documents\chameleon2_test\chamviewpavan\cham2_0404.hdr';
chname = 'C:\Users\mixing\Documents\chameleon2_test\chamviewpavan\data\cham2_131218_161424.dat';
ch_raw = 'C:\Users\mixing\Documents\chameleon2_test\chamviewpavan\data\cham_SCAT_whnoise_1.dat';
rawfileid = fopen(hname,'r','ieee-le');
% headerid = fopen(fname,'r','ieee-le');
dataid = fopen(chname,'r','ieee-le');
chamid = fopen(ch_raw,'a+','ieee-le');
rawheader = fread(rawfileid,8192,'uint8=>uint8');
rawdata = fread(dataid,'uint16=>uint16');

% fwrite(rawfileid, rawheader, 'uint8');
fwrite(chamid,rawheader,'uint8');
fwrite(chamid,rawdata,'uint16');

% t_begin = now;



% F=fread(fid,2,'uchar');
% head.maxsensors=F(1);
% head.numberchannels=F(2);
% 
% F=fread(fid,2,'char');
% head.thisfile=fname;
% head.version=F;
% 
% F=fread(fid,16,'char');
% head.instrument=space(setstr(F'));
% head.baudrate=fread(fid,1,'int32=>double');
% head.samplerate=fread(fid,1,'float32=>double');
% head.num_sensors=fread(fid,1,'int16=>double');
% % note that the num_sensors can be less than the max (usually 16) if
% % not all sensor slots are equipped with sensors
% % The following loads in all of the sensor calibrations
% head.sensor_index=[];