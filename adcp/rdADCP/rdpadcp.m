function [adcp,cfg,ens]=rdpadcp(varargin);
% ADCP=RDPADCP(NAME) reads the p-file NAME and returns a (self-explanatory)
%  structure ADCP containing configuration information and measured data.
%  This program is designed for handling ADCP data recorded in real-time
%  (usually from a moving platform). For data downloaded from moored
%  instruments see RDRADCP.
%
%  The advantage of using the p-files is that navigation and configuration
%  data can be merged into it reducing the number of files required. 
%  P-files can be created by TRANSECT or WINRIVER. Both NB and BB/WH
%  ADCPs are handled.
%
%
%  [ADCP,CFG]=RDPADCP(...) returns configuration data in a
%  separate data structure.
%
%  Various options can be specified on input:
%  [...]=RDPADCP(NAME,NUM_AV)
%  [...]= RDPADCP(NAME,NUM_AV,NREC)
%
%  where NUM_AV is the length of block processing and NREC is the number
%  of records to process (-1 for all).
%
%  Reading different extensions (.000, .001, etc.):
%   It appears that some versions of TRANSECT put configuration data
%   at the beginning of every sub-file. In this case there is no problem
%   reading (say) a .001 file. However, other versions put configuration
%   data ONLY in the .000 file. In this case the only way to read the
%   entire dataset is to concatenate all files, e.g. something like
%      cat DEP.??? > DEP
%   in unix. If you have problems with this, please let me know exactly
%   what version of TRANSECT/WINRIVER you have been using.
%  
%  
%
%  It is of course more useful to be able to load data by time. If we call
%    RDPADCP(...,'info')
%  Then an info database of times is updated. Once this exists, call such as
%    RDPADCP(TLIMS,NUM_AV)
%  can be made where TLIMS=[FIRST_TIME LAST_TIME] (with times in matlab m-time
%  format).
%
% Note that you won't get EXACTLY the times you want - instead you will get
% a slightly larger chunk of time that depends on the internal file structure
% (basically you get some chunk that was originally an integer number of XXXP.YYY
%  files).
%
%  String parameter/option pairs can be added after these initial parameters:
%
%  'baseyear'    : Base year for NB firmware without this info, or base
%                  century for BB firmware (default to 2000).
%
%  'reference'  : ['best' | 'bottom' | 'navigation' | 'none'] 
%                 Reference for velocity info. Default is 'best', which uses
%                 bottom-track if available, otherwise uses nav (GPS) if available
%                 otherwise sets data to NaN. 'none' returns raw data.
%
%  'despike'    : [ 'no' | 'yes' | 5-element vector ]
%                 Controls ensemble averaging. With 'no' a simple mean is used.
%                 With 'yes' a mean is applied to all values that fall within a 
%                 window around the median (giving some outlier rejection). This 
%                 is useful for noisy data (default). Window sizes are 
%                 [.3 .3 .3 2 50] m/s for 
%                 [ horiz_vel vert_vel error_vel bottom_horiz_vel and bottom-range] 
%                 values. If you want to change these values, set 'despike' 
%                 to your 5-element vector.
%
% R. Pawlowicz (rich@ocgy.ubc.ca) - 10/07/98

% Rich Pawlowicz - 10/Jul/98 
% Modified for NB files, 3/Feb/99
% Changed to read NB files from JDG00 -and-
%   to return an mtime format, 29/Jun/00 
% 1/8/00 - Added database capability (and by-time loading)
% 26/4/01 - Added multi-file database capability.
% 26/4/01 - Added BB handling.
% 29/03/02 - Reworked interface to make cfg output more intuitive, also
%            added parameter/value input pairs.
% 18/04/02 - Finally got the real scoop from RDI as to why hdr.nbytes
%            was apparently wrong (their manual was incorrect).
% 29/11/02 - SOme changes in the field length for 'discharge' blocks
%           probably not completely correctly done.
%  8/3/02 - some weird stuff (extra added byte) in a ver 2.72 River transect
%           output file.
%  10/7/03 - uint32 should be int32 in ssp decoding.
%  11/11/03 - some changes in the field length for 'discharge blocks in
%             NB files (probably not completely correct as exact
%             version of changeover uncertains).
%  29/Sep/2005 - median windowing done slightly incorrectly in a way which biases
%                results in a negative way in data is *very* noisy. Now fixed.



global INFO PROGYEAR 

% Parse input

readbyfile=1;
INFO=struct('create',0,'mtime',[],'fileptr',[],'numrec',[]);
      % create = 0 for no info
               % 1 for create info
	       % 2 used as a flag to indicate "store time of next ping"
num_av=5;
nens=-1;
ref='best';

%%Spike parameters - delete points more than this value away from median in ensemble.
%      horiz  vert  error

vels=[.3 .3 .3 2 50];



% Assumed year
PROGYEAR=2000;

if isstr(varargin{1}),  % 'by file' input
  readbyfile=1;
  name=varargin{1};
  varargin(1)=[];
else
  readbyfile=0;
  tlims=varargin{1};
  varargin(1)=[];
end;

