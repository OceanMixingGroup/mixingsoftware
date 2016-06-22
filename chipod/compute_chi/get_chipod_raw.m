function [data,head]=get_chipod_raw(dpath,dpl,unit,ts,tf,time_offset)
%
% [data,head]=get_chipod_raw(dpath,dpl,unit,ts,tf,time_offset)
%
% get raw chipod data and create raw data structure from time ts to time tf
%
% dpath - data directory, i.e. '\\ganges\data\chipod\tao_sep05\'
% dpl - deployment name (string), i.e. 'eq08'
% unit - input number, (integer) i.e. 305
% ts - start time, Matlab format
% tf - finish time, Matlab format
% time_offset - time correction for timestamp. Default value is 0.
%   $Revision: 1.15 $  $Date: 2013/01/07 18:47:59 $
% ts=ts-1/86400;
% tf=tf+1/86400;


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% run independently for debugging
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dpath = '~/ganges/data/chipod/TAO11_140/';
% dpl = 'tao11_140';
% unit = 324;
% ts = datenum(2011,9,3,0,0,0);
% tf = datenum(2012,4,9,14,0,1);
% time_offset = (datenum(2038,08,17,7,31,0) - datenum(2011,09,01,21,15,0))*3600*24;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% 1. comment/uncomment line 1
%%%%%%% 2. comment/uncomment nargin stuff
%%%%%%% 3. uncomment/comment input stuff
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('get_chipod_raw')

%% make sure input is correct

if nargin<6
    time_offset=0;
end

%% get the correct directory, time and file name

pname=[dpath,filesep,'data',filesep,num2str(unit),filesep];
dd=dir(pname);
ip=strfind(dd(3).name,'.');ip=ip(end);
preffix=dd(3).name(1:ip-9);
kk=0;

for ii=1:length(dd)
    if ~dd(ii).isdir
        kk=kk+1;
        tmp=dd(ii).name;
        dfs(kk,:)= tmp(ip-8:ip-1);
    end
end

dfsnum=datenum(dfs,'yymmddHH');
ts1=ts-datenum(0,0,0,0,0,time_offset);
tf1=tf-datenum(0,0,0,0,0,time_offset);

id=find(dfsnum<=ts1,1,'last');
if isempty(id); id=1; end
fnam=[pname,preffix,dfs(id(1),:),'.',num2str(unit)];


%% load the correct file
% dat is the data from each file that has been loaded
% dt is the concatenation of all loaded files

if exist(fnam,'file') == 2
    [dat,head]=raw_load_chipod(fnam);
    
    % if the raw data file needs to be cleaned, do it here
    if exist(['clean_raw_chipod_' dpl '.m'],'file')
        [dat,head]=eval(['clean_raw_chipod_' dpl '(dat,head,unit)']);
    end
    names=fieldnames(dat);
    % change orientation of variables
    for ii=1:length(names)
        dt.(char(names(ii)))=dat.(char(names(ii)))';
    end
else
    display('no file')
end

