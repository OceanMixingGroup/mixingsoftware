function copy_files(from_path,to_path,to_path2)
% function COPY_FILES(FROM_PATH,TO_PATH,TO_PATH2) copies NEW FILES 
% from the directory FROM_PATH and places them into TO_PATH as they 
% are created.  Only files created after COPY_FILES is running are copied.
% COPY_FILES checks for a change in the number of files in a directory every
% 5 seconds, and if a new file has been created, it copies the most recently
% written file to TO_PATH.  If TO_PATH2 is supplied, it makes a copy in that
% directory as well.

% first make sure that the directories have a trailing slash
from_path=[from_path '/'];
to_path=[to_path '/'];
if nargin==3
  to_path2=[to_path2 '/'];
end

% now make sure that all slashes are appropriate for DOS/WIN95
if ~isunix
  from_path(findstr(from_path,'/'))='\';
  if findstr(from_path,'\\')
    from_path=from_path(1:length(from_path)-1);
  end
  to_path(findstr(to_path,'/'))='\';
  if findstr(to_path,'\\')
    to_path=to_path(1:length(to_path)-1);
  end
  if nargin==3
    to_path2(findstr(to_path2,'/'))='\';
  if findstr(to_path2,'\\')
    to_path2=to_path2(1:length(to_path2)-1);
  end
  end
end

disp('Wait for initialization')
d_old=dir(from_path);
d=d_old;
datemax=max(datenum(char({d.date}')));
disp('Copying files')
while 1

  % first see if the number of files has changed.
  while length(d)==length(d_old)
    pause(5)
    d=dir(from_path);
    d_len=length(d);
  end
  if datenum(char({d(d_len).date}))>datemax
    copy_filename=d(d_len).name;
    datemax=datenum(char({d(d_len).date}'));
	index=d_len;
  else
    [a,ind]=max(datenum(char({d.date}')))
    copy_filename=d(ind).name;
    datemax=datenum(char({d(ind).date}'));
	index=ind;
  end

while d(index).bytes==0
  d=dir(from_path);
  pause(5)
end
pause(5)
d_old=d;
  disp(['copying ' copy_filename])
  if isunix
    [s,m]=unix(['cp ' from_path copy_filename ' ' to_path copy_filename  ]);
    if s==1
      disp([from_path copy_filename ' to ' to_path ' NOT COPIED'])
    end  
  else
    [s,m]=unix(['copy ' from_path copy_filename ' ' to_path  copy_filename ]);
	ddd=dir([from_path copy_filename]);
	if ddd.bytes<50000
	 % sound(sin(1:3000)),pause(.2),sound(sin([1:3000]/2))
	end
if m(9)~='1'
      disp([from_path copy_filename ' to ' to_path ' NOT COPIED'])
    end
  end
  if nargin==3
    if isunix
      [s,m]=unix(['cp ' from_path copy_filename ' ' to_path2  copy_filename ]);
      if s==1
	disp([from_path copy_filename ' to ' to_path2 ' NOT COPIED'])
      end
    else
      [s,m]=unix(['copy ' from_path copy_filename ' ' to_path2  copy_filename ])
      if m(9)~='1'
	disp([from_path copy_filename ' to ' to_path2 ' NOT COPIED'])
      end
    end
  end
end
