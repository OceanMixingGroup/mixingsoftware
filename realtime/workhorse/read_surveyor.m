function [adcp]=read_workhorse(name,nskip);
% function [adcp]=read_workhorse(name);
% Reads workhorse ADCP data.
% 
% name is the file name, adcp is a Matlab structure with all the data
% decoded in it.  Data is not converted to scientific units, though
% data flagged by RDI as "bad" is converted to NaNs.
% 
% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:51 $ $Author: aperlin $	
% Originally: J.Klymak May 2002
%
% No Warranty.   Please report bugs to mailto:jklymak@coas.oregonstate.edu
  
if nargin<2
  nskip=0;
end;
  
% load the file;  little endian.  
fin = fopen(name,'r','ieee-le')
if fin<1
  fprintf('Could not open %s\n',name);
  adcp=[];
  return;
end

dat = fread(fin,[1024 Inf],'uchar');
if isempty(dat);
  % this is an empty file...
  adcp = [];
  return;
end;


fseek(fin,0,'eof');
filelen = ftell(fin);
fseek(fin,0,'bof');
done = 0;
pos=0;
adcp=[];
num = 0;
nbytes=0;

[offsets,nbytes,pos]=read_header(fin,dat,nbytes);
nbytes=nbytes+2;
fprintf(1,'Skipping %02d bytes\n',nskip*nbytes);
if nskip*nbytes<filelen-nbytes+1
  fseek(fin,nskip*nbytes,'bof')
else
  fprintf(1,'At end fo file\n',nskip*nbytes);
  fseek(fin,0,'eof')
end;
pos=ftell(fin)

while pos<filelen-nbytes+1
  [offsets,nbytes,pos]=read_header(fin,dat,nbytes);
  nbytes=nbytes+2;
  if isnan(nbytes)
    fclose(fin);
    return;
  else
    profile=[];
    % these two are always in each ensemble...
    profile.cfg=read_leader(fin);
    if isempty(profile.cfg)
      fclose(fin)
      return;
    end;
    
    profile=read_varleader(fin,profile);
    if isempty(profile)
      fclose(fin);
      return;
    end;
    
    % read the rest...
    for i=1:length(offsets)-2
      fseek(fin,pos+offsets(i+2),'bof');
      id = fread(fin,1,'uint16');
      %fprintf(1,'%04x\n',id)
      switch id;
       case hex2dec('0100')
	profile=read_velocity(fin,profile,profile.cfg.ncells);
	% ftell(fin);
	num = num+1;
	if (floor(num/10) == num/10)
	  fprintf(1,'.');
	end;
       case hex2dec('0200');
	profile=read_correlation(fin,profile,profile.cfg.ncells);
       case hex2dec('0300');
	profile=read_echo(fin,profile,profile.cfg.ncells);
       case hex2dec('0400');
	profile=read_percentgood(fin,profile,profile.cfg.ncells);
       case hex2dec('0600');
	profile=read_bottomtrack(fin,profile);
case hex2dec('2000');
          profile=read_navigation(fin,profile);
      end;
    end;
    
    fseek(fin,pos+nbytes-2,'bof');
    chksum = fread(fin,1,'uint16');
  end;
  adcp=filladcp(adcp,profile);
  pos = ftell(fin);
end; % while ~done
fprintf(1,'\n');
pos = ftell(fin)
fclose(fin);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function adcp=filladcp(adcp,profile);  
  if isempty(adcp);
    adcp=profile;
  else
    cfg1 = adcp.cfg;
    cfg2= profile.cfg;
    nav1 = adcp.nav;
    nav2 = profile.nav;
    fnames = fieldnames(adcp);
    ffnames = fieldnames(profile);
    if length(ffnames)==length(fnames)
      adcp = mergefields(adcp,profile);
      adcp.cfg = mergefields(cfg1,cfg2);
      adcp.nav = mergefields(nav1,nav2);
    else
      % do not include this incomplete profile...
    end;
    
  end;
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function profile=read_navigation(fin,profile);
  nav = [];
  nav_form = {'day','uchar';
    'month','uchar';
    'year','uint16';
    'firstfix','uint32';
    'pcclock','int32';
    'first_lat','uint32';  % these are in BAM format.  Ick
    'first_lon','uint32';
    'lastfix','uint32';
    'last_lat','uint32';  % these are in BAM format.  Ick
    'last_lon','uint32';
    'avg_speed','int16';
    'avg_headtrue','uint16';
    'avg_headmag','uint16';
    'speedmadegood','int16';
    'directionmadegood','uint16';
    'spare1','uint16';
    'flags','uint16';
    'spare1','uint16';
    'ensemblenum','uint32';
    'adcpyear','uint16';
    'adcpday','uchar';
    'adcpmonth','uchar';
    'adcptime','uint32';
    'pitch','int16';
    'roll','int16';
    'heading','int16';
    'nsamps','uint16';
    'ntracksamps','uint16';
    'nmagtracksamps','uint16';
    'nheadingsamps','uint16';
    'npitchrollsamps','uint16';
  };
