function []  = chi_merge_and_avg(basedir, ddir, aw)
%% []  = chi_merge_and_avg(basedir, dir, aw, [mask])
%     
%     This function averages all idividual files in dir
%     in to a single file called 
%     dir_aw.mat
%
%     INPUT
%        basedir  :  base directory of unit
%        dir      :  sub directory of proc (e.g. temp, chi ...)
%        aw       :  average width in sec (if 0 no averaging)
%        mask     :  flag structure to mask data (default no mask)
%
%   created by: 
%        Johannes Becherer
%        Tue Sep 20 16:28:51 PDT 2016
%

if ~isdir([basedir 'proc' filesep ddir])
   error([ddir ' is not a directory in ' basedir])
end

%---------------------find mat files----------------------
d = dir([basedir 'proc' filesep ddir]);
cnt = 1;
for i = 1:length(d)
   if ~(d(i).isdir)
      if d(i).name([-3:0]+end) == '.mat'
         fids{cnt} = d(i).name;
         cnt = cnt+1;
      end
   end
end

if cnt == 1  
   error([ 'There are no mat files in ' basedir ddir])
end


%---------------------first file----------------------
A = load([basedir 'proc' filesep ddir filesep fids{1}]);

   % what is the name of the field
   F  = fields(A);

%_____________________loop through substructures______________________
for s =1:length(F)

      % names of subfields
      FF = fields(A.(F{s}));
      
      % average first file
      if aw == 0
         avg.(F{s}) = A.(F{s});
      else
         avg.(F{s}) = average_fields(A.(F{s}), aw);
      end


   %_____________________loop through rest of files______________________
   for i = 2:length(fids)

      fid = fids{i};
      %load file
      A = load([basedir 'proc' filesep ddir filesep fid]);

      % average
      if aw == 0
         tmp = A.(F{s});
      else
         tmp = average_fields(A.(F{s}), aw);
      end

      % merge fields 
      for f = 1:length(FF)
         avg.(F{s}).(FF{f}) = [avg.(F{s}).(FF{f}) tmp.(FF{f})];
      end
      

   end
end

%---------------------save data----------------------
   if aw == 0
      sfid =[basedir 'proc' filesep ddir '.mat'] ;
   else
      sfid =[basedir 'proc' filesep ddir '_' num2str(aw) 'sec.mat'] ;
   end

   % find fields in avg
   Favg = fields(avg);
   for i =  1:length(Favg)
    eval([char(Favg(i)) ' = avg.' char(Favg(i))]);
   end

   % save all fields in avg
   if length(Favg)==1
      save([basedir 'proc' filesep ddir '.mat'], char(Favg(1)), '-v7.3'); 
   elseif length(Favg)==2
      save([basedir 'proc' filesep ddir '.mat'], char(Favg(1)), char(Favg(2)), '-v7.3'); 
   else length(Favg)==2
      save([basedir 'proc' filesep ddir '.mat'], char(Favg(1)), char(Favg(2)), char(Favg(3)), '-v7.3'); 
   end

