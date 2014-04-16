function [prfx num year]=getprefix(in)
% [PREFIX NUM]=getprefix(HEAD) gets the prefix and drop number by parsing
% the by parsing the string in the 'thisfile' field of the HEAD
% structure.
% 
% [PREFIX NUM]=getprefix(STRING) parses the string STRING for the prefix
% and drop number.
% 
% [PREFIX NUM YEAR]=getprefix(...) returns the year (by parsing the 2
% numbers in PREFIX)
% 
% This file contains preset prefix's which have more than 10,000 drops.
% If a new cruise has more than 10,000 drops, add its prefix to the d10k
% cell array contained in this function.
% 
% Currently included d10k prefix's: cr05

if isstruct(in)
  thf=in.thisfile;
elseif isstr(in)
  thf=in;
else
  error('Input to getprefix must be either a string or the HEAD structured variable')
end


d10k={'cr05'};

idot=strfind(thf,'.');
if ~isempty(idot)
  idot=idot(end);
  if isempty(str2num(thf(idot+1:end)))
    thf=thf(1:idot-1);
  end
end

inds=strfind(thf,'/');
if isempty(inds)
  inds=strfind(thf,'\');
end
if isempty(inds)
  inds=0;
end
ind=inds(end);
fname=thf(ind+1:end);
idot=strfind(fname,'.');
if length(idot)>1
  error('Filename contains more than one ''.'', getprefix unable to parse string')
end

if ~isempty(idot) 
  if idot~=length(fname) & idot~=1
    fname=fname([1:idot-1 idot+1:end]);
  elseif idot==1
    fname=fname(2:end);
  elseif idot==length(fname)
    fname=fname(1:end-1);
  end
end

  
for i0=1:length(d10k)
  l=length(d10k{i0});
  if strncmp(lower(d10k{i0}),lower(fname),l)
    prfx=fname(1:l);
    num=str2num(fname([l+1:end]));
    if nargout==3
      year=getyear(prfx);
    end
    return
  end
end

% Now that the file has not matched any of the d10k prefix's, we have a
% more difficult time parsing the string because of my new convention of
% naming files with 5 number slots.

% If the original input was a structure, than it is easy (because we
% already know it shouldn't be a d10k prefix):
if isstruct(in)
  prfx=fname(1:end-4);
  num=str2num(fname(end-3:end));
  if nargout==3
    year=getyear(prfx);
  end
  return
end

% Now assume that the prefix has two numbers in it for the date, then
% find the first number after that, and assume that from their to the end
% is the number.  The beginning is the prefix:

ind=1;
while isempty(str2num(fname(ind:ind+1)))
  ind=ind+1;
end
prf_ind=ind+1;
ind=ind+2;
while isempty(str2num(fname(ind:end)))
  prf_ind=prf_ind+1;
  ind=ind+1;
end
prfx=fname(1:prf_ind);
num=str2num(fname(ind:end));

if nargout==3
  year=getyear(prfx);
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function year=getyear(prfx)
% get the year from prfx
ind=1;
while isempty(str2num(prfx(ind:ind+1)))
  ind=ind+1;
end
yr=str2num(prfx(ind:ind+1));
if yr>80
  year=1900+yr;
else
  year=2000+yr;
end
