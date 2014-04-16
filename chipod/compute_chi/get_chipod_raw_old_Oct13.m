function [data,head]=get_chipod_raw(dpath,dpl,unit,ts,tf,time_offset)
% get_chipod(dpath,unit,ts,tf)
% get raw chipod data and create raw data structure from time ts to time tf
%
% dpath - data directory, i.e. '\\mserver\data\chipod\tao_sep05\'
% dpl - deployment name (string), i.e. 'eq08'
% unit - input number, (integer) i.e. 305
% ts - start time, Matlab format
% tf - finish time, Matlab format
% time_offset - time correction for timestamp. Default value is 0.
%   $Revision: 1.15 $  $Date: 2013/01/07 18:47:59 $
% ts=ts-1/86400;
% tf=tf+1/86400;
if nargin<6
    time_offset=0;
end
pname=[dpath,'\data\',num2str(unit),'\'];
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
% dfsnum=str2num(dfs(1:end,:));
dfsnum=datenum(dfs,'yymmddHH');
ts1=ts-datenum(0,0,0,0,0,time_offset);
tf1=tf-datenum(0,0,0,0,0,time_offset);
%%%%%% NEW %%%%%%%%%%%
id=find(dfsnum<=ts1,1,'last');
if isempty(id); id=1; end
fnam=[pname,preffix,dfs(id(1),:),'.',num2str(unit)];

if exist(fnam,'file') == 2
    [dat,head]=raw_load_chipod(fnam);
    if exist(['clean_raw_chipod_' dpl '.m'],'file')
        [dat,head]=eval(['clean_raw_chipod_' dpl '(dat,head,unit)']);
    end
    names=fieldnames(dat);
    for ii=1:length(names)
        dt.(char(names(ii)))=dat.(char(names(ii)))';
    end
else
    display('no file')
end
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
if ~exist('dt','var')
    data=[];head=[];
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if median(diff(dfsnum))<2/24
%     id=find(dfsnum>=ts1-2/24 & dfsnum<=tf1); % old standard (1h 15min files)
% else
%     id1=find(dfsnum<=ts1);id2=find(dfsnum<tf1); id=id1(end):id2(end);% new standard
% end
% if isempty(id)
%     if mean(diff(dfsnum))>tf1-ts1
%         id=find(dfsnum<ts1);id=id(end);
%         if dfsnum(id+1)<tf1
%             id=[id id+1];
%         end
%     else
%         data=[];head=[];
%         return
%     end
% end
% if mean(diff(dfsnum))<tf1-ts1
% %     id=[id(1)-1 id' id(end)+1]; 
% %     id=setdiff(id,[0 length(dd)-2]);
%     id=[id(1)-1 id' id(end)]; 
%     id=setdiff(id,[0 length(dd)-1 length(dd)]);
% end
% fnam=[pname,preffix,dfs(id(1),:),'.',num2str(unit)];
% dt.datenum=[];
% if exist(fnam,'file') == 2
%     [dat,head]=raw_load_chipod(fnam);
%     if exist(['clean_raw_chipod_' dpl '.m'],'file')
%         [dat,head]=eval(['clean_raw_chipod_' dpl '(dat,head,unit)']);
%     end
%     names=fieldnames(dat);
%     for i=1:length(names)
%         dt.(char(names(i)))=dat.(char(names(i)))';
%     end
% else
%     display('no file')
% end
% idd=id(end);
% id=setdiff(id,id(1));
% if ~isempty(id)
%     if size(id,2)==1; id=id';end
%     for ifil=id
%         fnam=[pname,preffix,dfs(ifil,:),'.',num2str(unit)];
%         if exist(fnam,'file') == 2
%             [dat,head]=raw_load_chipod(fnam);
%             if exist(['clean_raw_chipod_' dpl '.m'],'file')
%                 [dat,head]=eval(['clean_raw_chipod_' dpl '(dat,head,unit)']);
%             end
%             names=fieldnames(dat);
%             for i=1:length(names)
%                 dt.(char(names(i)))=[dt.(char(names(i))) dat.(char(names(i)))'];
%             end
%         end
%     end
% end
% while dt.datenum(end)<tf1 && idd<size(dfs,1)
%     fnam=[pname,preffix,dfs(idd+1,:),'.',num2str(unit)];
%     if exist(fnam,'file') == 2
%         [dat,head]=raw_load_chipod(fnam);
%         if exist(['clean_raw_chipod_' dpl '.m'],'file')
%             [dat,head]=eval(['clean_raw_chipod_' dpl '(dat,head,unit)']);
%         end
%         names=fieldnames(dat);
%         for i=1:length(names)
%             dt.(char(names(i)))=[dt.(char(names(i))) dat.(char(names(i)))'];
%         end
%     end
%     idd=idd+1;
% end
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
            idfast=[idt(1)*head.irep.T1P:(1+idt(end))*head.irep.T1P-1]-head.irep.T1P+1;
        elseif isfield(head.irep,'S1')
            idfast=[idt(1)*head.irep.S1:(1+idt(end))*head.irep.S1-1]-head.irep.S1+1;
        elseif  isfield(head.irep,'AX')
            idfast=[idt(1)*head.irep.AX:(1+idt(end))*head.irep.AX-1]-head.irep.AX+1;
        elseif  isfield(head.irep,'W1')
            idfast=[idt(1)*head.irep.W1:(1+idt(end))*head.irep.W1-1]-head.irep.W1+1;
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
    else
        idslow=floor(idt(1)/head.oversample(head.sensor_index.T1))+1:floor((1+idt(end))/head.oversample(head.sensor_index.T1));
        idslow2=floor(idt(1)/head.oversample(head.sensor_index.CMP))+1:floor((1+idt(end))/head.oversample(head.sensor_index.CMP));
        idt=idslow(1)*head.oversample(head.sensor_index.T1)-1:(1+idslow(end))*head.oversample(head.sensor_index.T1)-2;
        for i=1:length(names)
            if length(dat.datenum)>=length(dat.(char(names(i))))-20 && ...
                    length(dat.datenum)<=length(dat.(char(names(i))))+20
                data.(char(names(i)))=dt.(char(names(i)))(idt);
            elseif length(dat.datenum)>=head.oversample(head.sensor_index.T1)*length(dat.(char(names(i))))-20 && ...
                    length(dat.datenum)<=head.oversample(head.sensor_index.T1)*length(dat.(char(names(i))))+20
                data.(char(names(i)))=dt.(char(names(i)))(idslow);
            elseif length(dat.datenum)>=head.oversample(head.sensor_index.CMP)*length(dat.(char(names(i))))-20 && ...
                    length(dat.datenum)<=head.oversample(head.sensor_index.CMP)*length(dat.(char(names(i))))+20
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

