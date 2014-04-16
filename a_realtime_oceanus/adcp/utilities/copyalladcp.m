function copyalladcp(frompath,topath)
%
% copyalladcp(frompath,topath)
%
% This function is meant to be called by: timer_adcpbackup_yq14
%
% This function copies all of the ADCP data from the ship's computer to a
% local computer. Right now it just recopies the entire folder every time.
% For now, this is okay. Possily, if a cruise gets really long, it should
% be rewritten so that the code checks the dates of all of the files and
% then only backs up the ones that have changed since the last backup.
% However, since the directory structure of the ADCP data is so complicated
% AND since the ADCP data only needs to be copied about every two hours AND
% because a day's worth of data takes about 15 seconds to copy, I am
% totally okay with not making this code more sleek. Time is of the essence
% right now. Possibly I will want to rewrite this while on the equator
% cruise in Fall 2014. A good reference will be: run_adcp_backup.
%
% Sally Warner, January 2014
%
%
%
%
  

% add error warnings about the paths
if ~exist(frompath)
  error(['The source directory: ' frompath ' can''t be found.  Check',  ...
          'that the machine has been mounted']);
end

if ~exist(topath)
  error(['The source directory: ' topath ' can''t be found. Create',  ...
          ' the directory']);
end


% copy the folder and all of its subdirectories
disp(['At ' datestr(now) ': Copying all of ' frompath])
disp(['to ' topath])
tic
copyfile([frompath],[topath])
toc
disp('')