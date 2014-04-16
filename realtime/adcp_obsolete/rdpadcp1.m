function [adcp,cfg,ens]=rdpadcp1(name,num_av,nens,cfg,progyear);
% read (binary) processed ADCP files, puts all the relevant data into a 
% structure, and saves it to a mat-file for future use. 
% [ADCP,CFG]=RDPADCP(NAME) reads the p-file NAME and returns a structure
%  CFG containing configuration info and a structure ADCP containing data.
%
% The advantage of using the p-files is that navigation data can be merged
% into it.
%   RDPADCP(NAME,NUM_AV)
%   RDPADCP(NAME,NUM_AV,NREC)
%

% Rich Pawlowicz - 10/Jul/98 
% Modified for NB files, 3/Feb/99
% Changed to read NB files from JDG00 -and-
%   to return an mtime format, 29/Jun/00 

if nargin==1,
  num_av=5;   % Block filtering and decimation parameter (# ensembles to block together).
  nens=-1;
elseif nargin==2,
  nens=-1;
end;
if nargin<4
    cfg=[];
end;
% % Assumed year
% progyear=2001;
% 
% fprintf('Assuming year is %d (for NB-ADCP)\n',progyear);

%%Spike parameters - delete points more than this value away from median in ensemble.
%      horiz  vert  error
vels=[.3 .3 .3];
bvels=[1 .3 .3];
%brnge=20;

vels=[.3 .3 .3];
bvels=[2 .3 .3];
brnge=50;

shipdisp=10*3*num_av/2*10;

naminfo=dir(name);

fprintf('\nOpening file %s\n',name);
fd=fopen(name,'r','ieee-le');
if fd<0,
 error(['Invalid filename: ' name ]);
end;
if isempty(cfg)
  % Read first segment with configuration data
  cfg=read_cfgseg(fd);
end;
if isempty(cfg)
  adcp=[];
  cfg=[];
  return;
end;
  
% Get # of bytes per segment
pos=ftell(fd);
[ens,hdr]=read_ensemble(fd,-num_av,cfg);   % Read first ensembleand initialize
if isempty(hdr)
    adcp=[];
    cfg=[];
    return;
end;

bytes=ftell(fd)-pos;             % Bytes in the ensemble
fseek(fd,pos,'bof');              % Reposition

% Estimate number of records (since I don't feel like handling EOFs correctly,
% we just don't read that far!)
if nens==-1,
  nens=fix((naminfo.bytes-pos)/bytes);
  fprintf('\nEstimating %d ensembles in this file\nReducing by a factor of %d\n',nens,num_av); 
else
  fprintf('\nReading %d ensembles in this file\nReducing by a factor of %d\n',nens,num_av); 
end;
 
% Number of records after averaging.

n=fix(nens/num_av);

% Structure to hold all ADCP data (config. data goes to cfg)

adcp=struct('name','bb-adcp','day',zeros(1,n),'time',zeros(1,n),'mtime',zeros(1,n),'number',zeros(1,n),'pitch',zeros(1,n),...
            'roll',zeros(1,n),'heading',zeros(1,n),'temperature',zeros(1,n),'bt_east_vel',zeros(1,n),...
            'bt_north_vel',zeros(1,n),'bt_vert_vel',zeros(1,n),'bt_error_vel',zeros(1,n),...
            'bt_range',zeros(4,n),'bt_x_disp',zeros(1,n),'bt_y_disp',zeros(1,n),...
            'east_vel',zeros(hdr.n_deps,n),'north_vel',zeros(hdr.n_deps,n),'vert_vel',zeros(hdr.n_deps,n),...
            'error_vel',zeros(hdr.n_deps,n),'perc_good',zeros(hdr.n_deps,n),'intens',zeros(hdr.n_deps,4,n),...
            'nav_east_vel',zeros(1,n),'nav_north_vel',zeros(1,n),'latitude',zeros(1,n),...
            'longitude',zeros(1,n),'num_avg',zeros(1,n),'comment',setstr(repmat(' ',1,80)));

switch cfg.adcp_type,
  case 1,
    adcp.name='bb-adcp';
  case 0, 
    adcp.name='nb-adcp'; 
  otherwise
    adcp.name='unknown';
end;

% Calibration factors for backscatter data
Range=cfg.bin1_dist+[0:cfg.n_cells-1]'*cfg.cell_size;

% Store this in cfg
cfg.Range=Range;

intens_cal=log10(Range)*([1 1 1 1]*20) + Range*([1 1 1 1]*cfg.absorption*2);

% Loop for all records
for k=1:n,
  
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
  if cfg.adcp_type==0,
    adcp.mtime(k)=datenum(progyear,1,1)+adcp.time(k)/86400 - 1;
  else
      %% Do this for BB!
  end;
  adcp.num_average(k) = ens.num_averaged(1);
  adcp.number(k)      =ens.number(1);
  adcp.pitch(k)       =mean(ens.pitch);
  adcp.roll(k)        =mean(ens.roll);
  adcp.heading(k)     =mean(ens.heading);
  adcp.temperature(k) =mean(ens.temperature);
  adcp.bt_east_vel(k) =nmedian(ens.bt_east_vel ,bvels(1));
  adcp.bt_north_vel(k)=nmedian(ens.bt_north_vel,bvels(1));
  adcp.bt_vert_vel(k) =nmedian(ens.bt_vert_vel ,bvels(2));
  adcp.bt_error_vel(k)=nmedian(ens.bt_error_vel,bvels(3));
  adcp.bt_range(:,k)  =nmedian(ens.bt_range,brnge,2);
  adcp.bt_x_disp(k)   =nmedian(ens.bt_x_disp,shipdisp);
  adcp.bt_y_disp(k)   =nmedian(ens.bt_y_disp,shipdisp);
  
  adcp.nav_east_vel(k) =nmedian(ens.nav_east_vel,bvels(1));
  adcp.nav_north_vel(k)=nmedian(ens.nav_north_vel,bvels(1));
  adcp.latitude(k)     =nmedian(ens.latitude,shipdisp/111e3);
  adcp.longitude(k)    =nmedian(ens.longitude,shipdisp/111e3);

  ol=ones(size(ens.east_vel,1),1);
  adcp.east_vel(:,k)    =nmedian((ens.east_vel) ,vels(1),2);
  adcp.north_vel(:,k)   =nmedian((ens.north_vel),vels(1),2);
  adcp.vert_vel(:,k)    =nmedian((ens.vert_vel) ,vels(2),2);
  adcp.error_vel(:,k)   =nmedian((ens.error_vel),vels(3),2);
  adcp.intens(:,:,k)   =nmean(ens.intens,3).*cfg.intens_scale + intens_cal;  
  adcp.perc_good(:,k)  =nmean(ens.percent,2);
end;  

fprintf('\n');
fclose(fd);


%---------------re-----------------------
function hdr=read_hdr(fd,adcp_type,n_cells);
% Reads a Header

hdrid=fread(fd,1,'uint16');  % Head ID
   %fprintf('%03d: HEADER ID: %s\n\n',0,dec2hex(hdrid,4));
if hdrid~=hex2dec('7e7f'),
  
 % search around for header...
 pos = ftell(fd);
 fprintf('Header not found first try: pos...%05d %sh\n',pos-2,dec2hex(hdrid,4));
     
 %fseek(fd,-40*2,'cof'); % Skip checksum
 % search for stinky header...
 num = 0;
 while hdrid~=hex2dec('7e7f');
   num=num+1;
   hdrid=fread(fd,1,'uint16');  % Head ID
%   fprintf('%03d: HEADER ID: %s\n',i,dec2hex(hdrid,4));
 end;
 fprintf('Skipped %d \n',num);
% error('Header ID incorrect - data corrupted or not a processed file?');
end; 

hdr.nbyte          =fread(fd,1,'int16');

hdr.n_deps         =fread(fd,1,'int8');
if adcp_type==0, hdr.n_deps=n_cells; end;

ndat=fread(fd,1,'int8');
if ndat>0
  hdr.dat_offsets    =fread(fd,ndat,'int16');
else
  hdr=[];
  return;
end;

hdr.nbyte=hdr.nbyte-6-ndat*2;

%-------------------------------------
function cfg=read_cfgseg(fd);
% Read config data

hdr=read_hdr(fd,0,0);
if isempty(hdr)
    return;
end;
cfgid=fread(fd,1,'uint16');
if cfgid~=hex2dec('000a'),
 warning('Cnfig ID incorrect - data corrupted or not a processed file?');
end; 

cfg=read_cfg(hdr,fd);

fseek(fd,2,'cof'); % Skip checksum

%-------------------------------------
function cfg=read_cfg(hdr,fd);
% Reads the configuration data

cfg.adcp_type      =fread(fd,1,'uint8');          % =1 for broadband, =0 for narrowband

if cfg.adcp_type==1, % BB P-file format
  cfg.prog_ver       =fread(fd,4,'uint8');
  cfg.n_beams        =fread(fd,1,'uint8');
  cfg.beam_angle     =fread(fd,1,'uint16');
  cfg.beam_freq      =fread(fd,1,'uint16');
  cfg.prof_mode      =fread(fd,1,'uint8');         %
  cfg.coord_sys      =fread(fd,1,'uint16');        % 0=beam,1=earth,2=ship,3=instrument
  cfg.orientation    =fread(fd,1,'uint16');        % 0=up,1=down
  cfg.beam_pattern   =fread(fd,1,'uint16');        % 0=convex,1=concave
  cfg.n_cells        =fread(fd,1,'uint8');
  cfg.time_between_ping_groups=fread(fd,1,'uint32')*.01; % seconds
  cfg.pings_per_ensemble=fread(fd,1,'uint16');
  cfg.cell_size      =fread(fd,1,'uint16')*.01;	% meters
  cfg.blank          =fread(fd,1,'uint16')*.01;	% meters
  cfg.adcp_depth     =fread(fd,1,'uint32')*.01;	% meters
  cfg.avg_method     =fread(fd,1,'uint8');         % 0=time,1=space
  cfg.avg_interval   =fread(fd,1,'uint32')*.01;	% seconds or meters
  cfg.magnetic_var   =fread(fd,1,'int32')*.001;	% degrees
  cfg.compass_offset =fread(fd,1,'int32')*.001;   % degrees
  cfg.xducer_misalign=fread(fd,1,'int32')*.001;   % degrees
  cfg.intens_scale   =fread(fd,1,'uint16')*.001;   % db/count
  cfg.absorption     =fread(fd,1,'uint16')*.001;   % db/m
  cfg.salinity       =fread(fd,1,'uint16')*.001;   % ppt
  cfg.ssp            =fread(fd,1,'uint32')*.001;   % m/s
  cfg.ssp_use        =fread(fd,1,'uint8');         % 0=use T,S,1=fixed
  cfg.use_pitchroll  =fread(fd,1,'uint8');         % 0=yes,1=no
  fseek(fd,20,'cof');
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
  %%fprintf('Header: excess bytes %d\n',hdr.nbyte-(97+nchar+s1+s2));

  fseek(fd,hdr.nbyte-(97+nchar+s1+s2),'cof');  % get to end of segment
                                               % (should be 96 not 97 - not sure why the diff).
else
  cfg.prog_ver       =fread(fd,6,'uint8');
  cfg.n_beams        =fread(fd,1,'uint8');
  cfg.beam_angle     =fread(fd,1,'uint8');
  cfg.beam_freq      =fread(fd,1,'uint16');
  cfg.range_switch   =fread(fd,1,'uint8');         %
  cfg.coord_sys      =fread(fd,1,'uint8');         % 0=beam,1=earth
  cfg.orientation    =fread(fd,1,'uint8');        % 0=up,1=down
  cfg.beam_pattern   =fread(fd,1,'uint8');        % 0=convex,1=concave
  cfg.n_cells        =fread(fd,1,'uint8');
  cfg.time_between_ping_groups=fread(fd,1,'uint32')*.01; % seconds
  cfg.pings_per_ensemble=fread(fd,1,'uint16');
  cfg.cell_size      =fread(fd,1,'uint8');	% meters
  cfg.xmit_pulse     =fread(fd,1,'uint16');	% transmit pulse length (meters)
  cfg.blank          =fread(fd,1,'uint16');	% meters
  cfg.adcp_depth     =fread(fd,1,'uint32')*.01;	% meters
  cfg.avg_method     =fread(fd,1,'uint8');         % 0=time,1=space
  cfg.avg_interval   =fread(fd,1,'uint32')*.01;	% seconds or meters
  cfg.magnetic_var   =fread(fd,1,'int32')*.001;	% degrees
  cfg.compass_offset =fread(fd,1,'int32')*.001;   % degrees
  cfg.xducer_misalign=fread(fd,1,'int32')*.001;   % degrees
  cfg.intens_scale   =fread(fd,1,'uint16')*.001;   % db/count
  cfg.absorption     =fread(fd,1,'uint16')*.001;   % db/m
  cfg.salinity       =fread(fd,1,'uint16')*.001;   % ppt
  cfg.ssp            =fread(fd,1,'uint32')*.001;   % m/s
  cfg.ssp_use        =fread(fd,1,'uint8');         % 0=use T,S,1=fixed
  cfg.use_pitchroll  =fread(fd,1,'uint8');         % 0=yes,1=no
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
  %%fprintf('Header: excess bytes %d\n',hdr.nbyte-(95+nchar+s1));

  fseek(fd,hdr.nbyte-(95+nchar+s1),'cof');  % get to end of segment
                                               % (should be 94 not 95 - not sure why the diff).
end;


%-----------------------------
function [ens,hdr]=read_ensemble(fd,num_av,cfg);

% To save it being re-initialized every time.
global ens


% If num_av<0 we are reading only 1 element and initializing
if num_av<0,
 n=abs(num_av);
 pos=ftell(fd)
 hdr=read_hdr(fd,cfg.adcp_type,cfg.n_cells)
 if isempty(hdr)
   hdr=[];
   ens=[];
   return;
 end;
 if 0
 if length(hdr.dat_offsets)>=6
   if hdr.dat_offsets(6)==779
     hdr.dat_offsets(6)=hdr.dat_offset-2;
   end;
 end;
end;
 hdr.dat_offsets
 
 if isempty(hdr)
     return;
 end;
 
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

if cfg.adcp_type==0,
  bad_val=32767;
else
  bad_val=-32768;
end;
bad_vald1000=bad_val*0.001;;

k=0;
while k<num_av,
  startpos = ftell(fd);
  hdr=read_hdr(fd,cfg.adcp_type,cfg.n_cells);
  if isempty(hdr)
      return;
  end;
  k=k+1;

  for n=1:length(hdr.dat_offsets),
    pos = ftell(fd);
    id=fread(fd,1,'uint16');
    dec2hex(id,4);
%     fprintf('ID: %s\n',dec2hex(id,4));
    switch dec2hex(id,4),

    case '000B',   % Leader
      if cfg.adcp_type==1, % BB format
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
      
    case '0001',  % Velocities

      [vels,nread]=fread(fd,[4 hdr.n_deps],'int16');
      if nread<4*hdr.n_deps
	% we prematurely reached the end of file.  Hmmm...
	warning('premature EOF in the velocity block');

         if n<length(hdr.dat_offsets),
        skp=hdr.dat_offsets(n+1)-hdr.dat_offsets(n);
      else
	% JMK fixed to skip right...
        skp=hdr.nbyte-hdr.dat_offsets(n)+2+length(hdr.dat_offsets)*2;
      end;
%      fprintf(' - Skipping forward %d bytes\n',skp);
      fseek(fd,skp,'cof');

      else      
	vels=vels'*.001;     % m/s
	ens.east_vel(:,k) =vels(:,1);
	ens.north_vel(:,k)=vels(:,2);
	ens.vert_vel(:,k) =vels(:,3);
	ens.error_vel(:,k)=vels(:,4);
      end;
     case '0003',  % Echo Intensities
      [dat,nread]=fread(fd,[4 hdr.n_deps],'uint8');
      if nread<4*hdr.n_deps
	% we prematurely reached the end of file.  Hmmm...
	warning('premature EOF in the intensities block');
	if n<length(hdr.dat_offsets),
	  skp=hdr.dat_offsets(n+1)-hdr.dat_offsets(n);
	else
	  % JMK fixed to skip right...
	  skp=hdr.nbyte-hdr.dat_offsets(n)+2+length(hdr.dat_offsets)*2;
	end;
	%      fprintf(' - Skipping forward %d bytes\n',skp);
	fseek(fd,skp,'cof');
      else
	ens.intens(:,:,k)   =dat';
      end;
      

    case '0104',  % Percent good

      ens.percent(:,k)   =fread(fd,[hdr.n_deps],'uint8')';

    case '000C'   % Discharge
      if cfg.adcp_type==0,
          % keyboard
%%        fseek(fd,4*hdr.n_deps-2,'cof'); % Lord knows why they have 2 bytes less than 
%%                                        % should, but they do... 
        if cfg.prog_ver(3)<=147
          fseek(fd,4*hdr.n_deps-2,'cof'); % Changed on Tully 28/june/00
        else
          fseek(fd,4*hdr.n_deps,'cof'); % Changed on Tully 28/june/00
        end;
        
      else                             
        fseek(fd,4*hdr.n_deps,'cof');
      end;
    
    case '000E'  % Ntuavigation

      ens.nav_east_vel(k)  =fread(fd,1,'int16')*.001;   % m/s
      ens.nav_north_vel(k) =fread(fd,1,'int16')*.001;   % m/s
      ens.nav_x_disp(k)    =fread(fd,1,'int32')*.01;   % m
      ens.nav_y_disp(k)    =fread(fd,1,'int32')*.01;   % m
      ens.nav_path_len(k)  =fread(fd,1,'uint32')*.01;  % m
      ens.latitude(k)      =fread(fd,1,'int32')*.001/3600; % Degrees Lat
      ens.longitude(k)     =fread(fd,1,'int32')*.001/3600; % Degrees Long
      ens.filterwidth(k)   =fread(fd,1,'uint16');

     case '000A',   % They sometimes stick the config file in the
                    % middle as well
       pos=ftell(fd);
       fprintf('pos %d',pos);
       read_cfg(hdr,fd);
       
     otherwise,
      fprintf('BAD ID: %s\n',dec2hex(id,4));
%      fseek(fd,-20,'cof');
      return;
%      for i=1:100
%         hdrid=fread(fd,1,'uint16');  % Head ID
%         fprintf('%03d: DATA: %s\n',i*2-20,dec2hex(hdrid,4));
	 
%      end;      
      %fprintf('Unrecognized ID code at: %sh',dec2hex(id,4));
      
      if n<length(hdr.dat_offsets),
        skp=hdr.dat_offsets(n+1)-hdr.dat_offsets(n);
      else
	% JMK fixed to skip right...
        skp=hdr.nbyte-hdr.dat_offsets(n)+2+length(hdr.dat_offsets)*2;
      end;
      pos = ftell(fd);
 %     keyboard;
%      fprintf('pos %d - Skipping forward %d bytes\n',pos,skp);
      fseek(fd,skp,'cof');
      pos = ftell(fd);
    end;
  end;
  % check that we haven't overun the data stream by accident...
  endpos = ftell(fd);
  skp = -(endpos-startpos-hdr.nbyte)+15;   % this needs changing depending on the
  % Transect you are using.
  if 0
  if skp~=0
    fprintf('\nWarning: Ran past end of block - skipping %d %d\n',skp,endpos);
    fseek(fd,skp,'cof');
    return;
    keyboard
  end;
end;
  checksums =dec2hex(fread(fd,1,'uint16'),4);% Skip checksum
 %keyboard;
end;

if cfg.adcp_type==1,
  big_err=abs(ens.bt_error_vel)>abs(bad_vald1000);
else
  big_err=zeros(size(ens.bt_error_vel));
end;

ens.bt_east_vel( ens.bt_east_vel== bad_vald1000 | big_err)=NaN;
ens.bt_north_vel(ens.bt_north_vel==bad_vald1000 | big_err)=NaN;
ens.bt_vert_vel( ens.bt_vert_vel== bad_vald1000 | big_err)=NaN;
ens.bt_error_vel(ens.bt_error_vel==bad_vald1000 | big_err)=NaN;

if cfg.adcp_type==1,
  ens.bt_range(:,isnan(ens.bt_error_vel))=NaN;
end;


big_err=abs(ens.error_vel)>.2;
	
ens.east_vel( ens.east_vel== bad_vald1000 | big_err)=NaN;
ens.north_vel(ens.north_vel==bad_vald1000 | big_err)=NaN;
ens.vert_vel( ens.vert_vel== bad_vald1000 | big_err)=NaN;
ens.error_vel(ens.error_vel==bad_vald1000 | big_err)=NaN;

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
   kk=sum(finite(x),1);
   if kk>0,
     x1=x(max(fix(kk/2),1));
     x2=x(max(ceil(kk/2),1));
     x(abs(x-(x1+x2)/2)>window)=NaN;
   end;
   x = sort(x,1);
   kk=sum(finite(x),1);
   x(isnan(x))=0;
   y=NaN;
   if kk>0,
    y=sum(x)/kk;
   end;
  else
   kk=sum(finite(x),1);
   ll=kk<n1-2;
   kk(ll)=0;x(:,ll)=NaN;
   x1=x(max(fix(kk/2),1)+[0:n2-1]*n1);
   x2=x(max(ceil(kk/2),1)+[0:n2-1]*n1);

   x(abs(x-ones(n1,1)*(x1+x2)/2)>window)=NaN;
   x = sort(x,1);
   kk=sum(finite(x),1);
   x(isnan(x))=0;
   y=NaN+ones(1,n2);
   if any(kk),
    y(kk>0)=sum(x(:,kk>0))./kk(kk>0);
   end;
  end;
end; 

if 0,
  ll=find(kk==0);
  if any(ll), y(ll)=NaN; end;

  ll=find(kk==1);
  if any(ll), y(ll)=x(1+[ll-1]*n1); end;

  ll=find(kk==2);
  if any(ll), y(ll)=(x( 2+[ll-1]*n1) + x(1+[ll-1]*n1))/2; end;

  ll=find(kk==3);
  if any(ll), y(ll)=x(2+[ll-1]*n1); end;

  for n=4:max(kk),
   ll=find(kk==n);
   if any(ll),
     y(ll)=sum(reshape(x([2:n-1]'*ones(1,length(ll)) + ones(n-2,1)*[ll-1]*n1),n-2,length(ll)))/(n-2);
   end;
  end;
end;

%y(ll)=(x( fix(kk(ll)/2)+[ll-1]*n1) + x( ceil(kk(ll)/2)+[ll-1]*n1))/2;
%y(ll)=x(1,ll);

% Permute and reshape back
siz(dim) = 1;
y = ipermute(reshape(y,siz(perm)),perm);

%--------------------------------------
function y=nmean(x,dim);

kk=finite(x);
x(~kk)=0;

if nargin==1, 
  % Determine which dimension SUM will use
  dim = min(find(size(x)~=1));
  if isempty(dim), dim = 1; end
end;

y = sum(x,dim)./sum(kk,dim);




