lv=length(varargin);
if lv>0 & isstr(varargin{lv}) & strcmp(varargin{lv},'info'),  % Create info file
   fprintf('Adding file info to database\n');
   INFO.create=1;
   varargin(lv)=[]; lv=lv-1;
end;    

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

while length(varargin)>0,
 switch varargin{1}(1:3),
	 case 'bas',
	   PROGYEAR = varargin{2};
	 case 'ref',
	   ref=varargin{2};
	 case 'des',
	   if isstr(varargin{2}),
	    if strcmp(varargin{2},'no'), vels='no';
	    else vels=[.3 .3 .3 2 50]; end;
	   else
	    vels=varargin{2}; 
	   end;   
	 otherwise,
	   error(['Unknown command line option  ->' varargin{1}]);
   end;
   varargin([1 2])=[];
end;   	          	
ref=ref(1:3);
 
shipdisp=10*3*num_av/2*10;

fprintf('Assuming base year is %d (for NB-ADCP)\n',PROGYEAR);



if readbyfile,
  naminfo=dir(name);

  fprintf('\nOpening file %s\n',name);
  fd=fopen(name,'r','ieee-le');

  if fd<0,
   error(['Invalid filename: ' name ]);
  end;

  % Read first segment with configuration data
  cfg=read_cfgseg(fd);

  % Get # of bytes per segment
  pos=ftell(fd);
  [ens,hdr]=read_ensemble(fd,-num_av,cfg);   % Read first ensembleand initialize
  bytes=ftell(fd)-pos;             % Bytes in the ensemble
  fseek(fd,pos,'bof');              % Reposition

  % Estimate number of records (since I don't feel like handling EOFs correctly,
  % we just don't read that far!)
  if nens==-1,
    nens=fix((naminfo.bytes-pos)/bytes)-1;
    fprintf('\nEstimating %d ensembles in this file\nReducing by a factor of %d\n',nens,num_av); 
  else
    fprintf('\nReading %d ensembles in this file\nReducing by a factor of %d\n',nens,num_av); 
  end;

  % Number of records after averaging.

  n=fix(nens/num_av);
  n_per_file=n;
  
else  %% Reading by time

  load Pdatabase
  kstart=sum(Pdatabase.stime<=tlims(1));
  if sum(Pdatabase.etime<=tlims(1))==kstart, kstart=kstart+1; end;
  
  kend=sum(Pdatabase.etime<=tlims(2))+1;
  if sum(Pdatabase.stime<=tlims(2))+1==kend, kend=kend-1; end;
  
  if kend==kstart,
    kkstart=sum(Pdatabase.cfgtimes{kstart}<=tlims(1));
    kkend=sum(Pdatabase.cfgtimes{kstart}<=tlims(2));  
    nens=sum(Pdatabase.numrec{kstart}(kkstart:kkend));
    fprintf('\nOpening file %s\n',Pdatabase.filname{kstart});
    fprintf('Using data blocks %d - %d\n',kkstart,kkend); 
  else
    kkstart=max(1,sum(Pdatabase.cfgtimes{kstart}<=tlims(1)));
    nens=sum(Pdatabase.numrec{kstart}(kkstart:end));
    for kk=kstart+1:kend,
      kkend=sum(Pdatabase.cfgtimes{kk}<=tlims(2));  
      nens=[nens sum(Pdatabase.numrec{kk}(1:kkend))];
    end;
    fprintf('\nOpening first file %s\n',Pdatabase.filname{kstart});
    fprintf('Using data blocks %d - %d\n',kkstart,length(Pdatabase.cfgtimes{kstart})); 
  end;  
  
  n_per_file=cumsum(fix(nens/num_av));
  n=n_per_file(end);
  fprintf('\nReading %d ensembles\nReducing by a factor of %d\n',sum(nens),num_av); 

  % Open the first file
  
  fd=fopen(Pdatabase.filname{kstart},'r','ieee-le');
  fseek(fd,Pdatabase.cfgptr{kstart}(kkstart),'bof');

  cfg=read_cfgseg(fd);
  pos=ftell(fd);
  [ens,hdr]=read_ensemble(fd,-num_av,cfg);   % Read first ensembleand initialize
  fseek(fd,pos,'bof');              % Reposition
end;

if num_av>1,
  if isstr(vels),
     fprintf('\n Simple mean used for ensemble averaging\n');
  else
     fprintf('\n Averaging after outlier rejection with parameters [%f %f %f %f %f]\n',vels);
  end;
end;

% Structure to hold all ADCP data (config. data goes to cfg)

adcp=struct('name','bb-adcp','config',cfg,'day',zeros(1,n),'time',zeros(1,n),'mtime',zeros(1,n),'number',zeros(1,n),'pitch',zeros(1,n),...
            'roll',zeros(1,n),'heading',zeros(1,n),'temperature',zeros(1,n),'bt_east_vel',zeros(1,n),...
            'bt_north_vel',zeros(1,n),'bt_vert_vel',zeros(1,n),'bt_error_vel',zeros(1,n),...
            'bt_range',zeros(4,n),'bt_x_disp',zeros(1,n),'bt_y_disp',zeros(1,n),...
            'east_vel',zeros(hdr.n_deps,n),'north_vel',zeros(hdr.n_deps,n),'vert_vel',zeros(hdr.n_deps,n),...
            'error_vel',zeros(hdr.n_deps,n),'intens',zeros(hdr.n_deps,4,n),...
            'nav_east_vel',zeros(1,n),'nav_north_vel',zeros(1,n),'latitude',zeros(1,n),...
            'longitude',zeros(1,n),'comment',setstr(repmat(' ',1,80)));

switch cfg.adcp_type,
  case 'broadband',
    adcp.name='bb-adcp';
  case 'narrowband', 
    adcp.name='nb-adcp'; 
  otherwise
    adcp.name='unknown';
end;


intens_cal=log10(cfg.range)*([1 1 1 1]*20) + cfg.range*([1 1 1 1]*cfg.absorption*2);

% Loop for all records
for k=1:n,
  
  if k>n_per_file(1),
    kstart=kstart+1;
    n_per_file(1)=[];
    fprintf('\nOpening next file %s\n',Pdatabase.filname{kstart});
    fd=fopen(Pdatabase.filname{kstart},'r','ieee-le');
    fseek(fd,Pdatabase.cfgptr{kstart}(1),'bof');

    cfg=read_cfgseg(fd);
    pos=ftell(fd);
    [ens,hdr]=read_ensemble(fd,-num_av,cfg);   % Read first ensembleand initialize
    fseek(fd,pos,'bof');              % Reposition
  end;
  
  if rem(k,50)==0,  fprintf('\n%d',k*num_av);end;
  fprintf('.');
  
  ens=read_ensemble(fd,num_av,cfg);

  if ens.day(num_av)~=ens.day(1),
    adcp.time(k)=median(ens.time+(ens.day>ens.day(1))*86400);
    if adcp.time(k)>86400,
      adcp.time(k)=adcp.time(k)-86400;
      adcp.day(k)=ens.day(num_av);
    else
      adcp.day(k)=ens.day(1);
    end;
  else
    adcp.time(k)=median(ens.time);
    adcp.day(k)=ens.day(1);
  end;
  
  if strcmp(cfg.adcp_type,'narrowband'),
    adcp.mtime(k)=datenum(PROGYEAR,1,1)+adcp.time(k)/86400;
  else
    adcp.mtime(k)=datenum(PROGYEAR,1,1)+adcp.day(k)+adcp.time(k)/86400;
  end;
  
  adcp.number(k)      =ens.number(1);
  adcp.pitch(k)       =mean(ens.pitch);
  adcp.roll(k)        =mean(ens.roll);
  adcp.heading(k)     =mean(ens.heading);
  adcp.temperature(k) =mean(ens.temperature);
  if isstr(vels),
     adcp.bt_east_vel(k) =nmean(ens.bt_east_vel);
     adcp.bt_north_vel(k)=nmean(ens.bt_north_vel);
     adcp.bt_vert_vel(k) =nmean(ens.bt_vert_vel);
     adcp.bt_error_vel(k)=nmean(ens.bt_error_vel);
     adcp.bt_range(:,k)  =nmean(ens.bt_range,2);
     adcp.bt_x_disp(k)   =nmean(ens.bt_x_disp);
     adcp.bt_y_disp(k)   =nmean(ens.bt_y_disp);

     adcp.nav_east_vel(k) =nmean(ens.nav_east_vel);
     adcp.nav_north_vel(k)=nmean(ens.nav_north_vel);
     adcp.latitude(k)     =nmean(ens.latitude);
     adcp.longitude(k)    =nmean(ens.longitude);

     ol=ones(size(ens.east_vel,1),1);

     if (strcmp(ref,'bes') | strcmp(ref,'bot')) & isfinite(adcp.bt_east_vel(k)),
       adcp.east_vel(:,k)    =nmean((ens.east_vel -ens.bt_east_vel(ol,:)) ,2);
       adcp.north_vel(:,k)   =nmean((ens.north_vel-ens.bt_north_vel(ol,:)),2);
       adcp.vert_vel(:,k)    =nmean((ens.vert_vel -ens.bt_vert_vel(ol,:)) ,2);
       adcp.error_vel(:,k)   =nmean((ens.error_vel-ens.bt_error_vel(ol,:)),2);
     elseif (strcmp(ref,'bes') | strcmp(ref,'nav')) & isfinite(adcp.nav_east_vel(k)), 
       if strcmp(ref,'bes'), disp('No Bottom track - using Nav to correct velocities'); end;
       adcp.east_vel(:,k)    =nmean((ens.east_vel +ens.nav_east_vel(ol,:)) ,2);
       adcp.north_vel(:,k)   =nmean((ens.north_vel+ens.nav_north_vel(ol,:)),2);
       adcp.vert_vel(:,k)    =nmean((ens.vert_vel) ,2);
       adcp.error_vel(:,k)   =nmean((ens.error_vel),2);
     elseif strcmp(ref,'non'),
       adcp.east_vel(:,k)    =nmean((ens.east_vel) ,2);
       adcp.north_vel(:,k)   =nmean((ens.north_vel),2);
       adcp.vert_vel(:,k)    =nmean((ens.vert_vel) ,2);
       adcp.error_vel(:,k)   =nmean((ens.error_vel),2);   
     else  
       disp('Velocities uncorrected - set to NaN');
       adcp.east_vel(:,k)    =NaN;
       adcp.north_vel(:,k)   =NaN;
       adcp.vert_vel(:,k)    =NaN;
       adcp.error_vel(:,k)   =NaN;
     end;
  else	  
     adcp.bt_east_vel(k) =nmedian(ens.bt_east_vel ,vels(4));
     adcp.bt_north_vel(k)=nmedian(ens.bt_north_vel,vels(4));
     adcp.bt_vert_vel(k) =nmedian(ens.bt_vert_vel ,vels(2));
     adcp.bt_error_vel(k)=nmedian(ens.bt_error_vel,vels(3));
     adcp.bt_range(:,k)  =nmedian(ens.bt_range,vels(5),2);
     adcp.bt_x_disp(k)   =nmedian(ens.bt_x_disp,shipdisp);
     adcp.bt_y_disp(k)   =nmedian(ens.bt_y_disp,shipdisp);

     adcp.nav_east_vel(k) =nmedian(ens.nav_east_vel,vels(4));
     adcp.nav_north_vel(k)=nmedian(ens.nav_north_vel,vels(4));
     adcp.latitude(k)     =nmedian(ens.latitude,shipdisp/111e3);
     adcp.longitude(k)    =nmedian(ens.longitude,shipdisp/111e3);

     ol=ones(size(ens.east_vel,1),1);

     if (strcmp(ref,'bes') | strcmp(ref,'bot')) & isfinite(adcp.bt_east_vel(k)),
       adcp.east_vel(:,k)    =nmedian((ens.east_vel -ens.bt_east_vel(ol,:)) ,vels(1),2);
       adcp.north_vel(:,k)   =nmedian((ens.north_vel-ens.bt_north_vel(ol,:)),vels(1),2);
       adcp.vert_vel(:,k)    =nmedian((ens.vert_vel -ens.bt_vert_vel(ol,:)) ,vels(2),2);
       adcp.error_vel(:,k)   =nmedian((ens.error_vel-ens.bt_error_vel(ol,:)),vels(3),2);
     elseif (strcmp(ref,'bes') | strcmp(ref,'nav')) & isfinite(adcp.nav_east_vel(k)), 
       if strcmp(ref,'bes'), disp('No Bottom track - using Nav to correct velocities'); end;
       adcp.east_vel(:,k)    =nmedian((ens.east_vel +ens.nav_east_vel(ol,:)) ,vels(1),2);
       adcp.north_vel(:,k)   =nmedian((ens.north_vel+ens.nav_north_vel(ol,:)),vels(1),2);
       adcp.vert_vel(:,k)    =nmedian((ens.vert_vel) ,vels(2),2);
       adcp.error_vel(:,k)   =nmedian((ens.error_vel),vels(3),2);
     elseif strcmp(ref,'non'),
       adcp.east_vel(:,k)    =nmedian((ens.east_vel) ,vels(1),2);
       adcp.north_vel(:,k)   =nmedian((ens.north_vel),vels(1),2);
       adcp.vert_vel(:,k)    =nmedian((ens.vert_vel) ,vels(2),2);
       adcp.error_vel(:,k)   =nmedian((ens.error_vel),vels(3),2);   
     else  
       disp('Velocities uncorrected - set to NaN');
       adcp.east_vel(:,k)    =NaN;
       adcp.north_vel(:,k)   =NaN;
       adcp.vert_vel(:,k)    =NaN;
       adcp.error_vel(:,k)   =NaN;
     end;
  end;
  adcp.intens(:,:,k)   =nmean(ens.intens,3)*cfg.intens_scale + intens_cal;
  
    
end;  

fprintf('\n');
fclose(fd);

% Make or update the database
if INFO.create==1,
  if strcmp(cfg.adcp_type,'broadband'),
    etime=adcp.mtime(k);
  else
    etime=datenum(PROGYEAR,1,1)+adcp.time(k)/86400;
  end;
  if ~exist('Pdatabase.mat'),
    Pdatabase.cfg={cfg};
    Pdatabase.filname={name};
    Pdatabase.stime=INFO.mtime(1);
    Pdatabase.etime=etime;
    Pdatabase.cfgtimes={INFO.mtime};
    Pdatabase.cfgptr={INFO.fileptr};
    Pdatabase.numrec={INFO.numrec};
    save Pdatabase Pdatabase
  else
    load Pdatabase
    k=sum(Pdatabase.stime<=INFO.mtime(1));
    if k==0 | Pdatabase.stime(k)~=INFO.mtime(1),  
      Pdatabase.cfg={Pdatabase.cfg{1:k},cfg,Pdatabase.cfg{k+1:end}};
      Pdatabase.filname={Pdatabase.filname{1:k},name,Pdatabase.filname{k+1:end}};
      Pdatabase.stime=[Pdatabase.stime(1:k),INFO.mtime(1),Pdatabase.stime(k+1:end)];
      Pdatabase.etime=[Pdatabase.etime(1:k),etime,Pdatabase.etime(k+1:end)];
      Pdatabase.cfgtimes={Pdatabase.cfgtimes{1:k},INFO.mtime,Pdatabase.cfgtimes{k+1:end}};
      Pdatabase.cfgptr={Pdatabase.cfgptr{1:k},INFO.fileptr,Pdatabase.cfgptr{k+1:end}};  
      Pdatabase.numrec={Pdatabase.numrec{1:k},INFO.numrec,Pdatabase.numrec{k+1:end}};  
      save Pdatabase Pdatabase
    else
      fprintf('Already in Database - not replacing!\n');
    end;
  end;  
end;      

%--------------------------------------
function hdr=read_hdr(fd,adcp_type,n_cells);
% Reads a Header

hdrid=fread(fd,1,'uint16');  % Head ID

if hdrid~=hex2dec('7e7f'),

 % This corrects a case where the .000 file seemed to have
 % one byte too many (prog_ver 2.72)
 if ftell(fd)>3,  % Not the very first segment
   backnum=-10;twin=20;
   fseek(fd,backnum,'cof');
   bb=fread(fd,twin,'uint8');
   ff=find(bb(1:twin-1)==hex2dec('7F') & bb(2:twin)==hex2dec('7E'));
   if any(ff),
     fseek(fd,-twin+(ff-1)+2,'cof'); % beginning of segment +2 for headerID
     fprintf('Warning - segment length wrong, correction %d\n',backnum+ff-1+2);
   else  
     error(['File ID is ' dec2hex(hdrid) ' not 7E7F - data corrupted or not a P-file?']);
   end; 
 else  
   error(['File ID is ' dec2hex(hdrid) ' not 7E7F - data corrupted or not a P-file?']);
 end;
end;

hdr.nbyte          =fread(fd,1,'int16')-1;  % Apparently this number is the
                                            % legnth of the segment to the end of
					    % the checksum but not including the
					    % header byte. For consistency with
					    % rdradcp I am subtracting one and
					    % claiming this is everything but
					    % the 2-byte checksum.

hdr.n_deps         =fread(fd,1,'uint8');
if strcmp(adcp_type,'narrowband'), hdr.n_deps=n_cells; end;

ndat=fread(fd,1,'int8');
hdr.dat_offsets    =fread(fd,ndat,'int16');

hdr.nbyte=hdr.nbyte-6-ndat*2;

%-------------------------------------
function cfg=read_cfgseg(fd);
% Read config data

hdr=read_hdr(fd,0,0);

cfgid=fread(fd,1,'uint16');
if cfgid~=hex2dec('000a'),
 warning(['Cnfig ID ' dec2hex(cfgid) ' is incorrect - data corrupted or not a P-file?']);
end; 

cfg=read_cfg(hdr,fd);

fseek(fd,2,'cof'); % Skip checksum

%-------------------------------------
function opt=getopt(val,varargin);
% Returns one of a list (0=first in varargin, etc.)
if val>length(varargin),
	opt='unknown';
else
   opt=varargin{val+1};
end;
   			
%-------------------------------------
function cfg=read_cfg(hdr,fd);
% Reads the configuration data

global INFO

fptr=ftell(fd)-2; % Pointer to beginning of segment

cfg.adcp_type      =getopt(fread(fd,1,'uint8'),'narrowband','broadband'); 

if strcmp(cfg.adcp_type,'broadband'), % BB P-file format
  cfg.prog_ver       =fread(fd,1,'uint8')+fread(fd,1,'uint8')/100;
  cfg.firm_ver       =fread(fd,1,'uint16')/100;
  cfg.n_beams        =fread(fd,1,'uint8');
  cfg.beam_angle     =fread(fd,1,'uint16');
  cfg.beam_freq      =fread(fd,1,'uint16');
  cfg.prof_mode      =fread(fd,1,'uint8');         
  cfg.coord_sys      =getopt(fread(fd,1,'uint16'),'beam','earth','ship','instrument');
  cfg.orientation    =getopt(fread(fd,1,'uint16'),'up','down');
  cfg.beam_pattern   =getopt(fread(fd,1,'uint16'),'convex','concave');
  cfg.n_cells        =fread(fd,1,'uint8');
  cfg.time_between_ping_groups=fread(fd,1,'uint32')*.01; % seconds
  cfg.pings_per_ensemble=fread(fd,1,'uint16');
  cfg.cell_size      =fread(fd,1,'uint16')*.01;	% meters
  cfg.blank          =fread(fd,1,'uint16')*.01;	% meters
  cfg.adcp_depth     =fread(fd,1,'uint32')*.01;	% meters
  cfg.avg_method     =getopt(fread(fd,1,'uint8'),'time','space');
  cfg.avg_interval   =fread(fd,1,'uint32')*.01;	% seconds or meters
  cfg.magnetic_var   =fread(fd,1,'int32')*.001;	% degrees
  cfg.compass_offset =fread(fd,1,'int32')*.001;   % degrees
  cfg.xducer_misalign=fread(fd,1,'int32')*.001;   % degrees
  cfg.intens_scale   =fread(fd,1,'uint16')*.001;   % db/count
  cfg.absorption     =fread(fd,1,'uint16')*.001;   % db/m
  cfg.salinity       =fread(fd,1,'uint16')*.001;   % ppt
  cfg.ssp            =fread(fd,1,'int32')*.01;    % m/s
  cfg.ssp_use        =getopt(fread(fd,1,'uint8'),'yes','no');
  cfg.use_pitchroll  =getopt(fread(fd,1,'uint8'),'yes','no');
  fseek(fd,20,'cof');                        % Bunch of stuff for discharge calcs.
  cfg.bin1_dist      =fread(fd,1,'uint16')*.01;	% meters
  cfg.xmit_pulse     =fread(fd,1,'uint16')*.01;	% meters
  fseek(fd,4,'cof');
  nchar=fread(fd,1,'uint8');
  cfg.deploy_name    =setstr(fread(fd,nchar,'char')');
  fseek(fd,2,'cof');
  s1=fread(fd,1,'uint8');
  cfg.cmd_set1       =setstr(fread(fd,[s1],'char')');
  s2=fread(fd,1,'uint8');
  cfg.cmd_set2       =setstr(fread(fd,[s2],'char')');
  cfg.comment        =setstr(repmat(' ',1,80));

  fprintf('CFG data');
 
  offset=hdr.nbyte-(96+nchar+s1+s2); 
  if offset~=0,
    fprintf(' Header: excess bytes %d\n',offset);
    fseek(fd,offset,'cof');  % get to end of segment
  end;
                           
elseif strcmp(cfg.adcp_type,'narrowband'),  % NB p-format
  cfg.prog_ver       =fread(fd,1,'uint8')+fread(fd,1,'uint8')/100;
  cfg.serialnum      =fread(fd,1,'uint16');
  cfg.firm_ver       =fread(fd,1,'uint16')/100;
  cfg.n_beams        =fread(fd,1,'uint8');
  cfg.beam_angle     =fread(fd,1,'uint8');
  cfg.beam_freq      =fread(fd,1,'uint16');
  cfg.range_switch   =fread(fd,1,'uint8');         %
  cfg.coord_sys      =getopt(fread(fd,1,'uint8'),'beam','earth');     
  cfg.orientation    =getopt(fread(fd,1,'uint8'),'up','down');
  cfg.beam_pattern   =getopt(fread(fd,1,'uint8'),'convex','concave');
  cfg.n_cells        =fread(fd,1,'uint8');
  cfg.time_between_ping_groups=fread(fd,1,'uint32')*.01; % seconds
  cfg.pings_per_ensemble=fread(fd,1,'uint16');
  cfg.cell_size      =fread(fd,1,'uint8');	% meters
  cfg.xmit_pulse     =fread(fd,1,'uint16');	% transmit pulse length (meters)
  cfg.blank          =fread(fd,1,'uint16');	% meters
  cfg.adcp_depth     =fread(fd,1,'uint32')*.01;	% meters
  cfg.avg_method     =getopt(fread(fd,1,'uint8'),'time','space');
  cfg.avg_interval   =fread(fd,1,'uint32')*.01;	% seconds or meters
  cfg.magnetic_var   =fread(fd,1,'int32')*.001;	% degrees
  cfg.compass_offset =fread(fd,1,'int32')*.001;   % degrees
  cfg.xducer_misalign=fread(fd,1,'int32')*.001;   % degrees
  cfg.intens_scale   =fread(fd,1,'uint16')*.001;   % db/count
  cfg.absorption     =fread(fd,1,'uint16')*.001;   % db/m
  cfg.salinity       =fread(fd,1,'uint16')*.001;   % ppt
  cfg.ssp            =fread(fd,1,'uint32')*.001;   % m/s
  cfg.ssp_use        =getopt(fread(fd,1,'uint8'),'yes','no');
  cfg.use_pitchroll  =getopt(fread(fd,1,'uint8'),'yes','no');
  fseek(fd,20,'cof');
  fseek(fd,8,'cof');
  cfg.bin1_dist      =cfg.adcp_depth+cfg.blank+cfg.cell_size/2;
  
  nchar=fread(fd,1,'uint8');
  cfg.deploy_name    =setstr(fread(fd,nchar,'char')');
  fseek(fd,2,'cof');
  s1=fread(fd,1,'uint8');
  cfg.cmd_set1       =setstr(fread(fd,[s1],'char')');
  cfg.comment        =setstr(repmat(' ',1,80));

  fprintf('CFG data');
  
  offset=hdr.nbyte-(94+nchar+s1);
  if offset~=0,
    fprintf('Header: excess bytes %d\n',offset);
    fseek(fd,offset,'cof');  % get to end of segment
  end;
                                           
else
   error(['Unknown adcp type']);				       					       					       
end;

% Calibration factors for backscatter data
cfg.range=cfg.bin1_dist+[0:cfg.n_cells-1]'*cfg.cell_size;


if INFO.create==1, % Set flag to store next time
  INFO.create=2;
  INFO.fileptr=[INFO.fileptr;fptr-6-length(hdr.dat_offsets)*2];
  INFO.numrec=[INFO.numrec;0];
end;

%-----------------------------
function [ens,hdr]=read_ensemble(fd,num_av,cfg);

% To save it being re-initialized every time.
global ens INFO PROGYEAR

% If num_av<0 we are reading only 1 element and initializing
if num_av<0,
 n=abs(num_av);
 pos=ftell(fd);
 hdr=read_hdr(fd,cfg.adcp_type,cfg.n_cells);
 fseek(fd,pos,'bof');
 clear global ens
 global ens
 ens=struct('day',zeros(1,n),'time',zeros(1,n),'number',zeros(1,n),'pitch',zeros(1,n),...
            'roll',zeros(1,n),'heading',zeros(1,n),'temperature',zeros(1,n),'bt_east_vel',zeros(1,n),...
            'bt_north_vel',zeros(1,n),'bt_vert_vel',zeros(1,n),'bt_error_vel',zeros(1,n),...
            'bt_range',zeros(4,n),'bt_x_disp',zeros(1,n),'bt_y_disp',zeros(1,n),...
            'elapsed_time',zeros(1,n),'bt_path_len',zeros(1,n),'num_averaged',zeros(1,n),...
            'east_vel',zeros(hdr.n_deps,n),'north_vel',zeros(hdr.n_deps,n),'vert_vel',zeros(hdr.n_deps,n),...
            'error_vel',zeros(hdr.n_deps,n),'intens',zeros(hdr.n_deps,4,n),'percent',zeros(hdr.n_deps,n),...
            'nav_east_vel',zeros(1,n),'nav_north_vel',zeros(1,n),'nav_x_disp',zeros(1,n),...
            'nav_y_disp',zeros(1,n),'nav_path_len',zeros(1,n),'latitude',zeros(1,n),...
            'longitude',zeros(1,n),'filterwidth',zeros(1,n));
  num_av=1;
  ens.day(1)=0;
end;


if strcmp(cfg.adcp_type,'narrowband'),
  bad_val=32767;
else
  bad_val=-32768;
end;
bad_vald1000=bad_val*0.001;;

k=0;
while k<num_av,

  hdr=read_hdr(fd,cfg.adcp_type,cfg.n_cells);
  k=k+1;
  
  for n=1:length(hdr.dat_offsets),

    id=fread(fd,1,'uint16');
%  fprintf('ID: %s\n',dec2hex(id,4));
    switch dec2hex(id,4),

    case '000B',   % Leader
      if strcmp(cfg.adcp_type,'broadband'), % BB format
	ens.day(k)            =fread(fd,1,'uint32');      % days from beginning of century
	ens.time(k)           =fread(fd,1,'uint32')*.01;  % secs from beginning of day
	ens.number(k)         =fread(fd,1,'uint16');
	ens.pitch(k)          =fread(fd,1,'int16')*.01;   % degrees
	ens.roll(k)           =fread(fd,1,'int16')*.01;   % degrees
	ens.heading(k)        =fread(fd,1,'uint16')*.01;  % degrees
	ens.temperature(k)    =fread(fd,1,'int16')*.01;   % Deg C
	ens.bt_east_vel(k)    =fread(fd,1,'int16')*.001;  % m/s
	ens.bt_north_vel(k)   =fread(fd,1,'int16')*.001;  % m/s
	ens.bt_vert_vel(k)    =fread(fd,1,'int16')*.001;  % m/s
	ens.bt_error_vel(k)   =fread(fd,1,'int16')*.001;  % m/s

	fseek(fd,8,'cof');   % Skip WL velocities
	ens.bt_range(:,k)     =fread(fd,4,'uint16')*.01;  % m/s
	ens.bt_x_disp(k)      =fread(fd,1,'int32')*.01;   % m
	ens.bt_y_disp(k)      =fread(fd,1,'int32')*.01;   % m
	ens.elapsed_time(k)   =fread(fd,1,'uint32')*.01;  % sec
	ens.bt_path_len(k)    =fread(fd,1,'uint32')*.01;  % m
	fseek(fd,14,'cof');
	ens.num_averaged(k)   =fread(fd,1,'uint16');
      else
	ens.time(k)           =fread(fd,1,'uint32');      % seconds since Jan1
	ens.number(k)         =fread(fd,1,'uint16');
	ens.pitch(k)          =fread(fd,1,'int16')*.01;   % degrees
	ens.roll(k)           =fread(fd,1,'int16')*.01;   % degrees
	ens.heading(k)        =fread(fd,1,'uint16')*.01;  % degrees
	ens.temperature(k)    =fread(fd,1,'int16')*.01;   % Deg C
	ens.bt_east_vel(k)    =fread(fd,1,'int16')*.001;  % m/s
	ens.bt_north_vel(k)   =fread(fd,1,'int16')*.001;  % m/s
	ens.bt_vert_vel(k)    =fread(fd,1,'int16')*.001;  % m/s
	ens.bt_error_vel(k)   =fread(fd,1,'int16')*.001;  % m/s

	ens.bt_range(:,k)     =fread(fd,4,'uint16');      % m/s
	ens.bt_x_disp(k)      =fread(fd,1,'int32')*.01;   % m
	ens.bt_y_disp(k)      =fread(fd,1,'int32')*.01;   % m
	ens.elapsed_time(k)   =fread(fd,1,'uint32')*.01;  % sec
	ens.bt_path_len(k)    =fread(fd,1,'uint32')*.01;  % m
	fseek(fd,14,'cof');
	ens.num_averaged(k)   =fread(fd,1,'uint16');
      end;
      
      if INFO.create>0, INFO.numrec(end)=INFO.numrec(end)+1; end;
      if INFO.create==2,  % Store the time
        if strcmp(cfg.adcp_type,'broadband'),
          INFO.mtime=[INFO.mtime;datenum(PROGYEAR,1,1)+ens.day(k)+ens.time(k)/86400];
	  INFO.create=1;
	else
          INFO.mtime=[INFO.mtime;datenum(PROGYEAR,1,1)+ens.time(k)/86400];
	  INFO.create=1;
	end;
      end;
      	
    case '0001',  % Velocities

      vels=fread(fd,[4 hdr.n_deps],'int16')'*.001;     % m/s
      ens.east_vel(:,k) =vels(:,1);
      ens.north_vel(:,k)=vels(:,2);
      ens.vert_vel(:,k) =vels(:,3);
      ens.error_vel(:,k)=vels(:,4);

    case '0003',  % Echo Intensities

      ens.intens(:,:,k)   =fread(fd,[4 hdr.n_deps],'uint8')';

    case '0104',  % Percent good

      ens.percent(:,k)   =fread(fd,[hdr.n_deps],'uint8')';

    case '000C'   % Discharge
      if strcmp(cfg.adcp_type,'narrowband'),
        if cfg.prog_ver<1.85,  % This for version  Transect v1.82
          fseek(fd,4*hdr.n_deps,'cof'); 
        else                   % This for version  Transect v1.85
	  fseek(fd,4*(hdr.n_deps-1)+2,'cof');
	end;  
%%	dec2hex(fread(fd,10,'uint16'),4)
      else  
        if cfg.prog_ver>6,                  % Appparently TRANSECT v 3,4,5 weirdness fixed later (29/11/02)         
          fseek(fd,4*hdr.n_deps,'cof');
        else
          fseek(fd,4*(hdr.n_deps-1)+2,'cof');
        end;
%%	dec2hex(fread(fd,hdr.n_deps*4,'uint32'),4)
      end;
    
    case '000E'  % Navigation

      ens.nav_east_vel(k)  =fread(fd,1,'int16')*.001;   % m/s
      ens.nav_north_vel(k) =fread(fd,1,'int16')*.001;   % m/s
      ens.nav_x_disp(k)    =fread(fd,1,'int32')*.01;   % m
      ens.nav_y_disp(k)    =fread(fd,1,'int32')*.01;   % m
      ens.nav_path_len(k)  =fread(fd,1,'uint32')*.01;  % m
      ens.latitude(k)      =fread(fd,1,'int32')*.001/3600; % Degrees Lat
      ens.longitude(k)     =fread(fd,1,'int32')*.001/3600; % Degrees Long
      ens.filterwidth(k)   =fread(fd,1,'uint16');

     case '000A',   % They sometimes stick the config file in the middle as well -
                    % We are going to ignore this data assuming it replicates the first.
       read_cfg(hdr,fd);
       
    otherwise,
      fprintf('Unrecognized ID code: %sh',dec2hex(id,4));
      if n<length(hdr.dat_offsets),
        skp=hdr.dat_offsets(n+1)-hdr.dat_offsets(n);
      else
        skp=hdr.nbyte-hdr.dat_offsets(n);
      end;
      fprintf(' - Skipping forward %d bytes\n',skp);
      fseek(fd,skp,'cof');

    end;
  end;
  fseek(fd,2,'cof'); % Skip checksum
 
end;

if strcmp(cfg.adcp_type,'broadband'),
  big_err=abs(ens.bt_error_vel)>abs(bad_vald1000);
else
  big_err=zeros(size(ens.bt_error_vel));
end;

ens.bt_east_vel( ens.bt_east_vel== bad_vald1000 | big_err)=NaN;
ens.bt_north_vel(ens.bt_north_vel==bad_vald1000 | big_err)=NaN;
ens.bt_vert_vel( ens.bt_vert_vel== bad_vald1000 | big_err)=NaN;
ens.bt_error_vel(ens.bt_error_vel==bad_vald1000 | big_err)=NaN;

if strcmp(cfg.adcp_type,'broadband'),
  ens.bt_range(:,isnan(ens.bt_error_vel))=NaN;
end;


%big_err=abs(ens.error_vel)>.2;
big_err=0;
	
ens.east_vel( ens.east_vel== bad_vald1000 | big_err)=NaN;
ens.north_vel(ens.north_vel==bad_vald1000 | big_err)=NaN;
ens.vert_vel( ens.vert_vel== bad_vald1000 | big_err)=NaN;
ens.error_vel(ens.error_vel==bad_vald1000 | big_err)=NaN;

ens.nav_east_vel( ens.nav_east_vel== bad_vald1000 | big_err)=NaN;
ens.nav_north_vel(ens.nav_north_vel==bad_vald1000 | big_err)=NaN;

ens.longitude(ens.longitude==2147483647*.001/3600)=NaN;
ens.latitude(ens.latitude==2147483647*.001/3600)=NaN;


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
























