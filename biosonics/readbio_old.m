function pings=readbio(fname,transducerdepth,horizontalsubsample,verticalsubsample)
%
% function pings=readbio(fname,transducerdepth,verticalsubsample);
%
% Reads a file of biosonics data and returns a structure "pings".
%
% fname is a biosonic *.DT4 file.  
% transducerdepth is the depth of the transducer in meters - can
%    be empty.
% verticalsubsample is subsampling in # of samples.  Data is bin
%    averaged and then subsampled - can be empty.
%
% i.e. 
% fname = '\\pequod\DATA\Coast01b\Tests\NWPTDCK.DT4';
% pings = readbio(fname,3);
%
% imagesc(pings.datenum,pings.depth,log(pings.sample));
% caxis([6 12])
%
% note that pings.sample is in counts, not dB.
%
% first attempt at reading biosonics data.
% not supported?
% Marker - note needed
% Ping Descriptor...
% dB instead of counts...
% to do?  Check output vs output from BioSonic... Did I do the
% Mantissa and Exponent correctly? 
%
% Written by Jody Klymak 
% Modified 22 June 2009 by A.Perlin to include GPS data 
% and process varying data formats
% 
% $Author: aperlin $ $Date: 2009/07/02 18:49:03 $ $Version$

  
if nargin<2
  transducerdepth=[];
end;
if isempty(transducerdepth)
  warning('transducerdepth==0');
  transducerdepth=0;
end;
pings.head.transducerdepth = transducerdepth;

if nargin<3
  horizontalsubsample=[];
end;
if nargin<4
  verticalsubsample=[];
end;

s=dbstack;
pings.head.history = sprintf('Made using %s from file %s',s.name,fname);

fin = fopen(fname);
npings = 0;
ntimes = 0;
npos=0;
nnav=0;

local.systime = NaN;
preallocatesize=500;

while ~feof(fin)
  tuple=readtuple(fin);
%   dec2hex(tuple.type)
  if isempty(tuple.type);
  elseif tuple.type==hex2dec('001E');
    % header data.
%     fprintf('Header\n');

    pings.head.absorption = tuple.absorption;
    pings.head.salinity = tuple.salinity;
    pings.head.temperature = tuple.temperature;
    pings.head.soundvel = tuple.soundvel;
    pings.head.powersetting = tuple.powersetting;
    pings.head.nochannels = tuple.nochannels;
  elseif tuple.type ==hex2dec('0012');
    % channel descriptor.
%     fprintf('Channel\n');
    local.npings = tuple.pingcount;
    local.nsamps = tuple.samplesperping;
    if local.npings==0% preallocate the arrays based on this.
      % guess something large.  
      local.npings=5000;
      warning('Do not know number of pings in this file');
    end;
    pings.systime=NaN*ones(1,local.npings);
    pings.sample=NaN*ones(local.nsamps,local.npings);
    time.systime = pings.systime; 
    time.datenum = pings.systime;     
    pos.systime = pings.systime;     
    pos.lon = pings.systime;     
    pos.lat = pings.systime;     
    % continue with channel data...
    pings.head.sampleperiod = tuple.sampleperiod*1e-9; % put into seconds...
    pings.head.emissiontype = tuple.emissiontype;
    pings.head.pulselength = tuple.pulselength*1e-6;
    pings.head.pingrate = tuple.pingrate*1e-3;
    pings.head.initialblanking = tuple.initialblanking;
    pings.head.threshold = tuple.threshold;
    pings.head.calcorrection = tuple.calcorrection;
  elseif  tuple.type==hex2dec('0015')
    % ping data
    npings = npings+1;
    if (mod(npings,250)==1);fprintf('.');end;
    pings.systime(npings) = tuple.systime;
    local.systime = tuple.systime;
    pings.sample(1:tuple.nsamples,npings) = tuple.samples;
  elseif  tuple.type==hex2dec('000F')
    % Time data...
    ntimes=ntimes+1;
    time.systime(ntimes) = tuple.systime;
    local.systime = tuple.systime;
    time.datenum(ntimes) = tuple.datenum;
  elseif  tuple.type==hex2dec('000E')
    npos=npos+1;
    pos.lat(npos)=tuple.latitude;
    pos.lon(npos)=tuple.longitude;
    % choose the systime based on the latest time
    pos.systime(npos)=local.systime;
  elseif  tuple.type==hex2dec('0011')
    nnav=nnav+1;
