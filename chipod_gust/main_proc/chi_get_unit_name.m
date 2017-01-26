function [unit]  = chi_get_unit_name(basedir)
%% [unit]  = chi_get__unit_name(basedir)
%        returns a unit string for a given basedir

   unit = basedir([-3:-1]+end);
   if(unit(1)==filesep) % in case the unit is 3 digit long
      unit = unit(2:4);
   end


