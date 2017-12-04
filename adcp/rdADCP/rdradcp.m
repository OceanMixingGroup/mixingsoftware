function [adcp,cfg,ens,hdr]=rdradcp(name,varargin);
% RDRADCP  Read (raw binary) RDI ADCP files, 
%  ADCP=RDRADCP(NAME) reads the raw binary RDI BB/Workhorse ADCP file NAME and
%  puts all the relevant configuration and measured data into a data structure 
%  ADCP (which is self-explanatory). This program is designed for handling data
%  recorded by moored instruments (primarily Workhorse-type but can also read
%  Broadband) and then downloaded post-deployment. For vessel-mount data I
%  usually make p-files (which integrate nav info and do coordinate transformations)
%  and then use RDPADCP. 
%
%  This current version does have some handling of VMDAS, WINRIVER, and WINRIVER2 output
%  files, but it is still 'beta'. There are (inadequately documented) timestamps
% of various kinds from VMDAS, for example, and caveat emptor on WINRIVER2 NMEA data.
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
%         last record to read). I don't handle bad data very well. Also - in Aug/2007
%         I discovered that WINRIVER-2 files can have a varying number of bytes per
%         ensemble. Thus the estimated number of ensembles in a file (based on the
%         length of the first ensemble and file size) can be too high or too low.
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
%  'type'       : [0 | 1 ]
%                 You can set up VMDAS with OS instruments to do both NB and BB
%                 pings. Use this to choose between the different ping types
%                 (i.e. read once with '0' for the NB data, again with '1' for BB
%                  data).
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
%   13/Aug/2007 - added Rio Grande (firmware v 10), 
%                 better handling of those cursed winriver ASCII NMEA blocks whose
%                 lengths change unpredictably.
%                 skipping the inadequately documented 2022 WINRIVER-2 NMEA block
%   13/Mar/2010 - firmware version 50 for WH.
%   12/Sep/2011 - firmware version 34 for DVL
%          2014 - add different 'type's for VMDAS multi-ping setups.
%   13/Mar/2015 - WINRIVER-II handler for GPS
%   20/Jun/2016 - Added Sentinel V-series support
%   19/Jul/2017 - added support for Vertical beam in V-series ADCPs

global STANDARD

