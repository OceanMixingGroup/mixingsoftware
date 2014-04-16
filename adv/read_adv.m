function [adv,varargout]=read_adv(fname,varargin);
% function adv=read_adv(fname,samplerate,year);
% default value for samplerate is 9.96
% default value for year is 1;
% This reads ADV data.  
% Strips data off front and end if it is bad....

% $Date: 2008/01/31 20:22:41 $ $Revision: 1.1.1.1 $ $Author: aperlin $ 


fid=fopen(fname);
dat = fread(fid,500,'uchar');
fclose(fid);

% remove the first 40 samples...
dat = dat(41:end);

id = [129 131 133 135 143];
nbytes = [18 24 22 28 32];
% start with type 1: 
idd=129;
nb=18;
for i=1:length(id)
  in{i} = find(dat(1:end-1)==id(i) & dat(2:end)==nbytes(i));
  if length(in{i})>0; idd=id(i); end
end;
[adv,varargout]=read_adv1(fname,idd,varargin{:});
% if length(in{1})>length(in{2})
%   [adv,varargout]=read_adv1(fname,varargin{:});
% else
%   [adv,varargout]=read_adv2(fname,varargin{:});
% end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [adv,startloc]=read_adv1(fname,idd,samplerate,year);
% function adv=read_adv(fname,samplerate);
% This reads ADV data.  
% Strips data off front and end if it is bad....

% $Date: 2008/01/31 20:22:41 $ $Revision: 1.1.1.1 $ $Author: aperlin $ 

if nargin<3
  samplerate=[];
end;
if nargin<4
    year=1;
end
if isempty(samplerate)
%   samplerate=9.96;
  samplerate=10;
end;
switch idd
    case 129
        nb=18;
    case 131
        nb=24;
    case 133
        nb=22;
    case 135
        nb=28;
    case 143
        nb=32;
end
adv=[];

fid=fopen(fname);
if fid<1
  adv=[];
  warning(sprintf('ADV file %s not found',fname));
  return;
end;

dat = fread(fid,Inf,'uchar');
% partial data structures are possible - look for the first three
% occurences of the start character: idd...
in = find(dat(1:end-1)==idd & dat(2:end)==nb);
if length(in)<3
  adv=[];
  startloc=[];
  disp(['Had an error in file ' fname])
  return;
end;

in(1:3);
% can't be in the first 20 because that is a time stamp...
ind=1;
if length(in)>3
  while (~(in(ind)-in(ind+1)==-nb & in(ind)-in(ind+2)==-nb*2) & ...
         (ind+3<=length(in)));
    ind = ind+1;
  end;
end;
startloc = in(ind)


filelen = length(dat);
fseek(fid,0,'eof');
pos = ftell(fid);

epoch=datenum(1970,1,1);%reference time - times written in seconds since epoch

fseek(fid,startloc-1,'bof');
% preallocate....
reclen = nb;
% Nall = ceil((pos-20)/18);
% length of the header is 40 bytes, not 20
Nall = ceil((pos-40)/reclen);
adv.id=NaN*ones(1,Nall);
adv.time=NaN*ones(1,Nall);
adv.numbytes=NaN*ones(1,Nall);
adv.samplenum=NaN*ones(1,Nall);
adv.vel=NaN*ones(3,Nall);
adv.amp=NaN*ones(3,Nall);
adv.cm=NaN*ones(3,Nall);
adv.checksum=NaN*ones(1,Nall);
switch idd
    case 131
        adv.heading=NaN*ones(1,Nall);
        adv.pitch=NaN*ones(1,Nall);
        adv.roll=NaN*ones(1,Nall);
    case 133
        adv.temp=NaN*ones(1,Nall);
        adv.press=NaN*ones(1,Nall);
    case 135
        adv.heading=NaN*ones(1,Nall);
        adv.pitch=NaN*ones(1,Nall);
        adv.roll=NaN*ones(1,Nall);
        adv.temp=NaN*ones(1,Nall);
        adv.press=NaN*ones(1,Nall);
    case 143
        adv.heading=NaN*ones(1,Nall);
        adv.pitch=NaN*ones(1,Nall);
        adv.roll=NaN*ones(1,Nall);
        adv.temp=NaN*ones(1,Nall);
        adv.press=NaN*ones(1,Nall);
        adv.ext1=NaN*ones(1,Nall);
        adv.ext2=NaN*ones(1,Nall);
end

datalen = nb; 
fseek(fid,0,'bof');

