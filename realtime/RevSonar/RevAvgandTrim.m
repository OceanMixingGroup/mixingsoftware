function trimsonar = RevAvgandTrim(sonar,dt,zmax);
% function sonar = RevAvgandTrim(sonar,dt,zmax);
% Returns a trimmed version of the sonar data....
%
% Data is bin averaged by dt and only data shallower than zmax is
% returned.

  
  
trimsonar.dasinfo = sonar.dasinfo;
% trimsonar.head = sonar.head;

% add some info to the upper data struct...
sonar.heading = sonar.head.heading;
sonar.ADUheading = atan2(sonar.head.ADU2_heading_sin, ...
                             sonar.head.ADU2_heading_cos);
sonar.pitch = sonar.head.pitch;
sonar.roll = sonar.head.roll;
sonar.tss_pitch = sonar.head.tss_pitch;
sonar.tss_roll = sonar.head.tss_roll;
sonar.ADU2_pitch = sonar.head.ADU2_pitch;
sonar.ADU2_roll = sonar.head.ADU2_roll;


sonar.int = squeeze(sum(sonar.int,1))/4;
dt = dt/24/3600;
in = find(abs(sonar.time-median(sonar.time))<1/24);
timebins = min(sonar.time(in)):(dt):(max(sonar.time(in))+dt)

in = find(sonar.ranges<zmax);

for i=1:length(in)
  u(i,:) = bindata1d(timebins,sonar.time,real(sonar.u(i,:)));
  v(i,:) = bindata1d(timebins,sonar.time,imag(sonar.u(i,:)));
  trimsonar.w(i,:) = bindata1d(timebins,sonar.time,sonar.w(i,:));
  trimsonar.int(i,:) = bindata1d(timebins,sonar.time,sonar.int(i,:));
end;
trimsonar.u = u+sqrt(-1)*v;
trimsonar.ranges = sonar.ranges(in);

tobin = {'csound','time','sog','cog','pcode_lon','pcode_lat','heading', ...
         'ADUheading','tss_pitch','tss_roll','ADU2_pitch','ADU2_roll', ...
         'pitch','roll'};

for i=1:length(tobin);
  trimsonar.(tobin{i}) = bindata1d(timebins,sonar.time,sonar.(tobin{i}));
end;
tobin = {'x','ship','shipPCODE','shipSOG'};
for i=1:length(tobin);
  trimsonar.(tobin{i}) = bindata1d(timebins,sonar.time,real(sonar.(tobin{i})))...
  + sqrt(-1)* bindata1d(timebins,sonar.time,imag(sonar.(tobin{i})));
end;