for i=1:size(nav_form,1)
  dat = fread(fin,1,nav_form{i,2});
  nav=setfield(nav,nav_form{i,1},dat);
end;
profile.nav = nav;
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [offsets,nbytes,pos]=read_header(fin,alldat,ensembleLen);
  
headid = {'7f','7f'};  
% find the first instance of header id...
[a,n] = fread(fin,2,'uchar');
n=1;
if (a(1)~=hex2dec(headid{1}) | a(2)~=hex2dec(headid{2}))
  pos = ftell(fin);
  
  
  % there are two cases here.  If ensembleLen==0, i.e. at begining of the
  % file, then this is hard, otherwise, easy:
  if ensembleLen>0
    in = find(alldat(1:end-ensembleLen-1)==127 & ...
      alldat(2:end-ensembleLen)==127 & alldat((ensembleLen+1):end-1)==127 & alldat((ensembleLen+2):end)==127);
    good = find(in>pos);
    
    if ~isempty(good)
      in = in(good(1));
      fprintf('Warning: Could not find header in expected place: %d\nStarting again at %d %d.\n',...
        ftell(fin)-2,in,in-ftell(fin)+2);
      
    else
      fprintf('Warning: Could not find header in expected place: %d\nNo other headers found\n',...
        ftell(fin)-2);
      offsets = [];
      nbytes = NaN;
      pos = NaN;
      return;
    end;
    pos = fseek(fin,in-1,'bof');
    [a,n] = fread(fin,2,'uchar');
  else % ensemble length ==0
    % we are at the beginning of the file or thereabouts....
    in = find(alldat(1:end-1)==127 &  alldat(2:end)==127);
    for i=1:(length(in)-2);
      i
      i1 = find(alldat(in(i):in(i+1))==0 & alldat([in(i):in(i+1)]+1)==128);
      i2 = find(alldat(in(i+1):in(i+2))==0 & alldat([in(i+1):in(i+2)]+1)==128);
      if ~isempty(i1) & ~isempty(i2) &((i2(1)-i1(1))==(in(i+1)-in(i)))
        pos = fseek(fin,in(i)-1,'bof');
        [a,n] = fread(fin,2,'uchar');
        break
      end;
    end;
    fprintf('Warning: Could not find header in expected place: %d\nStarting again at %d %d.\n',...
        ftell(fin)-2,in,in-ftell(fin)+2);
    
  end;
end;
pos = ftell(fin)-2;
nbytes = fread(fin,1,'uint16');
[a,n] = fread(fin,1,'uchar');
[ntypes,n] = fread(fin,1,'uchar');

for i=1:ntypes
  offsets(i) = fread(fin,1,'uint16');
end;
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cfg=read_leader(fin);

id = fread(fin,1,'uint16');
if ~id==0
  warning('Could not find the fixed leader data');
  cfg=[];
  return;
