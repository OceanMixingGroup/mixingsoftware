function concatenate_mp(datadir,outname,varargin)
% concatenate_mp(datadir,outname,'PropertyName',PropertyValue,...)
%
% DATADIR - directoiry name in which mat files corresponding to raw data
% files are saved
% OUTNAME - name of file (incuding the full path) in which you want to save data
% All other arguments are optional:
% DATAFIELDS (optional) is a cell array of names of variables to concatenate,
% i.e. {'top.T1','bottom.R2'}, variable 'time' will be added automatically
% if there is no varname, the function will concatenate all variables
% except for 'count'
% TS (optional) - start time;
% TF (optional) - end time;
% AVG (optional) - average time (in seconds);
% SUBSAMPLE (optional) - subsample interval count.
% Data could be either averaged or subsampled, but not both!
% 
% EXAMPLE: 
% concatenate_mp('j:\data2\mp_chipod\mat\','c:\work\ttp09b\test2',...
% 'datafields',{'top.T1','bottom.R2'},'ts',datenum(2009,12,3),'tf',datenum(2009,12,53),...
% 'avg',10)
% would concatinate T1, R2 and time fields from mp files in directory
% 'j:\data2\mp_chipod\mat\' starting at 3 Dec 2009 and ending at 5 Dec 2009,
% bin it in 10 second intervals and save the result in file
% c:\work\ttp09b\test2
% 
% concatenate_mp('j:\data2\mp_chipod\mat\','c:\work\ttp09b\test2',...
% 'datafields',{'top.T1','bottom.R2'},'ts',datenum(2009,12,3),'tf',datenum(2009,12,53),...
% 'subsample',10)
% would do the same with the exception that it would subsample every 10th 
% sample instead of averaging it as in previous example.

% Default values:
datafields={'all'};
ts=datenum(2000,1,1);
tf=datenum(2100,1,1);
avg=0;
subsample=1;

nn=length(varargin)/2;
if nn~=floor(nn)
  error('must have matching number of property-pairs')
end
for ii=1:2:nn*2
  tmp=varargin(ii+1);
  if strcmpi(char(varargin(ii)),'datafields')
      datafields=tmp{:};
  else
    eval([lower(char(varargin(ii))) '=' num2str(tmp{:}) ';' ])
  end
end

dd=dir([datadir '*.mat']);
if isempty(dd)
    error('No processed MP data files found')
end
for ii=1:length(dd)
    dfsnum(ii,:)=datenum(dd(ii).name(1:8),'yymmddHH');
end
id=find(dfsnum>=ts & dfsnum<=tf);
if isempty(id)
    error('No processed data in the requested time range found')
