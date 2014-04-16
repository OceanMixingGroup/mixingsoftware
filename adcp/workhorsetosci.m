function adcp = workhorsetosci(fname);
% function adcp = workhorsetosci(fname);
% read a file of workhorse adcp data and output in sensible units.
%
% Calls read_workhorse.m to translate raw data and then converts to
% something useful.
%
% adcp = workhorsetosci(radcp);
% If argument is a structure, then it assumes you have already read
% in the data and converts radcp to scientific units directly.

% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:41 $ $Author: aperlin $	
% Originally J. Klymak, May 2002
  
  if ~isstr(fname)
    radcp=fname;
  else
    radcp = read_workhorse(fname);
  end;
  if isempty(radcp)
    adcp = [];
    return;
  end;
  
  
  % cfg should not change during the file.  Of course, it may, but
  % that'd be bad.
  adcp.cfg = firstcol(radcp.cfg);

  adcp.ensemble = radcp.ensemble+radcp.ensemble2*2^16;
  % there are two timestamps...
  adcp.time1 = datenum(radcp.year+2000,radcp.month,radcp.day,radcp.hour, ...
		       radcp.minutes,radcp.second+radcp.hundredths/100); 
  adcp.time2 = datenum(radcp.RTCcentury*100+radcp.RTCyear, ...
		       radcp.RTCmonth,radcp.RTCday,radcp.RTChour, ...
		       radcp.RTCminutes,radcp.RTCsecond+ ...
		       radcp.RTChundredths/100);
  adcp.speedofsound = radcp.speedofsound;
  straightassign = {'heading', 0.01;
		    'hdgstddev', 1;
		    'roll', 0.01;
		    'rollstddev', 0.1;
		    'pitch',0.01;
		    'pitchstddev',0.1;
		    'salinity',1;
		    'temperature',0.01;
		    'pressure',1e-3;
		    'pressurevar',1e-3};
  for i=1:size(straightassign,1);
    dat = getfield(radcp,straightassign{i,1});
    dat = dat*straightassign{i,2};
    adcp = setfield(adcp,straightassign{i,1},dat);
  end;
  if isfield(radcp,'vel1')
    adcp.vel1 = radcp.vel1*0.001;
    adcp.vel2 = radcp.vel2*0.001;
    adcp.vel3 = radcp.vel3*0.001;
    adcp.vel4 = radcp.vel4*0.001;
  end;
  if isfield(radcp,'corr1')
    adcp.corr1 = radcp.corr1;
    adcp.corr2 = radcp.corr2;
    adcp.corr3 = radcp.corr3;
    adcp.corr4 = radcp.corr4;
  end;
  if isfield(radcp,'echo1')
    adcp.echo1 = radcp.echo1;
    adcp.echo2 = radcp.echo2;
    adcp.echo3 = radcp.echo3;
    adcp.echo4 = radcp.echo4;
  end;
  if isfield(radcp,'percentgood1')
    adcp.percentgood1 = radcp.percentgood1;
    adcp.percentgood2 = radcp.percentgood2;
    adcp.percentgood3 = radcp.percentgood3;
    adcp.percentgood4 = radcp.percentgood4;
  end;  
  if isfield(radcp,'bt_vel1');
    % check this....
    adcp.bt_vel1 = radcp.bt_vel1/1000;
    adcp.bt_vel2 = radcp.bt_vel2/1000;
    adcp.bt_vel3 = radcp.bt_vel3/1000;
    adcp.bt_vel4 = radcp.bt_vel4/1000;
    bad=find(adcp.bt_vel1==-32.768); adcp.bt_vel1(bad)=NaN;
    bad=find(adcp.bt_vel2==-32.768); adcp.bt_vel2(bad)=NaN;
    bad=find(adcp.bt_vel3==-32.768); adcp.bt_vel3(bad)=NaN;
    bad=find(adcp.bt_vel4==-32.768); adcp.bt_vel4(bad)=NaN;

    adcp.bt_range1 = radcp.bt_range1/100;
    adcp.bt_range2 = radcp.bt_range2/100;
    adcp.bt_range3 = radcp.bt_range3/100;
    adcp.bt_range4 = radcp.bt_range4/100;
    adcp.bt_corr1 = radcp.bt_corr1;
    adcp.bt_corr2 = radcp.bt_corr2;
    adcp.bt_corr3 = radcp.bt_corr3;
    adcp.bt_corr4 = radcp.bt_corr4;
    adcp.bt_percgood1 = radcp.bt_percgood1;
    adcp.bt_percgood2 = radcp.bt_percgood2;
    adcp.bt_percgood3 = radcp.bt_percgood3;
    adcp.bt_percgood4 = radcp.bt_percgood4;
  end;
  
  % get the ADCP z bins. convention: gets larger with depth....
  bits = char2bits(adcp.cfg.sysconfig,16);
  adcp.binpos = 0.01*(adcp.cfg.bin1dist+adcp.cfg.cellsize*[0:adcp.cfg.ncells-1])'; 
  adcp.downfacing = ~bits(8);
