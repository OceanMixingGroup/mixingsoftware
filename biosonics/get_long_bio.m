% function[pings]=get_long_bio(pname,ts,tf,transducerdepth,horizontalsubsample,verticalsubsample,new)
%
%   function to retrieve BioSonics image data between time endpoints 
%   ts, tf this concatenates files to the include endpoints and then 
%   cut to the correct length
%
%       pname - pathname to directory with BioSonics data files
%           OLD BioSonics filenaming convention used so
%           we just have to give location of DT* directory
%           i.e. if we are looking for data from 2001 that exists in
%           '\\Ladoga\datad\cruises\tx01\biosonics\DT2001\SEP\DAY29\*.dt4'
%           specify pname = ''\\Ladoga\datad\cruises\tx01\biosonics\'
%           NEW Biosonics filename convention does not create subdirectories 
%           corresponding to year/month/day, instead puts all
%           files into the root data directory and makes 
%           filenames in theformat 20060310_132953.dt4
%
%       ts - start time in datenum format
%       tf - end time in datenum format
%       trd - transducer depth
%       horizontalsubsample - horizontal subsample
%       verticalsubsample - vertical subsample
%       horizontalsubsample=40; verticalsubsample=10 makes 10 MB file for 2.5 days
% ********* BEWARE - don't try to make too long a data file with this routine
%                   as of 11/2001 we don't have enough memory to deal with
%                   more than about 20 mins of data
% DO NOT WORK PROPERLY IF ts AND tf ARE IN DIFFERENT MONTHS
function [pings]=get_long_bio(pname,ts,tf,transducerdepth,horizontalsubsample,verticalsubsample,new)

if isunix
  scr='/';
else
  scr='\';
end
  
if nargin<7
  new=0; 
end
if nargin<6
    verticalsubsample=1; % no subsample
end
if nargin<5
    horizontalsubsample=1; % no subsample
end
if nargin<4
    transducerdepth=0; % no subsample
end
clear pings

pings.head=[];
pings.depth=[];
pings.sample=[];
pings.systime=[];
pings.datenum=[];
pings.lat=[];
pings.lon=[];
pings.navtime=[];
% organise pathnames
% start times
ys=datestr(ts,10);
ms=datestr(ts,3);
ms2=datestr(ts,'mm');
ds=datestr(ts,7);
hmss=datestr(ts,13);
hrs=hmss(1:2);
mns=hmss(4:5);
secs=hmss(7:8);
if new==0
    timechk_s=str2num([hrs mns secs '00']);
else
    timechk_s=str2num([ys ms2 ds hrs mns secs]);
end
% end times
yf=datestr(tf,10);
mf=datestr(tf,3);
mf2=datestr(tf,'mm');
df=datestr(tf,7);
hmsf=datestr(tf,13);
hrf=hmsf(1:2);
mnf=hmsf(4:5);
secf=hmsf(7:8);
if new==0
    timechk_f=str2num([hrf mnf secf '00']);
else
    timechk_f=str2num([yf mf2 df hrf mnf secf]);
