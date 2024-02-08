%This script is used to merge the header and raw file
%of the chipod raw data which do not have the header prepended
%on them in the first place.
clear all;
%Call the the header to want to merge
hname = '\\ganges.ceoas.oregonstate.edu\data\chipod\Pirata22\headers\ChiPod3_621_hdr.500';
fid=fopen(hname,'r');
H = fread(fid); %reads the header

%dir the location of the location of raw files (which do not have the
%header).


%path of the raw files folder
pathname = 'C:\Users\Kerry\Documents\621\';
nm = dir(pathname);
for i = 3:length(nm) %the files that need to be merged
fid2 = fopen([pathname nm(i).name],'r'); %open the raw files
D = fread(fid2); %read them
%create a new directory location to save the raw files with header
%pre-pended on them.
fid3 = fopen(['C:\Users\Kerry\Documents\621b\' nm(i).name],'w');
% display(nm(i).name);
display([num2str(i-2) ' out of ' num2str(length(nm)-2)]);

A = cat(1,H,D); %concatenate header and raw file
fwrite(fid3,A); %write to the file in the directory
% delete(nm(i).name);
fclose(fid2);%close the file identifiers
fclose(fid3);
clear fid2 fid3 A D; %clear the temporary variables.

%clear the arrays and loop it.
end