end
id=[id(1)-1 id' id(end)+1];
id=setdiff(id,[0 length(dd)+1]);

for ii=id
    load([datadir '\' dd(ii).name])
    if strcmpi(char(datafields(1)),'all')
        if ii==id(1)
            names1=fieldnames(mp.top);
            names2=fieldnames(mp.bottom);
            names1=setdiff(names1,'count');
            names2=setdiff(names2,'count');
            if avg
                bintime=mp.time(1):avg/86400:mp.time(end);
                tt.time=bintime+avg/86400/2:avg/86400:bintime(end);
                for jj=1:length(names1)
                    tt.top.(char(names1(jj)))=bindata1d(bintime,...
                        mp.time,mp.top.(char(names1(jj))));
                    tt.bottom.(char(names2(jj)))=bindata1d(bintime,...
                        mp.time,mp.bottom.(char(names2(jj))));
                end
            else % if avg
                tt.time=mp.time(1:subsample:end);
                for jj=1:length(names1)
                    tt.top.(char(names1(jj)))=mp.top.(char(names1(jj)))(1:subsample:end);
                    tt.bottom.(char(names2(jj)))=mp.bottom.(char(names2(jj)))(1:subsample:end);
                end
            end % if avg
        else % if ii==id(1)
            if avg
                bintime=mp.time(1):avg/86400:mp.time(end);
                tt.time=[tt.time bintime+avg/86400/2:avg/86400:bintime(end)];
                for jj=1:length(names1)
                    tt.top.(char(names1(jj)))=[tt.top.(char(names1(jj))) ...
                        bindata1d(bintime,mp.time,mp.top.(char(names1(jj))))];
                    tt.bottom.(char(names2(jj)))=[tt.bottom.(char(names2(jj))) ...
                        bindata1d(bintime,mp.time,mp.bottom.(char(names2(jj))))];
                end
            else % if avg
                for jj=1:length(names1)
                    tt.top.(char(names1(jj)))=[tt.top.(char(names1(jj))) mp.top.(char(names1(jj)))(1:subsample:end)];
                    tt.bottom.(char(names2(jj)))=[ tt.bottom.(char(names2(jj))) mp.bottom.(char(names2(jj)))(1:subsample:end)];
                end
            end % if avg
        end % if ii==id(1)
    else % if strcmpi(char(datafields(1)),'all')
        if ii==id(1)
            if avg
                bintime=mp.time(1):avg/86400:mp.time(end);
                tt.time=bintime+avg/86400/2:avg/86400:bintime(end);
                for jj=1:length(datafields)
                    vnm=char(datafields(jj));
                    if strmatch('top',vnm)
                        vnm=vnm(5:end);
                        tt.top.(char(vnm))=bindata1d(bintime,...
                            mp.time,mp.top.(char(vnm)));
                    elseif strmatch('bottom',vnm)
                        vnm=vnm(8:end);
                        tt.bottom.(char(vnm))=bindata1d(bintime,...
                            mp.time,mp.bottom.(char(vnm)));
                    else
                        error('Invalid data field. See script header for examples.')
                    end
                end
            else % if avg
                tt.time=mp.time(1:subsample:end);
                for jj=1:length(datafields)
                    vnm=char(datafields(jj));
                    if strmatch('top',vnm)
                        vnm=vnm(5:end);
                        tt.top.(char(vnm))=mp.top.(char(vnm))(1:subsample:end);
                    elseif strmatch('bottom',vnm)
                        vnm=vnm(8:end);
                        tt.bottom.(char(vnm))=mp.bottom.(char(vnm))(1:subsample:end);
                    else
                        error('Invalid data field. See script header for examples.')
                    end
                end
            end % if avg
        else % if ii==id(1)
            if avg
                bintime=mp.time(1):avg/86400:mp.time(end);
                tt.time=[tt.time bintime+avg/86400/2:avg/86400:bintime(end)];
                for jj=1:length(datafields)
                    vnm=char(datafields(jj));
                    if strmatch('top',vnm)
                        vnm=vnm(5:end);
                        tt.top.(char(vnm))=[tt.top.(char(vnm)) ...
                            bindata1d(bintime,mp.time,mp.top.(char(vnm)))];
                    elseif strmatch('bottom',vnm)
                        vnm=vnm(8:end);
                        tt.bottom.(char(vnm))=[tt.bottom.(char(vnm)) ...
                            bindata1d(bintime,mp.time,mp.bottom.(char(vnm)))];
                    end
                end
            else % if avg
                tt.time=[tt.time mp.time(1:subsample:end)];
                for jj=1:length(datafields)
                    vnm=char(datafields(jj));
                    if strmatch('top',vnm)
                        vnm=vnm(5:end);
                        tt.top.(char(vnm))=[tt.top.(char(vnm)) mp.top.(char(vnm))(1:subsample:end)];
                    elseif strmatch('bottom',vnm)
                        vnm=vnm(8:end);
                        tt.bottom.(char(vnm))=[tt.bottom.(char(vnm)) mp.bottom.(char(vnm))(1:subsample:end)];
                    end
                end
            end
        end % if ii==id(1)
    end % if strcmpi(char(datafields(1)),'all')
end

mp=tt; clear tt
in=find(mp.time>=ts & mp.time<=tf);
mp.time=mp.time(in);
names1=fieldnames(mp.top);
for ii=1:length(names1)
    mp.top.(char(names1(ii)))=mp.top.(char(names1(ii)))(in);
end
names2=fieldnames(mp.bottom);
for ii=1:length(names2)
    mp.bottom.(char(names2(ii)))=mp.bottom.(char(names2(ii)))(in);
end
save(outname,'mp')