function ctd=read_sbe(asciiname,fmt);

if nargin==1
    fmt='';
end

ctd.filename=asciiname;

fid=fopen(asciiname,'r');

if fid==-1
    ctd.status=0;
    error(['Unable to open ' asciiname]);
    return
else
    ctd.status=1
end

% Read the header.
% Stop at line that starts with '*END*'

has_temp='';
has_cond='';
has_pres='';

head_len=1
str='*START*';
while (~strncmp(str,'*END*',5) & ...
       ~strncmp(str,'start sample number',19));
    str=fgetl(fid)
    if strfind(str,'pressure S')
    has_pres='P';
    end
    if (strncmp(lower(str),'** station',10)),
        ctd.station=fliplr(deblank(fliplr(deblank(str(min(findstr(str,':'))+ ...
                                                      2:end)))));
    elseif (strncmp(str,'interval =',10)),
        ctd.samp_interval=sscanf(str(findstr(str,'=')+1:end),'%f');
    elseif strfind(str,'temperature')
        has_temp='T';
    elseif strfind(str,'conductivity')
        has_cond='C';
    elseif (strfind(str,'* pressure S') | strfind(str,'pressure S'))
        has_pres='P';
    end
head_len=head_len+1;
end

if strncmp(str,'start sample number',19)
    %  If this is how we identified the header, we need to rewind a bit
    head_len=head_len-2;
    frewind(fid)
    for aaa=1:(head_len-2)
        str=fgetl(fid);
    end
end

head_len=head_len+2
ctd.header_length=head_len;
if isempty(fmt)
    fmt=[has_temp has_cond has_pres];
    ctd.sensors=fmt;
end

str=fgetl(fid);
nnn=findstr(str,'=');
gtime=datenum(str(nnn+1:end));
%gtime=get_timestamp(str);
ctd.start_time=datenum(gtime);
str=fgetl(fid);
n1=findstr(str,'=');
n2=findstr(str,'seconds');
if (n2-n1)>3
    ctd.sample_int2=str2num(str((n1+1):(n2-1)));
end
str=fgetl(fid);
n1=findstr(str,'=');
if n1
    ctd.startsample=str2num(str((n1+1):end));
else
    ctd.startsample==1;
end
fclose(fid);


if strcmp(fmt,'T')
    ctd.T=textread(asciiname,'%f%*[^\n]','headerlines',head_len,'delimiter',',');
elseif strcmp(fmt,'TC')
    [ctd.T ctd.C]=textread(asciiname,'%f%f%*[^\n]','headerlines',head_len,'delimiter',',');
elseif strcmp(fmt,'TCP')
    [ctd.T ctd.C ctd.P dummy dummy2]=textread(asciiname,'%f%f%f%s%s','headerlines',head_len,'delimiter',',');
end
ctd.time=ctd.start_time+[0:(length(ctd.T)-1)]'*ctd.sample_int2/24/3600;

return

function gtime=get_timestamp(str);
% Decodes time string

% Time to right of '='
str=str(findstr(str,'=')+1:end);

% is there hh:mm:ss in there?
is=findstr(str,':');
if any(is),
  isub=is(1)-2:length(str);
  
  % Date in   Dec 21 2005 format
  nbl=find(str(1:is(1)-3)~=' ');
  datstr=str(min(nbl):max(nbl));
  ibl=findstr(datstr,' ');
  % Write into 21-Dec-2001 format which matlab can decode
  datstr=[datstr(ibl(1)+1:ibl(2)-1) '-' datstr(1:ibl(1)-1) '-' datstr(ibl(2)+1:end)];
  if ibl(2)-ibl(1)==2,
   datstr=['0' datstr];
  end; 
  gtime=datevec(datstr);
  
  % Add hh:mm:ss
  if length(is)==1,
    gtime([4:5])=sscanf(str(isub),'%d:%2d');
  elseif length(is)==2,
    gtime([4:6])=sscanf(str(isub),'%d:%2d:%2d');
  else
    disp(['Can''t scan string ->' str '<- for time of day']);    
  end; 
else
    disp(['Can''t scan string ->' str '<- for time of day']);    
   gtime=[0 0 0 0 0 0];
end; 