%   toflip = {'vel1','vel2','vel3','vel4','echo1','echo2','echo3','echo4'};
%   if ~adcp.downfacing % upfacing;
%     adcp.binpos = -adcp.binpos;
%     adcp.heading = -adcp.heading;
%     % flip all the fields...
%     for iu=1:length(toflip)
%       if isfield(adcp,toflip{iu});
%         datu = getfield(adcp,toflip{iu});
%         adcp=setfield(adcp,toflip{iu},flipud(datu));
%       end;
%     end;
%   end;
%   theta = 180-adcp.heading; 

%   % rotate if need be...
%   bits = char2bits(adcp.cfg.coordtransform,8);
%   if bits(4) % must rotate
%     U = adcp.vel1+adcp.vel2*sqrt(-1);
%     U = U.*repmat(-exp(sqrt(-1)*theta*pi/180),size(U,1),1);
%     adcp.vel1 = real(U);
%     adcp.vel2 = imag(U);
%     if ~adcp.downfacing
%       adcp.vel1=-adcp.vel1;
%     end;
%     if isfield(adcp,'bt_vel1') & isfield(adcp,'bt_vel2');
%       U = adcp.bt_vel1+adcp.bt_vel2*sqrt(-1);
%       U = U.*repmat(-exp(sqrt(-1)*theta*pi/180),size(U,1),1);
%       adcp.bt_vel1 = real(U);
%       adcp.bt_vel2 = imag(U);
%     end;      
%   end;
  
  if isfield(radcp,'nav');
    nav = radcp.nav;
    adcp.navfirsttime = datenum(nav.year,nav.month,nav.day,0,0,nav.firstfix*1e-4);
    adcp.navlasttime = datenum(nav.year,nav.month,nav.day,0,0,nav.lastfix*1e-4);
    adcp.navfirstlon = bam2ang(nav.first_lon,32);
    adcp.navfirstlon(find(adcp.navfirstlon>180))=adcp.navfirstlon(find(adcp.navfirstlon>180))-360;
    adcp.navfirstlat = bam2ang(nav.first_lat,32);
    adcp.navfirstlat(find(adcp.navfirstlat>180))=adcp.navfirstlat(find(adcp.navfirstlat>180))-360;
    adcp.navlastlon = bam2ang(nav.last_lon,32);
    adcp.navlastlon(find(adcp.navlastlon>180))=adcp.navlastlon(find(adcp.navlastlon>180))-360;
    adcp.navlastlat = bam2ang(nav.last_lat,32);
    adcp.navlastlat(find(adcp.navlastlat>180))=adcp.navlastlat(find(adcp.navlastlat>180))-360;
    adcp.navroll = bam2ang(nav.roll,16);
    adcp.navpitch = bam2ang(nav.pitch,16);
    adcp.navheading = bam2ang(nav.heading,16);
    adcp.navnsamps = nav.nsamps;
    adcp.avg_speed = nav.avg_speed/1000;
    adcp.avg_headtrue = bam2ang(nav.avg_headtrue,16);
    adcp.navCOG=bam2ang(nav.directionmadegood,16);
    adcp.navSOG=nav.speedmadegood/1000;
  end;
  
  return;

function ang = bam2ang(bam,n);
%  function ang = bam2ang(bam,n);
% convert bam integers to angles.
x = dec2bin(bam,n)-'0';
for i=1:n
  y(i)=2.^(1-i);
end;
y = y*180;
x = x.*repmat(y,size(x,1),1);
ang=sum(x');
return;

  
function bits = char2bits(ch,n);
% function bits = char2bits(ch,n);
% returns the 8 bits set in the number.  Asummed to be unsigned...

  bits = zeros(1,n);
  i = 1;
while ch>0
  bits(i) = mod(ch,2);
  ch = floor(ch/2);
  i = i+1;
end;
% bits = fliplr(bits);
 
  
function cfg = firstcol(cfg);
  fnames = fieldnames(cfg);
  for i=1:length(fnames)
    dat = getfield(cfg,fnames{i});
    cfg=setfield(cfg,fnames{i},dat(1));
  end;
  return;
  
  