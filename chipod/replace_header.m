clear all;
xpod = [526];

for j = 1:length(xpod) 
    fidh = fopen(['\\ganges.ceoas.oregonstate.edu\data\chipod\Pirata24\header\ChiPod3_',num2str(xpod(j)),'_hdr.500'],'r');
    %open good header
    header = fread(fidh);

    %path of the raw files folder containing bad header
    pathname = ['\\ganges.ceoas.oregonstate.edu\data\chipod\Pirata24\no_flow_test\',num2str(xpod(j)),'\raw\'];
    nm = dir(pathname);

    for i = 3:length(nm) %the files that need to be merged
    % for i = 4:4
        display([num2str(i-2) ' out of ' num2str(length(nm)-2) ' ' num2str(xpod(j))]); %status of file being processed
        fidr = fopen([pathname nm(i).name],'r'); %open the raw files containing bad header
        fseek(fidr,8192,'bof'); %move to end of the bad header location of the raw file
        raw = fread(fidr); %read just the raw data from 8193 to end

%create a new directory location to save the raw files with header
%pre-pended on them.
        fidn = fopen(['\\ganges.ceoas.oregonstate.edu\data\chipod\Pirata24\no_flow_test\',num2str(xpod(j)),'\' [nm(i).name]],'w');
        A = cat(1,header,raw); %concatenate header and raw file
        fwrite(fidn,A); %write to the file in the directory
        fclose(fidr);%close the file identifiers
        fclose(fidn);

        clear fidn fidr A raw; %clear the temporary variables.
        %clear the arrays and loop it.
    end
clear fidh header i;
end
