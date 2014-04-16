function pings=readbio(fname,transducerdepth,horizontalsubsample,verticalsubsample)
%
% function pings=readbio(fname,transducerdepth,horizontalsubsample,verticalsubsample);
%
% Reads a file of biosonics data and returns a structure "pings".
%
% fname is a biosonic *.DT4 file.  
% transducerdepth is the depth of the transducer in meters - can
%    be empty.
% horisontalsubsample and verticalsubsample is subsampling in # of samples.  Data is bin
%    averaged and then subsampled - can be empty.
%
% i.e. 
% fname = 'st1020100609_004027.dt4';
% pings = readbio(fname,3);
%
% imagesc(pings.datenum,pings.depth,log(pings.sample));
% caxis([6 12])
% Written by A. Perlin 8 June 2010 
% 
% $Author: aperlin $ $Date: 2010/11/20 00:47:36 $ $Version$

  
if nargin<2
  transducerdepth=[];
end;
if isempty(transducerdepth)
%   warning('transducerdepth==0');
  transducerdepth=0;
end;

if nargin<3
  horizontalsubsample=[];
end;
if nargin<4
  verticalsubsample=[];
end;

s=dbstack;
pings.head.history = sprintf('Made using %s from file %s',s.name,fname);

fin = fopen(fname,'rb','l');
npings = 0;
ntimes = 0;
npos=0;
nnav=0;
nbot=0;
stopreading=0;
local.etm = NaN;
preallocatesize=500;
ii=0;
while ~feof(fin) && stopreading~=1
    tuple=readtuple(fin);
    if ~isempty(tuple.type)
        switch tuple.type
            case hex2dec('FFFF') % signature tuple
                pings.head.dt4_version_major=tuple.vmjr;
                pings.head.dt4_version_minor=tuple.vmnr;
            case {hex2dec('001E'),hex2dec('0018')}
                % file header
                pings.head.ab=tuple.ab;
                pings.head.sv=tuple.sv;
                pings.head.tmp=tuple.tmp;
                pings.head.sa=tuple.sa;
                if isfield(tuple,'tpov')
                    pings.head.tpov=tuple.tpov;
                else
                    pings.head.tpov=0;
                end
                pings.head.nch=tuple.nch;
            case hex2dec('0012') % channel descriptor
                % ch descriptor.
                local.ch=tuple.ch;
                local.npings = tuple.np;
                local.spp = tuple.spp; % number of samples per ping
                if local.npings==0% preallocate the arrays based on this.
                    % guess something large.
                    local.npings=5000;
                    warning('Do not know number of pings in this file');
                end;
                pings.head.sp = tuple.sp;  % sample period in s
                pings.head.pud = tuple.pud; % pulse duration in s
                pings.head.pp = tuple.pp; % number of seconds between pings (requested)
                pings.head.ib = tuple.ib; % initial blanking (number of samples skipped before data recording begins in each ping)
                pings.head.th = tuple.th; % the data collection threeshold in dB
                pings.head.corr = tuple.corr;
                pings.head.sn=tuple.corr; % serial number (shortened)
                pings.head.cald=tuple.cald/86400+datenum(1970,1,1); % calibration date
                pings.head.tech=tuple.tech; % tech signature
                pings.head.sl=tuple.sl; % source level in dB
                pings.head.rs=tuple.rs; % receiver sensitivity in dB
                pings.head.rsw=tuple.rsw; % receiver sensitivity for the wide-beam or phase elements in dB
                pings.head.pdpy=tuple.pdpy; % sign of split-beam y-axis element separation (zero - positive, nonzero - nagative)
                pings.head.pdpx=tuple.pdpx; % sign of split-beam x-axis element separation (zero - positive, nonzero - nagative)
                pings.head.nf=tuple.nf; % noise floor for the transducer in counts (max observed value due to system noise)
                pings.head.trtype=tuple.trtype; % transducer type (hardware, not usage mode). 0-single beam, 3-dual beam, 4-split-beam
                pings.head.fq=tuple.fq; % frequency of the transducer in Hz
                pings.head.pdy=tuple.pdy; % absolute value of the split-beam y-axis separation, in units of 0.01 mm (pdpy gives sign information)
                pings.head.pdx=tuple.pdx; % absolute value of the split-beam x-axis separation, in units of 0.01 mm (pdpx gives sign information)
                pings.head.phpy=tuple.phpy; % split-beam y-axis element polarity (+/-1)
                pings.head.phpx=tuple.phpx; % split-beam x-axis element polarity (+/-1)
                pings.head.aoy=tuple.aoy; % split-beam y-axis angle offset in units of degrees
                pings.head.aox=tuple.aox; % split-beam x-axis angle offset in units of degrees
                pings.head.bwy=tuple.bwy; % y-axis -3dB one-way beamwidth for the main element, in degrees
                pings.head.bwx=tuple.bwx; % x-axis -3dB one-way beamwidth for the main element, in degrees
                pings.head.smpr=tuple.smpr; % sample rate of the A/D converter, in HzIn most, but not all, transducers this is 41667. Thius field and the sp field in the ch descriptor are related by sp=1000000000/smpr
                pings.head.bwwy=tuple.bwwy; % y-axis -3dB one-way beamwidth for the wide-beam or phase elements, in degrees
                pings.head.bwwx=tuple.bwwx; % x-axis -3dB one-way beamwidth for the wide-beam or phase elements, in degrees
                pings.head.phy=tuple.phy; % the split-beam y-axis phase aperture, in degrees
                pings.head.phx=tuple.phx; % the split-beam x-axis phase aperture, in degrees
            case hex2dec('0036') % extended channel descriptor
                pings.head.corrwide=tuple.corrwide; % user-defined calibration correction in dB
                pings.head.thtyp=tuple.thtyp; % equal 40 if the data was collected with Visual Aqcuisition 6, or with "squared"
                                            % threshold mode of VA 4 or 5; equal to 20 if the data were collected with the
                                            % "linear" threeshold; equal to 0 if the data were collected with the "constant" threshold mode
                pings.head.putyp=tuple.putyp; % equal 0 if the data were collected in passive mode, or 1 in active mode
                pings.head.dpt=tuple.dpt; % depth in meters of the transducer
                pings.head.ph=tuple.ph; % PH value for this transducer
            case hex2dec('0015') % single-beam ping
                % ping data
                npings=npings+1;
                if (mod(npings,250)==1);fprintf('.');end;
                pings.pn(npings) = tuple.pn; % ping number
                pings.etm(npings) = tuple.etm; % ellapsed system time, ms
                pings.sample(1:tuple.ns,npings) = tuple.samples;
            case hex2dec('001C') % dual-beam ping
                % ping data
                npings=npings+1;
                if (mod(npings,250)==1);fprintf('.');end;
                pings.pn(npings) = tuple.pn;% ping number
                pings.etm(npings) = tuple.etm; % ellapsed system time, ms
                pings.nbsample(1:tuple.ns,npings) = tuple.nbsamples; % narrow-band samples
                pings.wbsample(1:tuple.ns,npings) = tuple.wbsamples; % wide-band samples
            case {hex2dec('000F'),hex2dec('0020')}
                % Time data...
                ntimes=ntimes+1;
                time.etm(ntimes) = tuple.etm;
                local.etm = tuple.etm;
                time.datenum(ntimes) = tuple.datenum;
                pings.head.timesource=tuple.source;
            case hex2dec('000E')
                % Position data
                npos=npos+1;
                pos.lat(npos)=tuple.lat;
                pos.lon(npos)=tuple.lon;
                % choose the systime based on the latest time
                if isfield(tuple,'etm')
                    pos.etm(npos)=tuple.etm;
                    pos.alt(npos)=tuple.alt;
                    local.etm=tuple.etm;
                else
                    pos.etm(npos)=local.etm;
                end
                pings.head.possource=tuple.psrc;
            case {hex2dec('0011'),hex2dec('0030')}
                % GPS Navigation data
                nnav=nnav+1;
                if isfield(tuple,'etm')
                    nav.etm(nnav)=tuple.etm;
                 else
                    nav.etm(nnav)=local.etm;
               end
                tt=textscan(tuple.navstring,'%s',999999,'delimiter','\r');
                t=char(tt{:});
                igpgga=strmatch('$GPGGA',t);
                if ~isempty(igpgga)
                    gpgga=t(igpgga,:);
                    gpgga(:,end+1)=',';
                    gpgga=textscan(gpgga','%s %s %f %s %f %s %f %f %f %f %s %f %s %s %s',size(gpgga,1),'delimiter',',');
                    lat=gpgga{3}(1);
                    nav.lat(nnav)=floor(lat/100)+(lat/100-floor(lat/100))*100/60;
                    im=strmatch('S',gpgga{4}(1));
                    if ~isempty(im)
                        nav.lat(nnav)=-nav.lat(nnav);
                    end
                    lon=gpgga{5}(1);
                    nav.lon(nnav)=floor(lon/100)+(lon/100-floor(lon/100))*100/60;
                    im=strmatch('W',gpgga{6}(1));
                    if ~isempty(im)
                        nav.lon(nnav)=-nav.lon(nnav);
                    end
                    nav.time(nnav)=datenum(['0000' char(gpgga{2}(1))],'yyyyHHMMSS');
                else
                    nav.lat(nnav)=NaN;
                    nav.lon(nnav)=NaN;
                    nav.time(nnav)=NaN;
                end
            case hex2dec('0032') % bottom pick
                nbot=nbot+1;
                bottom.pn(nbot) = tuple.pn; % ping number
                bottom.etm(nbot) = tuple.etm; % system time in seconds
                bottom.valid(nbot) = tuple.valid; % flag indicating whether a bottom pick was found
                bottom.range(nbot) = tuple.range; % range to bottom, in meters
            case {hex2dec('FE00'),hex2dec('FFFE')} % in file format description it is FFFE
                % END OF FILE TUPLE
                stopreading=1;
        end
        if ~isfield(tuple,'size')
            break
        elseif  tuple.dsize~=tuple.size-6
            break
        end
    end
end;
fclose(fin);
% if transducer depth is defined in the file, we will use that value, if
% not, we will use transducerdepth function argument instead
if isfield(pings.head,'dpt')
    if pings.head.dpt<=0
        pings.head.dpt=transducerdepth;
    end
else
    pings.head.dpt=transducerdepth;
end
    
if exist('nav','var')
    nav.time(nav.time==0 | nav.lat==0 | nav.lon==0)=NaN;
    nav.lat=nav.lat(~isnan(nav.time));
    nav.lon=nav.lon(~isnan(nav.time));
    nav.etm=nav.etm(~isnan(nav.time));
    nav.time=nav.time(~isnan(nav.time));
    [nav.etm iz]=unique(nav.etm,'first');
    nav.lat=nav.lat(iz);nav.lon=nav.lon(iz);nav.time=nav.time(iz);
    % if time crosses midnight we should add 1 day to the overmidnight part
    test=diff(nav.time);
    if ~isempty(find(test<-0.5,1))
        nav.time(nav.time<1.5)=nav.time(nav.time<1.5)+1;
    end
    % sort GPS time
    [nav.time ix]=sort(nav.time);
    nav.lat=nav.lat(ix);
    nav.lon=nav.lon(ix);
    nav.etm=nav.etm(ix);
    % add starting date to GPS time string
    startdate=floor(time.datenum(1));
    nav.time=nav.time-1+startdate;
else
    pings.navtime=NaN*pings.etm;
    pings.navlat=NaN*pings.etm;
    pings.navlon=NaN*pings.etm;
end
% add a datenum field to the pings structure

% trim the fields..
if ntimes>0
  time.etm=time.etm(1:ntimes);
  time.datenum=time.datenum(1:ntimes);
end;

if npings>0
  pings.etm = pings.etm(1:npings);
  pings.sample = pings.sample(:,1:npings);
end
if nbot>0
  bottom.etm=bottom.etm(1:nbot);
  bottom.pn=bottom.pn(1:nbot);
  bottom.etm=bottom.etm(1:nbot);
  bottom.valid=bottom.valid(1:nbot);
  bottom.range=bottom.range(1:nbot);
end;
if npos>0
  pos.lat=pos.lat(1:npos);
  pos.lon=pos.lon(1:npos);
  pos.etm=pos.etm(1:npos);
  if isfield(pos,'alt')
    pos.alt=pos.alt(1:npos);
  end
end;
% remove outliers in systime
pings.etm(pings.etm>pings.etm(end) | pings.etm<pings.etm(1))=NaN;
time.etm(time.etm>time.etm(end) | time.etm<time.etm(1))=NaN;
% fill gaps
good=find(~isnan(pings.etm));
pings.etm=interp1(good,pings.etm(good),[1:length(pings.etm)]);
good=find(~isnan(time.etm));
time.etm=interp1(good,time.etm(good),[1:length(time.etm)]);
% sort the fields (time/data in fields are often not in order)
[pings.etm ip]=sort(pings.etm);
pings.sample=pings.sample(:,ip);
[time.etm ip]=sort(time.etm);
time.datenum=time.datenum(ip);
[time.etm,ii]=unique(time.etm);
time.datenum=time.datenum(ii);
pings.datenum=interp1(time.etm,time.datenum,pings.etm,'linear','extrap');
% pings.datenum=interp1(1:length(time.datenum),time.datenum,...
%     1:(length(time.datenum)-1)/(length(pings.etm)-1):length(time.datenum),'linear','extrap');
if exist('pos','var')
    % remove outliers in systime
    pos.etm(pos.etm>pos.etm(end) | pos.etm<pos.etm(1))=NaN;
    % fill gaps
    good=find(~isnan(pos.etm));
    pos.etm=interp1(good,pos.etm(good),[1:length(pos.etm)]);
    [pos.etm,it]=unique(pos.etm,'first');
    pos.lon=pos.lon(it);pos.lat=pos.lat(it);
    % sort the fields (time/data in fields are often not in order)
    [pos.etm ip]=sort(pos.etm);
    pos.lon=pos.lon(ip);
    pos.lat=pos.lat(ip);
    % 
    if length(pos.lon)>1
        pings.lon=interp1(pos.etm,pos.lon,pings.etm,'linear','extrap');
        pings.lat=interp1(pos.etm,pos.lat,pings.etm,'linear','extrap');
    end
end
if exist('bottom','var')
    % remove outliers in systime
    bottom.etm(bottom.etm>bottom.etm(end) | bottom.etm<bottom.etm(1))=NaN;
    % fill gaps
    good=find(~isnan(bottom.etm));
    bottom.etm=interp1(good,bottom.etm(good),[1:length(bottom.etm)]);
    [bottom.etm,it]=unique(bottom.etm,'first');
    bottom.valid=bottom.valid(it);bottom.range=bottom.range(it);
    % sort the fields (time/data in fields are often not in order)
    [bottom.etm ip]=sort(bottom.etm);
    bottom.valid=bottom.valid(ip);
    bottom.range=bottom.range(ip);
    bottom.range(bottom.valid==0)=NaN;
    if length(bottom.range)>1
        pings.bottom=interp1(bottom.etm,bottom.range,pings.etm,'linear','extrap')+pings.head.dpt;
    end
end

if exist('nav','var')
    warning off
    if isfield(nav,'lon')
        if length(nav.lon)>1
            pings.navtime=interp1(nav.etm,nav.time,pings.etm,'linear','extrap');
            pings.navlon=interp1(nav.etm,nav.lon,pings.etm,'linear','extrap');
            pings.navlat=interp1(nav.etm,nav.lat,pings.etm,'linear','extrap');
%             pings.navtime=interp1(1:length(nav.time),nav.time,...
%                 1:(length(nav.time)-1)/(length(pings.etm)-1):length(nav.time),'linear','extrap');
%             pings.navlat=interp1(1:length(pos.lat),pos.lat,...
%                 1:(length(pos.lat)-1)/(length(pings.etm)-1):length(pos.lat),'linear','extrap');
%             pings.navlon=interp1(1:length(pos.lon),pos.lon,...
%                 1:(length(pos.lon)-1)/(length(pings.etm)-1):length(pos.lon),'linear','extrap');
        end
    end
end
% Make the depth field
if isfield(pings.head,'ib')
    pings.depth = pings.head.dpt+0.5*pings.head.sv*...
        pings.head.sp*[pings.head.ib+(1:size(pings.sample,1))]';
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
  pings.etm=pings.etm(horizontalsubsample:horizontalsubsample:end);
  pings.datenum=pings.datenum(horizontalsubsample:horizontalsubsample:end);
  pings.navtime=pings.navtime(horizontalsubsample:horizontalsubsample:end);
  pings.navlat=pings.navlat(horizontalsubsample:horizontalsubsample:end);
  pings.navlon=pings.navlon(horizontalsubsample:horizontalsubsample:end);
  pings.lat=pings.lat(horizontalsubsample:horizontalsubsample:end);
  pings.lon=pings.lon(horizontalsubsample:horizontalsubsample:end);
  pings.pn=pings.pn(horizontalsubsample:horizontalsubsample:end);
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
  pings.depth = pings.depth([verticalsubsample:verticalsubsample:end]); 
end
range=repmat(pings.depth-pings.head.dpt,1,length(pings.pn));
if pings.head.ab==0
    % CHECK REFERENCES AND FIND AN EQUATION!!!!!!!
    pings.head.ab=0.036;
end
if isfield(pings,'sample') % single-beam unit
    % Compute volume backscattering strength in dB
    psi=pings.head.bwy/20*pings.head.bwx/20*10^(-3.16);
    pings.Sv=20*log10(pings.sample)-(pings.head.sl+pings.head.rs+pings.head.tpov)+...
        20*log10(range)+2*pings.head.ab.*range-10*log10(pings.head.sv.*...
        pings.head.pud.*psi/2)+pings.head.corr;
    % Compute target strength in dB
    pings.TS=20*log10(pings.sample)-(pings.head.sl+pings.head.rs+pings.head.tpov)+...
        40*log10(range)+2*pings.head.ab.*range+pings.head.corr;
    pings.readme=strvcat('sample - data in counts','Sv - volume backscattering strength in dB',...
        'TS - target strength in dB');
elseif isfield(pings,'nbsample') % dual-beam unit
    % --- Sv & TS for narrow-beam data ----------
    % Compute volume backscattering strength in dB
    psi=pings.head.bwy/20*pings.head.bwx/20*10^(-3.16);
    pings.nbSv=20*log10(pings.nbsample)-(pings.head.sl+pings.head.rs+pings.head.tpov)+...
        20*log10(range)+2*pings.head.ab.*range-10*log10(pings.head.sv.*...
        pings.head.pud.*psi/2)+pings.head.corr;
    % Compute target strength in dB
    pings.nbTS=20*log10(pings.nbsample)-(pings.head.sl+pings.head.rs+pings.head.tpov)+...
        40*log10(range)+2*pings.head.ab.*range+pings.head.corr;
    % --- Sv & TS for wide-beam data ----------
    % Compute volume backscattering strength in dB
    psi=pings.head.bwwy/20*pings.head.bwwx/20*10^(-3.16);
    pings.wbSv=20*log10(pings.wbsample)-(pings.head.sl+pings.head.rsw+pings.head.tpov)+...
        20*log10(range)+2*pings.head.ab.*range-10*log10(pings.head.sv.*...
        pings.head.pud.*psi/2)+pings.head.corrwide;
    % Compute target strength in dB
    pings.wbTS=20*log10(pings.wbsample)-(pings.head.sl+pings.head.rsw+pings.head.tpov)+...
        40*log10(range)+2*pings.head.ab.*range+pings.head.corrwide;
    % Compensated target strangth in dB
    pings.TS=pings.nbTS+(pings.wbTS-pings.nbTS).*(pings.head.bwwx.^2/(pings.head.bwwx.^2-pings.head.bwx.^2));
    pings.readme=strvcat('nbsample - narrow-beam data in counts',...
        'nbSv - volume backscattering strength for narrow-beam data in dB',...
        'nbTS - target strength for narrow-beam data in dB',...
        'wbsample - wide-beam data in counts',...
        'wbSv - volume backscattering strength for wide-beam data in dB',...
        'wbTS - target strength for wide-beam data in dB',...
        'TS - compensated target strength in dB');
end
return;
%%%%%%%%%%%%%% Done main function %%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tuple = readtuple(fin)
  tuple.dsize = fread(fin,1,'uint16=>double');
  tuple.type = fread(fin,1,'uint16');
  if isempty(tuple.type)
    return
  end;
  
  switch tuple.type
   case hex2dec('FFFF')
     tuple = bio_decode_sig_tuple(tuple,fin); % signature tuple
   case hex2dec('001E')
     tuple = bio_decode_headerV3_tuple(tuple,fin); % V3 file header tuple 
   case hex2dec('0018')
     tuple = bio_decode_headerV2_tuple(tuple,fin); % V2 file header tuple
   case hex2dec('0012')
     tuple = bio_decode_ch_tuple(tuple,fin); % channel descriptor tuple
   case hex2dec('0036')
     tuple = bio_decode_extch_tuple(tuple,fin); % extended channel descriptor tuple
   case hex2dec('0015')
     tuple = bio_decode_ping1_tuple(tuple,fin); % single-beam ping tupple
   case hex2dec('001C')
     tuple = bio_decode_ping2_tuple(tuple,fin); % dual-beam ping tupple
%    case hex2dec('001D')
%      tuple = bio_decode_ping2_tuple(tuple,fin); % split-beam ping tupple
   case {hex2dec('000F'),hex2dec('0020')} % time tuple
     tuple = bio_decode_time_tuple(tuple,fin);
   case hex2dec('000E')
     tuple=bio_decode_position_tuple(tuple,fin); % position tuple
   case hex2dec('0011')
     tuple=bio_decode_navstring_tuple(tuple,fin); % navigation string tuple
   case hex2dec('0030')
     tuple=bio_decode_timestampednavstring_tuple(tuple,fin); % timestamped navigation string tuple
   case hex2dec('0032')
     tuple=bio_decode_bottom_tuple(tuple,fin); % bottom pick tuple
   case {hex2dec('FE00'),hex2dec('FFFE')} % END OF FILE TUPLE. In file format description it is FFFE!!!
     return
   otherwise 
     fseek(fin,tuple.dsize,'cof');
     tuple.size = fread(fin,1,'uint16=>double');
  end;
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function tuple = bio_decode_sig_tuple(tuple,fin) % signature tuple
  tuple.m1 = fread(fin,1,'uint16');
  if tuple.m1~=hex2dec('ADFF')
      disp('Invalid file format!')
      return
  end
  fseek(fin,8,'cof');
  tuple.m2 = fread(fin,1,'uint32=>double');
  if tuple.m2~=hex2dec('FEF82111')
      disp('Invalid file format!')
      return
  end
  tuple.vmjr = fread(fin,1,'uint8=>double');
  tuple.vmnr = fread(fin,1,'uint8=>double');
  fseek(fin,tuple.dsize-16,'cof'); % skip unknown (for now) fields
  tuple.size = fread(fin,1,'uint16=>double');
return;

function tuple = bio_decode_headerV3_tuple(tuple,fin) % V3 file header tuple
  tuple.ab = fread(fin,1,'uint16=>double')*0.0001; % absorbtion coefficient in dB/m
  tuple.sv = fread(fin,1,'uint16=>double')*0.0025 + 1400; % sound velocity in m/s
  tuple.tmp = fread(fin,1,'int16=>double')*0.01; % water temperature in degrees
  tuple.sa = fread(fin,1,'uint16=>double')*0.01; % water salinity in ppt
  tuple.tpov = fread(fin,1,'int16=>double')*0.1; % transmit power reduction factor, in dB
  tuple.nch = fread(fin,1,'uint16=>double');  % number of channel descriptor tuples, if 0 the file is corrupted 
  switch tuple.dsize
      case hex2dec('000C') % pre DT4v2.3 file
          fseek(fin,tuple.dsize-12,'cof'); % safety cushion
      case hex2dec('0010') % DT4v2.3 file
          tuple.tz = fread(fin,1,'int16=>double')*60; % timezone, as offset from GMT in seconds, a value 1966020 indicates timezone is unknown
          tuple.dst = fread(fin,1,'uint16=>double'); % indicates whether Daylight Saving Time is in effect (0 - it is not)
          fseek(fin,tuple.dsize-16,'cof'); % safety cushion
      otherwise 
          tuple.tz = fread(fin,1,'int16=>double')*60; % timezone, as offset from GMT in seconds, a value 1966020 indicates timezone is unknown
          tuple.dst = fread(fin,1,'uint16=>double'); % indicates whether Daylight Saving Time is in effect (0 - it is not)
          fseek(fin,tuple.dsize-16,'cof'); % skip unknown (for now) fields
  end
  tuple.size = fread(fin,1,'uint16=>double');
return;

function tuple = bio_decode_headerV2_tuple(tuple,fin) % V2 file header tuple
  tuple.ab = fread(fin,1,'uint16=>double')*0.0001; % absorbtion coefficient in dB/m. Should not be used - see V3 file header tuple.
  tuple.sv = fread(fin,1,'uint16=>double')*0.0025 + 1400; % sound velocity in m/s. Should not be used - see V3 file header tuple.
  tuple.tmp = fread(fin,1,'int16=>double')*0.01; % water temperature in degrees
  tuple.sa = fread(fin,1,'uint16=>double')*0.01; % water salinity in ppt
  tuple.nch = fread(fin,1,'uint16=>double'); % number of channel descriptor tuples; if 0, the file is corrupted
  fseek(fin,tuple.dsize-10,'cof'); % skip unknown (for now) fields
  tuple.size = fread(fin,1,'uint16=>double');
return;

function tuple = bio_decode_ch_tuple(tuple,fin) % channel descriptor tuple
  tuple.ch = fread(fin,1,'uint16=>double'); % numeric label for this channel
  tuple.np = fread(fin,1,'uint32=>double'); % number of pings on this ch present in the file. If 0 the file is corrupt or no data
  tuple.spp = fread(fin,1,'uint16=>double'); % samples per ping
  tuple.sp = fread(fin,1,'uint16=>double')*1e-9; % sample period in s
  fseek(fin,2,'cof');
  tuple.pud = fread(fin,1,'uint16=>double')*1e-6; % pulse duration in s
  tuple.pp = fread(fin,1,'uint16=>double')*1e-3; % number of seconds between pings (requested)
  tuple.ib = fread(fin,1,'uint16=>double'); % initial blanking (number of samples skipped before data recording begins in each ping)
  fseek(fin,2,'cof');
  tuple.th = fread(fin,1,'int16=>double')*0.01; % the data collection threeshold in dB
  % *** Read Receiver EEPROM image ***
  %  tuple.receivereeprom = fread(fin,128,'uchar=>char'); % 
  fseek(fin,2,'cof');
  tuple.sn = fread(fin,8,'uchar=>char')'; % head serial number (shortened)
  fseek(fin,26,'cof');
  tuple.cald = fread(fin,1,'uint32=>double'); % calibration date (UNIX time)
  fseek(fin,12,'cof');
  tuple.tech = fread(fin,4,'uchar=>char')'; % tech initials
  fseek(fin,2,'cof');
  tuple.sl = fread(fin,1,'uint16=>double')*0.1; % source level in dB
  fseek(fin,4,'cof');
  tuple.rs = fread(fin,1,'int16=>double')*0.1; % receiver sensitivity for the main element in dB
  fseek(fin,10,'cof');
  tuple.rsw = fread(fin,1,'int16=>double')*0.1; % receiver sensitivity for the wide-beam or phase elements in dB
  fseek(fin,2,'cof');
  tuple.pdpy = fread(fin,1,'uint8=>double'); % sign of split-beam y-axis element separation (zero - positive, nonzero - nagative)
  tuple.pdpx = fread(fin,1,'uint8=>double'); % sign of split-beam x-axis element separation (zero - positive, nonzero - nagative)
  tuple.nf = fread(fin,1,'uint16=>double'); % noise floor for the transducer in counts (max observed value due to system noise)
  tuple.trtype = fread(fin,1,'uint16=>double'); % transducer type (hardware, not usage mode). 0-single beam, 3-dual beam, 4-split-beam 
  tuple.fq = fread(fin,1,'uint32=>double'); % frequency of the transducer in Hz
  tuple.pdy = fread(fin,1,'uint16=>double'); % absolute value of the split-beam y-axis separation, in units of 0.01 mm (pdpy gives sign information)
  tuple.pdx = fread(fin,1,'uint16=>double'); % absolute value of the split-beam x-axis separation, in units of 0.01 mm (pdpx gives sign information)
  tuple.phpy = fread(fin,1,'int8=>double'); % split-beam y-axis element polarity (+/-1)
  tuple.phpx = fread(fin,1,'int8=>double'); % split-beam x-axis element polarity (+/-1)
  tuple.aoy = fread(fin,1,'int16=>double')*0.01; % split-beam y-axis angle offset in units of degrees
  tuple.aox = fread(fin,1,'int16=>double')*0.01; % split-beam x-axis angle offset in units of degrees
  tuple.bwy = fread(fin,1,'uint8=>double')*0.1; % y-axis -3dB one-way beamwidth for the main element, in degrees
  tuple.bwx = fread(fin,1,'uint8=>double')*0.1; % x-axis -3dB one-way beamwidth for the main element, in degrees
  tuple.smpr = fread(fin,1,'uint32=>double'); % sample rate of the A/D converter, in HzIn most, but not all, transducers this is 41667. Thius field and the sp field in the ch descriptor are related by sp=1000000000/smpr
  tuple.bwwy = fread(fin,1,'uint8=>double')*0.1; % y-axis -3dB one-way beamwidth for the wide-beam or phase elements, in degrees
  tuple.bwwx = fread(fin,1,'uint8=>double')*0.1; % x-axis -3dB one-way beamwidth for the wide-beam or phase elements, in degrees
  tuple.phy = fread(fin,1,'uint16=>double')*0.1; % the split-beam y-axis phase aperture, in degrees
  tuple.phx = fread(fin,1,'uint16=>double')*0.1; % the split-beam x-axis phase aperture, in degrees
  fseek(fin,16,'cof');
  % ***********************************
  fseek(fin,128,'cof');
  tuple.corr = fread(fin,1,'int16=>double')*0.01; % user-defined calibration correction (in dual-beam applies only to narrow-beam), in dB;
  if tuple.dsize==hex2dec('011A')
      fseek(fin,2,'cof');
      fseek(fin,tuple.dsize-282,'cof'); % skip unknown (for now) fields
  end
  fseek(fin,tuple.dsize-280,'cof'); % safety cushion
  tuple.size = fread(fin,1,'uint16=>double');
return;

function tuple = bio_decode_extch_tuple(tuple,fin) % extended channel descriptor tuple
  tuple.ch = fread(fin,1,'uint16=>double'); % channel number
  tuple.corrwide = fread(fin,1,'int16=>double')*0.01; % user-defined calibration correction in dB
  tuple.thtyp = fread(fin,1,'uint16=>double'); % equal 40 if the data was collected with Visual Aqcuisition 6, or with "squared"
                                               % threshold mode of VA 4 or 5; equal to 20 if the data were collected with the
                                               % "linear" threeshold; equal to 0 if the data were collected with the "constant" threshold mode
  tuple.putyp = fread(fin,1,'uint16=>double'); % equal 0 if the data were collected in passive mode, or 1 in active mode
  tuple.dpt = fread(fin,1,'float32=>double'); % depth in meters of the transducer
  tuple.ph = fread(fin,1,'float32=>double'); % PH value for this transducer
  fseek(fin,tuple.dsize-16,'cof'); % safety cushion
  tuple.size = fread(fin,1,'uint16=>double');
return;

function tuple = bio_decode_ping1_tuple(tuple,fin) % single-beam ping tupple
  tuple.ch = fread(fin,1,'uint16=>double'); % channel number
  tuple.pn = fread(fin,1,'uint32=>double'); % ping number
  tuple.etm = fread(fin,1,'uint32=>double'); % ellapsed system tyme, ms
  tuple.ns = fread(fin,1,'uint16=>double');  
  samples = fread(fin,tuple.ns,'uint16=>uint16');
  % The data is stored in a 16 bit float - the first four bits are the exponent,
  % the last 12 bits are the mantissa, where the biosonics output is M * 2^E 
  mantissa=uint32(bitand(uint16(samples),uint16(ones(size(samples))*4095)));
  exponent=bitshift(samples,-12);
  tuple.samples=double(mantissa);
  tuple.samples(exponent>0)=double(bitshift((mantissa(exponent>0)+4096),(exponent(exponent>0)-1)));
  fseek(fin,tuple.dsize-(12+tuple.ns*2),'cof'); % skip unknown (for now) fields
  tuple.size = fread(fin,1,'uint16');
return;

function tuple = bio_decode_ping2_tuple(tuple,fin) % dual-beam ping tupple
  tuple.ch = fread(fin,1,'uint16=>double');
  tuple.pn = fread(fin,1,'uint32=>double'); % ping number
  tuple.etm = fread(fin,1,'uint32=>double'); % ellapsed system time, ms
  tuple.ns = fread(fin,1,'uint16=>double');  
  samples = fread(fin,tuple.ns,'uint32=>uint32');
  % Low-order word in samples contains the narrow-beam data and high-order word
  % contains the wide-beam data
  % THE FOLLOWING TWO LINES MIGHT BE WRONG!!!
  wbsamples=bitshift(samples,-16);
  nbsamples=uint16(bitand(uint16(samples),uint16(ones(size(samples))*65535)));
  % The data is stored in a 16 bit float - the first four bits are the exponent,
  % the last 12 bits are the mantissa, where the biosonics output is M * 2^E 
  % The data is stored in a 16 bit float - the first four bits are the exponent,
  % the last 12 bits are the mantissa, where the biosonics output is M * 2^E 
  wbmantissa=uint32(bitand(uint16(wbsamples),uint16(ones(size(wbsamples))*4095)));
  wbexponent=bitshift(wbsamples,-12);
  nbmantissa=uint32(bitand(uint16(nbsamples),uint16(ones(size(nbsamples))*4095)));
  nbexponent=bitshift(nbsamples,-12);
  tuple.wbsamples=double(wbmantissa);
  tuple.wbsamples(wbexponent>0)=double(bitshift((wbmantissa(wbexponent>0)+4096),(wbexponent(wbexponent>0)-1)));
  tuple.nbsamples=double(nbmantissa);
  tuple.nbsamples(nbexponent>0)=double(bitshift((nbmantissa(nbexponent>0)+4096),(nbexponent(nbexponent>0)-1)));
  fseek(fin,tuple.dsize-(12+tuple.ns*4),'cof'); % skip unknown (for now) fields
  tuple.size = fread(fin,1,'uint16');
return;

function tuple = bio_decode_time_tuple(tuple,fin) % time tuple
  tuple.time = fread(fin,1,'uint32=>double');
  source = fread(fin,1,'uchar=>uint8');
  tuple.subsecond = fread(fin,1,'uchar');
  tuple.etm = fread(fin,1,'uint32=>double'); % system time, ms
  fseek(fin,tuple.dsize-10,'cof'); % skip unknown (for now) fields
  tuple.size = fread(fin,1,'uint16=>double');
  % lets provide a Matlab datenum...
  % tuple.time is seconds from 00:00:00 1/1/70...
  tuple.datenum = tuple.time/(86400);  % convert to days from seconds
  tuple.datenum = tuple.datenum+datenum(1970,1,1,0,0,0);
  % check if there is any subsecond data
  if tuple.subsecond>128
    tuple.subsecond = tuple.subsecond-128;
  end;
  tuple.datenum = tuple.datenum+tuple.subsecond/(86400*100);
  % good to 100ths of a second....
  if source==hex2dec('00')
      tuple.source='time is not valid';
  elseif source==hex2dec('02')
      tuple.source='system time';
  elseif source==hex2dec('11')
      tuple.source='GPS time';
  else
      tuple.source='unknown time source';
  end
return;

function tuple = bio_decode_position_tuple(tuple,fin) % position tuple
  tuple.lat = fread(fin,1,'int32=>double')*1e-5/60; % latitude
  tuple.lon = fread(fin,1,'int32=>double')*1e-5/60; % longitude
  psrc = fread(fin,1,'uchar=>uint8'); 
  fseek(fin,1,'cof');
  if tuple.dsize==hex2dec('000A')
      fseek(fin,tuple.dsize-10,'cof');
  else
      tuple.etm = fread(fin,1,'uint32=>double'); % system time in ms
      tuple.alt = fread(fin,1,'float32=>double'); % altitude in meters
      fseek(fin,tuple.dsize-18,'cof');
  end 
  tuple.size = fread(fin,1,'uint16');
  if psrc==hex2dec('00')
      tuple.psrc='position is not valid';
  elseif psrc==hex2dec('11')
      tuple.psrc='GPS position';
  else
      tuple.psrc='unknown position source';
  end
return;

function tuple = bio_decode_navstring_tuple(tuple,fin) % navigation string tuple
  tuple.navstring = fread(fin,tuple.dsize,'schar=>char');
  tuple.size = fread(fin,1,'uint16=>double');
return;

function tuple = bio_decode_timestampednavstring_tuple(tuple,fin) % time stamped navigation string tuple
  tuple.etm = fread(fin,1,'uint32=>double'); % system time in ms
  tuple.strlen = fread(fin,1,'uint16'); % length of string data in bytes
  tuple.navstring = fread(fin,tuple.strlen,'schar=>char');
  tuple.size = fread(fin,1,'uint16=>double');
return;

function tuple = bio_decode_bottom_tuple(tuple,fin) % time stamped navigation string tuple
  tuple.ch = fread(fin,1,'uint16=>double'); % channel number
  tuple.pn= fread(fin,1,'uint32=>double'); % ping number
  tuple.etm = fread(fin,1,'uint32=>double'); % system time in ms
  tuple.valid = fread(fin,1,'uint16'); % flag indicating whether a bottom pick was found
  tuple.samplenum = fread(fin,1,'uint32=>double'); % sample number of pick
  tuple.range = fread(fin,1,'float32=>double'); % range to bottom, in meters
  tuple.size = fread(fin,1,'uint16=>double');
return;