function [bottom] = read_bottom_out(fname);
%
MarlinDepthOffset = 63.8;

readstr=['%02d%02d%f' ...   % time
     ' %02d%f %c' ...  % lat
     ' %03d%f %c' ...     % lon
     ' %f' ...         % sog
     ' %f' ...         % depth
     ' %d' ...         % depth flag
     ' %02d%02d%04d'...  % date
     ' %f %f %f %d %f %f %f %f %f']; % heading, marlin vel, marlin pressure , ??, bottom
                      % avoid range, adcp vel, adcp range, adcp ensemble,
                      % adcp pressure(*1000)

nscan=1;
num = 0;
while nscan<19
  fin = fopen(fname,'r')
  if fin>0
    [data,nscan]=fscanf(fin,readstr);
    fclose(fin);
  end;
  num =num+1;
  if num>10
    warning(['Cannot decode' fname]);
    bottom = [];
    return;
  end;
end;

h=data(1);m=data(2);s=data(3);
lat = data(4); latmin=data(5); hemilat=char(data(6));
lon = data(7); lonmin=data(8); hemilon=char(data(9));
shipsog=data(10);
shipdepth=data(11);
shipdepthflag=data(12);
day=data(13);month=data(14);year=data(15);
shiphead=data(16);
MarlinSpeed=data(17);
MarlinDepth=data(18);
OAdisttobottom=data(19);
adcpvel=data(20);
adcprange=data(21);
adcensemble=data(22);
adcppressure=data(23)/1000;

bottom.time = datenum(year,month,day,h,m,s);
bottom.lat = lat+latmin/60;

keyboard;
if strcmp(hemilat,'S');
  bottom.lat = -bottom.lat;
end;
bottom.lon = lon+lonmin/60;
if strcmp(hemilon,'W');
  bottom.lon = -bottom.lon;
end;
bottom.adcprange=adcprange;
bottom.shipsog = shipsog*mpernm/(3600);
bottom.shipdepth = shipdepth;
if ~shipdepthflag
  bottom.shipdepth=NaN;
end;
bottom.shiphead = shiphead;
if MarlinSpeed==-999
  bottom.MarlinSpeed = NaN;
else;
  bottom.MarlinSpeed = MarlinSpeed;
end;
if adcpvel==-999
  bottom.MarlinSpeed = NaN;
else;
  bottom.MarlinSpeed = adcpvel;
end;
if MarlinDepth==-999
  bottom.MarlinDepth = -10;
else;
  bottom.MarlinDepth =  adcppressure;
end;
if OAdisttobottom==99.0
  bottom.OAdisttobottom = NaN;
else;
  bottom.OAdisttobottom = OAdisttobottom;
end;







