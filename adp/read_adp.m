function adp=read_adp(filename,pnum,doplot);
% function ADP=READ_ADP(FILENAME,PNUM) reads a Sontek ADP file 
% and output the result into the
% structured variable ADP
% pnum is the filenumber for the profile-timing system.  
    
% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:41 $ $Author: aperlin $	
% written by J.Nash Aug 23, 1999

  
  NOMRECLEN = 320; % the nominal file record length in seconds.
                   % Needed for ptime calc.
	
% first a bit of error checking...
  adp=[];
  if ~nargin	
	[filen,pathn]=uigetfile('*.adp',['Select an ADP file for' ...
					' processing']);
	filename=[pathn filen];
  end
  if nargin<2
    pnum=[];
  end;
  if ~nargout
	global adp
  end
  
  if ~strncmpi(fliplr(filename),'pda.',4)
	filename=[filename '.adp'];
  end
  
  if ~exist(filename)
	warning(['file ' filename ' not found']);
	return
  end

  if isempty(pnum)
    pnum=0;
  end;
  
  % open the file
  fid=fopen(filename,'rb','ieee-le');

  
  % Now we have some definitions:
  coords={'beam','xyz','ENU'};
  orientation={'down','up','side'};	
	
  adp.filename=filename;	
	
  % read in the sensor configuration.
  [F,ct]=fread(fid,96,'uchar');
  if ct<70
    adp=[];
    warning([filename ' is not a valid ADP file']);
    return;
  end;
  
  adp.sensor_config=uint8(F');

  % determine the number of beams:
  nbeams=F(27);

  % pressure calibrations:
  p_ord2=touint(F,83)*1e-12;
  p_lin=tolong(F,71)*1e-8;
  p_off=tolong(F,75)*1e-5;
  % get if CTD is attached?
  ctd_enabled = F(80);
  
  % read in the operation configuration.
  [F,ct]=fread(fid,64,'uchar');
  adp.operation_config=uint8(F');

  % read in the setup parameters.
  [F,ct]=fread(fid,256,'uchar');
  adp.setup_parameters=uint8(F');
  adp.profile.ncells = touint(F,19);  
  adp.profile.cellsize = touint(F,21);  
  adp.profile.blankdist = touint(F,23);  
  bottom_track_enabled=F(246);	

  
  % determine the number of cells
  ncells=touint(F,19);

  % somehow we must be able to tell if gps data is in the old or
  % new format.  Old is 40 bytes, new is 48.   For now, assume it
  % is 48...
  fpos = ftell(fid);
  
  [F,ct]=fread(fid,2,'uchar');
  % go back to where we were...
  fseek(fid,fpos,'bof');
  % check F
  if F(2)==16
    gps_len=0;
    gps_enabled = 0;
  elseif F(2)==17
    gps_len=40;
    gps_enabled=1;
  else
    gps_len=48;
    gps_enabled=2;
  end;
  
  % detemine the number of bytes of each profile 
  profile_length=80+4*ncells*nbeams+2+18*bottom_track_enabled + ...
      gps_len + 16*ctd_enabled;
  
  
  % Give a units string:
  adp.profile.units.velocities='m/s';
  adp.profile.units.distances='m';
  adp.profile.units.temperature='deg C';
  adp.profile.units.pressure='dbar';
  adp.profile.units.attitude='deg';
  adp.profile.units.voltage='volts';
  adp.profile.units.amplitude='counts';
  adp.profile.units.snr='db';
 
 
  
  % now extract each of the profiles
  [F,ct]=fread(fid,profile_length,'uchar');

  if ct<profile_length
    adp=[];
    warning([filename ' is not a valid ADP file']);
    return;
  end;
  n=1; % first profile number
  dt=0;
  while ct==profile_length
    if floor(n/10)==n/10
      fprintf(1,'.');
    end;
    
	adp.profile.number(n)=((F(18)*256+F(17))*256+F(16))*256+F(15);
	adp.profile.time(n)=datenum(256*F(20)+F(19),F(22),F(21), ...
				F(24),F(23),F(26));
	dt = (adp.profile.time(n)-adp.profile.time(1))*(24* ...
							    3600);
	adp.profile.year(n) = 256*F(20)+F(19);
	if isfield(adp.profile,'Nbeams');
	  oldNbeams = adp.profile.Nbeams;
	else 
	  oldNbeams=1e6;
	end;
	adp.profile.Nbeams=F(27);
	if (oldNbeams<1e6) & (oldNbeams ~= adp.profile.Nbeams)
	  adp.profile.Nbeams = oldNbeams;
	  warning([filename ' only has ' int2str(n-1) ' good profiles']);
	  adp.profile.year=adp.profile.year(1:n-1);
	  adp.profile.number=adp.profile.number(1:n-1);
	  adp.profile.time=adp.profile.time(1:n-1);
	  break
	end;
	% we need to check here before trying the nexty stuff...
	if (F(28)+1 <4 & F(28)+1 >0)
	  adp.profile.orientation=cellstr(char(orientation(F(28)+1)));
	else        
	  warning([filename ' only has ' int2str(n-1) ' good profiles']);
	  adp.profile.year=adp.profile.year(1:n-1);
	  adp.profile.number=adp.profile.number(1:n-1);
	  adp.profile.time=adp.profile.time(1:n-1);
	  break
	end;      
	adp.profile.tempmode=F(29);
	adp.profile.coord=cellstr(char(coords(F(30)+1)));
	adp.profile.ncells=touint(F,31);
	adp.profile.cellsize=touint(F,33)/100;
	adp.profile.blankdist=touint(F,35)/100;
	adp.profile.avginterval=touint(F,37);
	adp.profile.npings(n)=touint(F,39);	
	adp.profile.meanheading(n)=toint(F,41)/10;
	adp.profile.meanpitch(n)=toint(F,43)/10;
	adp.profile.meanroll(n)=toint(F,45)/10;
	adp.profile.meantemp(n)=toint(F,47)/100;
	pval=touint(F,49);
	adp.profile.meanpres(n)=p_off+p_lin*pval+p_ord2*pval^2;
	% to convert counts to dbar 
	adp.profile.stdheading(n)= F(51)/10;
	adp.profile.stdpitch(n)= F(52)/10;
	adp.profile.stdroll(n)= F(53)/10;
	adp.profile.stdtemp(n)= F(54)/10;
	adp.profile.stdpress(n)= touint(F,55)*p_lin; % to convert counts
                                                 % to dbar 
	adp.profile.soundspeed(n)= touint(F,57)/10;
	adp.profile.voltage(n)= F(76)*.2;
	F(69:71);
	adp.profile.noise(1:3)=F(69:71);
	%	adp.profile.  (n)=touint(F,);
	
	pos = 80;
	if bottom_track_enabled
	  adp.profile.btm_good_pings(n)=toint(F,pos);
	  adp.profile.btm_range(1:3,n)=touint(F,pos+[2:2:6])/100;
	  adp.profile.btm_vel(1:3,n)=toint(F,pos+[10:2:14])/1000;
	  pos = pos+18;
	end
	if ctd_enabled;
	  adp.profile.Temperature = tolong(F,pos);
	  adp.profile.Conductivity = tolong(F,pos+4);
	  adp.profile.Pressure = tolong(F,pos+8);
	  adp.profile.Salinity = tolong(F,pos+12);
	  pos = pos+16;
	end;	
	if (gps_enabled==2)
	  % new, all doubles, version of the GPS data...
	  pos = pos+gps_len;
	  % if the gps is enabled, then we need to get doubles.  I
          % don't know an easy way to do this with byte shifting
          % etc, so I must reread.
	  fpos = ftell(fid);
	  fseek(fid,fpos-profile_length+80+ctd_enabled*16+18* ...
		bottom_track_enabled,'bof');
	  Fdouble = fread(fid,(gps_len)/8,'double');
	  fseek(fid,fpos,'bof');
	  adp.profile.StartUTC(n) = Fdouble(end-5);
	  adp.profile.StartLat(n) = Fdouble(end-4);
	  adp.profile.StartLon(n) = Fdouble(end-3);
	  adp.profile.EndUTC(n) = Fdouble(end-2);
	  adp.profile.EndLat(n) = Fdouble(end-1);
	  adp.profile.EndLon(n) = Fdouble(end);
	elseif (gps_enabled==1)
	  warning('OLD STYLE GPS NOT IMPLEMENTED');
	  % This format not supported
	  pos = pos+gps_len;
	end;
	os = pos;
	adp.profile.vel1(1:ncells,n) = toint(F,os+[1:2:(ncells*2)])/1000;
	adp.profile.vel2(1:ncells,n) = toint(F,os+ncells*2+[1:2: ...
		    (ncells*2)])/1000;
	adp.profile.vel3(1:ncells,n) = toint(F,os+ncells*4+[1:2: ...
		    (ncells*2)])/1000;
	adp.profile.velstd1(1:ncells,n) =F(os+ncells*6+[1:ncells])/1000; 
	adp.profile.velstd2(1:ncells,n) =F(os+ncells*7+[1:ncells])/1000; 
	adp.profile.velstd3(1:ncells,n) =F(os+ncells*8+[1:ncells])/1000; 
	adp.profile.amp1(1:ncells,n) =F(os+ncells*9+[1:ncells]); 
	adp.profile.amp2(1:ncells,n) =F(os+ncells*10+[1:ncells]); 
	adp.profile.amp3(1:ncells,n) =F(os+ncells*11+[1:ncells]); 

	% read in the next profile
	[F,ct]=fread(fid,profile_length,'uchar');
	% advance the profile number
	n=n+1;
  end
fprintf(1,'\n');

  adp.profile.binpos = (adp.profile.blankdist + ...
      (0.5:1:adp.profile.ncells)*adp.profile.cellsize)';
  if strcmp(adp.profile.orientation,'up');
    adp.profile.binpos = adp.profile.binpos*-1;
  end;
  

  % Calculate the signal to noise ratio:
  adp.profile.snr1=0.43*(adp.profile.amp1-adp.profile.noise(1));
  adp.profile.snr1(find(adp.profile.snr1<0))=0;
  adp.profile.snr2=0.43*(adp.profile.amp2-adp.profile.noise(2));
  adp.profile.snr2(find(adp.profile.snr2<0))=0;
  adp.profile.snr3=0.43*(adp.profile.amp3-adp.profile.noise(3));
  adp.profile.snr3(find(adp.profile.snr3<0))=0;

  % get ptime 
  NOMRECLEN=NOMRECLEN/24/3600;
  adp.profile.ptime = pnum+1+(adp.profile.time-median(adp.profile.time)-NOMRECLEN/2)/ ...
      NOMRECLEN;
 
  
  
  % it happens that the adp file is almost empty.  Set to empty if
  % this is the case for error checking
  [m,n]=size(adp.profile.vel1);
  if m*n<=0
    adp=[];
    return;
  end;
  
    
  doplot=0;
  if doplot
    plot(diff(adp.profile.time));
    ppause;
  end;
  
  disp(['Extracted ' num2str(length(adp.profile.time)) ' profiles from ' filename])

  if ~nargout
    disp('Result has been output to GLOBAL STRUCT adp');
  end

  fclose(fid);


function a=touint(F,n);
  a=F(n)+F(n+1)*256;
  return

function a=toint(F,n);
  a=F(n)+F(n+1)*256 - (F(n+1)>127)*65536;
return

function a=tolong(F,n);
  a=F(n)+256*F(n+1)+ 256^2*F(n+2) + 256^3*F(n+3) - (F(n+3)>127)*256^4;
return

function a=toulong(F,n);
  a=F(n)+256*F(n+1)+ 256^2*F(n+2) + 256^3*F(n+3);
return

function adp=trimbad(adp,bad);
  % trims all the bad data
  len = size(adp.time,2);
  good = setdiff([1:len],bad);
  varnames = fieldnames(adp);
  for i=1:length(varnames)
    var = getfield(adp,varnames{i});
    if size(var,2)==len
      % trim
      var = var(:,good);
      adp=setfield(adp,varnames{i},var);
    end;
  end;
return;
  
