%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% ReadRTI_ENSfiles.m
%
% My attempt to directly read the binary .ENS files from the RTI ADCP into
% Matlab.
%
% Figured out how to parse different ensembles and variables etc., but was
% not successful at reading the actual data in each. There seems to be 4
% times the number of data elements that there should be; I think this has
% something to do with each data value being a 4byte (32bit) integer, but
% somehow I am reading it in a 4 separate values?
%
% Info on the structure of the binary file is give in the Users' guide
%
% A. Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear;close all;clc

cd /Users/Andy/Desktop

fid=fopen('01470000000000000000000000000175_A0000002_1.ens')
str=fread(fid,inf);

keep_going=1;

%str(1:32) % RTI header
%str(33:52) % 1st matlab header

ind_mat_hdr=33:52;
mycount=1
wh_ens=1

while keep_going==1
    
    if mycount>1
        ind_mat_hdr=ind_dat_end+1 : ind_dat_end + 20;
    end
    
    %    str(ind_mat_hdr);
    
    if str(ind_mat_hdr(1))==10
        NbytesperInt=4;
    else
        disp('???')
        str(ind_mat_hdr(1))
    end
    %    NbytesperInt=4;
    
    clear Nbins Nbeams Nbytesname Nbytesdat
    Nbins=str(ind_mat_hdr(5));
    Nbeams=str(ind_mat_hdr(9));
    Nbytesname=str(ind_mat_hdr(17)); % # bytes in matrix name
    % Nbytesdat=NbytesperInt*Nbeams*Nbins;
    Nbytesdat=NbytesperInt*Nbeams*Nbins;
    %
    ind_ensname=ind_mat_hdr(end)+1:ind_mat_hdr(end) +Nbytesname;
    Ensname=char(str(ind_ensname))' % matrix name
    %
    ind_datstart=ind_mat_hdr(end)+1 +Nbytesname;
    ind_dat_end=ind_mat_hdr(end) +Nbytesname  + Nbytesdat;
    %
    
    
    %    size(dat)
    %~~ Now actually read the data
    %    eval([Ensname '=dat'])
    
    %~~ E00001 - beam velocities [single precision floating point]
    if strcmp(char(str(ind_ensname(end-2))),'0') && strcmp(char(str(ind_ensname(end-1))),'1')
        clear dat dat2
        %    dat=str(ind_datstart : ind_dat_end);
        status=fseek(fid,0,'bof');
        status=fseek(fid,ind_datstart,'cof');
        E00001=fread(fid,Nbytesdat,'single');
        disp('Reading Beam Velocities')
    end
    
    %~~ E00002 - Instrument velocities [single precision floating point]
    if strcmp(char(str(ind_ensname(end-2))),'0') && strcmp(char(str(ind_ensname(end-1))),'2')
        clear dat dat2
        %    dat=str(ind_datstart : ind_dat_end);
        status=fseek(fid,0,'bof');
        status=fseek(fid,ind_datstart,'cof');
        E00002=fread(fid,Nbytesdat,'single');
        disp('Reading Inst Velocities')
    end
    
    %~~ E00003 - Earth velocities [single precision floating point]
    if strcmp(char(str(ind_ensname(end-2))),'0') && strcmp(char(str(ind_ensname(end-1))),'3')
        clear dat dat2
        %    dat=str(ind_datstart : ind_dat_end);
        status=fseek(fid,0,'bof');
        status=fseek(fid,ind_datstart,'cof');
        E00003=fread(fid,Nbytesdat,'single');
        disp('Reading earth Velocities')
    end
    
    %~~ E00004 - amplitudes [single precision floating point]
    if strcmp(char(str(ind_ensname(end-2))),'0') && strcmp(char(str(ind_ensname(end-1))),'4')
        clear dat dat2
        %    dat=str(ind_datstart : ind_dat_end);
        status=fseek(fid,0,'bof');
        status=fseek(fid,ind_datstart,'cof');
        E00004=fread(fid,Nbytesdat,'single');
        disp('Reading amplitudes')
    end
    
    %~~ E00005 - correlation [single precision floating point]
    if strcmp(char(str(ind_ensname(end-2))),'0') && strcmp(char(str(ind_ensname(end-1))),'5')
        clear dat dat2
        %    dat=str(ind_datstart : ind_dat_end);
        status=fseek(fid,0,'bof');
        status=fseek(fid,ind_datstart,'cof');
        E00005=fread(fid,Nbytesdat,'single');
        disp('Reading correlations')
    end
    
    %~~ E00006 - good beam pings [32 bit integer]
    if strcmp(char(str(ind_ensname(end-2))),'0') && strcmp(char(str(ind_ensname(end-1))),'6')
        clear dat dat2
        %    dat=str(ind_datstart : ind_dat_end);
        status=fseek(fid,0,'bof');
        status=fseek(fid,ind_datstart,'cof');
        E00006=fread(fid,Nbytesdat,'int32');
        disp('Reading good beam pings')
        %pause
    end
    
    %~~ E00007 - good earth pings [32 bit integer]
    if strcmp(char(str(ind_ensname(end-2))),'0') && strcmp(char(str(ind_ensname(end-1))),'7')
        clear dat dat2
        %    dat=str(ind_datstart : ind_dat_end);
        status=fseek(fid,0,'bof');
        status=fseek(fid,ind_datstart,'cof');
        E00007=fread(fid,Nbytesdat,'int32');
        disp('Reading good beam pings')
        % pause
    end
    
    
    %~~ E00008 - ensenmble data [32 bit integer]
    if strcmp(char(str(ind_ensname(end-2))),'0') && strcmp(char(str(ind_ensname(end-1))),'8')
        disp('aha2')
        status=fseek(fid,0,'bof');
        status=fseek(fid,ind_datstart,'cof');
        E0008=fread(fid,Nbytesdat,'uint64');
        %      dat=fread(fid,Nbytesdat,'single');
        %        dat(23)
        %  pause
    end
    
    %~~ E00009 - ancillary data [single precision floating point]
    if strcmp(char(str(ind_ensname(end-2))),'0') && strcmp(char(str(ind_ensname(end-1))),'8')
        disp('aha2')
        status=fseek(fid,0,'bof');
        status=fseek(fid,ind_datstart,'cof');
        %        dat=fread(fid,Nbytesdat,'uint64');
        E00009=fread(fid,Nbytesdat,'single');
        %        dat(23)
        %pause
    end
    
    if strcmp(char(str(ind_ensname(end-2))),'1') && strcmp(char(str(ind_ensname(end-1))),'4')
        
        keep_going=0; % only do 1st ensemble now for testing
        
        disp('end of ensemble reached')
        %    break
        ind_dat_end=ind_dat_end+36;
        wh_ens=wh_ens+1;
    end
    
    if ind_dat_end(end)+1>=length(str)
        keep_going=0;
    end
    
    mycount=mycount+1;
    
    %    pause
    
end


%%