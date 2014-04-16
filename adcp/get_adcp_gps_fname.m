function gps=get_adcp_gps_fname(fname);
% get_adcp_gps.m
% 
% example: gps=get_adcp_gps('\\atlantic\tgtall\adcp\t122\t122003n');
% script to read ascii gps adcp data
% gps.number - number of adcp ping,
% gps.lat - latitude (decimal degrees),
% gps.lon - longitude (decimal degrees),
% gps.time - time of pinging in matlab format (note!!! 
% year, month & day are = 0, there are only hours, minutes and seconds)
%d=dir([prefix '.*']);
%file={d.name}; file=sort(file);
j=0; k=0;
%  fname = sprintf('%s.%03d',prefix,i-1);
fid=fopen(fname);
d=dir(fname);
% assume that d.date is correct day....
%t0 = floor(datenum(d.date));
%disp(file(i))
wrap=0;
while 1
    junk=fgetl(fid);
    %    if ~ischar(junk), break, end
    if (length(junk)>=25 & junk(1)=='E')
        j=j+1;
        gps.number(j)=str2num(junk(10:14));
%         disp(gps.number(j));
        k=0;
        time=[];lat=[];lon=[];
        gps.time(j)=NaN;
        gps.lat(j)=NaN;
        gps.lon(j)=NaN;
    elseif (length(junk)>=40 & junk(1:6)=='$GPGGA' & j>0)
        str = parsecommas(junk);
        k=k+1;
        if length(str)==15
            temp=junk(8:17);
            ii=find(temp=='.');
            if length(str{2})==10
                time(k)=datenum(0,0,0,str2num(str{2}(1:2))...
                    ,str2num(str{2}(3:4)),str2num(str{2}(5:end)));
            else
                time(k)=NaN;
            end
            % take care of day wrap around...
            if length(str{3})==9
                lat(k)=str2num(str{3}(1:end-7))+str2num(str{3}(end-6:end))/60;
            else
                lat(k)=NaN;
            end
            % Only western hemisphere.....
            if length(str{5})==10
                lon(k)=-str2num(str{5}(1:end-7))-str2num(str{5}(end-6:end))/60;
            else
                lon(k)=NaN;
            end
            if time(k)<nanmean(time)
                % we probably have a wrap-around...
                time(k)=time(k)+1;
                wrap=1;
            end;
        else
            time(k)=NaN;
            lat(k)=NaN;
            lon(k)=NaN;
        end
        gps.time(j)=nanmean(time);
        gps.lat(j)=nanmean(lat);
        gps.lon(j)=nanmean(lon);
    elseif ~ischar(junk)
        break
    end
end
fclose('all');
if ~isfield(gps,'time')
  gps=[];
  return;
end;
ind=find(gps.time==0);
gps.time(ind)=NaN;
gps.lat(ind)=NaN;
gps.lon(ind)=NaN;
% fix the time
% it appears vaguely possible that number will increment with no data.
gps.number = gps.number(1:length(gps.lon));
%if wrap
%  gps.time=gps.time-1;
%end;
%gps.time = gps.time+t0;

%gps.readme=['ADCP GPS data. gps.number - number of adcp ping, '... 
%        'gps.lat - latitude (decimal degrees), gps.lon - longitude '... 
%    '(decimal degrees), gps.time - time of pinging in matlab format (note!!!'... 
% ' year, month & day are = 0, there are only hours, minutes and seconds)'];

function strs=parsecommas(str);

  pos =[0 find(str==',') length(str)+1];
  for i=1:length(pos)-1
    strs{i}= str(pos(i)+1:pos(i+1)-1);
  end;
return;