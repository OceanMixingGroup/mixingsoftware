function sorted_filenames = dirs(str_descr, varargin)
% sorted_filenames = dirs(str_descr, varargin)
% return an ascii-sorted directory listing 
% str_descr is whatever string descriptor one would normally use with "dir"
%
% varargin is name, value pairs: if not set, act as the original
% matlab "dir" command does
%
% varargin:
% name        values               comments
%
% 'sort'     'none'                matlab's original order (why???)
%            'ascii'               default
%            'time'                modification date: oldest is first
%            'date'                modification date: oldest is first
% 'reverse'    [0 or 1]           0 reverse order
% 'fullpath',  [0 or 1]           0 (do not include full path in name)
% 'fullfile',  [0 or 1]           0 (do not include full path in name)
%                                   (same as 'fullpath')
% 'cell'       [ 0 or 1]          0 return structure (same as matlab's "dir")
%                                   1: return a cellarray of filenames, as
%                                      filestruct(:).name

%JH 2001/04/06

cfg.sort = [];
cfg.fullpath = 0;
cfg.fullfile = 0;
cfg.reverse = 0;
cfg.cell = 0;


cfg = fillstruct(cfg, varargin, 0);


dstruct = dir(str_descr);
fnames = fieldnames(dstruct);
dcell = struct2cell(dstruct);   %(4 X nfiles)

if (nargin == 1) 
   cfg.sort = 'ascii';
end
if (isempty(cfg.sort))
   cfg.sort = 'ascii';
end


if strcmp(cfg.sort, 'ascii')
   %sort dirlist by ascii
   [sorted_names, sorti] = sort(dcell(1,:));
   sorted_dcell = dcell(:,sorti);
   if (cfg.reverse == 1)
      sorted_dcell = fliplr(sorted_dcell);
   end
   sorted_filenames = cell2struct(sorted_dcell', fnames(:)',2);
elseif (strcmp(cfg.sort, 'none'))
   sorted_filenames = dstruct;
elseif (strcmp(cfg.sort, 'date') | strcmp(cfg.sort, 'time'))
   nnums = zeros(length(dstruct),1);
   for ii=1:length(dstruct)
      nnums(ii) = datenum(dstruct(ii).date);
   end
   [junk,sorti] = sort(nnums);
   sorted_dcell = dcell(:,sorti);
   if (cfg.reverse == 1)
      sorted_dcell = fliplr(sorted_dcell);
   end
   sorted_filenames = cell2struct(sorted_dcell', fnames(:)',2);
else
   help(mfilename)
   error('can only sort by ''ascii'', ''date'' (equivalent to ''time'')  or ''none'' at the moment')
end


if (cfg.fullpath | cfg.fullfile)
   if (isdir(str_descr))
      dirstr = str_descr;
   else %assume it was a wildcard description
      [pp,nn,ee]=fileparts(str_descr);
      dirstr = pp;
   end
   
   for ii=1:length(sorted_filenames)
      sorted_filenames(ii).name = fullfile(dirstr, sorted_filenames(ii).name);
   end
end


if cfg.cell
   cnames = {};
   for ifile = 1:length(sorted_filenames)
      cnames{ifile} = sorted_filenames(ifile).name;
   end
   sorted_filenames = cnames;
end



   







