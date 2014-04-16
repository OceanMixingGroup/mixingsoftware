function bigsonar = getrawmat(dname,t1,t2);
% function sonar = getrawmat(d,t1,t2);
% Find all the sonar files in d between t1 and t2.  Return processed data
% only
  
  
  bigsonar = [];
  
  toassign={'w','x','ship','shipPCODE','shipSOG','csound','time', ...
            'sog','cog','pcode_lon','pcode_lat','heading', 'ADUheading', ...
            'tss_pitch','tss_roll','ADU2_pitch','ADU2_roll', 'pitch','roll'}
  
  MAXDEPTH = 200;
  num = 0;  
  d=dir(dname);
  for i=1:length(d)
    f = [dname d(i).name]
    date = revgettimefromfile(f);
    date
    if ~isnan(date)
      datestr(date)
    end;
    if (date>=t1 & date<=t2)
      load(f,'-mat');
      if num ==0
        indepth = find(sonar.ranges<=MAXDEPTH);
        num = num+1;
      end;
      
      trim.head = sonar.head;
      trim.dasinfo = sonar.dasinfo;
      trim.u = sonar.u(indepth,:);
      trim.int = squeeze(mean(sonar.int(:,indepth,:),1));
      trim.sn = squeeze(mean(sonar.sn(:,indepth,:),1));
      for j = 1:length(toassign)
        if isfield(sonar,toassign{j})
          trim.(toassign{j}) = sonar.(toassign{j});
        else
          trim.(toassign{j}) = NaN*sonar.time;
        end;
        
      end;
      % save the bigsonar head...
      if ~isempty(bigsonar)
        bighead = bigsonar.head;
      else
        bighead=[];
      end;
      bigsonar = mergefields(bigsonar,trim);
      bigsonar.head = mergefields(bighead,trim.head);
      bigsonar.ranges = sonar.ranges(indepth);
    end;  
  end;
  