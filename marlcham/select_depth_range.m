function out=select_depth_range(qmini,qmaxi)
% select_depth_range.m is a script to subsample cal and data over the
% desired index range.

global data cal head

f=fieldnames(data);
if ~isempty(f)
  for i=1:length(f)
    eval(['irep=head.irep.' char(f(i)) ';']);
    eval(['data.' char(f(i)) ' =data.' char(f(i)) ...
	  '(((qmini-1)*irep+1):qmaxi*irep);']);
  end
end

if ~isempty(cal)
  f=fieldnames(cal);
  if ~isempty(f)
	for i=1:length(f)
	  eval(['irep=head.irep.' char(f(i)) ';']);
	  eval(['cal.' char(f(i)) ' =cal.' char(f(i)) ...
			'(((qmini-1)*irep+1):qmaxi*irep);']);
	end
  end
end
out=qmaxi-qmini+1;
