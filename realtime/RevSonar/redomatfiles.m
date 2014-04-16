matpath = 'c:\work\ct03\revsonar140k\mat';;
trimpath = 'c:\work\ct03\revsonar140k\trim';
d = dir([matpath '\140K_MTF*']);

for i=1:length(d)
  d(i).name
  load(sprintf('%s\\%s',matpath,d(i).name),'-mat');
  sonar = RevGetBeamVels(sonar);
  sonar = RevBeamtoShip(sonar);
  trimsonar = RevAvgandTrim(sonar,10,400);
  save(sprintf('%s\\%s',trimpath,d(i).name),'trimsonar','-mat');
%   save(sprintf('%s\\%s',matpath,d(i).name),'sonar','-mat');
end;
