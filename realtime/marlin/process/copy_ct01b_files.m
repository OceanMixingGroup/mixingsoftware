function copy_files(root_from_path,root_to_path)
% function copy_files(root_from_path,root_to_path) copies files
% from subdirectories in root_FROM_PATH and places them into subdirs
% of root_TO_PATH as they 
% are created.  Only files created after COPY_FILES is running are copied.
% COPY_FILES checks for a change in the number of files in a directory every
% 5 seconds, and if a new file has been created, it copies the most recently
% written file to TO_PATH.  If TO_PATH2 is supplied, it makes a copy in that
% directory as well.

% first make sure that the directories have a trailing slash
from_path=[root_from_path '/'];
to_path=[root_to_path '/'];

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
d=dir([from_path ]);
file_time=char({d.date}');
tmp=char({d.name}');
good=find(tmp(:,1)~='.'); bad=find(tmp(:,1)=='.');
[datemax,max_i]=max(datenum(file_time(good,:)));
disp('Copying files')
copy_filename=d(max_i+length(bad)).name
ln=length(copy_filename);
fn=str2num(copy_filename([ln-4 (ln-2):ln]));
prefix=copy_filename(1:ln-5);
suffix=num2str(fn+10000);

while 1
  copy_filename=[prefix suffix(2) '.' ... 
      suffix(3:5)]
  % suffix_next=num2str(str2num(suffix)+1);
  % copy_filename_next=[prefix suffix(2) '.' ... 
  % 			  suffix_next(3:5)];
  [from_path '' copy_filename]
  while ~exist([from_path '' copy_filename],'file');
    for i=1:10; pause(1); end
  end
  d=dir([from_path '' copy_filename]);
  d1.bytes=d.bytes-1;
  while d1.bytes~=d.bytes;
    d=dir([from_path '' copy_filename]);
    for i=1:20; pause(1); end
    d1=dir([from_path '' copy_filename]);
  end
  % this check doesn't work for Win2000!!!
  % d=dir([from_path '' copy_filename]);
  % while d.bytes==0
  %   pause(10)
  %   d=dir([from_path '' copy_filename]);
  % end
  filenum=suffix(2:5);
  disp(['copying ' [from_path copy_filename]])
  [s,m]=unix(['copy ' from_path  copy_filename ' ' to_path ...
      copy_filename ]);
    
    disp(m)
    disp(size(m));
    [b,g]=size(m);
    if g > 9
      if m(9)~='1'
        disp([from_path copy_filename ' to ' to_path2 ' NOT COPIED'])
      end
    else
      disp(size(m))
      disp(' m is less than nine - this is for debugging')
    end   
    
    % [s,m]=unix(['copy ' from_path 'sbd\' prefix filenum '.sbd ' to_path ...
    %			  'sbd\' prefix filenum '.sbd'])
    %if m(9)~='1'
    %      disp([from_path copy_filename ' to ' to_path ' NOT COPIED'])
    %end
    %[s,m]=unix(['copy ' from_path 'dnadp\D' prefix filenum '.adp ' to_path ...
    %			  'dnadp\D' prefix filenum '.adp'])
    %if m(9)~='1'
    %      disp([from_path copy_filename ' to ' to_path ' NOT COPIED'])
    %end
    %[s,m]=unix(['copy ' from_path 'upadp\U' prefix filenum '.adp ' to_path ...
    %			  'upadp\U' prefix filenum '.adp'])
    %  [s,m]=unix(['copy ' from_path 'sbd\' prefix filenum '.sbd ' to_path ...
    %			  'sbd\' prefix filenum '.sbd'])
    
    
    %	ddd=dir([from_path copy_filename]);
    %if m(9)~='1'
    %      disp([from_path copy_filename ' to ' to_path ' NOT COPIED'])
    %end
    suffix=num2str(str2num(suffix)+1);
    
  end
  