function ppod=raw_load_ppod(name,extension,type)
% function ppod=raw_load_ppod(name,extension,type)
% example: ppod=raw_load_ppod('\\mserver\data\sw06\MooringRecovery\SW38\PPod_201\raw2\','ch1','o')
% read PPOD data structure
% and converts to mat format
% all input parameters are optional
% NAME is diectory name fhere PPOD raw data files are saved
% or name of a raw data file
% EXTENSION is file extansion of raw data files
% must start with 'c','t','p','i' or 'a' (case insensitive) 
% parameter TYPE is referred to the type of raw data format
% TYPE could be 'o', 'p', 't' , 'i' or 'a'
% if TYPE=='o' function it attempts to read old 
% "semi"-ASCII files (pre-May 2008)
% 'o' data format example:
% ? H„??H„?"?00114.6189
% *000114.6190
% *000114.6189
% if TYPE=='p' or TYPE=='t' than raw_load_ppod attempts to read  
% binary type of data files (post-May 2008 and pre-January 2009), 
% if TYPE=='i' than raw_load_ppod attempts to read ASCII data structure
% (e.g. in ppod0910)
% binary type of data files (post-May 2008 and pre-January 2009), 
% if TYPE=='i' than raw_load_ppod attempts to read ASCII data structure
% (e.g. in ppod0910)
% 'i' data format example:
% 03/10/09  21:04:58, 58.029, 000114.7496
% 03/10/09  21:04:58, 58.029, 000114.7510
% if TYPE=='a' function attempts to read Airpod data (post-January 2009)
% If there are no input parameters, the function will open GUI to read
% data. 
% 
% ATTENTION:
% Old data format (TYPE='o') could read files only from a continuous deployment
% if ppod was turned on/off during deployment 
% raw data files should be splited in separate directories
% $Revision: 1.15 $ $Date: 2010/11/18 22:27:47 $ $Author: aperlin $	 
%% Input, output and common constants
if nargout<1
    global ppod
end
if nargin<1
    [raw_name,dirname]=uigetfile('*.*','Load Binary File');
    fname=[dirname raw_name];
    iext=find(fname=='.');iext=iext(end)+1;
    switch lower(fname(iext))
        case 'c'
            type='o';
            d=dir([dirname '\*.c*']);
        case 't'
            type='t';
            d=dir(fname);
        case 'p'
            type='p';
            d=dir(fname);
        case 'i'
            type='i';
            d=dir(fname);
        case 'a'
            type='a';
            d=dir(fname);
    end
elseif nargin==1
    d=dir(name);
    if exist(name)==2
        iext=find(d(1).name=='.');iext=iext(end)+1;
        dirname=name(1:end-length(d(1).name));
        if isempty(dirname)
            dirname=pwd;
        end
        switch lower(d(1).name(iext))
            case 'c'
                type='o';
            case 't'
                type='t';
            case 'p'
                type='p';
            case 'i'
                type='i';
            case 'a'
                type='a';
            otherwise
                disp('Cannot find recognized file type')
        end
    elseif exist(name)==7
        jj=3;
        type='';
        dirname=name;
        while jj<length(d)
            if ~d(jj).isdir && isempty(strfind(d(jj).name,'.txt')) ...
                    && isempty(strfind(d(jj).name,'.csv')) && isempty(strfind(d(jj).name,'.pdf'))...
                    && isempty(strfind(d(jj).name,'.mat'))
                iext=find(d(jj).name=='.');iext=iext(end)+1;
                if length(d(jj).name)>iext
                    switch lower(d(jj).name(iext))
                        case 'c'
                            type='o';jj=1e6;
                            d=dir([name '\*.ch*']);
                        case 't'
                            type='t';jj=1e6;
                            d=dir([name '\*.td*']);
                        case 'p'
                            type='p';jj=1e6;
                            d=dir([name '\*.p*']);
                        case 'i'
                            type='p';jj=1e6;
                            d=dir([name '\*.i*']);
                        case 'a'
                            type='a';jj=1e6;
                            d=dir([name '\*.a*']);
                        otherwise
                            jj=jj+1;
                    end
                end
            else
                jj=jj+1;
            end
        end
    else
        disp('Cannot find input directory or input file')
        return
    end
    if isempty(type)
        disp('Cannot find recognized file types in the directory')
        return
    end
elseif nargin==2
    if exist(name)==2
        d=dir(name);
        iext=find(d(1).name=='.');iext=iext(end)+1;
        dirname=name(1:end-length(d(1).name));
        if isempty(dirname)
            dirname=pwd;
        end
        switch lower(extension(1))
            case 'c'
                type='o';
            case 't'
                type='t';
            case 'p'
                type='p';
            case 'i'
                type='i';
            case 'a'
                type='a';
            otherwise
                disp('Cannot find recognized file type')
                return
        end
    elseif exist(dirname)==7
        d=dir([name '*' extension]);
        dirname=name(1:end-length(d(1).name));
        type='';
        switch lower(extension(1))
            case 'c'
                type='o';
            case 't'
                type='t';
            case 'p'
                type='p';
            case 'i'
                type='i';
            case 'a'
                type='a';
            otherwise
                disp('Cannot find recognized file type')
                return
        end
    else
        disp('Cannot find input directory or input file')
        return
    end
    if isempty(type)
        disp('Cannot find recognized file types in the directory')
        return
    end
else
    if exist(name)==2
        d=dir(name);
        dirname=name(1:end-length(d(1).name));
    elseif exist(name)==7
        dirname=name;
    end
    switch type
        case 'o'
            d=dir([dirname '\*.c*']);
        case 't'
            d=dir([dirname '\*.t*']);
        case 'p'
            d=dir([dirname '\*.p*']);
        case 'i'
            d=dir([dirname '\*.i*']);
        case 'a'
            d=dir([dirname '\*.a*']);
        otherwise
            disp('Cannot find recognized file type')
            return
    end
end
epoch=double(datenum(1970,1,1)); %reference time - times written in seconds since epoch

%% Read old data format (type='o')
if type=='o'
    ppod.p=[];
    ppod.time=[];
    dt='';
    k=0;
    iii=0;
    for ii=1:length(d)
        k=k+1;
        fname=[dirname d(ii).name];
        display(d(ii).name)
        fid = fopen(fname,'r');
        i=0;
        while ~feof(fid)
            iii=iii+1;
            i=i+1;
            id=fread(fid,1,'uint16=>double');
            channel=fread(fid,1,'uint16=>double');
            starttime=fread(fid,1,'uint32=>double','b')/3600/24+epoch;
            endtime=fread(fid,1,'uint32=>double','b')/3600/24+epoch;
            datalength=fread(fid,1,'uint16=>double','b');
            dd=textscan(fid,['%' num2str(datalength) 's'],1,'endOfLine','^');
            dt=[dt char(dd{:})];
            if k==1 && i==1
                head.starttime=starttime;
            end
        end
        if strcmp(dt(end-6),'.')
            in=find(dt=='*');
            p.p=ones(1,length(in))*NaN;
            for m=1:length(in)-1
                p.p(m)=str2num(dt(in(m)+5:in(m+1)-3));
            end
            p.p(length(in))=str2num(dt(in(length(in))+5:end-3));
            ppod.p=[ppod.p p.p];
            deltatime=(endtime-head.starttime)/length(ppod.p); % time between samples [days]
            dt='';
            if ii==length(d)
                ppod.time=[head.starttime:deltatime:head.starttime+(length(ppod.p)-1)*deltatime];
            end
        elseif ii==length(d)
            in=find(dt=='*');
            p.p=ones(1,length(in)-1)*NaN;
            for m=1:length(in)-1
                p.p(m)=str2num(dt(in(m)+5:in(m+1)-3));
            end
            ppod.p=[ppod.p p.p];
            if ~exist('deltatime','var')% time between samples [days]
                deltatime=(endtime-head.starttime)/length(ppod.p);
            end
            ppod.time=[head.starttime:deltatime:head.starttime+(length(ppod.p)-1)*deltatime];
        end
        fclose(fid);
    end
end

%% Read format type='p' or type='t'
if type=='p' || type=='t'
    ppod.ttime=[];
    ppod.temp=[];
    ppod.time=[];
    ppod.data=[];
    fields=fieldnames(ppod);
    TMPOFF=0.985;
    OSFREQ=7373402.4;
    if type=='p'
        dfactor=64;
    elseif type=='t'
        dfactor=256;
    end
    for ii=1:length(d)
        fname=[dirname d(ii).name];
        display(d(ii).name)
        fid = fopen(fname,'r');
        if(fid)
            while ~feof(fid)
                bln=0;
                %**** READ BLOCK **********
                % read block marker
                btype=fread(fid,4,'uchar=>uchar');
                if isempty(btype)
                    break
                end
                % read time (Unix standard)
                wrtime=fread(fid,1,'int32=>double');
                % read block number
                blocknum=fread(fid,1,'uint32=>double');
                % check block number
                if blocknum>bln
                    bln=blocknum;
                else
                    break
                end
                % read number of readings in block (should be 120)
                validlongs=fread(fid,1,'int16');
                % read board temperature counts
                bdtemp=fread(fid,1,'int16');
                % read data
                data=fread(fid,120,'uint32=>double');
                % read pad
                pad=fread(fid,14,'uchar');
                % read checksum (bytes 510 and 511 not used with USB
                checksum=fread(fid,1,'uint16=>ushort');
                % ****** END OF READ BLOCK *********************
                % CONVERT UNITS
                p.ttime(blocknum)=double(wrtime)/86400+epoch;
                % calculate board temperature with TI algorithm from MSP430 data sheet
                p.temp(blocknum)=(((1.5 * bdtemp)/4096.0) - TMPOFF)/0.00355;
                % get number of input cycles
                fcy=data(1:validlongs)./2^24 + 400;
                % mask off input cycles to get clock cycles
                fcount=bitand(data(1:validlongs),uint32(hex2dec('00FFFFFF')));
                if ~isfield(p,'time')
                    %                     p.time(1:validlongs)=double(wrtime-validlongs+1:wrtime)/86400+epoch;
                    p.time(1:validlongs)=double(wrtime:wrtime+validlongs-1)/86400+epoch;
                    p.data(1:validlongs)=1e6.*(double(fcount)./OSFREQ)./(dfactor.*double(fcy));
                else
                    % %                     p.time(end+1:end+validlongs)=double(wrtime-validlongs+1:wrtime)/86400+epoch;
                    p.time(end+1:end+validlongs)=double(wrtime:wrtime+validlongs-1)/86400+epoch;
                    p.data(end+1:end+validlongs)=1e6.*(double(fcount)./OSFREQ)./(dfactor.*double(fcy));
                end
            end
            fclose(fid);
        end
        for jj=1:length(fields)
            ppod.(char(fields(jj)))=[ppod.(char(fields(jj))) p.(char(fields(jj)))];
        end
    end
    ppod.ttime(ppod.ttime==0)=NaN;
    ppod.time(ppod.time==0)=NaN;
    ppod.temp(ppod.temp==0)=NaN;
    ppod.data(ppod.data==0)=NaN;
    ppod.ttime=fillgap(ppod.ttime);
    ppod.time=fillgap(ppod.time);
end

%% Read Airpod data format (type='a')
if type=='a'
    for ii=1:length(d)
        fname=[dirname '\' d(ii).name];
        if isempty(strfind(fname,'.mat')) && isempty(strfind(fname,'.txt'))...
                && isempty(strfind(fname,'.pdf')) && isempty(strfind(fname,'.csv'))
            iext=find(fname=='.');iext=iext(end)-1;
            disp(sprintf('processing file %s', d(ii).name));
            TMPOFF=0.985;
            dfactor=64;
            matlab_sec(1:120)= [0  double([1:119])./double(86400.0) ];
            oldtime= -1;

            Y=zeros(1,3)* NaN;
            C=zeros(1,3)* NaN;
            D=zeros(1,2)* NaN;
            T=zeros(1,5)* NaN;
            fid = fopen(fname,'r');
            if fid
                try
                    %**** READ HEADER **********
                    % read block marker
                    btype=fread(fid,4,'uchar=>uchar'); %4*8=32 bits=4 bytes
                    test= (btype ==[170 170 170 170]');
                    if sum(test)==4
                        % first 2 blocks is message header
                        st=504;
                        % waste another 4 chars
                        junk =fread(fid,4, 'uchar=>uchar');
                        data =fread(fid,st, 'uchar=>uchar'); %user data
                        % remove trailing spaces at 512 boundary
                        for jj=st:-1: 1
                            if( data(jj) > 32) break; end
                        end
                        data=data(1:jj);
                        %                     data=data(data~=0);
                        % read second 512 block
                        % first waste 8 chars
                        junk=fread(fid,8,'uchar=>uchar');
                        data2=fread(fid, st, 'uchar=>uchar');
                        data3=[data' data2' ];
                        [pcb firmware OSFREQ U0 Y C D T sensor]=headerfile(data3);
                        ppod.header.sensor=sensor;
                        ppod.header.pcb=pcb;
                        ppod.header.firmware=firmware;
                        ppod.header.pcb=pcb;
                        ppod.header.parocoefs.U0=U0;
                        ppod.header.parocoefs.Y=Y;
                        ppod.header.parocoefs.C=C;
                        ppod.header.parocoefs.D=D;
                        ppod.header.parocoefs.T=T;
                        ppod.header.OSFREQ=OSFREQ;
                        sum_parocoefs = sum([U0 Y C D T]);
                    elseif sum(test)~=4
                        disp('Cannot find header')
                    end

                    bln=0;
                    while ~feof(fid)
                        %**** READ BLOCK **********
                        % read block marker
                        btype=fread(fid,4,'uchar=>uchar'); %4*8=32 bits=4 bytes
                        test= (btype ==[187 187 187 187]');
                        if sum(test)==4
                            % read time (Unix standard)
                            wrtime=fread(fid,1,'int32=>double');
                            % read block number
                            blocknum=fread(fid,1,'uint32=>double');
                            % read number of readings in block (should be 120)
                            validlongs=fread(fid,1,'int16=>double');
                            if validlongs~=120
                                disp(sprintf('number of data points in the block is  %d',...
                                    validlongs))
                            end
                            % read board temperature counts
                            bdtemp=fread(fid,1,'int16=>double');
                            % read data
                            data=fread(fid,validlongs,'uint32=>double');
                            junk=fread(fid,120-validlongs,'uint32=>double');
                            % read pad
                            tmpd=fread(fid,2,'uint32=>uint32'); % 4
                            % read rtc
                            rtc=fread(fid,6,'uchar=>uchar');
                            % read checksum (bytes 510 and 511 not used with USB
                            checksum=fread(fid,1,'uint16=>double');
                            % ****** END OF READ BLOCK *********************

                            % check block number
                            if blocknum>bln bln=blocknum;
                            else break ;
                            end

                            if( mod(blocknum, 100) ==0)
                                disp(sprintf('blockn=%d', blocknum));
                            end

                            tmpd1=tmpd(1); tmpd2=tmpd(2);
                            year=str2num(sprintf('%03x',rtc(1)));
                            mon =str2num(sprintf('%03x',rtc(2)));
                            day =str2num(sprintf('%03x',rtc(3)));
                            hour=str2num(sprintf('%03x',rtc(4)));
                            min =str2num(sprintf('%03x',rtc(5)));
                            sec =str2num(sprintf('%03x',rtc(6)));
                            newtime=datenum(2000+year,mon,day,hour,min,sec);
                            if isempty(newtime)
                                disp('invalid time stamp')
                                break
                            end

                            tcy1= bitshift(uint32(tmpd1), -24) ;
                            tct1= bitand  (uint32(tmpd1) , uint32(hex2dec('00FFFFFF')));
                            tcy2= bitshift(uint32(tmpd2), -24) ;
                            tct2= bitand  (uint32(tmpd2) , uint32(hex2dec('00FFFFFF')));
                            if (tcy1 ~= 0)
                                d_tmpd1=1e6*(double(tct1)/OSFREQ)...
                                    /(1024*double(tcy1));
                            else d_tmpd1=0.0; end

                            if (tcy2 ~= 0)
                                d_tmpd2=1e6*(double(tct2)/OSFREQ)...
                                    /(1024*double(tcy2));
                            else d_tmpd2=0.0; end

                            % calculate board temperature with TI algorithm from
                            %  MSP430 data sheet
                            boardtemp= (((1.5 * bdtemp)/4096.0) - TMPOFF)/0.00355;
                            rtc_elapse = round(86400*(newtime-oldtime));
                            offset=0;
                            if oldtime< 0
                                rtc_elapse=120;
                            end
                            oldtime=newtime ;
                            if rtc_elapse < 120 && rtc_elapse >0
                                offset= 120-rtc_elapse;
                                disp(sprintf('smaller nonstandard rtc interval %d seconds',...
                                    rtc_elapse));
                            end
                            if rtc_elapse > 120  % not accounting for 121 sec periods
                                offset= 120-rtc_elapse;
                                disp(sprintf('larger nonstandard rtc interval %d seconds',...
                                    rtc_elapse));
                            end
                            if rtc_elapse < 0
                                disp(sprintf('backward time'));
                            end
                            if rtc_elapse == 0
                                disp(sprintf('zero time'));
                            end

                            msp_tux= zeros(1,validlongs);
                            p_t    = msp_tux;
                            tperid = msp_tux;

                            % get number of input cycles
                            fcy= bitshift(uint32(data(1:validlongs)), -24) ;
                            fcy= fcy +400 ;
                            % mask off input cycles to get clock cycles
                            fcount=uint32(data(1:validlongs));
                            fcount=bitand( fcount,  uint32(hex2dec('00FFFFFF')));

                            msp_tux= (wrtime : wrtime+validlongs-1);

                            p_t(1:validlongs)= ...
                                1e6*(double(fcount)/OSFREQ)./(dfactor.*double(fcy));

                            if( validlongs == 120 )
                                rtc(1:120)=double ( newtime+matlab_sec);
                                tperid(1:59)  = d_tmpd1 ;
                                tperid(60:120)= d_tmpd2 ;
                            elseif (validlongs <=59)
                                rtc(1:validlongs)=double(newtime+ matlab_sec(1:validlongs));
                                tperid(1:validlongs)= d_tmpd1 ;
                            else
                                rtc(1:validlongs)=double(newtime+ matlab_sec(1:validlongs));
                                tperid(1:59)= d_tmpd1 ;
                                tperid(60:validlongs)= d_tmpd2;
                            end

                            if ~isfield(ppod,'time')
                                ppod.time(1:validlongs)=newtime+(msp_tux-wrtime)/86400;
                                ppod.boardtemp(1:validlongs)= boardtemp;
                                ppod.p_us(1:validlongs)= p_t;
                                ppod.t_us(1:validlongs)= tperid;
                            else
                                % CPU clock drifts, but real time (within 1 sec) is saved once every
                                % 120 measurements. When elapsed between two blocks real time (rounded to 1 sec)
                                % happens to be 119 sec we overwrite one value from the previous block
                                ppod.time(end+1-offset:end+validlongs-offset)=newtime+(msp_tux-wrtime)/86400;
                                ppod.boardtemp(end+1-offset:end+validlongs-offset)= boardtemp;
                                ppod.p_us(end+1-offset:end+validlongs-offset)= p_t;
                                ppod.t_us(end+1-offset:end+validlongs-offset)= tperid;
                            end
                        end
                    end % while
                end
                % When elapsed between two blocks real time (rounded to 1 sec)
                % happens to be 121 sec we get 0's in our arrays,
                % because there are still 120 data points in the block.
                % We linearly interpolate into these periods.
                good=find(ppod.time~=0);
                ppod.time=interp1(good,ppod.time(good),[1:length(ppod.time)]);
                ppod.boardtemp=interp1(good,ppod.boardtemp(good),[1:length(ppod.time)]);
                ppod.p_us=interp1(good,ppod.p_us(good),[1:length(ppod.time)]);
                ppod.t_us=interp1(good,ppod.t_us(good),[1:length(ppod.time)]);
                if ~isnan(sum_parocoefs)
                    [psia,parocelsius]=convert_paro2(U0,Y,C,D,T,ppod.p_us,ppod.t_us);
                    ppod.p=psia;
                    ppod.t=parocelsius;
                end
            end
            ppod.boardtemp(ppod.boardtemp==0)=NaN;
            ppod.readme=strvcat('boardtemp is CPU temperature','p_us is pressure in microseconds',...
                't_us is temperature in microseconds','p is absolute pressure in psi',...
                't is temperature in C',...
                'PLEASE NOTE:',...
                'CPU clock drifts, but real time (within 1 sec) is saved once every',...
                '120 measurements. When elapsed between two blocks real time (rounded to 1 sec)',...
                'happens to be 119 sec we overwrite one value from the previous block.',...
                'When elapsed between two blocks real time (rounded to 1 sec)',...
                'happens to be 121 sec we insert in the block a ficticious 121st "measurement".');
            fclose all;
            save([fname '.mat'],'ppod')
        end % if fid
    end %~isempty(strfind(d(jj).name,'.mat'))
end % for ii=1:length(d)
%% Read format type='i'
if type=='i'
    ppod.time=[];
    ppod.p=[];
    for ii=1:length(d)
        fname=[dirname d(ii).name];
        display(d(ii).name)
        fid = fopen(fname,'r');
        if(fid)
            tt=textscan(fid,'%s %s %s','delimiter',',');
            fclose(fid);
            ppod.time=datenum(char(tt{1}),'mm/dd/yy  HH:MM:SS');
            [ppod.time ii]=unique(ppod.time);
            t=char(tt{3});
            ppod.p=str2num(t(:,5:end));
            ppod.p=ppod.p(ii);
            ppod.p(ppod.p>999)=NaN;
            ppod.readme=strvcat('p is absolute pressure in psi');
            save([fname '.mat'],'ppod')
        end
    end
end % if type=='i'