% load additional files if necessary to fill the desired time range
idd=id-1;
while dt.datenum(1)>ts1 && idd>0
    fnam=[pname,preffix,dfs(idd,:),'.',num2str(unit)];
    if exist(fnam,'file') == 2
        [dat,head]=raw_load_chipod(fnam);
        if exist(['clean_raw_chipod_' dpl '.m'],'file')
            [dat,head]=eval(['clean_raw_chipod_' dpl '(dat,head,unit)']);
        end
        names=fieldnames(dat);
        for ii=1:length(names)
            dt.(char(names(ii)))=[dat.(char(names(ii)))' dt.(char(names(ii)))];
        end
    end
    idd=idd-1;
end
idd=id+1;
while dt.datenum(end)<tf1 && idd<size(dfs,1)
    fnam=[pname,preffix,dfs(idd,:),'.',num2str(unit)];
    if exist(fnam,'file') == 2
        [dat,head]=raw_load_chipod(fnam);
        if exist(['clean_raw_chipod_' dpl '.m'],'file')
            [dat,head]=eval(['clean_raw_chipod_' dpl '(dat,head,unit)']);
        end
        names=fieldnames(dat);
        for ii=1:length(names)
            dt.(char(names(ii)))=[dt.(char(names(ii))) dat.(char(names(ii)))'];
        end
    end
    idd=idd+1;
end

%% if there is no data, return to get_chipod_cals with empty datafiles
if ~exist('dt','var')
    data=[];head=[];
    return
end

%% interpolate data to correct time steps between ts and tf

if ~isempty(dt.datenum)
    dt.datenum=dt.datenum+datenum(0,0,0,0,0,time_offset);
    idt=find(dt.datenum>=ts & dt.datenum<=tf);
    if isempty(idt)
        data=[];head=[];
        return
    end
    if any(head.version==[16 32 48 64])
        idslow=floor(idt(1)/10)+1:floor((1+idt(end))/10);
        idslow2=floor(idt(1)/120)+1:floor((1+idt(end))/120);
        idt=idslow(1)*10-9:(1+idslow(end))*10-10;
        if isfield(head.irep,'T1P')
            idfast=[idt(1)*head.irep.T1P:(1+idt(end))*head.irep.T1P-1]-...
                head.irep.T1P+1;
        elseif isfield(head.irep,'S1')
            idfast=[idt(1)*head.irep.S1:(1+idt(end))*head.irep.S1-1]-...
                head.irep.S1+1;
        elseif  isfield(head.irep,'AX')
            idfast=[idt(1)*head.irep.AX:(1+idt(end))*head.irep.AX-1]-...
                head.irep.AX+1;
        elseif  isfield(head.irep,'W1')
            idfast=[idt(1)*head.irep.W1:(1+idt(end))*head.irep.W1-1]-...
                head.irep.W1+1;
        end
        for i=1:length(names)
            if length(dat.datenum)==length(dat.(char(names(i))))
                data.(char(names(i)))=dt.(char(names(i)))(idt);
            elseif length(dat.datenum)==10*length(dat.(char(names(i))))
                data.(char(names(i)))=dt.(char(names(i)))(idslow);
            elseif length(dat.datenum)==120*length(dat.(char(names(i))))
                data.(char(names(i)))=dt.(char(names(i)))(idslow2);
            else
                data.(char(names(i)))=dt.(char(names(i)))(idfast);
            end
        end
        
    elseif head.version == 80 % RAMA13

    % get index that matches T1, T2, AX, AY, AZ, W1, W, etc
        idslow=floor(idt(1)/head.oversample(head.sensor_index.T1)) + ...
            1:floor((1+idt(end))/head.oversample(head.sensor_index.T1));
        % get index that matches CMP
        idslow2=floor(idt(1)/head.oversample(head.sensor_index.CMP)) + ...
            1:floor((1+idt(end))/head.oversample(head.sensor_index.CMP));
        % rematch the time index
        idt=idslow(1)*head.oversample(head.sensor_index.T1) - ...
            1:(1+idslow(end))*head.oversample(head.sensor_index.T1)-2;
        
        % extract all variables over the correct indices
        for i=1:length(names)
            % extract variables that are collected at the same freq as datenum
            if length(dat.datenum)>=length(dat.(char(names(i))))-20 && ...
                    length(dat.datenum)<=length(dat.(char(names(i))))+20
                data.(char(names(i)))=dt.(char(names(i)))(idt);
            % extract variables that are collected at the same rate as T1
            elseif length(dat.datenum)>=head.oversample(head.sensor_index.T1)*...
                    length(dat.(char(names(i))))-20 && ...
                    length(dat.datenum)<=head.oversample(head.sensor_index.T1)*...
                    length(dat.(char(names(i))))+20
                data.(char(names(i)))=dt.(char(names(i)))(idslow);
            % extract variables that are collected at the same rate as CMP
            elseif length(dat.datenum)>=head.oversample(head.sensor_index.CMP)*...
                    length(dat.(char(names(i))))-20 && ...
                    length(dat.datenum)<=head.oversample(head.sensor_index.CMP)*...
                    length(dat.(char(names(i))))+20
                data.(char(names(i)))=dt.(char(names(i)))(idslow2);
            end
        end
        % (sjw) In newer version of chipods, there are lots of extraneous
        % fields that are saved like R1, R2, R3, R4, VA, MK0, MK1, QUE, VD,
        % MK5 and MK6. We don't need to include these in 'data'. The above 
        % step removes these fields (because they are saved at weird
        % intervals). But here now they need to be skipped also, so need a
        % new fieldnames variable called 'namesgood'. (If these variables are
        % collected at regular intervals, they will be included in 'data')
        namesgood = fieldnames(data);
        for i=1:length(namesgood)
            if length(data.(char(namesgood(i))))==length(idslow)
                data.(char(namesgood(i)))=data.(char(namesgood(i)))(1:10*length(idslow2));
            elseif length(data.(char(namesgood(i))))==length(idt)
                data.(char(namesgood(i)))=data.(char(namesgood(i)))(1:20*length(idslow2));
            end
        end
        
    else
        % get index that matches T1, T2, AX, AY, AZ, W1, W, etc
        idslow=floor(idt(1)/head.oversample(head.sensor_index.T1)) + ...
            1:floor((1+idt(end))/head.oversample(head.sensor_index.T1));
        % get index that matches CMP
        idslow2=floor(idt(1)/head.oversample(head.sensor_index.CMP)) + ...
            1:floor((1+idt(end))/head.oversample(head.sensor_index.CMP));
        % rematch the time index
        idt=idslow(1)*head.oversample(head.sensor_index.T1) - ...
            1:(1+idslow(end))*head.oversample(head.sensor_index.T1)-2;
        % extract all variables over the correct indices
        for i=1:length(names)
            if length(dat.datenum)>=length(dat.(char(names(i))))-20 && ...
                    length(dat.datenum)<=length(dat.(char(names(i))))+20
                data.(char(names(i)))=dt.(char(names(i)))(idt);
            elseif length(dat.datenum)>=head.oversample(head.sensor_index.T1)*...
                    length(dat.(char(names(i))))-20 && ...
                    length(dat.datenum)<=head.oversample(head.sensor_index.T1)*...
                    length(dat.(char(names(i))))+20
                data.(char(names(i)))=dt.(char(names(i)))(idslow);
            elseif length(dat.datenum)>=head.oversample(head.sensor_index.CMP)*...
                    length(dat.(char(names(i))))-20 && ...
                    length(dat.datenum)<=head.oversample(head.sensor_index.CMP)*...
                    length(dat.(char(names(i))))+20
                data.(char(names(i)))=dt.(char(names(i)))(idslow2);
            end
        end
        for i=1:length(names)
            if length(data.(char(names(i))))==length(idslow)
                data.(char(names(i)))=data.(char(names(i)))(1:10*length(idslow2));
            elseif length(data.(char(names(i))))==length(idt)
                data.(char(names(i)))=data.(char(names(i)))(1:20*length(idslow2));
            end
        end

    end
else
    data=[];head=[];
    return
end

