function [defstruct] = fillstruct(defstruct, newarg, append);
% [nameval_struct] = fillstruct(defstruct, newarg, append);
% takes default structure and updates the fields with values from newargs.
%
% newargs:   can be a structure or a 1-dimensional cellarray 
%                 if newarg is a cellarray, it is used as {name},{value} pairs
% append:     allows creation of new structure elements from newargs
% append = 0 (DEFAULT; add the new name.value pairs to defstruct)
% append = 1 (fail if any newargs fields are not present in defstruct)
%
% useage:
% updated_struct = fillstruct(defstruct, varargin)

%Jules 2000/10/31
%Jules 2003/11/05: changed the 'append' default to FALSE

program_name = 'fillstruct';

% error checking ------------------------------

if ((nargin ~= 2) & (nargin ~= 3))
   help(program_name)
   error('must specify 2 or 3 arguments')
end

if (nargin == 2)
   append = 0;
end

   
if (~isstruct(defstruct))
   help(program_name)
   error('first argument must be the structure of default values')
end

% check second argument: make into a structure ----------

if (isempty(newarg))  %just return the input if no new args
   return
end


if (iscell(newarg)) %make sure it has an even number of elements
   if (rem(length(newarg),2) ~= 0)
      newarg
      error('newarg must have name, value _pairs_')
   end
   %there has to be a better way...    % too bad this doesn't work:
   % struct = cell2struct(cell{1:2:end}, cell{2:2:end},2)
   newargs = struct(newarg{1},newarg(2));
   for num = 3:2:length(newarg)
      newargs = setfield(newargs, newarg{num}, newarg{num+1});
   end
elseif (isstruct(newarg)) %rename it if it is a structure
   newargs = newarg;
else
   error('second argument must be a cellarray or a structure')   
end

% assign or bomb out ------------------------------

def_fnames = sort(fieldnames(defstruct));  %default fieldnames
new_fnames  = sort(fieldnames(newargs));   %new fieldnames

for fni = 1:length(new_fnames)
   if (~isfield(defstruct, new_fnames{fni}) & ~append)
      error(sprintf('field "%s" does not exist in default structure',...
                    new_fnames{fni}))
   end
   %now update it anyway 
   defstruct = setfield(defstruct, new_fnames{fni}, ...
                                   getfield(newargs,new_fnames{fni}));
end


