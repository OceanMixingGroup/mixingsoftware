function [status,msg]=copyfilecareful(from,to);
% 
% function [status,msg]=copyfilecareful(from,to);
% 
%  This is a slight exageration of copyfile.m that runs diff.exe on
%  the two files after the copy and then retries the copy up to 10
%  times.  If it fails, it errors...
%
  bad = 1;
  num = 0;
  while bad
    [status,msg]=copyfile(from,to);
    if status
      error(msg);
    end;
%    bad=dos(['diff ' from ' ' to]); % note that "diff" returns 0 if
                                    % the two files are the same....
    num = num+1;
    if num>10;
      error(['Cannot confirm that ' from ' was successfully copied' ...
		    ' to ' to])
    end;
    bad=0;
  end;
  if ~bad
    fprintf(1,'Sucessfully compared %s to %s\n',from,to); 
  end;
  
  
