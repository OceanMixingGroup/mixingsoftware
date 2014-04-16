function d=dirdiff(frompath,topath,ignoresize);
% function dirdiff(frompath,topath);
% Finds files that are in frompath that are not in topath.  
% Also checks creation date to make sure that they are not newer in
% frompath.  
%
% Note that the paths can have asterixes in them but they shoudl be
% parallel.
  
  if nargin<3
    ignoresize=0;
  end;
fromdir = dir(frompath);
todir = dir(topath);
topathstrip=topath;
while ~exist(topathstrip,'dir');
  topathstrip=topathstrip(1:end-1);
end;

num=0;
d=[];
for i=1:length(fromdir);
  if ~(fromdir(i).name(1)=='.');
    from.name{i} = fromdir(i).name;
    from.date(i) = datenum(fromdir(i).date);
    from.bytes(i) = fromdir(i).bytes;
    if fromdir(i).bytes
      dd = dir([topathstrip '/' from.name{i}]);
      
      if ~isempty(dd)
      else
	num=num+1;
	d{num} = fromdir(i).name;
	
      end;
    end;  % check for empty files
  end; % check for file names that start with .
end;






