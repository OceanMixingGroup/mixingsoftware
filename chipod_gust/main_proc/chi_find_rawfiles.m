function [fids, fdate] = chi_find_rawfiles(basedir)
%% [fids, fdate] = chi_find_rawfiles(basedir)
%     This function finds all the raw data that match unit
%     in rawdir, and returns a list of files  (fids{i})
%     and the corresponding date stamps (as string, fdate{i})
   
   rawdir = [basedir filesep 'raw' filesep];
   unit   = chi_get_unit_name(basedir);

   d = dir(rawdir);
   cnt = 1;
   fids = [];
   for i = 1:length(d)
      if(~d(i).isdir)
         if(d(i).name([1:3])=='raw') % check if raw-file
            if(d(i).name([-2:0]+end)== unit([-2:0]+end)) % check if correct unit
               % read in the file date from file name
               is1 = strfind(d(i).name,'_');  % find under score
               is2 = strfind(d(i).name,'.');  % find dot

               fdate{cnt} = d(i).name((is1+1):(is2-1));
               fids{cnt} = d(i).name;
               cnt = cnt+1;
            else
               disp([d(i).name ' does not fit unit ' unit]);
            end
         end
      end
   end

   if(isempty(fids))
      error(['There are no matching raw files at the given path ' rawdir])
      return;
   end
   
end   
