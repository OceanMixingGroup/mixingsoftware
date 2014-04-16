% script: run_backup.m
%
% This is the top-level script for the computer backing up the biosonics data on pequod....
%
% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:42 $ $Author: aperlin $	
% Originally G. Thompson 
% User editable things
%

frompath = '\\pequod\data\dt\data\DT2003\';
% this is the top-level directory in which the biosonics data is
% stored...

topath = '\\seagoer\dataf\data\nh03\biosonics\DT2003';
% this is the top level directory where the biosonics data is backed
% up to....

polltime = 180;
% this approximately how often the daq computer is polled in seconds.
transducerdepth =5;
dx=4;dz=8;
% User NON editable things
%

% Check that the frompath exists...
if ~exist(frompath)
	error(['The source directory: ' frompath ' can''t be found.  Check',  ...
	 'that the machine has been mounted']);
end;

% Check that the topath exists...
if ~exist(topath)
	error(['The source directory: ' topath ' can''t be found. Create',  ...
	' the directory']);
end;

% loop through all directories and subdirectories under the frompath directory
while 1
	subdir = dir(frompath);
	subdir.name;
	% These are the subdirectories that are in the top directory.
	subdir=subdir(3:length(subdir));
	%cut the '.' and '..' from the dir structure
	for loop =1:length(subdir);
		subsubdir = dir([frompath '\' subdir(loop).name]);
		% These are the subdirectories that will be created in the subdir.
		subsubdir=subsubdir(3:length(subsubdir));
		%cut the '.' and '..' from the structure
		fprintf(1,'Polling for new files in %s\n',frompath,'\',subdir.name,'\',subsubdir.name );
		% first thing is to compare the two directory trees and make sure
		% they are identical.  If not, do some copying....
		% We can't automate because of the somewhat annoying naming convention
		s=sprintf('%s',subdir(loop).name);
		for loop2 = 1:length(subsubdir);
			ss=sprintf('%s',subsubdir(loop2).name);
			fromdir = dir([frompath '\',s,'\',ss]);
			fromdir=fromdir(3:length(fromdir));
			%cut the '.' and '..' from the structure
			fromdirname=([frompath '\' ,s, '\' , ss]);
			todir = dir([topath '\',s,'\',ss]);
            todir = todir(3:length(todir));%this is the structure with the file names to be copied
            %cut the '.' and '..' from the structure
			todirname = ([topath '\',s,'\',ss]);
			% files are sequential therefore lets strip the sequence numbers
			% to compare....
			tonum=[];
			fromnum=[];
			for i=1:length(fromdir);
				if fromdir(i).bytes;
					ind = findstr(fromdir(i).name,'.');
					fromnum(i) = str2num(fromdir(i).name(1:ind-1));
				end;
			end;
			if length(todir) == 0;
				else
				for i=1:length(todir);
					ind = findstr(todir(i).name,'.');
					tonum(i) = str2num(todir(i).name(1:ind-1));
				end;
			end;
			[tocopy,inds] = setdiff(fromnum,tonum);%compare the two computers to see what files are different
            %make subdirectory structure same on each computer
            if ~exist(todirname);
                newdir=[s,'\',ss];
			    [status,msg] = mkdir(topath,newdir);
                fprintf(1,'making new dir %s\n',todirname);
                pause (3)
            end;
			% check to make sure that the fromfile is full-sized.                        
            for i=1:length(inds);
				if fromdir(inds(i)).bytes > 0;
					fromname = [fromdirname '\' fromdir(inds(i)).name];
					fprintf(1,'Copying %s\n', fromname);
					[status,msg]=copyfile([fromdirname '\' fromdir(inds(i)).name],...
						[todirname '\']);
				% we want to check the copy...
				%keyboard;
				fin = [todirname '\' fromdir(inds(i)).name];
				thename=fromdir(inds(i)).name;
				day = num2str(subsubdir(loop2).name(4:end));
				fout = sprintf('\\ladoga\data\cruises\ct03\biosonics\\mat\\200110%02d%s.mat',str2num(day),thename(1:4));
				pings=fastreadbio(fin,transducerdepth,dx,dz);
				save(fout,'pings');
				disp('copied mat file');
				pause (3)
			end;
		end;
	end;
for j=1:polltime
	%fprintf(1,'-');
	pause(1); 
end;
end;
end;