end;
leader_form={'cpu_ver',  'uchar';
	     'cpu_rev',  'uchar';
	     'sysconfig',  'uint16';
	     'spare1', 'uchar';
	     'spare1',   'uchar';
	     'nbeams',   'uchar';
	     'ncells',   'uchar';
	     'npings',   'int16';
	     'cellsize',   'uint16';
	     'blankaftertransmit',   'uint16';
	     'profilemode', 'uchar';
	     'spare1', 'uchar';
	     'nocodereps', 'uchar';
	     'percgoodmin', 'uchar';
	     'errorvelmax', 'uint16';
	     'tppminutes', 'uchar';
	     'tppseconds', 'uchar';
	     'tpphunddredths', 'uchar';
	     'coordtransform', 'uchar';
	     'headalignment', 'uint16';
	     'headbias', 'uint16';
	     'sensorsource', 'uchar';
	     'sensoravail', 'uchar';
	     'bin1dist', 'uint16';
	     'xmitpulselen', 'uint16';
	     'reflayerav', 'uint16';
	     'falsetargetthresh', 'uchar';
	     'spare2', 'uchar';
	     'transmitlagdist', 'uint16';
       'spare1','uchar';
       'spare1','uchar';
       'spare1','uchar';
       'spare1','uchar';
       'spare1','uchar';
       'spare1','uchar';
       'spare1','uchar';
       'spare1','uchar';
     };
cfg=[];
for i=1:size(leader_form,1)
  dat = fread(fin,1,leader_form{i,2});
  cfg=setfield(cfg,leader_form{i,1},dat);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function head=read_varleader(fin,head);

id = fread(fin,1,'uint16');
if id~=hex2dec('0080');
  warning('Could not find the variable leader data');
  head=[];
  return;
end;
leader_form={'ensemble',  'uint16';
	     'year',      'uchar';
	     'month',      'uchar';
	     'day',      'uchar';
	     'hour',      'uchar';
	     'minutes',      'uchar';
	     'second',      'uchar';
	     'hundredths',      'uchar';
	     'ensemble2',      'uchar';
	     'bitresult',      'uint16';
	     'speedofsound',      'uint16';
	     'depthoftransducer',      'uint16';
	     'heading',      'uint16';
	     'pitch',      'int16';
	     'roll',      'int16';
	     'salinity',      'uint16';
	     'temperature',      'uint16';
	     'MPTminutes',      'uchar';
	     'MPTsecond',      'uchar';
	     'MPThundredths',      'uchar';
	     'hdgstddev',      'uchar';
	     'pitchstddev',      'uchar';
	     'rollstddev',      'uchar';
	     'ADC0',      'uchar';
	     'ADC1',      'uchar';
	     'ADC2',      'uchar';
	     'ADC3',      'uchar';
	     'ADC4',      'uchar';
	     'ADC5',      'uchar';
	     'ADC6',      'uchar';
	     'ADC7',      'uchar';
	     'errorstatus',      'uint32';
	     'spare1',      'uint16';
	     'pressure',      'uint32';
	     'pressurevar',      'uint32';
	     'spare2',      'uchar';
	     'RTCcentury',      'uchar';
	     'RTCyear',      'uchar';
	     'RTCmonth',      'uchar';
	     'RTCday',      'uchar';
	     'RTChour',      'uchar';
	     'RTCminutes',      'uchar';
	     'RTCsecond',      'uchar';
	     'RTChundredths',      'uchar';
	     };
for i=1:size(leader_form,1)
  dat = fread(fin,1,leader_form{i,2});
  head=setfield(head,leader_form{i,1},dat);