%     nav.lat(nnav)=tuple.navlat;
%     nav.lon(nnav)=tuple.navlon;
    nav.time(nnav)=tuple.navtime;
  end;

end;
fclose(fin);
if exist('nav','var')
    nav.time(nav.time==0)=NaN;
    nav.time=nav.time(~isnan(nav.time));
%     nav.lat(nav.lon==0)=NaN;
%     nav.lon(nav.lon==0)=NaN;
%     nav.lat=nav.lat(~isnan(nav.time));
%     nav.lon=nav.lon(~isnan(nav.time));
    % if time crosses midnight we should add 1 day to the overmidnight part
    test=diff(nav.time);
    if ~isempty(find(test<-0.5,1))
        nav.time(nav.time<1.5)=nav.time(nav.time<1.5)+1;
    end
    % sort GPS time
    [nav.time ix]=sort(nav.time);
%     nav.lat=nav.lat(ix);
%     nav.lon=nav.lon(ix);
    % add starting date to GPS time string
    startdate=floor(time.datenum(1));
    nav.time=nav.time-1+startdate;
else
    pings.navtime=NaN*pings.systime;
%     pings.navlat=NaN*pings.systime;
%     pings.navlon=NaN*pings.systime;
end
% add a datenum field to the pings structure

% trim the fields..
if ntimes>0
  time.systime=time.systime(1:ntimes);
  time.datenum=time.datenum(1:ntimes);
end;

pings.systime = pings.systime(1:npings);
pings.sample = pings.sample(:,1:npings);

% remove outliers in systime
if exist('pos','var')
    pos.systime(pos.systime>pos.systime(end) | pos.systime<pos.systime(1))=NaN;
end
pings.systime(pings.systime>pings.systime(end) | pings.systime<pings.systime(1))=NaN;
time.systime(time.systime>time.systime(end) | time.systime<time.systime(1))=NaN;
% fill gaps
if exist('pos','var')
    good=find(~isnan(pos.systime));
    pos.systime=interp1(good,pos.systime(good),[1:length(pos.systime)]);
end
good=find(~isnan(pings.systime));
pings.systime=interp1(good,pings.systime(good),[1:length(pings.systime)]);
good=find(~isnan(time.systime));
time.systime=interp1(good,time.systime(good),[1:length(time.systime)]);
% sort the fields (time/data in fields are often not in order)
if exist('pos','var')
    [pos.systime ip]=sort(pos.systime);
    pos.lon=pos.lon(ip);
    pos.lat=pos.lat(ip);
end
[pings.systime ip]=sort(pings.systime);
pings.sample=pings.sample(:,ip);
[time.systime ip]=sort(time.systime);
[time.datenum ip]=sort(time.datenum);

pings.datenum=interp1(1:length(time.datenum),time.datenum,...
    1:(length(time.datenum)-1)/(length(pings.systime)-1):length(time.datenum),'linear','extrap');
if exist('nav','var')
    warning off
    pings.navtime=interp1(1:length(nav.time),nav.time,...
        1:(length(nav.time)-1)/(length(pings.systime)-1):length(nav.time),'linear','extrap');
    pings.lat=interp1(1:length(pos.lat),pos.lat,...
        1:(length(pos.lat)-1)/(length(pings.systime)-1):length(pos.lat),'linear','extrap');
    pings.lon=interp1(1:length(pos.lon),pos.lon,...
        1:(length(pos.lon)-1)/(length(pings.systime)-1):length(pos.lon),'linear','extrap');
end
% Make the depth field
if isfield(pings.head,'initialblanking')
    pings.depth = transducerdepth+0.5*pings.head.soundvel*...
        pings.head.sampleperiod*[pings.head.initialblanking+(1:size(pings.sample,1))]';
end

%%% subsample horizontaly
if isempty(horizontalsubsample)
  horizontalsubsample=0;
end;
if horizontalsubsample>1 
  b=ones(1,horizontalsubsample);
  b=b./sum(b);
  a=1;
  for i=1:size(pings.sample,1)
    good = find(~isnan(pings.sample(i,:)));
    pings.sample(i,good) = filtfilt(b,a,pings.sample(i,good));
  end;
  pings.sample=pings.sample(:,horizontalsubsample:horizontalsubsample:end);
  pings.systime=pings.systime(horizontalsubsample:horizontalsubsample:end);
  pings.datenum=pings.datenum(horizontalsubsample:horizontalsubsample:end);
  pings.navtime=pings.navtime(horizontalsubsample:horizontalsubsample:end);