end
% number of days to read
ndays=floor(tf)-floor(ts)+1;
if new==0 % old filename standard
    if ndays>1  % we have to look at least at 2 directories
        ndir=ndays;
        nds=str2num(ds);
        ndf=str2num(df);
        % get file information
        for idir=1:ndir
            if ndf>nds % that means that data ends in the same month
                day=nds+idir-1;
                bname(idir,:)=(['DT',ys,scr,ms,scr,'DAY',sprintf('%02d',day),scr]);
            else
                if idir<=ndir-ndf
                    day=nds+idir-1;
                    bname(idir,:)=(['DT',ys,scr,ms,scr,'DAY',sprintf('%02d',day),scr]);
                else
                    day=idir-(ndir-ndf);
                    bname(idir,:)=(['DT',yf,scr,mf,scr,'DAY',sprintf('%02d',day),scr]);
                end
            end
            lp=length([pname bname(idir,:)]);
            pathname(idir,1:lp)=[pname bname(idir,:)];
            clear flist a;
            flist=dir([pathname(idir,:),'*.dt4']);
            for i=1:length(flist)
                a(i,:)=str2num(flist(i).name(1:8));
            end
            if (idir==1)
                ids=find(a > timechk_s);
                if isempty(ids)
                    ids=length(a);
                end
            elseif idir==ndir
                ids=find(a < timechk_f);
                if (length(ids)<=1)
                    ids=1;
                end
            else
                ids=[1:length(a)]';
            end
            if ids~=1
                ids=[ids(1)-1 ids']';
            end
            % open files and make data set
            for id=ids(1):1:ids(end)
                fname=([pathname(idir,1:lp),flist(id).name(1:8),'.dt4'])
                png=readbio(fname,transducerdepth,horizontalsubsample,verticalsubsample);
                %find zeros and negative values before computing logs
                idl= png.sample <= 0;
                png.sample(idl)=1e-3;
                pings.head=[pings.head png.head];
                if size(pings.sample,1)<size(png.sample,1) && size(pings.sample,1)>0
                    ddp=size(png.sample,1)-size(pings.sample,1);
                    pings.sample(end+1:end+ddp,:)=NaN;
                    pings.depth=png.depth;
                elseif size(pings.sample,1)>size(png.sample,1)
                    ddp=size(pings.sample,1)-size(png.sample,1);
                    png.sample(end+1:end+ddp,:)=NaN;
                else
                    pings.depth=png.depth;
                end
%                 pings.depth=png.depth;
%                 if size(png.sample,1)>size(pings.sample,1)
%                     pings.sample=[pings.sample;...
%                         ones(size(png.sample,1)-size(pings.sample,1),size(pings.sample,2))*NaN];
%                 elseif size(png.sample,1)<size(pings.sample,1)
%                     pings.sample=pings.sample(1:size(png.sample,1),:);
%                 end
                pings.sample=[pings.sample png.sample];
                pings.systime=[pings.systime png.systime];
                pings.datenum=[pings.datenum png.datenum];
                pings.lat=[pings.lat png.lat];
                pings.lon=[pings.lon png.lon];
                pings.navtime=[pings.navtime png.navtime];
                clear png
                % retain only data from time interval
                idx=find(pings.datenum > ts & pings.datenum < tf);
                pings.sample=pings.sample(:,idx);
                pings.systime=pings.systime(idx);
                pings.datenum=pings.datenum(idx);
                pings.lat=pings.lat(idx);
                pings.lon=pings.lon(idx);
                pings.navtime=pings.navtime(idx);
            end
        end
    else        % we only have to look at 1 directory
        ndir=1;
        bname=(['DT',ys,scr,ms,scr,'DAY',ds,scr]);
        pathname=[pname bname];
        % get file information
        flist=dir([pathname,'*.DT4']);
        for i=1:length(flist)
            a(i,:)=str2num(flist(i).name(1:8));
        end
        id1=find((a-timechk_s) < 0, 1, 'last' ); % find 1st file
        if isempty(id1); id1=1; end
        id2=find((a-timechk_f) < 0, 1, 'last' ); % find last file
        if isempty(id2); id2=length(flist); end
        ids=[id1:1:id2];
        % open files and make data set
        for id=ids(1):1:ids(end)
            fname=([pathname,flist(id).name(1:8),'.dt4'])
            png=readbio(fname,transducerdepth,horizontalsubsample,verticalsubsample);
            %find zeros and negative values before computing logs
            idl= png.sample <= 0;
            png.sample(idl)=1e-3;
            pings.head=[pings.head png.head];
            if size(pings.sample,1)<size(png.sample,1) & size(pings.sample,1)>0
                ddp=size(png.sample,1)-size(pings.sample,1);
                pings.sample(end+1:end+ddp,:)=NaN;
                pings.depth=png.depth;
            elseif size(pings.sample,1)>size(png.sample,1)
                ddp=size(pings.sample,1)-size(png.sample,1);
                png.sample(end+1:end+ddp,:)=NaN;
            else
                pings.depth=png.depth;
            end
            pings.sample=[pings.sample png.sample];
            pings.systime=[pings.systime png.systime];
            pings.datenum=[pings.datenum png.datenum];
            pings.lat=[pings.lat png.lat];
            pings.lon=[pings.lon png.lon];
            pings.navtime=[pings.navtime png.navtime];
            clear png
            % retain only data from time interval
            idx=find(pings.datenum > ts & pings.datenum < tf);
            pings.sample=pings.sample(:,idx);
            pings.systime=pings.systime(idx);
            pings.datenum=pings.datenum(idx);
            pings.lat=pings.lat(idx);
            pings.lon=pings.lon(idx);
            pings.navtime=pings.navtime(idx);
        end
    end
else % new filename standard
    pathname=pname;
    % get file information
    flist=dir([pathname,'*.dt4']);
    for i=1:length(flist)
        a(i,:)=str2num([flist(i).name(1:8) flist(i).name(10:15)]);
    end
    id1=find((a-timechk_s) < 0, 1, 'last' ); % find 1st file 
    if isempty(id1); id1=1; end
    id2=find((a-timechk_f) < 0, 1, 'last' ); % find last file
    if isempty(id2); id2=length(flist); end
    ids=[id1:1:id2];
    % open files and make data set
    for id=ids(1):1:ids(end)
        fname=([pathname,flist(id).name])
        png=readbio(fname,transducerdepth,horizontalsubsample,verticalsubsample);
%         png=readbio(fname,transducerdepth,horizontalsubsample,verticalsubsample);
        %find zeros and negative values before computing logs
        idl= png.sample <= 0;
        png.sample(idl)=1e-3;
        pings.head=[pings.head png.head];
        if size(pings.sample,1)<size(png.sample,1) & size(pings.sample,1)>0
            ddp=size(png.sample,1)-size(pings.sample,1);
            pings.sample(end+1:end+ddp,:)=NaN;
            pings.depth=png.depth;
        elseif size(pings.sample,1)>size(png.sample,1)
            ddp=size(pings.sample,1)-size(png.sample,1);
            png.sample(end+1:end+ddp,:)=NaN;
        else
            pings.depth=png.depth;
        end
        pings.sample=[pings.sample png.sample];
%         pings.systime=[pings.systime png.systime];
        pings.datenum=[pings.datenum png.datenum];
        pings.lat=[pings.lat png.lat];
        pings.lon=[pings.lon png.lon];
        pings.navtime=[pings.navtime png.navtime];
%         png
        clear png
    end
    % retain only data from time interval
    idx=find(pings.datenum > ts & pings.datenum < tf);
    pings.sample=pings.sample(:,idx);
%     pings.systime=pings.systime(idx);
    pings.datenum=pings.datenum(idx);
    pings.lat=pings.lat(idx);
    pings.lon=pings.lon(idx);
    pings.navtime=pings.navtime(idx);
end

