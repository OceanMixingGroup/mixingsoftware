function cur=read_tao_cur(fname)
% read_tao_cur.m
% create mat files from fixed depth current meters ASCII data
% $Revision: 1.8 $ $Date: 2012/05/31 23:40:32 $ $Author: aperlin $	
% Originally A. Perlin
fid=fopen(fname,'r');
qlt=strvcat('Quality Code Definitions:',...
'0 = datum missing',...
'1 = highest quality; Pre/post-deployment calibrations agree to within',...
'sensor specifications.  In most cases only pre-deployment calibrations have',...
'been applied',...
'2 = default quality; Pre-deployment calibrations applied.  Default',...
'value for sensors presently deployed and for sensors which were either not',...
'recovered or not calibratable when recovered.',...
'3 = adjusted data; Pre/post calibrations differ, or original data do',...
'not agree with other data sources (e.g., other in situ data or climatology),',...
'or original data are noisy.  Data have been adjusted in an attempt to',...
'reduce the error.',...
'4 = lower quality; Pre/post calibrations differ, or data do not agree',...
'with other data sources (e.g., other in situ data or climatology), or data',...
'are noisy.  Data could not be confidently adjusted to correct for error.',...
'5 = sensor or tube failed');
srs=strvcat('Source code definitions:',...
'    0 - No Sensor, No Data ',...
'    1 - Real Time (Telemetered Mode)',...
'    2 - Derived from Real Time',...
'    3 - Temporally Interpolated from Real Time',...
'    4 - Source Code Inactive at Present',...
'    5 - Recovered from Instrument RAM (Delayed Mode)',...
'    6 - Derived from RAM',...
'    7 - Temporally Interpolated from RAM');
dd=textscan(fid,'%s',2,'delimiter','\r\n');
a=char(dd{:});
ik=find(a(1,:)=='(');
cur.readme=strvcat('Fixed Depth Currents',' ',a(1,:),a(2,:),' ',qlt,srs);
ib=find(a(1,:)==',');
nblocks=str2num(a(1,ib(2)+1:ib(2)+4));
bb='';
for i=1:nblocks
    if findstr(bb,'Time')
        dd=textscan(fid,'%s',3,'delimiter','\r\n');
        a=char(dd{:});
        a=strvcat(bb,a);
    else
        dd=textscan(fid,'%s',4,'delimiter','\r\n');
        a=char(dd{:});
    end
    ik=find(a(1,:)==',');
    it=strfind(a(1,:),'times');
    nlines=str2double(a(1,ik(1)+1:it-1));
    iks=strfind(a(3,:),':');
   iks=strfind(a(3,:),':');
   ikk=min([strfind(a(3,:),'I'),strfind(a(3,:),'Q')]);
   if isempty(ikk)
       depth=str2num(a(3,iks+1:end));
   else
       depth=str2num(a(3,iks+1:ikk-1));
   end
    cur(i).depth=unique(depth);nvar=length(depth)/length(cur(i).depth);
    frm='';
    for ii=1:nvar*length(cur(i).depth)
        frm=[frm ' %f'];
    end
    sdmid=findstr(a(4,:),'SDMID');
    sdmi=findstr(a(4,:),'SDMI');
    sdm=findstr(a(4,:),'SDM');
    src=[];instr=[];
    if ~isempty(sdmid)
        fac=5;
    elseif ~isempty(sdmi)
        fac=4;
    elseif ~isempty(sdm)
        fac=3;
    else
        fac=2;
        src=strfind(a(3,:),'SOURCE');
        instr=strfind(a(3,:),'INSTRUMENT');
    end
    lstr=length(cur(i).depth)*fac;
    if isempty(src) && isempty(instr)
        tmp=textscan(fid,['%s %s' frm ' %' num2str(lstr) 'c'],nlines);
    elseif ~isempty(src) && isempty(instr)
        tmp=textscan(fid,['%s %s' frm ' %' num2str(lstr) 'c' ' %' num2str(lstr/2) 'c'],nlines);
    elseif isempty(src) && ~isempty(instr)
        tmp=textscan(fid,['%s %s' frm ' %' num2str(lstr) 'c' ' %' num2str(lstr) 'c'],nlines);
    else
        tmp=textscan(fid,['%s %s' frm ' %' num2str(lstr) 'c' ' %' num2str(lstr/2) 'c' ' %' num2str(lstr) 'c'],nlines);
    end    
    secs=strfind(a(4,:),'SS');
    if ~isempty(secs)
        cur(i).time=datenum([char(tmp{1}) char(tmp{2})],'yyyymmddHHMMSS');
    else
       cur(i).time=datenum([char(tmp{1}) char(tmp{2})],'yyyymmddHHMM');
    end
    for ii=1:length(cur(i).depth)
        cur(i).u(:,ii)=tmp{2+ii*nvar-nvar+1}/100;
        cur(i).v(:,ii)=tmp{2+ii*nvar-nvar+2}/100;
    end
    cur(i).u(cur(i).u<-9)=NaN;
    cur(i).v(cur(i).v<-9)=NaN;
    qs=char(tmp{end});
    for ii=1:length(cur(i).depth)
        ttmp=qs(:,ii*fac-fac+1:ii*fac);
        bad=find(ttmp(:,fac)==' ');for j=1:length(bad);ttmp(bad(j),:)=repmat('0',1,fac); end
        if fac==2
            cur(i).quality(:,ii)=str2num(ttmp(:,1:2));
        else
            cur(i).quality(:,ii)=str2num(ttmp(:,1:2));
            cur(i).source(:,ii)=str2num(ttmp(:,3));
        end
    end
   dd=textscan(fid,'%s',1,'delimiter','\r\n');
   bb=char(dd{1});
end
fclose(fid);
id=find(fname=='.');
save(fname(1:id-1),'cur')
