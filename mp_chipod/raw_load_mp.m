function mp=raw_load_mp(fname)
% function mp=raw_load_mp(fname)
% example: mp=raw_load_ppod('\\mserver\data2\ttp09b\data\MP\file1.dat')
% read MP data structure
% and converts to mat format
% fname is a raw file name to read
% $Revision: 1.2 $ $Date: 2010/09/13 17:30:31 $ $Author: aperlin $	 
%% Read data
% display(fname)
if nargin<1
    [raw_name,temp]=uigetfile('*.*','Load Binary File');
    fname=[temp raw_name];
    if raw_name==0
        error('File not found')
        return
    end
end
fid = fopen(fname,'r');
if fid<=0
    display('Can''t find the data file...')
    return
end
epoch=datenum(1970,1,1);% reference time
% preallocate array
d=dir(fname);
nentries=floor(d.bytes/38); % 38 bytes per one entry
fields1={'T1','T1P','T2','T2P','AX','AY','AZ','count'};
fields2={'T1','T1P','T2','T2P','R1','R2','R3','count'};
mp.time=NaN*ones(1,nentries);
for ii=1:length(fields1)
    mp.top.(char(fields1(ii)))=NaN*ones(1,nentries);
    mp.bottom.(char(fields2(ii)))=NaN*ones(1,nentries);
end
% read the data
for jj=1:nentries
    unixtime=fread(fid,1,'uint32=>double');
    tick=fread(fid,1,'uint16=>double');
    mp.time(jj)=(unixtime+tick/120);
    data=fread(fid,16,'uint16=>double');
    for ii=1:length(fields1)
        mp.top.(char(fields1(ii)))(jj)=data(ii);
        mp.bottom.(char(fields2(ii)))(jj)=data(ii+length(fields1));
    end
end
%% Convert data to matlab time and Volts
% time is saved in seconds since January 1st 1970
mp.time=mp.time/86400+epoch;
% Conversion from counts to Volts
for ii=1:length(fields1)-1
    mp.top.(char(fields1(ii)))=mp.top.(char(fields1(ii)))/16000;% 65536/4.096=16000
    mp.bottom.(char(fields2(ii)))=mp.bottom.(char(fields2(ii)))/16000;
end
fclose(fid);
