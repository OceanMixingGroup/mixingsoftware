function [avg] = average_fields(data, dt)
%%   [avg] = average_fields(data)
%        
%        This function averages all fields in 
%        data on time interval dt 
%
%
%        INPUT
%           avg.time  = matlab time 
%           dt        = time interval in [s] 


if ~isfield(data, 'time')
   if isfield(data, 'datenum')
      data.time = data.datenum(1:2:end);
   else
      error('there must be a time vector in the structure data');
      return;
   end
end

if ~isfield(data, 'time_tp')
   % for gust Tp is on the same time step as the other variables 
   if isfield(data, 'datenum')
      data.time_tp = data.datenum;
   else
      data.time_tp = data.time;
   end
end

if ~isfield(data, 'time_cmp')
   % usually there should always be a compass time, however 
   data.time_cmp = data.time;
end

%_____________________create new time vector______________________
sec_d = 3600*24; % factor sec to day
avg.time = (data.time(1)+.5*dt/sec_d):dt/sec_d:(data.time(end)-.5*dt/sec_d);


%_____________________get all fields______________________
fs = fields(data);
   %---------------------initialize fileds fields----------------------
   for f = 1:length(fs)
      % ignor time vectors
      if ~( strcmp(fs{f}, 'time') |  strcmp(fs{f}, 'time_cmp') |  strcmp(fs{f}, 'time_tp'))
         avg.(fs{f}) = nan(size(avg.time));
      end
   end


%_____________________loop through every time step______________________
   %---------------------find indezes----------------------
   ii       =  find( (data.time<=(avg.time(1)+.5*dt/sec_d) ) ...
                   & (data.time>=(avg.time(1)-.5*dt/sec_d) ) );
   
   ii_tp    =  find( (data.time_tp<=(avg.time(1)+.5*dt/sec_d) ) ...
                   & (data.time_tp>=(avg.time(1)-.5*dt/sec_d) ) );
   
   ii_cmp   =  find( (data.time_cmp<=(avg.time(1)+.5*dt/sec_d) ) ...
                   & (data.time_cmp>=(avg.time(1)-.5*dt/sec_d) ) );

   D_ii     = round( (dt/sec_d)/nanmean(diff(data.time)) );
   D_ii_tp  = round((dt/sec_d)/nanmean(diff(data.time_tp)));                
   D_ii_cmp = round((dt/sec_d)/nanmean(diff(data.time_cmp))); 
 % if ((dt/sec_d)/nanmean(diff(data.time))- round( (dt/sec_d)/nanmean(diff(data.time)) ) ) ~=0
 %      warning('the total length of the file is not a divisible by the intened timestep intended time step')
 %      D_ii     = floor(D_ii);
 %      D_ii_tp  = floor(D_ii_tp);
 %      D_ii_cmp = floor(D_ii_cmp);
 %  end

for t = 1:length(avg.time)



   %---------------------loop through fields----------------------
   for f = 1:length(fs)
      % ignor time vectors
      if ~(   strcmp(fs{f}, 'time_cmp')...
         |  strcmp(fs{f}, 'time_tp'))
         
         % check if length time 
         if( strcmp(fs{f}, 'compass') | strcmp(fs{f}, 'cmp') | strcmp(fs{f}, 'pitch') | strcmp(fs{f}, 'roll') )
            % compass stuff is in deg and must be treated differently
            tmp = data.(fs{f})(ii_cmp)/180*pi; % transfor into rad
            tmp = exp(1i * tmp);  % convert to complex plain
            avg.(fs{f})(t) = angle(nanmean(tmp))/pi*180;
         elseif(length(data.(fs{f})) == length(data.time))
            avg.(fs{f})(t) = nanmean(data.(fs{f})(ii));
         elseif(length(data.(fs{f})) == length(data.time_tp))
            avg.(fs{f})(t) = nanmean(data.(fs{f})(ii_tp));
         else
            if(t==1)
%              warning([fs{f} ' is not a field that can be averaged, '...
 %                         ' because there is no corresponding time vector'])
               % if it contains a structure
               if( isstruct( data.(fs{f}) ) )
                  avg.(fs{f}) = data.(fs{f});
               end
            end
         end


      end
   end

   ii     = ii       + D_ii;
   ii_tp  = ii_tp    + D_ii_tp;
   ii_cmp = ii_cmp   + D_ii_cmp;
end




