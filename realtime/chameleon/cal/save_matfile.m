function save_matfile(fn,series)
% function save_matfile(filename,series) writes to FILENAME the series
% SERIES contained within cal. and writes the header information. 
 
global head cal
nplots=length(series);
for i=1:nplots
  tempser=[upper(deblank(char(series(i))))];
  eval(['temp.' upper(tempser) '=cal.' ...
        upper(tempser) ';']);
end
cal=temp;
eval(['save ' fn ' cal head'])
