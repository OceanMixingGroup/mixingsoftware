function [data_out] = tlim_data(data, tl)
%%   [data] = tlim_data(data, tl)
%        
%        This function cuts all fields in 
%        data in time limits tl 
%
%
%        INPUT
%           data      = data structure from chi pod calibration 
%           tl        = time interval in matlab time 
%           
%   created by: 
%        Johannes Becherer
%        Mon Nov 28 11:42:54 PST 2016


if ~isfield(data, 'time')
   if isfield(data, 'datenum')
      data.time = data.datenum(1:2:end);
   else
      error('there must be a time vector in the structure data');
      return;
   end
end

if ~isfield(data, 'time_dt')
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


%_____________________get all fields______________________
fs = fields(data);


   %---------------------find indezes----------------------
   ii       =  find( (data.time<= tl(2) )     & (data.time>= tl(1)) );
   ii_tp    =  find( (data.time_tp<= tl(2) )  & (data.time_tp>= tl(1)) );
   ii_cmp   =  find( (data.time_cmp<= tl(2) ) & (data.time_cmp>= tl(1)) );
   


   %---------------------loop through fields----------------------
   for f = 1:length(fs)
         
         % check if length time 
         if(  length(data.(fs{f})) == length(data.time_cmp))
            data_out.(fs{f}) = data.(fs{f})(ii_cmp);
         elseif(length(data.(fs{f})) == length(data.time))
            data_out.(fs{f}) = data.(fs{f})(ii);
         elseif(length(data.(fs{f})) == length(data.time_tp))
            data_out.(fs{f}) = data.(fs{f})(ii_tp);
         else
              warning([fs{f} ' is not a field that can be cut, '...
                          ' because there is no corresponding time vector'])
               % if it contains a structure
               if( isstruct( data.(fs{f}) ) )
                  data_out.(fs{f}) = data.(fs{f});
               end
         end


   end


