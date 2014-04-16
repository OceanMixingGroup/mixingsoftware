% copyfilesdsadsa
% copy Revelle sonar files to topath
%  topath = 'd:\data\ct03\revsonar140k';
%  matpath = 'c:\work\ct03\revsonar140k\mat';
%  trimpath = 'c:\work\ct03\revsonar140k\trim';
%  frompath = '\\172.16.50.140\140ksonar\*MTF*';
%  frompath2 = '\\172.16.50.140\140ksonar\';
 topath = 'd:\data\ct03\revsonar50k';
 matpath = 'c:\work\ct03\revsonar50k\mat';
 trimpath = 'c:\work\ct03\revsonar50k\trim';
 frompath = '\\172.16.50.50\50ksonar\*MTF*';
 frompath2 = '\\172.16.50.50\50ksonar\';
 done =0;
 while ~done
     fprintf(1,'Polling for new data\n');
     
     d=dirdiff(frompath,topath,0,1);
     for i=1:length(d)
       [frompath2 d{i}]
       copyfile([frompath2 d{i}],topath);
       pause(1);
     end;
    
     % process data...
     d=dirdiffoneway(topath,trimpath);
     d=setdiff(d,{'50K_48MTF[15_01_03.200317]c','50K_48MTF[15_01_03.203050]c',...
         '50K_48MTF[20_01_03.201436]c'});
     for i=1:length(d)
       d{i}
       sonar=PinkelRead(sprintf('%s\\%s',topath,d{i}));
       sonar = RevGetBeamVels(sonar);
       sonar = RevBeamtoShip(sonar);
       % second input in RevAvgandTrim is averaging time (in minutes)
       % and third input is max depth (in meters)
       trimsonar = RevAvgandTrim(sonar,20,300);
       save(sprintf('%s\\%s',trimpath,d{i}),'trimsonar','-mat');
%        save(sprintf('%s\\%s',matpath,d{i}),'sonar','-mat');
 %      savesonar = mergfields(savesonar,trimsonar);
     end;     
    fprintf(1,'Pausing\n');
    for i=1:600
        pause(1)
    end;
    
 end;
 