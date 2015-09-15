% function copyalladcp(frompath,topath)
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
set_currents_oceanus  

% add error warnings about the paths
if ~exist(frompathbackup)
  error(['The source directory: ' frompathbackup ' can''t be found.  Check',  ...
          'that the machine has been mounted']);
end

if ~exist(topathbackup)
  error(['The source directory: ' topathbackup ' can''t be found. Create',  ...
          ' the directory']);
end


% copy the UHDAS+CODAS data and all of its subdirectories
disp(['At ' datestr(now) ': Copying all of ' frompathbackup])
disp(['to ' topathbackup])
tic
copyfile(frompathbackup,topathbackup)
toc
disp('')


% copy the ADCP data that has been processed by Sasha's code
disp(['At ' datestr(now) ': Copying all of ' wh300copypath])
disp(['to ' wh300savepath])
tic
copyfile(wh300copypath,wh300savepath)
toc

disp(['At ' datestr(now) ': Copying all of ' os75copypath])
disp(['to ' os75savepath])
tic
copyfile(os75copypath,os75savepath)
toc

disp(['At ' datestr(now) ': Copying all of ' os150copypath])
disp(['to ' os150savepath])
tic
copyfile(os150copypath,os150savepath)
toc

