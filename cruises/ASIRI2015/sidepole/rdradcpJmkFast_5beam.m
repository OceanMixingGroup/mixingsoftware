function [adcp]=rdradcpJmkFast_5beam(name,varargin);
% RDRADCP  Read (raw binary) RDI ADCP files,
%  ADCP=RDRADCP(NAME) reads the raw binary RDI BB/Workhorse ADCP file NAME and
%  puts all the relevant configuration and measured data into a data structure
%  ADCP (which is self-explanatory). This program is designed for handling data
%  recorded by moored instruments (primarily Workhorse-type but can also read
%  Broadband) and then downloaded post-deployment. For vessel-mount data I
%  usually make p-files (which integrate nav info and do coordinate transformations)
%  and then use RDPADCP.
%
%  This current version does have some handling of VMDAS and WINRIVER output
%  files, but it is still 'beta'. There are (inadequately documented) timestamps
% of various kinds, for example.
%
%  [ADCP,CFG]=RDRADCP(...) returns configuration data in a
%  separate data structure.
%
%  Various options can be specified on input:
%  [..]=RDRADCP(NAME,NUMAV) averages NUMAV ensembles together in the result.
%  [..]=RDRADCP(NAME,NUMAV,NENS) reads only NENS ensembles (-1 for all).
%  [..]=RDRADCP(NAME,NUMAV,[NFIRST NEND]) reads only the specified range
%   of ensembles. This is useful if you want to get rid of bad data before/after
%   the deployment period.
%
%  Notes- sometimes the ends of files are filled with garbage. In this case you may
%         have to rerun things explicitly specifying how many records to read (or the
%         last record to read). I don't handle bad data very well.
%
%       - I don't read in absolutely every parameter stored in the binaries;
%         just the ones that are 'most' useful. Look through the code if
%         you want to get other things.
%
%       - chaining of files does not occur (i.e. read .000, .001, etc.). Sometimes
%         a ping is split between the end of one file and the beginning of another.
%         The only way to get this data is to concatentate the files, using
%           cat file1.000 file1.001 > file1   (unix)
%           copy file1.000/B+file2.001/B file3.000/B     (DOS/Windows)
%
%         (as of Dec 2005 we can probably read a .001 file)
%
%       - velocity fields are always called east/north/vertical/error for all
%         coordinate systems even though they should be treated as
%         1/2/3/4 in beam coordinates etc.
%
%  String parameter/option pairs can be added after these initial parameters:
%
%  'baseyear'    : Base century for BB/v8WH firmware (default to 2000).
%
%  'despike'    : [ 'no' | 'yes' | 3-element vector ]
%                 Controls ensemble averaging. With 'no' a simple mean is used
%                 (default). With 'yes' a mean is applied to all values that fall
%                 within a window around the median (giving some outlier rejection).
%                 This is useful for noisy data. Window sizes are [.3 .3 .3] m/s
%                 for [ horiz_vel vert_vel error_vel ] values. If you want to
%                 change these values, set 'despike' to the 3-element vector.
%
% R. Pawlowicz (rich@eos.ubc.ca) - 17/09/99