end;

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function profile=read_velocity(fin,profile,ncells);

  vel = reshape(fread(fin,4*ncells,'int16'),4, ...
			ncells)';
  badflag = -32768;
  in = find(vel==badflag);
  vel(in)=NaN;
  profile.vel1 = vel(:,1);
  profile.vel2 = vel(:,2);
  profile.vel3 = vel(:,3);
  profile.vel4 = vel(:,4);
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function profile=read_correlation(fin,profile,ncells);
  correlation = reshape(fread(fin,4*ncells,'uchar'),4, ...
			ncells)';
  profile.correlation1=correlation(:,1);
  profile.correlation2=correlation(:,2);
  profile.correlation3=correlation(:,3);
  profile.correlation4=correlation(:,4);
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function profile=read_echo(fin,profile,ncells);
  echo = reshape(fread(fin,4*ncells,'uchar'),4, ...
			ncells)';
  profile.echo1=echo(:,1);
  profile.echo2=echo(:,2);
  profile.echo3=echo(:,3);
  profile.echo4=echo(:,4);

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function profile=read_percentgood(fin,profile,ncells);
  percentgood = reshape(fread(fin,4*ncells,'uchar'),4, ...
			ncells)';
  profile.percentgood1=percentgood(:,1);
  profile.percentgood2=percentgood(:,2);
  profile.percentgood3=percentgood(:,3);
  profile.percentgood4=percentgood(:,4);
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function profile=read_bottomtrack(fin,profile);

  profile.bt_pingsperensemble=fread(fin,1,'uint16');
  profile.bt_delaybeforeacquire=fread(fin,1,'uint16');
  profile.bt_corrmin=fread(fin,1,'uchar');
  profile.bt_evalampmin=fread(fin,1,'uchar');
  profile.bt_percgoodmin=fread(fin,1,'uchar');
  profile.bt_mode=fread(fin,1,'uchar');
  profile.bt_errvelmax=fread(fin,1,'uint16');
  junk=fread(fin,1,'uint32');
  
  profile.bt_range1=fread(fin,1,'uint16')';
  profile.bt_range2=fread(fin,1,'uint16')';
  profile.bt_range3=fread(fin,1,'uint16')';
  profile.bt_range4=fread(fin,1,'uint16')';
  profile.bt_vel1=fread(fin,1,'int16')';
  profile.bt_vel2=fread(fin,1,'int16')';
  profile.bt_vel3=fread(fin,1,'int16')';
  profile.bt_vel4=fread(fin,1,'int16')';
  profile.bt_corr1=fread(fin,1,'uchar')';
  profile.bt_corr2=fread(fin,1,'uchar')';
  profile.bt_corr3=fread(fin,1,'uchar')';
  profile.bt_corr4=fread(fin,1,'uchar')';
  profile.bt_evalamp1=fread(fin,1,'uchar')';
  profile.bt_evalamp2=fread(fin,1,'uchar')';
  profile.bt_evalamp3=fread(fin,1,'uchar')';
  profile.bt_evalamp4=fread(fin,1,'uchar')';
  profile.bt_percgood1=fread(fin,1,'uchar')';
  profile.bt_percgood2=fread(fin,1,'uchar')';
  profile.bt_percgood3=fread(fin,1,'uchar')';
  profile.bt_percgood4=fread(fin,1,'uchar')';
  profile.bt_reflayermin=fread(fin,1,'uint16')';
  profile.bt_reflayernear=fread(fin,1,'uint16');
  profile.bt_reflayervel1=fread(fin,1,'uint16')';
  profile.bt_reflayervel2=fread(fin,1,'uint16')';
  profile.bt_reflayervel3=fread(fin,1,'uint16')';
  profile.bt_reflayervel4=fread(fin,1,'uint16')';
  profile.bt_refcorr1=fread(fin,1,'uchar')';
  profile.bt_refcorr2=fread(fin,1,'uchar')';
  profile.bt_refcorr3=fread(fin,1,'uchar')';
  profile.bt_refcorr4=fread(fin,1,'uchar')';
  profile.bt_refint1=fread(fin,1,'uchar')';
  profile.bt_refint2=fread(fin,1,'uchar')';
  profile.bt_refint3=fread(fin,1,'uchar')';
  profile.bt_refint4=fread(fin,1,'uchar')';
  profile.bt_refpercgood1=fread(fin,1,'uchar')';
  profile.bt_refpercgood2=fread(fin,1,'uchar')';
  profile.bt_refpercgood3=fread(fin,1,'uchar')';
  profile.bt_refpercgood4=fread(fin,1,'uchar')';
  profile.bt_maxdepth=fread(fin,1,'uint16')';
  profile.bt_refrssiamp1=fread(fin,1,'uchar')';
  profile.bt_refrssiamp2=fread(fin,1,'uchar')';
  profile.bt_refrssiamp3=fread(fin,1,'uchar')';
  profile.bt_refrssiamp4=fread(fin,1,'uchar')';
  profile.bt_gain=fread(fin,1,'uchar')';
  extrabytes = fread(fin,4,'uchar');
 %profile.bt_range1 = profile.bt_range1+65536*extrabytes(1);
 % profile.bt_range2 = profile.bt_range2+65536*extrabytes(2);
 % profile.bt_range3 = profile.bt_range3+65536*extrabytes(3);
 % profile.bt_range4 = profile.bt_range4+65536*extrabytes(4);
  junk=fread(fin,4,'uchar')';
return;
  

