function adp=read_adp(filename,pnum,doplot);
% function ADP=READ_ADP(FILENAME,PNUM) reads a Sontek ADP file 
% and output the result into the
% structured variable ADP
% pnum is the filenumber for the profile-timing system.  
    
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
  fid=fopen(filename,'r');

  % Now we have some definitions:
	coords={'beam','xyz','ENU'};
    orientation={'down','up','side'};	
	
  adp.filename=filename;	
	
  % read in the sensor configuration.
  [F,ct]=fread(fid,96,'char');
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
  
  % read in the operation configuration.
  [F,ct]=fread(fid,64,'char');
  adp.operation_config=uint8(F');

  % read in the setup parameters.
  [F,ct]=fread(fid,256,'char');
  adp.setup_parameters=uint8(F');
  adp.profile.ncells = touint(F,19);  
  adp.profile.cellsize = touint(F,21);  
  adp.profile.blankdist = touint(F,23);  
  bottom_track_enabled=F(246);	

  % determine the number of cells
  ncells=touint(F,19);

  % detemine the number of bytes of each profile 
  profile_length=80+4*ncells*nbeams+2+18*bottom_track_enabled;
  
  % determine the offset location where the velocity data comes in
  os=80+18*bottom_track_enabled;
  
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
  [F,ct]=fread(fid,profile_length,'char');
  if ct<profile_length
    adp=[];
    warning([filename ' is not a valid ADP file']);
    return;
  end;
  n=1; % first profile number
  dt=0;
  while ct==profile_length
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
	if bottom_track_enabled
	  adp.profile.btm_good_pings(n)=toint(F,81);
	  adp.profile.btm_range(1:3,n)=touint(F,81+[2:2:6])/100;
	  adp.profile.btm_vel(1:3,n)=toint(F,81+[10:2:14])/1000;
	end
	adp.profile.vel1(1:ncells,n) = toint(F,os+[1:2:(ncells*2)])/1000;
	adp.profile.vel2(1:ncells,n) = toint(F,os+ncells*2+[1:2:(ncells*2)])/1000;
	adp.profile.vel3(1:ncells,n) = toint(F,os+ncells*4+[1:2:(ncells*2)])/1000;
	adp.profile.velstd1(1:ncells,n) =F(os+ncells*6+[1:ncells])/1000; 
	adp.profile.velstd2(1:ncells,n) =F(os+ncells*7+[1:ncells])/1000; 
	adp.profile.velstd3(1:ncells,n) =F(os+ncells*8+[1:ncells])/1000; 
	adp.profile.amp1(1:ncells,n) =F(os+ncells*9+[1:ncells]); 
	adp.profile.amp2(1:ncells,n) =F(os+ncells*10+[1:ncells]); 
	adp.profile.amp3(1:ncells,n) =F(os+ncells*11+[1:ncells]); 

	% read in the next profile 	
	[F,ct]=fread(fid,profile_length,'char');
	% advance the profile number
	n=n+1;
  end

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

  % OK, there is a crappy failure mode whereby the first few
  % time entries are crappy, and presumably the data too.

  bad = find(adp.profile.time(1:end-1)>adp.profile.time(end));
  if ~isempty(bad)
    fprintf(1,'Bad timestamp in %s, removinging %d profiles\n',filename,...
	    length(bad));
    adp.profile=trimbad(adp.profile,bad);
  end;

  % there is another failure mode where the first (and maybe more)
  % entries are old, screwing up the ptime calculation...
  medtime = median(adp.profile.time);
  bad = find(adp.profile.time<medtime-1.2*NOMRECLEN/(3600*24));
  adp.profile=trimbad(adp.profile,bad);
  
  % this logic removes repeated data.  This occurs if the ADP is
  % turned on to ping less than once every five seconds.  The
  % result will be the same data repeated a number of times.  The
  % difficulty is that the file write may start in the middle of
  % the repeated pings, screwing up the p-time.
  % the procedure is this - ptime = 0 is assumed to be the first
  % ping since that is when the corresponding Marlin file was
  % written (this actually has about a 7.5 second ambiguity).  This
  % first ping may actually contain data that is older than when
  % the Marlin file was written, so we only need to figure out when
  % that likely was....   I need 2 pieces of info 1) how many saves
  % there are between real pings and 2) how many saves there are at
  % the beginning of the file
  bad = find(diff(adp.profile.time)<=0)+1;
  % tells me repeated data
  timeoff = 0;
  if ~isempty(bad)
    % if there is repeated data....
    % find non-repeated data...
    good = [find(diff(adp.profile.time)>0)]+1;
    if length(good)>1
      % figure out the nominal time between pings....
      dt = median(diff(adp.profile.time(good)));
      % figure out how many repeated pings there usually are 
      nsavesperping = median(diff(good));
      % figure out how many repeated pings there are at the beginning
      nsavesbegin = good(1)-1;
      if nsavesbegin>=nsavesperping
	nsavesbegin=nsavesperping;
      else;
	% calculate the time offset.  Note that we need the mod since
	% it is possible that the first save actually corresponds with
	% the first ping.   
	timeoff = -mod(nsavesbegin,nsavesperping)*dt/nsavesperping;
      end;
    end;
    fprintf(1,'Bad timestamp in %s, removinging %d profiles\n',filename,...
	    length(bad));
    % removes repeated pings....
    adp.profile=trimbad(adp.profile,bad);
    bad = find(diff(adp.profile.time)<=0);
  end;
  adp.profile.ptime = ...
      (adp.profile.time-adp.profile.time(1)+timeoff)*3600*24/ ...
      NOMRECLEN+pnum;

  
  
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
  disp('Resu7lt has been output to GLOBAL STRUCT adp');
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
  
