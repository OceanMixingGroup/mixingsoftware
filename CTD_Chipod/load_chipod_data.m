function big=load_chipod_data(the_path,time_range,suffix,isbig)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function big=load_chipod_data(the_path,time_range,suffix,isbig)
%
% Load chipod data for a specified time range. If time range spans multiple
% chipod files, get data from both and combine.
%
% INPUT
% the_path   : Path to folder containing chipod data files
% time_range : Time range of ctd profile (datenum)
% suffix     : Suffix for chipod filenames (usually the chipod SN)
% isbig      : Specify if 'big' chipod (data structure is different)
%
% OUTPUT
% big        : Structure with chipod data for this time range
%
% Part of CTD_chipod software in OSU 'mixingsoftware' github repository.
%
% Dependencies:
% calls mixingsoftware/adcp/mergefields_jn.m
% notes:
%
% AP 24 Mar - need to increase t_extra to find good chi files?
%
% Original - J. Nash, J. Marion?
% Comments and updates by A. Pickering
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

if nargin<4
    isbig=1; % presume it is a big chipod
end


the_files=dir([the_path '/*.' suffix]);
%t_extra=2;%
t_extra=24;% AP
if isbig==1
    t_extra=24;
end
nfiles=length(the_files);
big=[];
fnamelist={} ; % list of chipod files for this time range
fcount=1;
for a=1:nfiles
    a;%
    fname=the_files(a).name;
    time_inds=findstr(fname,'.')+[-8:-1];
    file_time=fname(time_inds);
    
    %    if datenum(file_time,'yymmddhh')>(time_range(1)-t_extra/24) & datenum(file_time,'yymmddhh')<(time_range(2)+t_extra/24)
    if datenum(file_time,'yymmddhh')>(time_range(1)-t_extra/24) && datenum(file_time,'yymmddhh')<(time_range(2))% AP start time of file has to be before end of time_range...
        
        % we've got the right file, so let's load it.
        fname=fullfile(the_path,the_files(a).name);
        %        disp('found a file')
        
        % save the filename
        fnamelist{fcount}=the_files(a).name;
        fcount=fcount+1;
        
        try
            if isbig
                [data head]=raw_load_chipod(fname);
                chidat.datenum=data.datenum;
                len=length(data.datenum);
                if mod(len,2)
                    len=len-1; % for some reason datenum is odd!
                end
                chidat.T1=makelen(data.T1(1:(len/2)),len);
                chidat.T1P=data.T1P;
                chidat.T2=makelen(data.T2(1:(len/2)),len);
                chidat.T2P=data.T2P;
                chidat.AX=makelen(data.AX(1:(len/2)),len);
                chidat.AY=makelen(data.AY(1:(len/2)),len);
                chidat.AZ=makelen(data.AZ(1:(len/2)),len);
            else
                % its a minichipod
                
                try
                    [out,counter]=load_mini_chipod(fname);
                catch
                    try
                        [out,counter]=load_mini_chipod(fname,8400);
                    catch
                    end
                end
                chidat.datenum=counter;
                chidat.T1=out(:,2);
                chidat.T1P=out(:,1);
                
                %~~ Sometimes AX/AZ are wired differently; AZ should always
                %be larger than AX because it contains g
                clear A1 A2
                A1=3*out(:,3);
                A2=3*out(:,4);
                if nanmean(A1)>nanmean(A2)
                    chidat.AX=A2;
                    chidat.AZ=A1;
                elseif nanmean(A1)<nanmean(A2)
                    chidat.AX=A1;
                    chidat.AZ=A2;
                end
                %~~
                
            end
            big=mergefields_jn(big,chidat,1,1);
        catch
        end
        %	else
        % do nothing.
    else
        %        disp('didnt find any files in time range');
    end
    
end

if isempty(big)
    big.datenum=NaN;
    big.fname='Did not find any files';
end

%datestr([big.datenum(1) big.datenum(end)])
ginds=find(big.datenum>time_range(1) & big.datenum<time_range(2));
fnames=fieldnames(big);
for a=1:length(fnames)
    big.(fnames{a})=big.(fnames{a})(ginds);
end


big.MakeInfo=['Made ' datestr(now) ' w/ ' mfilename ' in ' version];
% also save name of chi file data is from - AP
big.chi_files=fnamelist;

doplots=0;
if doplots
    
    figure(77);clf
    ax1=subplot(311)
    plot(big.datenum,big.T1);
    title(datestr(mean(chidat.datenum)))
    ylabel('T1')
    axis tight
    xlim(time_range)
    datetick('x')
    %    kdatetick
    
    ax2=subplot(312)
    plot(big.datenum,big.T1P);
    axis tight
    ylabel('T1P')
    xlim(time_range)
    datetick('x')
    %   kdatetick
    
    ax3=subplot(313)
    plot(big.datenum,big.AX,big.datenum,big.AZ);
    axis tight
    ylabel('A')
    xlim(time_range)
    legend('Ax','Az','location','best')
    datetick('x')
    %  kdatetick
    linkaxes([ax1 ax2 ax3],'x')
    
end

%%