% read the time stamp;
junk1=char((fread(fid,4))');
if junk1(1:4)=='Time'
    adv.starttime=[junk1 char((fread(fid,16))')];
    hr=str2num(adv.starttime(6:7));
    mn=str2num(adv.starttime(9:10));
    sc=str2num(adv.starttime(12:13));
    adv.endtime=char((fread(fid,20))');
elseif junk1(1:4)=='Unix'
    junk2=char((fread(fid,4))');
    starttime=fread(fid,1,'uint32','b')/3600/24+epoch;
    adv.starttime=datestr(starttime,0);
    endtime=starttime+length(in)/samplerate/3600/24;
    adv.endtime=datestr(endtime,0);
    junk3=fread(fid,28);
end
disp(adv.starttime)
disp(adv.endtime)

ftell(fid);
clear ii
ii=0;
fseek(fid,startloc-1,'bof');

while (ftell(fid)+datalen)<=filelen;
  
  ii = ii + 1;
  %   disp(ii)
  if ii==1
      if junk1(1:4)=='Time'
          adv.time(ii)=datenum(year,1,0,hr,mn,sc)+str2num(adv.starttime(15:17));
      elseif junk1(1:4)=='Unix'
          adv.time(ii)=starttime;
      end
  else
    adv.time(ii)=adv.time(ii-1)+1/samplerate/60/60/24;
  end
  adv.id(ii)=fread(fid,1,'uchar');
  adv.numbytes(ii)=fread(fid,1,'uchar');
  while ~(adv.id(ii)==idd & adv.numbytes(ii)==nb)
    in = find(dat(1:end-nb-1)==idd & dat(2:end-nb)==nb & dat(nb+1:end-1)==idd & dat(nb+2:end)==nb);
    pos=ftell(fid);
    % warning(sprintf('Could not find header at %d\n',pos));
    good = find(in>pos);
    if ~isempty(good)
      fseek(fid,in(good(1))-1,'bof');
      adv.id(ii)=fread(fid,1,'uchar');
      adv.id(ii);
      adv.numbytes(ii)=fread(fid,1,'uchar');
    else
      fclose(fid);
      return;
    end;
  end;
  switch idd
      case 129
          adv.samplenum(ii)=fread(fid,1,'uint16');
          adv.vel(1:3,ii)=fread(fid,[3 1],'int16');
          adv.amp(1:3,ii)=fread(fid,[3 1],'uchar');
          adv.cm(1:3,ii)=fread(fid,[3 1],'uchar');
          adv.checksum(ii)=fread(fid,1,'uint16');
      case 131
          adv.samplenum(ii)=fread(fid,1,'uint16');
          adv.vel(1:3,ii)=fread(fid,[3 1],'int16');
          adv.amp(1:3,ii)=fread(fid,[3 1],'uchar');
          adv.cm(1:3,ii)=fread(fid,[3 1],'uchar');
          adv.heading(ii)=fread(fid,1,'int16');
          adv.pitch(ii)=fread(fid,1,'int16');
          adv.roll(ii)=fread(fid,1,'int16');
          adv.checksum(ii)=fread(fid,1,'uint16');
      case 133
          adv.samplenum(ii)=fread(fid,1,'uint16');
          adv.vel(1:3,ii)=fread(fid,[3 1],'int16');
          adv.amp(1:3,ii)=fread(fid,[3 1],'uchar');
          adv.cm(1:3,ii)=fread(fid,[3 1],'uchar');
          adv.temp(ii)=fread(fid,1,'int16');
          adv.press(ii)=fread(fid,1,'uint16');
          adv.checksum(ii)=fread(fid,1,'uint16');
      case 135
          adv.samplenum(ii)=fread(fid,1,'uint16');
          adv.vel(1:3,ii)=fread(fid,[3 1],'int16');
          adv.amp(1:3,ii)=fread(fid,[3 1],'uchar');
          adv.cm(1:3,ii)=fread(fid,[3 1],'uchar');
          adv.heading(ii)=fread(fid,1,'int16');
          adv.pitch(ii)=fread(fid,1,'int16');
          adv.roll(ii)=fread(fid,1,'int16');
          adv.temp(ii)=fread(fid,1,'int16');
          adv.press(ii)=fread(fid,1,'uint16');
          adv.checksum(ii)=fread(fid,1,'uint16');
      case 143
          adv.samplenum(ii)=fread(fid,1,'uint16');
          adv.vel(1:3,ii)=fread(fid,[3 1],'int16');
          adv.amp(1:3,ii)=fread(fid,[3 1],'uchar');
          adv.cm(1:3,ii)=fread(fid,[3 1],'uchar');
          adv.heading(ii)=fread(fid,1,'int16');
          adv.pitch(ii)=fread(fid,1,'int16');
          adv.roll(ii)=fread(fid,1,'int16');
          adv.temp(ii)=fread(fid,1,'int16');
          adv.press(ii)=fread(fid,1,'uint16');
          adv.ext1(ii)=fread(fid,1,'int16');
          adv.ext2(ii)=fread(fid,1,'int16');
          adv.checksum(ii)=fread(fid,1,'uint16');
  end
  if feof(fid)
    break
  end
  if mod(ii,10)==0
    fprintf(1,'.');
  end;
end   
dd=filelen-ftell(fid);
fclose(fid);
return;