% R. Pawlowicz - 17/Oct/99
%          5/july/00 - handled byte offsets (and mysterious 'extra" bytes) slightly better, Y2K
%          5/Oct/00 - bug fix - size of ens stayed 2 when NUMAV==1 due to initialization,
%                     hopefully this is now fixed.
%          10/Mar/02 - #bytes per record changes mysteriously,
%                      tried a more robust workaround. Guess that we have an extra
%                      2 bytes if the record length is even?
%          28/Mar/02 - added more firmware-dependent changes to format; hopefully this
%                      works for everything now (put previous changes on firmer footing?)
%          30/Mar/02 - made cfg output more intuitive by decoding things.
%                    - An early version of WAVESMON and PARSE which split out this
%                      data from a wave recorder inserted an extra two bytes per record.
%                      I have removed the code to handle this but if you need it see line 509
%         29/Nov/02  - A change in the bottom-track block for version 4.05 (very old!).
%         29/Jan/03  - Status block in v4.25 150khzBB two bytes short?
%         14/Oct/03  - Added code to at least 'ignore' WinRiver GPS blocks.
%         11/Nov/03  - VMDAS navigation block, added hooks to output
%                      navigation data.
%         26/Mar/04  - better decoding of nav blocks
%                    - better handling of weird bytes at beginning and end of file
%                      (code fixes due to Matt Drennan).
%         25/Aug/04  - fixes to "junk bytes" handling.
%         27/Jan/05  - even more fixed to junk byte handling (move 1 byte at a time rather than
%                      two for odd lengths.
%  29/Sep/2005 - median windowing done slightly incorrectly in a way which biases
%                results in a negative way in data is *very* noisy. Now fixed.
%
%   28/Dc/2005  - redid code for recovering from ensembles that mysteriously change length, added
%                 'checkheader' to make a complete check of ensembles.
%     Feb/2006  - handling of firmware version 9 (navigator)
%   23/Aug/2006 - more firmware updates (16.27)
%   23/Aug2006  - ouput some bt QC stiff
%   29/Oct/2006 - winriver bottom track block had errors in it - now fixed.
%   30/Oct/2006 - pitch_std, roll_std now uint8 and not int8 (thanks Felipe pimenta)

%%
num_av=1;   % Block filtering and decimation parameter (# ensembles to block together).
nens=-1;   % Read all ensembles.
century=2000;  % ADCP clock does not have century prior to firmware 16.05.
vels='no';   % Default to simple averaging

%%
lv=length(varargin);
if lv>=1 & ~isstr(varargin{1}),
  num_av=1; % Block filtering and decimation parameter (# ensembles to block together).
  varargin(1)=[];
  lv=lv-1;
  if lv>=1 & ~isstr(varargin{1}),
    nens=varargin{1};
    varargin(1)=[];
    lv=lv-1;
  end;
end;

% Read optional args
while length(varargin)>0,
  switch varargin{1}(1:3),
    case 'bas',
      century = varargin{2};
    case 'des',
      if isstr(varargin{2}),
        if strcmp(varargin{2},'no'), vels='no';
        else vels=[.3 .3 .3]; end;
      else
        vels=varargin{2};
      end;
    otherwise,
      error(['Unknown command line option  ->' varargin{1}]);
  end;
  varargin([1 2])=[];
end;


%%

% Check file information first

naminfo=dir(name);

if isempty(naminfo),
  fprintf('ERROR******* Can''t find file %s\n',name);
  return;
end;

fprintf('\nOpening file %s\n\n',name);
fd=fopen(name,'r','ieee-le');

% Read first ensemble to initialize parameters



%% go through a search of the file for headers...

fseek(fd,0,'bof');              % Rewind
ch = uint8(fread(fd,Inf,'uint8'));
size(ch)
in = find(ch(1:end-1)==127 & ch(2:end)==127);
% these are all the header candidates.  Some are data, some are actual
% headers....
bytesens = double(ch(in+2))+double(ch(in+3))*256;
i = 1;
fprintf('Parsing\n');
while i<length(in)
  if mod(i,500)==0;
    %fprintf('%d\n',i);
  end;

  if in(i+1)<in(i)+bytesens(i)+2
    in(i+1)=[];
    bytesens(i+1)=[];
  else
    i=i+1;
  end;
end;

% make an array

if in(end)+bytesens(end)>length(ch)
  in=in(1:end-1);
  bytesens=bytesens(1:end-1);
end;
dat = double(ch(in(1)+[1:bytesens(1)]-1));

%% preallocate arrays...
hdr = gethdr(dat,0);
ldr = getleader(dat,hdr.offsets(1));
% get some things from the leader:
adcp.depths = ldr.bin1+((1:ldr.nbins)-1)*ldr.binl;

adcp.cor = zeros(ldr.nbins,length(in),4);
adcp.int = zeros(ldr.nbins,length(in),4);
adcp.vel = zeros(ldr.nbins,length(in),4);
adcp.pgood = zeros(ldr.nbins,length(in),4);

varl = initvarl(length(in));
adcp = initbot(length(in),adcp);

%%
fprintf('Decoding %d records\n',length(in));


for i=1:length(in);
%for i=7000:8000
  if mod(i,500)==0;
   % fprintf('%d of %d\n',i,length(in));
  end;
  dat = double(ch(in(i)+[0:bytesens(i)-1]));
  
  hdr = gethdr(dat,0);
  % get the ids..
  ids = dat(hdr.offsets+1)+ 256*dat(hdr.offsets+2);
 % ldr = getleader(dat,hdr.offsets(1));
  varl = getvar(dat,hdr.offsets(2),varl,i);
  offsets = hdr.offsets;
  nbins = ldr.nbins;
  for j=3:length(hdr.offsets)
    switch ids(j)
      case 256 
        vel = getvel(dat,offsets(j),nbins);
        adcp.vel(:,i,:)=reshape(vel,4,nbins)';
      case 512
        cor = getcor(dat,offsets(j),nbins);
        adcp.cor(:,i,:)=reshape(cor,4,nbins)';
      case 768
        int = getint(dat,offsets(j),nbins);
        adcp.int(:,i,:)=reshape(int,4,nbins)';
      case 1024
        percgood = getpercgood(dat,offsets(j),nbins);
        adcp.pgood(:,i,:)=reshape(percgood,4,nbins)';

        
      case 2560
          vel5=getvel5(dat,offsets(j),nbins);
          adcp.vel5(:,i)=vel5(:);
          
      case 3072
          int = getint5(dat,offsets(j),nbins);  
          adcp.int5(:,i)=int(:);
          
      case 1536
        
        adcp = getbot(dat,offsets(j),adcp,i);
      case 8192
        % vmdas file with nav info in it...  From vmdas manual
        if ~isfield(adcp,'slat')
          adcp = initvmhd(length(in),adcp);
        end
        adcp = getvmhd(dat,offsets(j),adcp,i);
      otherwise
        % dec2hex(ids(j))
          
    end   
    
  end;
end;

%%

adcp.heading=varl.heading;
adcp.roll=varl.roll;
adcp.pitch=varl.pitch;
adcp.time=varl.time;

%%
% fix order of vels
todo = {'cor','int','vel','pgood'};
for ii=1:length(todo);
  adcp.(todo{ii}) = permute(adcp.(todo{ii}),[3 1 2]);
end;

%%
function hdr=gethdr(dat,offset);
%
hdr.id = dat(1);
hdr.source= dat(2);
hdr.nbyte = dat(3)+256*dat(4);
hdr.ndat = dat(6);
hdr.offsets=dat(7+[0:1:hdr.ndat-1]*2) + 256*dat(8+[0:1:hdr.ndat-1]*2);



%%
function ldr=getleader(dat,off,ldr,i);
%
ldr = [];
off = off+1;
dd = double(dat(off:end));

ldr.nbins = dd(10);
ldr.npings = dd(11)+256*dd(12);

ldr.binl = (dd(13)+256*dd(14))*0.01;
ldr.blankl = (dd(15)+256*dd(16))*0.01;
ldr.promode = dd(17);
ldr.codereps= dd(19);
ldr.headal = (dd(27)+256*dd(28));
if ldr.headal>32768
  ldr.headal = -2*32768+ldr.headal
end;
ldr.headal=ldr.headal*0.01;

ldr.magbias = (dd(29)+256*dd(30));
if ldr.headal>32768
  ldr.magbias = -2*32768+ldr.magbias
end;
ldr.magbias=ldr.magbias*0.01;
ldr.bin1 = (dd(33)+256*dd(34))*0.01;
ldr.xmitlen= dd(35)+256*dd(36);

%% 
function adcp = initvmhd(nens,adcp);

adcp.stime = NaN*ones(1,nens);
adcp.etime = NaN*ones(1,nens);
adcp.slat = NaN*ones(1,nens);
adcp.slon = NaN*ones(1,nens);
adcp.elat = NaN*ones(1,nens);
adcp.elon = NaN*ones(1,nens);
adcp.spd= NaN*ones(1,nens);
adcp.headtrue = NaN*ones(1,nens);
adcp.headmag = NaN*ones(1,nens);
adcp.smg = NaN*ones(1,nens);
adcp.hmg = NaN*ones(1,nens);


%% 
function adcp = getvmhd(dat,off,adcp,i);

keyboard;

dd = dat((off+1):end);

time = dd(7)+dd(8)*256+dd(9)*256^2+dd(10)*256^3;

time = mod(time*0.0001,24*3600); % seconds...
year = dd(5)+256*dd(6);

adcp.stime(i) = datenum(year,dd(4),dd(3),0,0,time);
if i>1 & adcp.stime(i)>adcp.stime(i-1)+0.5
  adcp.stime(i) = adcp.stime(i)-1;
end;


time = dd(23)+dd(24)*256+dd(25)*256^2+dd(26)*256^3;
time = mod(time*0.0001,24*3600); % seconds...
adcp.etime(i) = datenum(year,dd(4),dd(3),0,0,time);
% believe it or not the date clicks over before the time (sigh)...

if i>1 & adcp.etime(i)>adcp.etime(i-1)+0.5
  adcp.etime(i) = adcp.etime(i)-1;
end;

lat = dd(15)+dd(16)*256+dd(17)*256^2+dd(18)*256^3;
if lat>2^32/2;
  lat = -2^32+lat;
end;
adcp.slat(i) = lat*180/2^31;
lat = dd(19)+dd(20)*256+dd(21)*256^2+dd(22)*256^3;
if lat>2^32/2;
  lat = -2^32+lat;
end;
adcp.slon(i) = lat*180/2^31;

lat = dd(27)+dd(28)*256+dd(29)*256^2+dd(30)*256^3;
if lat>2^32/2;
  lat = -2^32+lat;
end;
adcp.elat(i) = lat*180/2^31;

lat = dd(31)+dd(32)*256+dd(33)*256^2+dd(34)*256^3;
if lat>2^32/2;
  lat = -2^32+lat;
end;
adcp.elon(i) = lat*180/2^31;
return
% the rest of this is crap for some reason...
x = dat(35)+256*dat(36);
if x > 2^16/2
  x=-2^16+x;
end;
adcp.spd(i) = x*1e-3;

adcp.headtrue(i) = dat(37)+256*dat(38);
adcp.headmag(i) = dat(39)+256*dat(40);
x = dat(41)+dat(42)*256;
if x > 32768
  x=-2*32768+x;
end;
adcp.smg(i) = x*1e-3;
adcp.hmg(i) = dat(43)+256*dat(44);





%% 
function adcp = initbot(nens,adcp);

adcp.btrange = NaN*zeros(4,nens);
adcp.btvel = NaN*zeros(4,nens);
adcp.btcorr = NaN*zeros(4,nens);
adcp.btamp = NaN*zeros(4,nens);
adcp.wrlon= NaN*zeros(1,nens);
adcp.wrlat= NaN*zeros(1,nens);

%%
function adcp = getbot(dat,off,adcp,i);

dd = dat(off+(1:50));
x = getshort(dd(25:32));
x(x==-32768)=NaN;

adcp.btvel(:,i)=x/1000;
adcp.btrange(:,i) = getushort(dd(17:24))/100;
bad = find(adcp.btrange(:,i)==0);
adcp.btrange(bad,i) = NaN;
adcp.btcorr(:,i) = dd(33:36);
adcp.btamp(:,i) = dd(37:40);

% some odd winriver stuff that may or may not be here....
lat=dd(5)+dd(6)*256+dd(47)*256^2+dd(48)*256^3;
if lat>2^32/2;
  lat = -2^32+lat;
end;
adcp.wrlon(i)=lat*180/2^31;

lat=dd(13)+dd(14)*256+dd(15)*256^2+dd(16)*256^3;
if lat>2^32/2;
  lat = -2^32+lat;
end;
adcp.wrlat(i)=lat*180/2^31;





%% function
function x = getshort(dd)
x = dd(1:2:end)+256*dd(2:2:end);
in = find(x>32767);
x(in)=-2*32768+x(in);

%% function
function x = getushort(dd)
x = dd(1:2:end)+256*dd(2:2:end);

%% 
function varl = initvarl(nens);
varl.time = zeros(1,nens);
varl.ens = zeros(1,nens);
varl.pitch= zeros(1,nens);
varl.heading = zeros(1,nens);
varl.roll = zeros(1,nens);

%%
function varl=getvar(dat,off,varl,i);
%
ldr = [];
off = off+1;
dd = dat(off:end);

varl.time(i)=datenum(dd(5:10)');
varl.ens(i)=dd(3)+256*dd(4);
varl.heading(i)=(dd(19)+256*dd(20))*0.01;
varl.pitch(i)=(dd(21)+256*dd(22)-2^(32/2))*0.01;
varl.roll(i)=(dd(23)+256*dd(24)-2^(32/2))*0.01;



%%
function vel=getvel(dat,offset,nbins);

offset = offset+2;

vel = dat(offset+2*[1:4*nbins]-1)+256*(dat(offset+2*[1:4*nbins]));
vel(vel>=32768)=-2*32768+vel(vel>=32768);

%%
function vel=getcor(dat,offset,nbins);

offset = offset+2;

vel = dat(offset+[1:4*nbins]);

%%
function vel=getint(dat,offset,nbins);

offset = offset+2;

vel = dat(offset+[1:4*nbins]);

% added AP 08/29/15
function vel=getint5(dat,offset,nbins);

offset = offset+2;

%vel = dat(offset+[1:4*nbins]);
vel = dat(offset+[1:nbins]);

%
function vel=getpercgood(dat,offset,nbins);

offset = offset+2;

vel = dat(offset+[1:4*nbins]);



















