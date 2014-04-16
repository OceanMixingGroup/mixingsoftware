function head=cnvrt_hdrs(head,force)
% HEAD=CONVERTHEAD(HEAD) converts chameleon header data (time,lat,lon) to
% datenum and decimal format.
% 
% CONVERTHEAD uses the time, lat and lon fields of the chameleon data
% header 'HEAD' to produce the new fields Dlat, Dlon and Mtime.
% 
% CONVERTHEAD does not recreate these fields if they already exist and
% are non-empty/non-NaN.
% 
% The form:
% HEAD=CONVERTHEAD(HEAD,1) will override the default of not over-writing
% the existing fields, and will re-calculate Mtime, Dlat, Dlon,
% regaurdless of whether values already exist or not.

if nargin==1
  force=0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First Calculate the time.
if force || ~isfield(head,'Mtime') || isempty(head.Mtime) || isnan(head.Mtime)
  % First get the day from the computer time:
  day1=str2num(head.starttime(15:17));
  day2=str2num(head.endtime(15:17));
  day1o=day1;
  day2o=day2;
  % Now fix the day, if the computer has changed days before NAVtime, or
  % vice-versa:
  if strcmp(head.starttime(6:7),'23') & strcmp(head.time.start(1:2),'00')
    day1=day1+1;
  end
  if strcmp(head.starttime(6:7),'00') & strcmp(head.time.start(1:2),'23')
    day1=day1-1;
  end
  if strcmp(head.endtime(6:7),'23') & strcmp(head.time.end(1:2),'00')
    day2=day2+1;
  end
  if strcmp(head.endtime(6:7),'00') & strcmp(head.time.end(1:2),'23')
    day2=day2-1;
  end
  % Now compute Mtime:
  if length(head.time.start)>=9 & length(head.time.end)>=9
    time1_b=str2num(head.time.start(1:2))+str2num(head.time.start(3:4))/60 ...
            +str2num(head.time.start(5:end))/3600.;
    time2_b=str2num(head.time.end(1:2))+str2num(head.time.end(3:4))/60 ...
            +str2num(head.time.end(5:end))/3600.;
  elseif length(head.time.start)>=9 & length(head.time.end)<9
    time1_b=str2num(head.time.start(1:2))+str2num(head.time.start(3:4))/60 ...
            +str2num(head.time.start(5:end))/3600.;
    dt=str2num(head.endtime(6:7))+str2num(head.endtime(9:10))/60 ...
       + str2num(head.endtime(12:13))/3600 - ...
       str2num(head.starttime(6:7))+str2num(head.starttime(9:10))/60 ...
       + str2num(head.starttime(12:13))/3600;
    time2_b=time1_b+dt;
    day2=day2o;
  elseif length(head.time.start)<9 & length(head.time.end)>=9
    time2_b=str2num(head.time.end(1:2))+str2num(head.time.end(3:4))/60 ...
            +str2num(head.time.end(5:end))/3600.;
    dt=str2num(head.endtime(6:7))+str2num(head.endtime(9:10))/60 ...
       + str2num(head.endtime(12:13))/3600 - ...
       str2num(head.starttime(6:7))+str2num(head.starttime(9:10))/60 ...
       + str2num(head.starttime(12:13))/3600;
    time1_b=time2_b-dt;
    day1=day1o;
  else
    disp(['No nav-time data for ' head.thisfile ', using computer time.'])
    time1_b=str2num(head.starttime(6:7))+str2num(head.starttime(9:10))/60 ...
            + str2num(head.starttime(12:13))/3600;
    time2_b=str2num(head.endtime(6:7))+str2num(head.endtime(9:10))/60 ...
            + str2num(head.endtime(12:13))/3600;
    day1=day1o;
    day2=day2o;
  end
  time_b=.5* (day1+time1_b/24 + day2+time2_b/24);
  if ~isfield(head,'year')
    [junk junk2 head.year]=getprefix(head);
  end
  head.Mtime=time_b+datenum(head.year,0,0);
end
% Does the above work for all data?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Notice below that I have used the starting position, rather than the
% end position, or some average of the two, because I believe this to be
% a more accurate representation of where chameleon actually is.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now calculate the latitude:
if force || ~isfield(head,'Dlat') || isempty(head.Dlat) || isnan(head.Dlat)
  if ~isempty(head.lat.start)
    head.Dlat=str2num(head.lat.start(1:2))+str2num(head.lat.start(3:end))/60;
  elseif ~isempty(head.lat.end)
    % Rarely head.lat/lon.start will get written to the header incorrectly.  If
    % this happened, Dlon/Dlat will be empty, and we should use head.lat/lon.end:
    head.Dlat=str2num(head.lat.end(1:2))+str2num(head.lat.end(3:end))/60;
  else
    head.Dlat=NaN;
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now calculate the longitude:
if force || ~isfield(head,'Dlon') || isempty(head.Dlon) || isnan(head.Dlon)
  if ~isempty(head.lon.start)
    head.Dlon=-(str2num(head.lon.start(1:3))+(str2num(head.lon.start(4:end))/60));
  elseif ~isempty(head.lon.end)
    % Rarely head.lat/lon.start will get written to the header incorrectly.  If
    % this happened, Dlon/Dlat will be empty, and we should use head.lat/lon.end:
    head.Dlon=-(str2num(head.lon.end(1:3))+(str2num(head.lon.end(4:end))/60));
  else
    head.Dlon=NaN;
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