num_av=5;   % Block filtering and decimation parameter (# ensembles to block together).
nens=-1;   % Read all ensembles.
century=2000;  % ADCP clock does not have century prior to firmware 16.05.
vels='no';   % Default to simple averaging
STANDARD=-1;  % Default to ignoring this.

lv=length(varargin);
if lv>=1 & ~isstr(varargin{1}),
  num_av=varargin{1}; % Block filtering and decimation parameter (# ensembles to block together).
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
	 case 'typ',  
	    STANDARD=varargin{2};  % Read type 0 or 1 for VMDAS-OS with two types of ping
	 otherwise,
	   error(['Unknown command line option  ->' varargin{1}]);
   end;
   varargin([1 2])=[];
end;   	          	




% Check file information first

naminfo=dir(name);

if isempty(naminfo),
  fprintf('ERROR******* Can''t find file %s\n',name);
  return;
end;

fprintf('\nOpening file %s\n\n',name);
fd=fopen(name,'r','ieee-le');

% Read first ensemble to initialize parameters
 
[ens,hdr,cfg,pos]=rd_buffer(fd,-2); % Initialize and read first two records
if ~isstruct(ens) & ens==-1,
  disp('No Valid data found');
  adcp=[];
  return;
end;  
fseek(fd,pos,'bof');              % Rewind

% This is a fix for not getting century right in early firmware versions

if (cfg.prog_ver<16.05 & cfg.prog_ver>5.999) | cfg.prog_ver<5.55 | (cfg.prog_ver>=23 & cfg.prog_ver<30),
  fprintf('***** Assuming that the century begins year %d (info not in this firmware version) \n\n',century);
else
  century=0;  % century included in clock.  
end;

dats=datenum(century+ens.rtc(1,:),ens.rtc(2,:),ens.rtc(3,:),ens.rtc(4,:),ens.rtc(5,:),ens.rtc(6,:)+ens.rtc(7,:)/100);
t_int=diff(dats);
fprintf('Record begins at %s\n',datestr(dats(1),0));
fprintf('Ping interval appears to be  %s\n',datestr(t_int,'HH:MM:SS.FFF'));


% Estimate number of records (since I don't feel like handling EOFs correctly,
% we just don't read that far!)

nensinfile=fix(naminfo.bytes/(hdr.nbyte+2));
fprintf('\nEstimating %d ensembles in this file\n',nensinfile);  

if length(nens)==1,
  if nens==-1,
    nens=nensinfile;
  end; 
  fprintf('   Reading %d ensembles, reducing by a factor of %d\n',nens,num_av); 
else
  fprintf('   Reading ensembles %d-%d, reducing by a factor of %d\n',nens,num_av); 
  fseek(fd,(hdr.nbyte+2)*(nens(1)-1),'cof');
  nens=diff(nens)+1;
end;

% Number of records after averaging.

n=fix(nens/num_av);
fprintf('Final result %d values\n',n); 

if num_av>1,
  if isstr(vels),
     fprintf('\n Simple mean used for ensemble averaging\n');
  else
     fprintf('\n Averaging after outlier rejection with parameters [%f %f %f]\n',vels);
  end;
end;
   

% Structure to hold all ADCP data 
% Note that I am not storing all the data contained in the raw binary file, merely
% things I think are useful.

switch cfg.sourceprog,
  case {'WINRIVER','WINRIVER2'}
    adcp=struct('name','adcp','config',cfg,'mtime',zeros(1,n),'number',zeros(1,n),'pitch',zeros(1,n),...
        	'roll',zeros(1,n),'heading',zeros(1,n),'pitch_std',zeros(1,n),...
        	'roll_std',zeros(1,n),'heading_std',zeros(1,n),'depth',zeros(1,n),...
        	'temperature',zeros(1,n),'salinity',zeros(1,n),...
        	'pressure',zeros(1,n),'pressure_std',zeros(1,n),...
		'coords','',...
        	'east_vel',zeros(cfg.n_cells,n),'north_vel',zeros(cfg.n_cells,n),'vert_vel',zeros(cfg.n_cells,n),...
        	'error_vel',zeros(cfg.n_cells,n),'corr',zeros(cfg.n_cells,4,n),...
        	'status',zeros(cfg.n_cells,4,n),'intens',zeros(cfg.n_cells,4,n),...
	        'bt_range',zeros(4,n),'bt_vel',zeros(4,n),...
		'bt_corr',zeros(4,n),'bt_ampl',zeros(4,n),'bt_perc_good',zeros(4,n),...
		'nav_mtime',zeros(1,n),...
                'nav_longitude',zeros(1,n),'nav_latitude',zeros(1,n));
  case 'VMDAS',
    adcp=struct('name','adcp','config',cfg,'mtime',zeros(1,n),'number',zeros(1,n),'pitch',zeros(1,n),...
        	'roll',zeros(1,n),'heading',zeros(1,n),'pitch_std',zeros(1,n),...
        	'roll_std',zeros(1,n),'heading_std',zeros(1,n),'depth',zeros(1,n),...
        	'temperature',zeros(1,n),'salinity',zeros(1,n),...
        	'pressure',zeros(1,n),'pressure_std',zeros(1,n),...
		'coords','',...
        	'east_vel',zeros(cfg.n_cells,n),'north_vel',zeros(cfg.n_cells,n),'vert_vel',zeros(cfg.n_cells,n),...
        	'error_vel',zeros(cfg.n_cells,n),'corr',zeros(cfg.n_cells,4,n),...
        	'status',zeros(cfg.n_cells,4,n),'intens',zeros(cfg.n_cells,4,n),...
	        'bt_range',zeros(4,n),'bt_vel',zeros(4,n),...
		'bt_corr',zeros(4,n),'bt_ampl',zeros(4,n),'bt_perc_good',zeros(4,n),...
	        'nav_smtime',zeros(1,n),'nav_emtime',zeros(1,n),...
	        'nav_slongitude',zeros(1,n),'nav_elongitude',zeros(1,n),...
	        'nav_slatitude',zeros(1,n),'nav_elatitude',zeros(1,n),...
	        'nav_speedmadegd',zeros(1,n),'nav_direcmadegd',zeros(1,n),'nav_mtime',zeros(1,n));
  otherwise 
    adcp=struct('name','adcp','config',cfg,'mtime',zeros(1,n),'number',zeros(1,n),'pitch',zeros(1,n),...
        	'roll',zeros(1,n),'heading',zeros(1,n),'pitch_std',zeros(1,n),...
        	'roll_std',zeros(1,n),'heading_std',zeros(1,n),'depth',zeros(1,n),...
        	'temperature',zeros(1,n),'salinity',zeros(1,n),...
        	'pressure',zeros(1,n),'pressure_std',zeros(1,n),...
		'coords','',...
        	'east_vel',zeros(cfg.n_cells,n),'north_vel',zeros(cfg.n_cells,n),'vert_vel',zeros(cfg.n_cells,n),...
        	'error_vel',zeros(cfg.n_cells,n),'corr',zeros(cfg.n_cells,4,n),...
        	'status',zeros(cfg.n_cells,4,n),'intens',zeros(cfg.n_cells,4,n),...
		'bt_range',zeros(4,n),'bt_vel',zeros(4,n),...
		'bt_corr',zeros(4,n),'bt_ampl',zeros(4,n),'bt_perc_good',zeros(4,n));
end;


% Calibration factors for backscatter data

clear global ens
% Loop for all records
fprintf('\n    0');
for k=1:n,

  % Gives a display so you know something is going on...
    
  if rem(k,50)==0,  
     fprintf('\n%5d',k*num_av);
  else  
     fprintf('.');
  end;
  
  % Read an ensemble
  
  ens=rd_buffer(fd,num_av);

  if ~isstruct(ens), % If aborting...
    fprintf('Only %d records found..suggest re-running RDRADCP using this parameter\n',(k-1)*num_av);
    fprintf('(If this message preceded by a POSSIBLE PROGRAM PROBLEM message, re-run using %d)\n',(k-1)*num_av-1);
    break;
  end;
    
  dats=datenum(century+ens.rtc(1,:),ens.rtc(2,:),ens.rtc(3,:),ens.rtc(4,:),ens.rtc(5,:),ens.rtc(6,:)+ens.rtc(7,:)/100);
  adcp.mtime(k)=median(dats);  
  adcp.number(k)      =ens.number(1);
  adcp.heading(k)     =mean(ens.heading);
  adcp.pitch(k)       =mean(ens.pitch);
  adcp.roll(k)        =mean(ens.roll);
  adcp.heading_std(k) =mean(ens.heading_std);
  adcp.pitch_std(k)   =mean(ens.pitch_std);
  adcp.roll_std(k)    =mean(ens.roll_std);
  adcp.depth(k)       =mean(ens.depth);
  adcp.temperature(k) =mean(ens.temperature);
  adcp.salinity(k)    =mean(ens.salinity);
  adcp.pressure(k)    =mean(ens.pressure);
  adcp.pressure_std(k)=mean(ens.pressure_std);

  if isstr(vels),
    adcp.east_vel(:,k)    =nmean(ens.east_vel ,2);
    adcp.north_vel(:,k)   =nmean(ens.north_vel,2);
    adcp.vert_vel(:,k)    =nmean(ens.vert_vel ,2);
    adcp.error_vel(:,k)   =nmean(ens.error_vel,2);
  else
   adcp.east_vel(:,k)    =nmedian(ens.east_vel  ,vels(1),2);
   adcp.north_vel(:,k)   =nmedian(ens.north_vel,vels(1),2);
   adcp.vert_vel(:,k)    =nmedian(ens.vert_vel  ,vels(2),2);
   adcp.error_vel(:,k)   =nmedian(ens.error_vel,vels(3),2);
  end;
  
  adcp.corr(:,:,k)      =nmean(ens.corr,3);        % added correlation RKD 9/00
  adcp.status(:,:,k)	=nmean(ens.status,3);   
  
  adcp.intens(:,:,k)     =nmean(ens.intens,3);
  adcp.perc_good(:,:,k)  =nmean(ens.percent,3);  % felipe pimenta aug. 2006

  
  adcp.bt_range(:,k)   =nmean(ens.bt_range,2);
  if isstr(vels),                                 % added despiking for botom velocities RP 10/13
    adcp.bt_vel(:,k)     =nmean(ens.bt_vel,2);
  else
    adcp.bt_vel(:,k)= nmedian(ens.bt_vel,vels(1)*1e3,2);
  end;
    
  adcp.bt_corr(:,k)=nmean(ens.bt_corr,2);          % felipe pimenta aug. 2006
  adcp.bt_ampl(:,k)=nmean(ens.bt_ampl,2);          %  "
  adcp.bt_perc_good(:,k)=nmean(ens.bt_perc_good,2);%  " 
    
  % Vertical velocity data?  
  if isfield(ens,'Vvert_vel'),
    if ~isfield(adcp,'Vvert_vel'),  % preallocate if required
       adcp.Vvert_vel=zeros(cfg.Vn_cells,n);
    end;   
    adcp.Vvert_vel(:,k)=mean(ens.Vvert_vel,2);
  end;
  if isfield(ens,'Vintens'),
    if ~isfield(adcp,'Vintens'),    % preallocate if required
       adcp.Vintens=zeros(cfg.Vn_cells,n);
    end;   
    adcp.Vintens(:,k)=mean(ens.Vintens,2);
  end;
    
  switch cfg.sourceprog,
    case {'WINRIVER','WINRIVER2'}
 %%%   disp(datestr(ens.smtime,'HH:MM:SS'));
     adcp.nav_mtime(k)=nmean(ens.smtime);
 %%%   disp(['--' datestr(adcp.nav_mtime(k),'HH:MM:SS')]);
     adcp.nav_longitude(k)=nmean(ens.slongitude);
     adcp.nav_latitude(k)=nmean(ens.slatitude);  
   case 'VMDAS',
     adcp.nav_smtime(k)   =ens.smtime(1);
     adcp.nav_emtime(k)   =ens.emtime(end);
     adcp.nav_slatitude(k)=ens.slatitude(1);
     adcp.nav_elatitude(k)=ens.elatitude(end);
     adcp.nav_slongitude(k)=ens.slongitude(1);
     adcp.nav_elongitude(k)=ens.elongitude(end);
     adcp.nav_speedmadegd(k)=nmean(ens.speedmadegd);
     adcp.nav_direcmadegd(k)=nmean(ens.direcmadegd);
     adcp.nav_mtime(k)=nmean(ens.nmtime);
  end;   
end;  

% Comments to help understand names
switch adcp.config.coord_sys,
  case 'beam',
    adcp.coords='Beam coords: 1=east, 2=north, 3=vert, 4=error';
  case 'instrument',
    adcp.coords='Instrument coords: 1->2=east, 4->3=north, away=vert, error=error';
  case 'ship',
    adcp.coords='Ship coords: beam=east, forward=north, vert=vert, error=error';
  case 'earth',
    adcp.coords='Earth coords: east=east, north=north, vert=vert, error=error';
end;
  
  
fprintf('\n');
fprintf('Read to byte %d in a file of size %d bytes\n',ftell(fd),naminfo.bytes);
if ftell(fd)+hdr.nbyte<naminfo.bytes,
  fprintf('-->There may be another %d ensembles unread\n',fix((naminfo.bytes-ftell(fd))/(hdr.nbyte+2)));
end;
 
fclose(fd);

%----------------------------------------
function valid=checkheader(fd);
% Checks header - valid only if we find the header start
% block for the NEXT block as well (in case 7F7F shows up
% by coincidence) 

%disp('checking');
valid=0;
numbytes=fread(fd,1,'int16');          % Following the header bytes is numbytes               
if numbytes>0,                                         % and we move forward numbytes>0
   status=fseek(fd,numbytes-2,'cof'); 
   if status==0,     
     cfgid=fread(fd,2,'uint8');
     if length(cfgid)==2,                % will Skip the last ensemble (sloppy code)
       fseek(fd,-numbytes-2,'cof');     
    %% fprintf([dec2hex(cfgid(1)) ' ' dec2hex(cfgid(2)) '\n']);          
       if cfgid(1)==hex2dec('7F') & cfgid(2)==hex2dec('7F')          % and we have *another* 7F7F
	 valid=1;                                                    % ...ONLY THEN it is valid.   
       end;
     end;  
   end;  
else    
   fseek(fd,-2,'cof');
end;
     

%-------------------------------------
function [hdr,pos]=rd_hdr(fd);
% Read config data
% Changed by Matt Brennan to skip weird stuff at BOF (apparently
% can happen when switching from one flash card to another
% in moored ADCPs).

cfgid=fread(fd,2,'uint8');
nread=0;
while (cfgid(1)~=hex2dec('7F') | cfgid(2)~=hex2dec('7F'))  | ~checkheader(fd),
    nextbyte=fread(fd,1,'uint8');
    pos=ftell(fd);
    nread=nread+1;
    if isempty(nextbyte),  % End of file
        disp('EOF reached before finding valid cfgid');
	hdr=NaN;
        return;
    end
    cfgid(2)=cfgid(1);cfgid(1)=nextbyte; 
    if mod(pos,1000)==0
        disp(['Still looking for valid cfgid at file position ' num2str(pos) '...'])
    end
end; 

pos=ftell(fd)-2;
if nread>0,
  disp(['Junk found at BOF...skipping ' int2str(nread) ' bytes until ']);
  disp(['cfgid=' dec2hex(cfgid(1)) dec2hex(cfgid(2)) ' at file pos ' num2str(pos)])
end;

hdr=rd_hdrseg(fd);

%-------------------------------------
function cfg=rd_fix(fd);
% Read config data

global STANDARD

cfgid=fread(fd,1,'uint16');
if cfgid~=hex2dec('0000') & cfgid~=hex2dec('0001'),
 warning(['Fixed header ID ' cfgid 'incorrect - data corrupted or not a BB/WH raw file?']);
end; 

%if isempty(STANDARD),   % If not defined, take the first one listed
%  if cfgid==hex2dec('0000'),
%    STANDARD=0;
%  elseif cfgid==hex2dec('0001')
%    STANDARD=1;
%  else
%    warning(['Can''t make sense of Fixed Header ID ' cfgid ]);
%  end;
%end;
  

cfg=rd_fixseg(fd);



%--------------------------------------
function [hdr,nbyte]=rd_hdrseg(fd);
% Reads a Header

hdr.nbyte          =fread(fd,1,'int16');
fseek(fd,1,'cof');
ndat=fread(fd,1,'int8');
hdr.dat_offsets    =fread(fd,ndat,'int16');
nbyte=4+ndat*2;

%-------------------------------------
function opt=getopt(val,varargin);
% Returns one of a list (0=first in varargin, etc.)
if val+1>length(varargin),
	opt='unknown';
else
   opt=varargin{val+1};
end;
   			
%
%-------------------------------------
function [cfg,nbyte]=rd_fixseg(fd);
% Reads the configuration data from the fixed leader


% This is what I know about firmware versions from scouring manuals:
%
% 4,5 - BB-ADCP
% 8,9,16 - WH navigator
% 10 -rio grande
% 11- H-ADCP
% 14, 23 -- Ocean Surveyor
% 15, 17 - NB
% 19 - REMUS, or customer specific (I have no info on this)
% 31 - Streampro
% 34 - NEMO
% 47, 66? - V series
% 50 - WH, no bottom track (built on 16.31)
% 51 - WH, w/ bottom track
% 52 - WH, mariner

% This is what we can handle

cfg.prog_ver       =fread(fd,1,'uint8')+fread(fd,1,'uint8')/100;
switch fix(cfg.prog_ver),
   case {4,5}
      cfg.name='bb-adcp';
   case {8,9,10,16,50,51,52}
      cfg.name='wh-adcp';
   case {14,23}
      cfg.name='os-adcp';
   case {34}
      cfg.name='dvl'   ;    
   case {47}
      cfg.name='V-adcp';   
   otherwise
      cfg.name='unrecognized firmware version'   ;    
end;

% Does data come from the instrument or from WINRIVER or VMDAS?

cfg.sourceprog='instrument';  % default - depending on what data blocks are
                             % around we can modify this later in rd_buffer.


config         =fread(fd,2,'uint8');  % Coded stuff
cfg.config          =[dec2base(config(2),2,8) '-' dec2base(config(1),2,8)];
if strcmp(cfg.name,'V-adcp'),
   cfg.beam_angle     =25;
   cfg.numbeams       =getopt(bitand(config(2),16)==16,4,5);
   cfg.beam_freq      =getopt(bitand(config(1),7),NaN,NaN,300,500,1000,NaN,NaN);
   cfg.beam_pattern   ='convex';  
   cfg.orientation    =getopt(bitand(config(1),128)==128,'down','up');    % 1=up,0=down
else
   cfg.beam_angle     =getopt(bitand(config(2),3),15,20,30,'other');
   cfg.numbeams       =getopt(bitand(config(2),16)==16,4,5);
   cfg.beam_freq      =getopt(bitand(config(1),7),75,150,300,600,1200,2400,38);
   cfg.beam_pattern   =getopt(bitand(config(1),8)==8,'concave','convex'); % 1=convex,0=concave
   cfg.orientation    =getopt(bitand(config(1),128)==128,'down','up');    % 1=up,0=down
end;
cfg.simflag        =getopt(fread(fd,1,'uint8'),'real','simulated'); % Flag for simulated data
cfg.laglength      =fread(fd,1,'uint8'); 
cfg.n_beams        =fread(fd,1,'uint8');
cfg.n_cells        =fread(fd,1,'uint8');
cfg.pings_per_ensemble=fread(fd,1,'uint16');
cfg.cell_size      =fread(fd,1,'uint16')*.01;	 % meters
cfg.blank          =fread(fd,1,'uint16')*.01;	 % meters
cfg.prof_mode      =fread(fd,1,'uint8');         %  For OS this is 1 (BB) or 10 (NB)
cfg.corr_threshold =fread(fd,1,'uint8');
cfg.n_codereps     =fread(fd,1,'uint8');
cfg.min_pgood      =fread(fd,1,'uint8');
cfg.evel_threshold =fread(fd,1,'uint16');
cfg.time_between_ping_groups=sum(fread(fd,3,'uint8').*[60 1 .01]'); % seconds
coord_sys      =fread(fd,1,'uint8');                                % Lots of bit-mapped info
  cfg.coord=dec2base(coord_sys,2,8);
  cfg.coord_sys      =getopt(bitand(bitshift(coord_sys,-3),3),'beam','instrument','ship','earth');
  cfg.use_pitchroll  =getopt(bitand(coord_sys,4)==4,'no','yes');  
  cfg.use_3beam      =getopt(bitand(coord_sys,2)==2,'no','yes');
  cfg.bin_mapping    =getopt(bitand(coord_sys,1)==1,'no','yes');
cfg.xducer_misalign=fread(fd,1,'int16')*.01;    % degrees
cfg.magnetic_var   =fread(fd,1,'int16')*.01;	% degrees
cfg.sensors_src    =dec2base(fread(fd,1,'uint8'),2,8);
cfg.sensors_avail  =dec2base(fread(fd,1,'uint8'),2,8);
cfg.bin1_dist      =fread(fd,1,'uint16')*.01;	% meters
cfg.xmit_pulse     =fread(fd,1,'uint16')*.01;	% meters
cfg.water_ref_cells=fread(fd,2,'uint8');
cfg.fls_target_threshold =fread(fd,1,'uint8');
fseek(fd,1,'cof');
cfg.xmit_lag       =fread(fd,1,'uint16')*.01; % meters
nbyte=40;

if fix(cfg.prog_ver)==8 | fix(cfg.prog_ver)==10 | fix(cfg.prog_ver)==16 ...
     | fix(cfg.prog_ver)==50 | fix(cfg.prog_ver)==51 | fix(cfg.prog_ver)==52,

  if cfg.prog_ver>=8.14,  % Added CPU serial number with v8.14
    cfg.serialnum      =fread(fd,8,'uint8');
    nbyte=nbyte+8; 
  end;

  if cfg.prog_ver>=8.24,  % Added 2 more bytes with v8.24 firmware
    cfg.sysbandwidth  =fread(fd,2,'uint8');
    nbyte=nbyte+2;
  end;

  if cfg.prog_ver>=16.05,                      % Added 1 more bytes with v16.05 firmware
    cfg.syspower      =fread(fd,1,'uint8');
    nbyte=nbyte+1;
  end;

  if cfg.prog_ver>=16.27,   % Added bytes for REMUS, navigators, and HADCP
    cfg.navigator_basefreqindex=fread(fd,1,'uint8');
    nbyte=nbyte+1;
    cfg.remus_serialnum=fread(fd,1,'uint32');  % Thanks to Mark Halverson for this decoding
    nbyte=nbyte+4;
    cfg.h_adcp_beam_angle=fread(fd,1,'uint8');
    nbyte=nbyte+1;
  end;  
    
elseif fix(cfg.prog_ver)==9,

  if cfg.prog_ver>=9.10,  % Added CPU serial number with v8.14
    cfg.serialnum      =fread(fd,8,'uint8');
    nbyte=nbyte+8; 
    cfg.sysbandwidth  =fread(fd,2,'uint8');
    nbyte=nbyte+2;
  end;

elseif fix(cfg.prog_ver)==14 | fix(cfg.prog_ver)==23,

    cfg.serialnum      =fread(fd,8,'uint8');  % 8 bytes 'reserved'
    nbyte=nbyte+8;

elseif fix(cfg.prog_ver)==34,

    fseek(fd,8,'cof'); % Spare
    nbyte=nbyte+8;
    cfg.sysbandwidth  =fread(fd,1,'uint16');
    nbyte=nbyte+2;
    fseek(fd,2,'cof'); % Spare
    nbyte=nbyte+2;
    cfg.serialnum      =fread(fd,1,'uint32');
    nbyte=nbyte+4; 

elseif  fix(cfg.prog_ver)==47,
    fseek(fd,8,'cof'); % spare
    cfg.sysbandwidth  =fread(fd,2,'uint8');
    cfg.syspower      =fread(fd,1,'uint8');
    fseek(fd,1,'cof'); % spare
    cfg.serialnum      =fread(fd,4,'uint8');
    cfg.beam_angle=fread(fd,1,'uint8');
    fseek(fd,1,'cof'); % spare
    nbyte=nbyte+18;    
	  
end;

% It is useful to have this precomputed.

cfg.ranges=cfg.bin1_dist+[0:cfg.n_cells-1]'*cfg.cell_size;
if strcmp(cfg.orientation,'up'), cfg.ranges=-cfg.ranges; end
	
	
%-----------------------------
function [ens,hdr,cfg,pos]=rd_buffer(fd,num_av);

% To save it being re-initialized every time.
global ens hdr

% A fudge to try and read files not handled quite right.
global FIXOFFSET SOURCE

% For OS files that can interleave NB and BB bings
global STANDARD

% If num_av<0 we are reading only 1 element and initializing
if num_av<0,
 SOURCE=0;
end; 
% This reinitializes to whatever length of ens we want to average.
if num_av<0 | isempty(ens),
 FIXOFFSET=0;   
 n=abs(num_av);
 [hdr,pos]=rd_hdr(fd);
 if ~isstruct(hdr), ens=-1; cfg=NaN; return; end;
 cfg=rd_fix(fd);
 fseek(fd,pos,'bof');
 clear global ens
 global ens
 
 ens=struct('number',zeros(1,n),'rtc',zeros(7,n),'BIT',zeros(1,n),'ssp',zeros(1,n),'depth',zeros(1,n),'pitch',zeros(1,n),...
            'roll',zeros(1,n),'heading',zeros(1,n),'temperature',zeros(1,n),'salinity',zeros(1,n),...
            'mpt',zeros(1,n),'heading_std',zeros(1,n),'pitch_std',zeros(1,n),...
            'roll_std',zeros(1,n),'adc',zeros(8,n),'error_status_wd',zeros(1,n),...
            'pressure',zeros(1,n),'pressure_std',zeros(1,n),...
            'east_vel',zeros(cfg.n_cells,n),'north_vel',zeros(cfg.n_cells,n),'vert_vel',zeros(cfg.n_cells,n),...
            'error_vel',zeros(cfg.n_cells,n),'intens',zeros(cfg.n_cells,4,n),'percent',zeros(cfg.n_cells,4,n),...
            'corr',zeros(cfg.n_cells,4,n),'status',zeros(cfg.n_cells,4,n),...
	    'bt_range',zeros(4,n),'bt_vel',zeros(4,n),...
	    'bt_corr',zeros(4,n),'bt_ampl',zeros(4,n),'bt_perc_good',zeros(4,n),...
            'smtime',zeros(1,n),'emtime',zeros(1,n),'slatitude',zeros(1,n),...
	    'slongitude',zeros(1,n),'elatitude',zeros(1,n),'elongitude',zeros(1,n),...
	    'avgspd',zeros(1,n),'avtrktrue',zeros(1,n),'avtrkmag',zeros(1,n),...
	    'speedmadegd',zeros(1,n),'direcmadegd',zeros(1,n),...
	    'nmtime',zeros(1,n),'flags',zeros(1,n));
  num_av=abs(num_av);
end;
 
k=0;
while k<num_av,
   
   % This is in case junk appears in the middle of a file - look forward for next valid block
   num_search=6000;
   
   id1=fread(fd,2,'uint8');

   search_cnt=0;
   while search_cnt<num_search & ((id1(1)~=hex2dec('7F') | id1(2)~=hex2dec('7F') ) | ~checkheader(fd) ),
       search_cnt=search_cnt+1;
       nextbyte=fread(fd,1,'uint8');
       if isempty(nextbyte),  % End of file
           disp(['EOF reached after ' num2str(search_cnt) ' bytes searched for next valid ensemble start'])
           ens=-1;
           return;
       end;
       id1(2)=id1(1);id1(1)=nextbyte;
% fprintf([dec2hex(id1(1)) '--' dec2hex(id1(2)) '\n']);
   end;
   if search_cnt==num_search,
        error(sprintf('Searched %d entries...Not a workhorse/broadband file or bad data encountered: -> %x',search_cnt,id1)); 
   elseif search_cnt>0
       disp(['Searched ' int2str(search_cnt) ' bytes to find next valid ensemble start'])
   end


   startpos=ftell(fd)-2;  % Starting position.
   
   
   % Read the # data types.
   [hdr,nbyte]=rd_hdrseg(fd);     
   byte_offset=nbyte+2;
%% fprintf('# data types = %d\n  ',(length(hdr.dat_offsets)));
%% fprintf('Blocklen = %d\n  ',hdr.nbyte);
    % Read all the data types.
   for n=1:length(hdr.dat_offsets),

    id=dec2hex(fread(fd,1,'uint16'),4);
%%  fprintf('ID=%s SOURCE=%d  k=%d\n',id,SOURCE,k);%%pause;
    
    % handle all the various segments of data. Note that since I read the IDs as a two
    % byte number in little-endian order the high and low bytes are exchanged compared to
    % the values given in the manual.
    
    winrivprob=0;
    
    % For OS instruments run through VMDAS - 
    % if there are two different sets of pings, then they are differentiated by
    % having a 0 or a 1 in the 4th byte. In order NOT to read those, I change
    % the block number so it is not valid by sticking an 'X' in there (so it becomes
    % un-identifiable).
    
    if STANDARD==1, 
       if id(1)=='0'  & id(4)=='0',
         id(4)='X';
       elseif id(1)=='0'  & id(4)=='1',
         id(4)='0';
       end;
    elseif STANDARD==0,
        if id(1)=='0'  & id(4)=='0',
         id(4)='0';
       elseif id(1)=='0'  & id(4)=='1',
         id(4)='X';
       end;   	 	  
  %%     fprintf('NEW ID=%s SOURCE=%d\n',id,SOURCE);
    end;
    
%%  fprintf('id = %s\n',id);
 
 
 % The following code decodes different blocks. I try to implement a reader for
 % all the blocks I know about, but I have not necessarily implemented code
 % to decode the info in each block and return this to the user.
 
       
    switch id,           
     case {'0000' }   % Fixed leader
      [cfg,nbyte]=rd_fixseg(fd);
      nbyte=nbyte+2;
      
   %   fprintf('frm=%7.4f  NCELLS = %d\n',cfg.prog_ver,cfg.n_cells);
      
    case {'0080' }   % Variable Leader
      k=k+1;
      ens.number(k)         =fread(fd,1,'uint16');
      ens.rtc(:,k)          =fread(fd,7,'uint8');
      ens.number(k)         =ens.number(k)+65536*fread(fd,1,'uint8');
      ens.BIT(k)            =fread(fd,1,'uint16');
      ens.ssp(k)            =fread(fd,1,'uint16');
      ens.depth(k)          =fread(fd,1,'uint16')*.1;   % meters
      ens.heading(k)        =fread(fd,1,'uint16')*.01;  % degrees
      ens.pitch(k)          =fread(fd,1,'int16')*.01;   % degrees
      ens.roll(k)           =fread(fd,1,'int16')*.01;   % degrees
      ens.salinity(k)       =fread(fd,1,'int16');       % PSU
      ens.temperature(k)    =fread(fd,1,'int16')*.01;   % Deg C
      ens.mpt(k)            =sum(fread(fd,3,'uint8').*[60 1 .01]'); % seconds
      ens.heading_std(k)    =fread(fd,1,'uint8');     % degrees
      ens.pitch_std(k)      =fread(fd,1,'uint8')*.1;   % degrees
      ens.roll_std(k)       =fread(fd,1,'uint8')*.1;   % degrees
      ens.adc(:,k)          =fread(fd,8,'uint8');
      nbyte=2+40;
 
      if strcmp(cfg.name,'bb-adcp'),
      
          if cfg.prog_ver>=5.55,
              fseek(fd,15,'cof'); % 14 zeros and one byte for number WM4 bytes
	      cent=fread(fd,1,'uint8');            % possibly also for 5.55-5.58 but
	      ens.rtc(:,k)=fread(fd,7,'uint8');    % I have no data to test.
	      ens.rtc(1,k)=ens.rtc(1,k)+cent*100;
	      nbyte=nbyte+15+8;
          end;
          
      elseif strcmp(cfg.name,'wh-adcp'), % for WH versions.		

          ens.error_status_wd(k)=fread(fd,1,'uint32');
          nbyte=nbyte+4;;

          if fix(cfg.prog_ver)==8 | fix(cfg.prog_ver)==10 | fix(cfg.prog_ver)==16 ...
	       | fix(cfg.prog_ver)==50 | fix(cfg.prog_ver)==51 | fix(cfg.prog_ver)==52,

	      if cfg.prog_ver>=8.13,  % Added pressure sensor stuff in 8.13
                  fseek(fd,2,'cof');   
                  ens.pressure(k)       =fread(fd,1,'int32');  % changed from uint to int Nov/2013
                  ens.pressure_std(k)   =fread(fd,1,'int32');  % ditto (thanks to U. Neumeier for finding this)
	          nbyte=nbyte+10;  
	      end;

	      if cfg.prog_ver>=8.24,  % Spare byte added 8.24
	          fseek(fd,1,'cof');
	          nbyte=nbyte+1;
	      end;

 	  
	      if ( cfg.prog_ver>=10.01 & cfg.prog_ver<=10.99 ) ...
	          | cfg.prog_ver>=16.05,   % Added more fields with century in clock 16.05
	          cent=fread(fd,1,'uint8');            
	          ens.rtc(:,k)=fread(fd,7,'uint8');   
	          ens.rtc(1,k)=ens.rtc(1,k)+cent*100;
	          nbyte=nbyte+8;
	      end;
	      
	  elseif fix(cfg.prog_ver)==9,
	   
                  fseek(fd,2,'cof');   
                  ens.pressure(k)       =fread(fd,1,'uint32');  
                  ens.pressure_std(k)   =fread(fd,1,'uint32');
	          nbyte=nbyte+10;  
 
	      if cfg.prog_ver>=9.10,  % Spare byte added 8.24
	          fseek(fd,1,'cof');
	          nbyte=nbyte+1;
	      end;
	   
	  end;
       
      elseif strcmp(cfg.name,'os-adcp'),
	  
	  fseek(fd,16,'cof'); % 30 bytes all set to zero, 14 read above
	  nbyte=nbyte+16;
	  
	  if cfg.prog_ver>23,
               fseek(fd,2,'cof');
	       nbyte=nbyte+2;
	  end;    
	  
      elseif strcmp(cfg.name,'dvl'),
          fseek(fd,6,'cof'); % Error status word   
          ens.pressure(k)       =fread(fd,1,'uint32');  
          ens.pressure_std(k)   =fread(fd,1,'uint32');
          fseek(fd,4,'cof'); % Error status word   
	  nbyte=nbyte+18;

      elseif strcmp(cfg.name,'V-adcp'),
	  
	  fseek(fd,6,'cof'); % Error status word (I don't decode this)
          ens.pressure(k)       =fread(fd,1,'uint32')/1000;  % dbar  
          ens.pressure_std(k)   =fread(fd,1,'uint32')/1000;
	  fseek(fd,1,'cof'); % Spare
	  cent=fread(fd,1,'uint8');            % possibly also for 5.55-5.58 but
	  ens.rtc(:,k)=fread(fd,7,'uint8');    % I have no data to test.
	  ens.rtc(1,k)=ens.rtc(1,k)+cent*100;
	  fseek(fd,1,'cof'); % Spare
	  nbyte=nbyte+24; 
	  
      end;
      	      
    case {'0100'}  % Velocities
      vels=fread(fd,[4 cfg.n_cells],'int16')'*.001;     % m/s
      
      [nn,mm]=size(ens.east_vel);
      if nn~=cfg.n_cells,
        ens.east_vel =zeros(cfg.n_cells,mm);
	ens.north_vel=zeros(cfg.n_cells,mm);
	ens.vert_vel =zeros(cfg.n_cells,mm);
	ens.error_vel=zeros(cfg.n_cells,mm);
      end;
      	
      ens.east_vel(:,k) =vels(:,1);
      ens.north_vel(:,k)=vels(:,2);
      ens.vert_vel(:,k) =vels(:,3);
      ens.error_vel(:,k)=vels(:,4);
      nbyte=2+4*cfg.n_cells*2;
      
    case {'0200'}  % Correlations
     [nn,mm,oo]=size(ens.corr);
      if nn~=cfg.n_cells,
        ens.corr =zeros(cfg.n_cells,4,oo);
      end;	

      ens.corr(:,:,k)   =fread(fd,[4 cfg.n_cells],'uint8')';
      nbyte=2+4*cfg.n_cells;
      
    case {'0300'}  % Echo Intensities  
      [nn,mm,oo]=size(ens.intens);
      if nn~=cfg.n_cells,
        ens.intens =zeros(cfg.n_cells,4,oo);
      end;	

      ens.intens(:,:,k)   =fread(fd,[4 cfg.n_cells],'uint8')';
      nbyte=2+4*cfg.n_cells;

    case {'0400'}  % Percent good
      [nn,mm,oo]=size(ens.percent);
      if nn~=cfg.n_cells,
        ens.percent =zeros(cfg.n_cells,4,oo);
      end;	

      ens.percent(:,:,k)   =fread(fd,[4 cfg.n_cells],'uint8')';
      nbyte=2+4*cfg.n_cells;
   
      if fix(cfg.prog_ver)==34,   % This is perhaps a bug; thes block was
        fseek(fd,-2,'cof');       % 2 bytes short. I am *guessing* some problem
	nbyte=nbyte-2;            % with the checksum
      end;	 

    case {'0500'}  % Status
      [nn,mm,oo]=size(ens.status);
      if nn~=cfg.n_cells,
        ens.status =zeros(cfg.n_cells,4,oo);
      end;	
 
      if strcmp(cfg.name,'bb-adcp')
         % Note in one case with a 4.25 firmware SC-BB, it seems like
         % this block was actually two bytes short!
        ens.status(:,:,k)   =fread(fd,[4 cfg.n_cells],'uint8')';
	fseek(fd,-2,'cof');
        nbyte=2+4*cfg.n_cells-2;
      else	
        ens.status(:,:,k)   =fread(fd,[4 cfg.n_cells],'uint8')';
	nbyte=2+4*cfg.n_cells;
      end;
     
    case {'0600'} % Bottom track
                  % In WINRIVER GPS data is tucked into here in odd ways, as long
                  % as GPS is enabled.
      if SOURCE==2,
          fseek(fd,2,'cof');
          long1=fread(fd,1,'uint16');
          fseek(fd,6,'cof');           
          cfac=180/2^31;
          ens.slatitude(k)  =fread(fd,1,'int32')*cfac;
	  if ens.slatitude(k)==0, ens.slatitude(k)=NaN; end;
%%fprintf('\n k %8.3f',ens.slatitude(k));
      else    
          fseek(fd,14,'cof'); % Skip over a bunch of stuff
      end;    
      ens.bt_range(:,k)=fread(fd,4,'uint16')*.01; %
      ii=ens.bt_range(:,k)==0;                    % Change no data to NaN 10/13
      if any(ii), ens.bt_range(ii,k)=NaN; end;
      
      ens.bt_vel(:,k)  =fread(fd,4,'int16');
      ii=ens.bt_vel(:,k)==-32768;                 % Change baddata to NaN 10/13
      if any(ii),ens.bt_evl(ii,k)=NaN; end;
       
      ens.bt_corr(:,k)=fread(fd,4,'uint8');      % felipe pimenta aug. 2006
      ens.bt_ampl(:,k)=fread(fd,4,'uint8');      % "
      ens.bt_perc_good(:,k)=fread(fd,4,'uint8'); % "
      if SOURCE==2,
          fseek(fd,2,'cof');
          ens.slongitude(k)=(long1+65536*fread(fd,1,'uint16'))*cfac;
%%fprintf('\n k %d %8.3f %f ',long1,ens.slongitude(k),(ens.slongitude(k)/cfac-long1)/65536);
          if ens.slongitude(k)>180, ens.slongitude(k)=ens.slongitude(k)-360; end;
	  if ens.slongitude(k)==0, ens.slongitude(k)=NaN; end;
	  fseek(fd,16,'cof');
	  qual=fread(fd,1,'uint8');
	  if qual==0, 
%%	     fprintf('qual==%d,%f %f',qual,ens.slatitude(k),ens.slongitude(k));
	     ens.slatitude(k)=NaN;ens.slongitude(k)=NaN; 
	  end;
          fseek(fd,71-45-21,'cof');
      else    
          fseek(fd,71-45,'cof');
      end;    
      nbyte=2+68;
      if cfg.prog_ver>=5.3,    % Version 4.05 firmware seems to be missing these last 11 bytes.
       fseek(fd,78-71,'cof');  
       ens.bt_range(:,k)=ens.bt_range(:,k)+fread(fd,4,'uint8')*655.36;
       nbyte=nbyte+11;
       
       if strcmp(cfg.name,'wh-adcp'),
       
         if cfg.prog_ver>=16.20,   % RDI documentation claims these extra bytes were added in v 8.17
             fseek(fd,4,'cof');  % but they don't appear in my 8.33 data - conversation with
             nbyte=nbyte+4;       % Egil suggests they were added in 16.20
         end;
       end;	 
      end;
     
% The raw files produced by VMDAS contain a binary navigation data
% block. 
      
    case {'2000'},  % Something from VMDAS.
      cfg.sourceprog='VMDAS';
      if k==0, k=1; end;
      if SOURCE~=1, fprintf('\n***** Apparently a VMDAS file \n\n'); end;
      SOURCE=1;
      utim  =fread(fd,4,'uint8');
      mtime =datenum(utim(3)+utim(4)*256,utim(2),utim(1));
      ens.smtime(k)     =mtime+fread(fd,1,'int32')/1e4/86400;
      fseek(fd,4,'cof');  % PC clock offset from UTC
      cfac=180/2^31;
      ens.slatitude(k)  =fread(fd,1,'int32')*cfac;
      ens.slongitude(k) =fread(fd,1,'int32')*cfac;
      ens.emtime(k)     =mtime+fread(fd,1,'int32')/1e4/86400;
      ens.elatitude(k)  =fread(fd,1,'int32')*cfac;
      ens.elongitude(k) =fread(fd,1,'int32')*cfac;
      ens.avgspd(k)     =fread(fd,1,'int16')/1000; % m/sec
      cfac2=180/2^15;
      ens.avgtrktrue(k) =fread(fd,1,'int16')*cfac2;
      ens.avgtrkmag(k)  =fread(fd,1,'int16')*cfac2;
      ens.speedmadegd(k)=fread(fd,1,'int16')/1000; % m/sec  Calculated from positions
      ens.direcmadegd(k)=fread(fd,1,'int16')*cfac2; % Calculated from positions
      fseek(fd,2,'cof');   
      ens.flags(k)      =fread(fd,1,'uint16');	
      fseek(fd,6,'cof');
      utim  =fread(fd,4,'uint8');
      mtime =datenum(utim(1)+utim(2)*256,utim(4),utim(3));
      ens.nmtime(k)     =mtime+fread(fd,1,'uint32')/1e4/86400;
                          % in here we have 'ADCP clock' (not sure how this
                          % differs from RTC (in header) and UTC (earlier in this block).
      fseek(fd,16,'cof');
      nbyte=2+76;
      
    case {'2022'},  % New NMEA data block from WInRiverII
    
      cfg.sourceprog='WINRIVER2';
      if SOURCE~=3, fprintf('\n***** Apparently a WINRIVER II file  - GGA handler only implemented \n\n'); end;
      SOURCE=3;
      
      specID=fread(fd,1,'uint16');
      msgsiz=fread(fd,1,'int16');
      deltaT=fread(fd,1,'double');  % Whatever this is, it is undocumented.
      nbyte=2+12;


 %%     fprintf(' %d \n',specID);
      switch specID,
        case 100,
	  gpstring=char(fread(fd,10,'uchar')');
	  utc=char(fread(fd,10,'uchar')');
	  try, ens.smtime(k)=(sscanf(utc(1:2),'%d')+sscanf(utc(3:4),'%d')/60+sscanf(utc(5:6),'%d')/3600)/24; end;
	  ens.slatitude(k)=fread(fd,1,'double');
	  if char(fread(fd,1,'uchar'))=='S',
	     ens.slatitude(k)=-ens.slatitude(k);
	  end;   
	  ens.slongitude(k)=fread(fd,1,'double');
	  if char(fread(fd,1,'uchar'))=='W',
	     ens.slongitude(k)=-ens.slongitude(k);
	  end;   
          nbyte=nbyte+38;
	  msgsiz=msgsiz-38;
 	case 101,
	             % WinriverII v<2.000 VTG not implemented
 	case 102,
 	             % WinriverII v<2.000 DBT not implemented
	case 103,
	             % WinriverII v<2.000 HDT not implemented
	case 104,
	  gpstring=char(fread(fd,7,'uchar')');
	  utc=char(fread(fd,10,'uchar')');
	  ens.smtime(k)=(sscanf(utc(1:2),'%d')+sscanf(utc(3:4),'%d')/60+sscanf(utc(5:6),'%d')/3600)/24;
	  ens.slatitude(k)=fread(fd,1,'double');
	  if char(fread(fd,1,'uchar'))=='S',
	     ens.slatitude(k)=-ens.slatitude(k);
	  end;   
	  ens.slongitude(k)=fread(fd,1,'double');
	  if char(fread(fd,1,'uchar'))=='W',
	     ens.slongitude(k)=-ens.slongitude(k);
	  end;   
          nbyte=nbyte+35;
	  msgsiz=msgsiz-35;
	case 105,
	             % WinriverII v>=2.000 VTG not implemented
	case 106,
	             % WinriverII v>=2.000 DBT not implemented
	case 107,
	             % WinriverII v>=2.000 HDT not implemented
       end;
      fseek(fd,msgsiz,'cof');
      nbyte=nbyte+msgsiz;
	 
       
% The following blocks come from WINRIVER files, they aparently contain
% the raw NMEA data received from a serial port.
%
% Note that for WINRIVER files somewhat decoded data is also available
% tucked into the bottom track block.
%
% I've put these all into their own block because RDI's software apparently completely ignores the
% stated lengths of these blocks and they very often have to be changed. Rather than relying on the
% error coding at the end of the main block to do this (and to produce an error message) I will
% do it here, without an error message to emphasize that I am kludging the WINRIVER blocks only!
    
    case {'2100','2101','2102','2103','2104'}
    
    winrivprob=1;
    
    switch id,
    
      case '2100', % $xxDBT  (Winriver addition) 38
	cfg.sourceprog='WINRIVER';
	if SOURCE~=2, fprintf('\n***** Apparently a WINRIVER file - Raw DBT NMEA data handler not yet implemented\n\n'); end;
	SOURCE=2;
	str=fread(fd,38,'uchar')';
	nbyte=2+38;

      case '2101', % $xxGGA  (Winriver addition) 94 in manual but 97 seems to work
                   % Except for a winriver2 file which seems to use 77.
	cfg.sourceprog='WINRIVER';
	if SOURCE~=2, fprintf('\n***** Apparently a WINRIVER file - Raw GG NMEA data handler not yet implemented\n\n'); end;
	SOURCE=2;
	str=setstr(fread(fd,97,'uchar')');
	nbyte=2+97;
	l=strfind(str,'$GPGGA');
	if ~isempty(l),
          ens.smtime(k)=(sscanf(str(l+7:l+8),'%d')+(sscanf(str(l+9:l+10),'%d')+sscanf(str(l+11:l+12),'%d')/60)/60)/24;
	end;
  %	disp(['->' setstr(str(1:50)) '<-']);

      case '2102', % $xxVTG  (Winriver addition) 45 (but sometimes 46 and 48)
	cfg.sourceprog='WINRIVER';
	if SOURCE~=2, fprintf('\n***** Apparently a WINRIVER file - Raw VTG NMEA data handler not yet implemented\n\n'); end;
	SOURCE=2;
	str=fread(fd,45,'uchar')';
	nbyte=2+45;
  %      disp(setstr(str));

      case '2103', % $xxGSA  (Winriver addition) 60
	cfg.sourceprog='WINRIVER';
	if SOURCE~=2, fprintf('\n***** Apparently a WINRIVER file - Raw GSA NMEA data handler not yet implemented\n\n'); end;
	SOURCE=2;
	str=fread(fd,60,'uchar')';
  %      disp(setstr(str));
	nbyte=2+60;

      case '2104',  %xxHDT or HDG (Winriver addition) 38
	cfg.sourceprog='WINRIVER';
	if SOURCE~=2, fprintf('\n***** Apparently a WINRIVER file - Raw HDT NMEA data handler not yet implemented\n\n'); end;
	SOURCE=2;
	str=fread(fd,38,'uchar')';
  %      disp(setstr(str));
	nbyte=2+38;
      end;  
      
     
        
    case '0701', % Number of good pings
      fseek(fd,4*cfg.n_cells,'cof');
      nbyte=2+4*cfg.n_cells;
    
    case '0702', % Sum of squared velocities
      fseek(fd,4*cfg.n_cells,'cof');
      nbyte=2+4*cfg.n_cells;

    case '0703', % Sum of velocities      
      fseek(fd,4*cfg.n_cells,'cof');
      nbyte=2+4*cfg.n_cells;

% These are for V-series ADCPs (47.xx firmware)

    case {'7000'}           % resend firmware and frequency info, as well as pressure rating
      fseek(fd,14,'cof');  % I am skipping this all...
      nbyte=2+14;
      
    case {'7001'}        % COntains info on ping sequencing
    
      fseek(fd,42,'cof');  % I am skipping this all
      nbyte=2+42;
      if ( cfg.prog_ver>=47.17  )    % Change happened after 47.11 and before 47.17
        fseek(fd,14,'cof');  % I am skipping this all
        nbyte=nbyte+14;
      end;
      
    case {'7002'}    % Advanced system diagnostics
      fseek(fd,14,'cof');   % Skip them all
      nbyte=2+14;
      
    case {'7003'}    % Contains various 'feature keys' in the V series firmware
      numfeature=fread(fd,1,'uint8');
      fseek(fd,1,'cof');  % Spare
      fseek(fd,86*(numfeature),'cof');
      nbyte=2+2+86*(numfeature);
    
    case {'7004'}  % Contains fault handling and diagnostics
      numfault=fread(fd,1,'uint16');
      fseek(fd,4*(numfault),'cof');
      nbyte=2+4*(numfault)+2;
 

    case {'3200'}   % Instrument transformation matrix (beam to instrument coords)
     vals=fread(fd,16,'int16')*0.0001;
     cfg.beam2instrument_transform_matrix= reshape(vals,4,4)';  % coord transformation matrix (specific to instrument)
     nbyte=2+32;



% These blocks were implemented for 5-beam Sentinel-V systems 

    case {'0F01'}, % Vertical beam leader
       cfg.Vn_cells=fread(fd,1,'uint16');
       cfg.Vpings_per_ensemble=fread(fd,1,'uint16');
       cfg.Vcell_size=fread(fd,1,'uint16')*.01;	 % meters
       cfg.Vbin1_dist=fread(fd,1,'uint16')*.01;	% meters
       cfg.Vmode     =fread(fd,1,'uint16');         %  1 = Low res, 2 = High res
       cfg.Vxmit_pulse     =fread(fd,1,'uint16')*.01;	% meters
       fseek(fd,38-14,'cof');
      cfg.Voffset     =fread(fd,1,'int16')*.001;	% seconds
      nbyte=2+38;
  %%% fprintf('%f\n',cfg.Voffset);
    
    case {'0A00'}, % Beam 5 velocity (not implemented)
      vels=fread(fd,[cfg.Vn_cells],'int16')'*.001;     % m/s
      ens.Vvert_vel(:,k) =vels;
     nbyte=2+2*cfg.n_cells;
%%% fprintf('-');

    case {'0B00'}, % Beam 5 correlations (not implemented)
      fseek(fd,cfg.n_cells,'cof');
      nbyte=2+cfg.n_cells;

    case {'0C00'}, % Beam 5 amplitude 
      ens.Vintens(:,k)=fread(fd,[cfg.n_cells],'uint8');
      nbyte=2+cfg.n_cells;
      
      
% Can't remember what these are for: experimental 5-beam system?      
      
    case '0301', % Beam 5 Number of good pings (not implemented)
      fseek(fd,cfg.n_cells,'cof');
      nbyte=2+cfg.n_cells;

    case '0302', % Beam 5 Sum of squared velocities (not implemented)
      fseek(fd,cfg.n_cells,'cof');
      nbyte=2+cfg.n_cells;
             
    case '0303', % Beam 5 Sum of velocities (not implemented)
      fseek(fd,cfg.n_cells,'cof');
      nbyte=2+cfg.n_cells;
             
    case '020C', % Ambient sound profile (not implemented)
      fseek(fd,4,'cof');
      nbyte=2+4;
          
    case '3000',  % Fixed attitude data format for OS-ADCPs (not implemented)	     
      fseek(fd,32,'cof');
      nbyte=2+32;
 
     otherwise,
      % This is pretty idiotic - for OS-ADCPs (phase 2) they suddenly decided to code
      % the number of bytes into the header ID word. And then they don't really
      % document what they did! So, this is cruft of a high order, and although
      % it works on the one example I have - caveat emptor....
      %
      % Anyway, there appear to be codes 0340-03FC to deal with. I am not going to
      % decode them but I am going to try to figure out how many bytes to
      % skip.
      if strcmp(id(1:2),'30'),
        % I want to count the number of 1s in the middle 4 bits of the
	% 2nd two bytes.
        nflds=sum(dec2base(bitand(hex2dec(id(3:4)),hex2dec('3C')),2)=='1');
	% I want to count the number of 1s in the highest 2 bits of byte 3
	dfac= sum(dec2base(bitand(hex2dec(id(3)),hex2dec('C')),2)=='1');
	fseek(fd,12*nflds*dfac,'cof');
	nbyte=2+12*nflds*dfac;
      
      elseif id(4)~='X',  % I code ones to skip with an 'X'.
        fprintf('Unrecognized ID code: %s\n',id);
        nbyte=2;
      else
        nbyte=2;	
      end;	
     %% ens=-1;
     %% return;
      
      
    end;
   
    % here I adjust the number of bytes so I am sure to begin
    % reading at the next valid offset. If everything is working right I shouldn't have
    % to do this but every so often firmware changes result in some differences.

%%   fprintf('#bytes is %d, original offset is %d\n',nbyte,byte_offset);
    byte_offset=byte_offset+nbyte;   
      
    % Some  times when I don't want this warning
    printwarn =    ~winrivprob ... 
                 && ~(id(4)=='X') ...  % Skipping missed stuff for os-adcp
		 && ~( strcmp(cfg.name,'os-adcp')  & (strcmp(id,'0000') | strcmp(id,'2000')) );
  
    if n<length(hdr.dat_offsets),
      if hdr.dat_offsets(n+1)~=byte_offset,    
        if printwarn, fprintf('%s: Adjust location by %d\n',id,hdr.dat_offsets(n+1)-byte_offset); end;
        fseek(fd,hdr.dat_offsets(n+1)-byte_offset,'cof');
      end;	
      byte_offset=hdr.dat_offsets(n+1); 
    else
      if hdr.nbyte-2~=byte_offset,    
        if printwarn, fprintf('%s: Adjust location by %d\n',id,hdr.nbyte-2-byte_offset); end;
        fseek(fd,hdr.nbyte-2-byte_offset,'cof');
      end;
      byte_offset=hdr.nbyte-2;
    end;
  end;

  % Now at the end of the record we have two reserved bytes, followed
  % by a two-byte checksum = 4 bytes to skip over.

  readbytes=ftell(fd)-startpos;
  offset=(hdr.nbyte+2)-byte_offset; % The 2 is for the checksum

  if offset ~=4 & FIXOFFSET==0, 
    fprintf('\n*****************************************************\n');
    if feof(fd),
      fprintf(' EOF reached unexpectedly - discarding this last ensemble\n');
      ens=-1;
    else
      fprintf('Adjust location by %d (readbytes=%d, hdr.nbyte=%d)\n',offset,readbytes,hdr.nbyte);
      fprintf(' NOTE - If this appears at the beginning of the read, it is\n');
      fprintf('        is a program problem, possibly fixed by a fudge\n');
      fprintf('        PLEASE REPORT TO rich@eos.ubc.ca WITH DETAILS!!\n\n');
      fprintf('      -If this appears at the end of the file it means\n');
      fprintf('       The file is corrupted and only a partial record has  \n');
      fprintf('       has been read\n');
    end;
    fprintf('******************************************************\n');
    FIXOFFSET=offset-4;
  end;  
  fseek(fd,4+FIXOFFSET,'cof'); 
   
  % An early version of WAVESMON and PARSE contained a bug which stuck an additional two
  % bytes in these files, but they really shouldn't be there 
  %if cfg.prog_ver>=16.05,    
  %	  fseek(fd,2,'cof');
  %end;
  	   
end;

% Blank out stuff bigger than error velocity
% big_err=abs(ens.error_vel)>.2;
big_err=0;
	
% Blank out invalid data	
ens.east_vel(ens.east_vel==-32.768 | big_err)=NaN;
ens.north_vel(ens.north_vel==-32.768 | big_err)=NaN;
ens.vert_vel(ens.vert_vel==-32.768 | big_err)=NaN;
ens.error_vel(ens.error_vel==-32.768 | big_err)=NaN;




%--------------------------------------
function y=nmedian(x,window,dim);
% Copied from median but with handling of NaN different.

if nargin==2, 
  dim = min(find(size(x)~=1)); 
  if isempty(dim), dim = 1; end
end

siz = [size(x) ones(1,dim-ndims(x))];
n = size(x,dim);

% Permute and reshape so that DIM becomes the row dimension of a 2-D array
perm = [dim:max(length(size(x)),dim) 1:dim-1];
x = reshape(permute(x,perm),n,prod(siz)/n);

% Sort along first dimension
x = sort(x,1);
[n1,n2]=size(x);

if n1==1,
 y=x;
else
  if n2==1,
   kk=sum(isfinite(x),1);
   if kk>0,
     x1=x(fix((kk-1)/2)+1);
     x2=x(fix(kk/2)+1);
     x(abs(x-(x1+x2)/2)>window)=NaN;
   end;
   x = sort(x,1);
   kk=sum(isfinite(x),1);
   x(isnan(x))=0;
   y=NaN;
   if kk>0,
    y=sum(x)/kk;
   end;
  else
   kk=sum(isfinite(x),1);
   ll=kk<n1-2;
   kk(ll)=0;x(:,ll)=NaN;
   x1=x(fix((kk-1)/2)+1+[0:n2-1]*n1);
   x2=x(fix(kk/2)+1+[0:n2-1]*n1);

   x(abs(x-ones(n1,1)*(x1+x2)/2)>window)=NaN;
   x = sort(x,1);
   kk=sum(isfinite(x),1);
   x(isnan(x))=0;
   y=NaN+ones(1,n2);
   if any(kk),
    y(kk>0)=sum(x(:,kk>0))./kk(kk>0);
   end;
  end;
end; 

% Permute and reshape back
siz(dim) = 1;
y = ipermute(reshape(y,siz(perm)),perm);

%--------------------------------------
function y=nmean(x,dim);
% R_NMEAN Computes the mean of matrix ignoring NaN
%         values
%   R_NMEAN(X,DIM) takes the mean along the dimension DIM of X. 
%

kk=isfinite(x);
x(~kk)=0;

if nargin==1, 
  % Determine which dimension SUM will use
  dim = min(find(size(x)~=1));
  if isempty(dim), dim = 1; end
end;

if dim>length(size(x)),
 y=x;              % For matlab 5.0 only!!! Later versions have a fixed 'sum'
else
  ndat=sum(kk,dim);
  indat=ndat==0;
  ndat(indat)=1; % If there are no good data then it doesn't matter what
                 % we average by - and this avoid div-by-zero warnings.

  y = sum(x,dim)./ndat;
  y(indat)=NaN;
end;

