%   pings.navlat=pings.navlat(horizontalsubsample:horizontalsubsample:end);
%   pings.navlon=pings.navlon(horizontalsubsample:horizontalsubsample:end);
  pings.lat=pings.lat(horizontalsubsample:horizontalsubsample:end);
  pings.lon=pings.lon(horizontalsubsample:horizontalsubsample:end);
end
%%% subsample vertically
if isempty(verticalsubsample)
  verticalsubsample=0;
end;
if verticalsubsample>1 
  b=ones(1,verticalsubsample);
  b=b./sum(b);
  a=1;
  for i=1:size(pings.sample,2)
    good = find(~isnan(pings.sample(:,i)));
    pings.sample(good,i) = filtfilt(b,a,pings.sample(good,i));
  end;
  
  pings.depth = filtfilt(b,a,pings.depth);
  pings.sample = pings.sample(verticalsubsample:verticalsubsample:end,:);
  pings.depth = pings.depth([verticalsubsample:verticalsubsample: ...
		    end]); 
end


return;
%%%%%%%%%%%%%% Done main function %%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tuple = readtuple(fin)
  tuple.count = fread(fin,1,'ushort');
  tuple.type = fread(fin,1,'ushort');
  if isempty(tuple.type)
    return
  end;
  
  switch tuple.type
   case hex2dec('0015')
     %fprintf('Ping!\n');
     tuple = bio_decode_ping_tuple(tuple,fin);
   case hex2dec('000F')
     %fprintf('Time!\n');
     tuple = bio_decode_time_tuple(tuple,fin);
   case hex2dec('001E')
     % Header
     tuple = bio_decode_header_tuple(tuple,fin);
   case hex2dec('0012')
     % Channel Descriptor....
     tuple = bio_decode_channel_tuple(tuple,fin);
     %keyboard;
   case hex2dec('0011')
    % navstring
     tuple=bio_decode_navstring_tuple(tuple,fin);
   case hex2dec('000E')
     % position
     tuple=bio_decode_position_tuple(tuple,fin);
   otherwise 
    tuple.data = fread(fin,tuple.count,'uchar');
    %fprintf('Unknown %s\n',dec2hex(tuple.type,4));
  end;
  tuple.back = fread(fin,1,'ushort');
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function tuple = bio_decode_navstring_tuple(tuple,fin)
  tuple.navstring = fread(fin,tuple.count,'char');
  % $$$$$$$$$$ added by A.Perlin 22 June 2009 $$$$$$$$$$$$$$
  % here we get GPS time, longitude and latitude out of $GPGGA line of navstring 
  % it needs to be integrated into output
  tt=textscan(char(tuple.navstring)','%s',999999,'delimiter','\r');
  t=char(tt{:});
  igpgga=strmatch('$GPGGA',t);
  if ~isempty(igpgga)
      gpgga=t(igpgga,:);
      gpgga(:,end+1)=',';
      gpgga=textscan(gpgga','%s %s %f %s %f %s %f %f %f %f %s %f %s %s %s',size(gpgga,1),'delimiter',',');
%       lat=gpgga{3}(1);
%       tuple.navlat=floor(lat/100)+(lat/100-floor(lat/100))*100/60;
%       im=strmatch('S',gpgga{4}(1));
%       if ~isempty(im)
%           tuple.navlat(im)=-tuple.navlat(im);
%       end
%       lon=gpgga{5}(1);
%       tuple.navlon=floor(lon/100)+(lon/100-floor(lon/100))*100/60;
%       im=strmatch('W',gpgga{6}(1));
%       if ~isempty(im)
%           tuple.navlon(im)=-tuple.navlon(im);
%       end
      tuple.navtime=datenum(['0000' char(gpgga{2}(1))],'yyyyHHMMSS');
  else
      tuple.navlat=NaN;
      tuple.navlon=NaN;
      tuple.navtime=NaN;
  end
  % $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
return;

function tuple = bio_decode_position_tuple(tuple,fin)
  tuple.latitude = fread(fin,1,'long')*1e-5/60;
  tuple.longitude = fread(fin,1,'long')*1e-5/60;
  tuple.source = fread(fin,1,'char');
  junk = fread(fin,1,'char');
return;
  
function tuple = bio_decode_channel_tuple(tuple,fin)
  count = tuple.count;
  tuple.channelnum = fread(fin,1,'ushort');
  count=count-2;
  tuple.pingcount = fread(fin,1,'long');
  count=count-4;
  tuple.samplesperping = fread(fin,1,'ushort');
  count=count-2;
  tuple.sampleperiod = fread(fin,1,'ushort'); % ns
  count=count-2;
  tuple.emissiontype = fread(fin,1,'uchar'); 
  count=count-1;
  junk = fread(fin,1,'uchar'); 
  count=count-1;
  tuple.pulselength = fread(fin,1,'ushort'); % micro-s
  count=count-2;
  tuple.pingrate    = fread(fin,1,'ushort'); % ms/ping...
  count=count-2;
  tuple.initialblanking    = fread(fin,1,'ushort'); % samples
  count=count-2;
  tuple.datalimit    = fread(fin,1,'ushort'); % words ???
  count=count-2;
  tuple.threshold    = fread(fin,1,'short')*0.01; % dB 
  count=count-2;
  tuple.receivereprom    = fread(fin,128,'uchar'); % Ummm? 
  count=count-128;
  tuple.transmittereprom    = fread(fin,128,'uchar'); % Ummm? 
  count=count-128;
  tuple.calcorrection = fread(fin,1,'short')*0.001; % dB;
  count=count-2;
  % read the rest
  if count>0
    junk    = fread(fin,count,'uchar'); % Ummm? 
  end;
return;

function tuple = bio_decode_header_tuple(tuple,fin)
  count=tuple.count;
  % Hmmmm. 
  tuple.absorption = fread(fin,1,'ushort')*0.0001; % dB/m
  tuple.soundvel = fread(fin,1,'ushort')*0.0025 + 1400; % m/s
  tuple.temperature = fread(fin,1,'short')*0.01; % to degrees
  tuple.salinity = fread(fin,1,'ushort')*0.01; % ppt
  tuple.powersetting = fread(fin,1,'short')*0.1; % in dB
  tuple.nochannels = fread(fin,1,'ushort');  
return;


function tuple = bio_decode_time_tuple(tuple,fin)
  tuple.time = fread(fin,1,'ulong');
  tuple.source = fread(fin,1,'uchar');
  tuple.subsecond = fread(fin,1,'uchar');
  tuple.systime = fread(fin,1,'ulong');
  % lets provide a Matlab datenum...
  % tuple.time is seconds from 00:00:00 1/1/70...
  tuple.datenum = tuple.time/(24*3600);  % convert to days from seconds
  tuple.datenum = tuple.datenum+datenum(1970,1,1,0,0,0);
  % check if there is any subsecond data
  if tuple.subsecond>128
    tuple.subsecond = tuple.subsecond-128;
  end;
  tuple.datenum = tuple.datenum+tuple.subsecond/(24*3600*100);
  % good to 100ths of a second....
return;


function tuple = bio_decode_ping_tuple(tuple,fin)
  % note that this does not handle the case where there is data
  % standing in for empty data.  In that instance we are screwed...
  tuple.channel = fread(fin,1,'ushort');
  tuple.pingnum = fread(fin,1,'ulong');
  tuple.systime = fread(fin,1,'ulong');
  tuple.nsamples = fread(fin,1,'ushort');  
  tuple.samples = fread(fin,tuple.nsamples,'ushort');
  % OK, this is OK.  However, the samples are really stored as
  % floats.  Umm, 16-bit floats.  Why oh why?
  % This foolishness is done by masking off the first 12 bits and
  % as the mantissa and then the last 4 bits is the exponent.    
  mantissa = mod(tuple.samples,4096);
  exponent = (tuple.samples-mantissa)/4096;
  % Ummm, OK, but the count is not simply the normal exponent.  Oh
  % no... a value of 0x1000 is added to the mantissa and then it is
  % shifted to the left by (exponent-1) bits.  Whoever came up with
  % this silliness....
  % Shifting to the left means multiplying by 2.  So
  % 2.^(epxonent-1).  Adding 0x1000?
  tuples.sample = mantissa;
  in = find(exponent>0);  % only if exponent is bigger than zero...
  tuples.sample(in) = (tuples.sample(in)+4096).*(2.^(exponent(in)-1));
return;