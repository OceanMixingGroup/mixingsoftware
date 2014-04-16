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
%   $Revision: 1.6 $  $Date: 2010/05/18 00:51:14 $
if nargin<6
    time_offset=0;
end
pname=[dpath,'\data\',num2str(unit),'\'];
dd=dir(pname);
for ii=3:length(dd)
    tmp=dd(ii).name;
    dfs(ii-2,:)=tmp(1:8);
end
dfsnum=str2num(dfs(1:end,:));
ts1=ts-datenum(0,0,0,0,0,time_offset);
tf1=tf-datenum(0,0,0,0,0,time_offset);
[y,m,d,h,mi,s]=datevec(ts1);
if h==0
    h=24;d=d-1;
end
ystr=num2str(y);mstr=num2str(m+1000);dstr=num2str(d+1000);hstr=num2str(h+1000-1);
fs=[ystr(3:4) mstr(3:4) dstr(3:4) hstr(3:4)];fs=str2num(fs);
[y,m,d,h,mi,s]=datevec(tf1);
ystr=num2str(y);mstr=num2str(m+1000);dstr=num2str(d+1000);hstr=num2str(h+1000+1);
ff=[ystr(3:4) mstr(3:4) dstr(3:4) hstr(3:4)];ff=str2num(ff);

id=find(dfsnum>=fs & dfsnum<=ff);
if isempty(id)
    data=[];head=[];
    return
end
id=[id(1)-1 id' id(end)+1]; %original
id=setdiff(id,[0 length(dd)-2]);

fnam=[pname,dfs(id(1),:),'.',num2str(unit)];
dt.datenum=[];
if exist(fnam,'file') == 2
    [dat,head]=raw_load_chipod(fnam);
    if exist(['clean_raw_chipod_' dpl '.m'],'file')
        [dat,head]=eval(['clean_raw_chipod_' dpl '(dat,head,unit)']);
    end
    names=fieldnames(dat);
    for i=1:length(names)
        dt.(char(names(i)))=dat.(char(names(i)))';
    end
else
    display('no file')
end
id=setdiff(id,id(1));
if ~isempty(id)
    for ifil=id
        fnam=[pname,dfs(ifil,:),'.',num2str(unit)];
        if exist(fnam,'file') == 2
            [dat,head]=raw_load_chipod(fnam);
            if exist(['clean_raw_chipod_' dpl '.m'],'file')
                [dat,head]=eval(['clean_raw_chipod_' dpl '(dat,head,unit)']);
            end
            names=fieldnames(dat);
            for i=1:length(names)
                dt.(char(names(i)))=[dt.(char(names(i))) dat.(char(names(i)))'];
            end
        end
    end
end
if ~isempty(dt.datenum)
    dt.datenum=dt.datenum+datenum(0,0,0,0,0,time_offset);
    idt=find(dt.datenum>=ts & dt.datenum<=tf);
    if isempty(idt)
        data=[];head=[];
        return
    end
    idslow=floor(idt(1)/10)+1:floor((1+idt(end))/10);
    idslow2=floor(idt(1)/120)+1:floor((1+idt(end))/120);
    idt=idslow(1)*10:(1+idslow(end))*10-1;
    if isfield(head.irep,'T1P')
        idfast=idt(1)*head.irep.T1P:(1+idt(end))*head.irep.T1P-1;
    elseif isfield(head.irep,'S1')
        idfast=idt(1)*head.irep.S1:(1+idt(end))*head.irep.S1-1;
    elseif  isfield(head.irep,'AX')
        idfast=idt(1)*head.irep.AX:(1+idt(end))*head.irep.AX-1;
    elseif  isfield(head.irep,'W1')
        idfast=idt(1)*head.irep.W1:(1+idt(end))*head.irep.W1-1;
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
end

