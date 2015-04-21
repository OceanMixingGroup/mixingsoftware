  function Y = structcat(names, names_once, col_or_row, insert_nan, varargin)
% function Y = structcat(names, names_once, col_or_row, insert_nan, S1, index1, S2, index2, ...)
% S1, S2, etc = structures to concatenate
% index1, index2, etc = index to take froms S1, S2, etc
% names = cell with fields to concatenate  
% names_once = cell with fields to include from S1 only 
% col_or_row = 'col' or 'row' index
% insert_nan = 0/1 = concatenate arrays/add NaN between arrays
  
N = nargin - 4;

if strcmp(col_or_row, 'col')
  cols = 1;
elseif strcmp(col_or_row, 'row')
  cols = 0;
end

S = varargin{1};
index = varargin{2};

nnames = length(names);
for ii = 1:nnames
  if cols
    eval([' Y.' names{ii} ' = S.' names{ii} '(index, :); ']);
  else
    eval([' Y.' names{ii} ' = S.' names{ii} '(:, index); ']);
  end
end

if ~isempty(names_once)
  nnames_once = length(names_once);
  for kk = 1:2:N - 1
    S = varargin{kk};
    for ii = 1:nnames_once
      try
        eval([' Y.' names_once{ii} ' = S.' names_once{ii} '; ']);
      end    
    end
  end
end

for kk = 3:2:N - 1
  S = varargin{kk};
  index = varargin{kk + 1};
  for ii = 1:nnames
    if cols
      eval([' x = S.' names{ii} '(index, :); '])
    else
      eval([' x = S.' names{ii} '(:, index); '])
    end
    n = size(x);
    if cols
      if insert_nan 
        eval([' Y.' names{ii} ' = [Y.' names{ii} '; NaN*ones(1, n(2)); x]; ']);
      else      
        eval([' Y.' names{ii} ' = [Y.' names{ii} '; x]; ']);
      end
    else
      if insert_nan 
        eval([' Y.' names{ii} ' = [Y.' names{ii} ', NaN*ones(n(1), 1), x]; ']);
      else      
        eval([' Y.' names{ii} ' = [Y.' names{ii} ', x]; ']);
      end
    end
  end
end
