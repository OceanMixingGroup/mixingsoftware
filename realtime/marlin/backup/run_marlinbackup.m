function run_marlinbackup(frompath,topath,dataprefix);
% function run_marlinbackup(frompath,topath,dataprefix);
% This is the top-level script for the back-up computer....
%
% frompath = '//flipper/datad/Home/MarlChamDAQ';
% this is the top-level directory in which the Marlin data is
% stored...
%topath = 'c:/jklymak/HOME/test';
% this is the top level directory where the Marlin data is backed
% up to....

% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:49 $ $Author: aperlin $	

%dataprefix='lab';
% this is the prefix of the datafiles

polltime = 15;
% this approximately how often the daq computer is polled in seconds.

% Check that the frompath exists...
if ~exist(frompath)
  error(['The source directory: ' frompath ' can''t be found.  Check',  ...
          'that the machine has been mounted']);
end;
if ~exist(topath)
  error(['The source directory: ' topath ' can''t be found. Create',  ...
	 ' the directory']);
end;
while 1
  fprintf(1,'Polling for new files in %s\n',frompath );
  % first thing is to compare the two directory trees and make sure
  % they are identical.  If not, do some copying....
  % We can't automate because of the annoying naming convention

  % MarlCham files
  fromp = [frompath '/Marlin/'];
  top = [topath '/Marlin/'];
  fromdir = [fromp dataprefix '*'];
  todir = [top dataprefix '*'];
  % files are sequential therefore lets strip the sequence numbers
  % to compare....
  d=dirdiff(fromdir,todir);
  copyall(fromp,top,d);
  

  % Upadp files
  fromp = [frompath '/Upadp/'];
  top = [topath '/Upadp/'];
  fromdir = [fromp 'U' dataprefix '*.adp'];
  todir = [top 'U' dataprefix '*.adp'];
  % files are sequential therefore lets strip the sequence numbers
  % to compare....
  d=dirdiff(fromdir,todir);
  copyall(fromp,top,d);
  
  % Dnadp files
  fromp = [frompath '/Dnadp/'];
  top = [topath '/Dnadp/'];
  % check for the existence of top...  
  fromdir = [fromp 'D' dataprefix '*.adp'];
  todir = [top 'D' dataprefix '*.adp'];
  % files are sequential therefore lets strip the sequence numbers
  % to compare....
  d=dirdiff(fromdir,todir);
  copyall(fromp,top,d);
  
  % Seabird files
  fromp = [frompath '/Sbd/'];
  top = [topath '/Sbd/'];
  % check for the existence of top...  
  fromdir = [fromp dataprefix '*.sbd'];
  todir = [top dataprefix '*.sbd'];
  % files are sequential therefore lets strip the sequence numbers
  % to compare....
  d=dirdiff(fromdir,todir);
  copyall(fromp,top,d);

  % Adv files
  fromp = [frompath '/ADV/'];
  top = [topath '/ADV/'];
  % check for the existence of top...  
  fromdir = [fromp dataprefix '*.adv'];
  todir = [top dataprefix '*.adv'];
  % files are sequential therefore lets strip the sequence numbers
  % to compare....
  d=dirdiff(fromdir,todir);
  copyall(fromp,top,d);
  

  
  fprintf(1,'\nWaiting %d seconds to poll again; on file: %d\n',...
	  polltime,polltime);
  for j=1:polltime
    fprintf(1,'-');
    pause(1); 
  end;
  fprintf('\n');
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function copyall(fromdir,todir,names);

  for i=1:length(names);
    from = [fromdir '/' names{i}];
    to = [todir '/'];
    fprintf(1,'Copying %s to %s\n',from,to);
    
    
    [status,msg]=copyfile(from,to);
    if ~status
      error(msg);
    end;
  end;
  




