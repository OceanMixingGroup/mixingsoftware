function ppod=raw_load_ppod(name,extension,type)
% function ppod=raw_load_ppod(name,extension,type)
% example: ppod=raw_load_ppod('//mserver/data/sw06/MooringRecovery/SW38/PPod_201/raw2/','ch1','o')
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
% $Revision: 1.22 $ $Date: 2012/10/12 17:10:13 $ $Author: aperlin $	 
%% Input, output and common constants
if nargout<1
    global ppod
end
clear ppod
if nargin<1
    [raw_name,dirname]=uigetfile('*.*','Load Binary File');
    fname=[dirname raw_name];
    iext=find(fname=='.');iext=iext(end)+1;
    switch lower(fname(iext))
        case 'c'
            type='o';
            d=dir([dirname '/*.c*']);
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
        case 'h'
            type='h';
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
            case 'h'
                type='h';
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
                            d=dir([name '/*.ch*']);
                        case 't'
                            type='t';jj=1e6;
                            d=dir([name '/*.td*']);
                        case 'p'
                            type='p';jj=1e6;
                            d=dir([name '/*.p*']);
                        case 'i'
                            type='p';jj=1e6;
                            d=dir([name '/*.i*']);
                        case 'a'
                            type='a';jj=1e6;
                            d=dir([name '/*.a*']);
                        case 'h'
                            type='h';jj=1e6;
                            d=dir([name '/*.h*']);
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
            case 'h'
                type='h';
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
            case 'h'
                type='h';
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
            d=dir([dirname '/*.c*']);
        case 't'
            d=dir([dirname '/*.t*']);
        case 'p'
            d=dir([dirname '/*.p*']);
        case 'i'
            d=dir([dirname '/*.i*']);
        case 'a'
            d=dir([dirname '/*.a*']);
        case 'h'
            d=dir([dirname '/*.h*']);
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

%% Read Airpod & HSP data format (type='a' or type='h')
if type=='a' || type=='h'
    for ii=1:length(d)
        fname=[dirname '/' d(ii).name];
        if isempty(strfind(fname,'.mat')) && isempty(strfind(fname,'.txt'))...
                && isempty(strfind(fname,'.pdf')) && isempty(strfind(fname,'.csv'))
            iext=find(fname=='.');iext=iext(end)-1;
            disp(sprintf('processing file %s', d(ii).name));
            fid = fopen(fname,'r');
            if fid
                    btype=fread(fid,4,'uchar=>uchar'); %4*8=32 bits=4 bytes
%                     if size(btype,1)==4
%                         test= (btype ==[170 170 170 170]');
%                     else
%                         test=0;
%                     end
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
                    tmp=data';tmp(tmp<32 | tmp>126)=32;tmp=cast(tmp,'char');
                    fwv1=strfind(tmp,'Firmware Version');
                    firmware=tmp(fwv1+16:fwv1+21);
                    firmware=char(textscan(firmware,'%c',length(firmware)))';
                    % if Firmware version <5 waste 8 chars
                    %                         if firmware(1)~='5'
                    if any(firmware(1)=='5')
                        junk=fread(fid,8,'uchar=>uchar');
                    end
                    data2=fread(fid, st, 'uchar=>uchar');
                    aa=[data' data2'];
                    aa(aa<32 | aa>126)=32;
                    aa=cast(aa,'char');
                    in0=strfind(aa,'qqq');
                    in1=strfind(aa,'Firmware Version');
                    in2=strfind(aa,'PPOD Serial Number:');
                    in3=strfind(aa,'Main Oscillator Frequency:');
                    in4=strfind(aa,'Sensor Calibration Data');
                    in5=strfind(aa,'00B0:');
                    in6=strfind(aa,'00C0:');
                    in7=strfind(aa,'01E0:');
                    in8=strfind(aa,'01F0:');
                    in9=strfind(aa,'0200:');
                    in10=strfind(aa,'0210:');
                    in11=strfind(aa,'0220:');
                    in12=strfind(aa,'0230:');
                    in13=strfind(aa,'0240:');
                    in14=strfind(aa,'0250:');
                    in15=strfind(aa,'0260:');
                    in16=strfind(aa,'0270:');
                    in17=strfind(aa,'0280:');
                    in18=strfind(aa,'0290:');
                    in19=strfind(aa,'02A0:');
                    in20=strfind(aa,'02B0:');
                    in21=strfind(aa,'02C0:');
                    ppod.header.firmware=firmware;
                    if ~isempty(in2)
                        ppod.header.pcb=aa(in2+19:in3-1);
                    else
                        ppod.header.pcb=aa(in0-4:in0-1);
                    end
                    ppod.header.sensor=aa(in5+5:in6-1);
                    ppod.header.parocoefs.U0=str2num(aa(in7+5:in8-1));
                    ppod.header.parocoefs.Y=[str2num(aa(in8+5:in9-1)) ...
                        str2num(aa(in9+5:in10-1)) str2num(aa(in10+5:in11-1))];
                    ppod.header.parocoefs.C=[str2num(aa(in11+5:in12-1)) ...
                        str2num(aa(in12+5:in13-1)) str2num(aa(in13+5:in14-1))];
                    ppod.header.parocoefs.D=[str2num(aa(in14+5:in15-1)) ...
                        str2num(aa(in15+5:in16-1))];
                    ppod.header.parocoefs.T=[str2num(aa(in16+5:in17-1)) ...
                        str2num(aa(in17+5:in18-1)) str2num(aa(in18+5:in19-1)) ...
                        str2num(aa(in19+5:in20-1)) str2num(aa(in20+5:in21-1))];
                    ppod.header.OSFREQ=str2num(aa(in3+26:in4-1));
                    if type=='h' || ppod.header.firmware(1)=='7' % HSP Ppod
                        fseek(fid,0,'eof'); % move to end of file
                        pos2 = ftell(fid); % pos2 is overall length of file
                        fseek(fid,8192,'bof'); % move to just past the header
                        nseconds=floor((pos2-8192)/128); % number of full 128-byte one second blocks
                        disp(sprintf('%d seconds of data in the file',nseconds));
                        ppod.time=NaN*ones(1,nseconds);
                        ppod.p_us=NaN*ones(1,nseconds);
                        ppod.t_us=NaN*ones(1,nseconds);
                        ppod.axcount = NaN*ones(1,nseconds);
                        ppod.axcount = NaN*ones(1,nseconds);
                        ppod.axcount = NaN*ones(1,nseconds);
%                         ppod.clock=NaN*ones(1,nseconds);
                        ppod.p_us20=NaN*ones(1,nseconds*20);
%                         ppod.hcy = NaN*ones(1,nseconds*20);
                        ppod.time20 = NaN*ones(1,nseconds*20);
                        % now read the data from the file
                        for ii=1:nseconds
                            btype = fread(fid,1,'uint32=>double');
                            Armtime = fread(fid,1,'uint32=>double');
                            p1hzcycles = fread(fid,1,'uint32=>double');
                            t1hzcycles = fread(fid,1,'uint32=>double');
                            clockcycles = fread(fid,1,'uint32=>double');
                            p1hzcount = fread(fid,1,'uint16=>double');
                            t1hzcount = fread(fid,1,'uint16=>double');
                            
                            axcount = fread(fid,1,'uint16=>double');
                            aycount = fread(fid,1,'uint16=>double');
                            azcount = fread(fid,1,'uint16=>double');
                            dstate = fread(fid,1,'uint16=>double');
                            spare = fread(fid,8,'uint16=>double');
                            hspack=fread(fid,20,'*uint32');
%                             ppod.clock(ii) = clockcycles;
                            ppod.axcount(ii) = axcount;
                            ppod.aycount(ii) = aycount;
                            ppod.azcount(ii) = azcount;
                            ppod.time(ii)=(Armtime)/86400+epoch;
                            ppod.p_us(ii)=(1.0e6 * p1hzcycles/clockcycles)/(64 *p1hzcount);
                            ppod.t_us(ii)=(1.0e6 * t1hzcycles/clockcycles)/(1024 *t1hzcount);
                            % now put the high-speed 20Hz data into the HS pressure period
                            % array
                            hscount = double(hspack/(2^24))*64;
%                             hcy = double((bitand(hspack, (2^24-1))));
                            hscycles =  double((bitand(hspack, (2^24-1))))./clockcycles;
                            hpdtemp = 1.0e6*(hscycles)./ (hscount );
                            ppod.p_us20(ii*20-19:ii*20)= hpdtemp(1:20);
%                             ppod.hcy(ii*20-19:ii*20)= hcy(1:20);
                        end % for ii=1:nseconds
                        % next, interpolate the temperature periods to get t periods at 20hz
                        k = [1:0.050:nseconds+1-0.050];
                        t_us20 = interp1(ppod.t_us,k);
                        ppod.time20 = interp1(ppod.time,k);
                        ppod.readme=char('p_us is pressure in microseconds at 1Hz','p_us20 is pressure in microseconds at 20Hz',...
                            't_us is temperature in microseconds at 1Hz',...
                            'p is absolute pressure in psi at 1Hz','p20 is absolute pressure in psi at 20Hz',...
                            't is temperature in C at 1Hz',...
                            'axcount, aycount & azcount are accelerations in counts (A2D converter counts)');
                        
                    elseif ppod.header.firmware(1)=='6' || ppod.header.firmware(1)=='1' % Ppod6
                        fseek(fid,0,'eof'); % move to end of file
                        pos2 = ftell(fid); % pos2 is overall length of file
                        fseek(fid,8192,'bof'); % move to just past the header
                        nseconds=floor((pos2-8192)/128); % number of full 128-byte one second blocks
                        disp(sprintf('%d seconds of data in the file',nseconds));
                        ppod.p_us=NaN*ones(1,nseconds);
                        ppod.t_us=NaN*ones(1,nseconds);
                        ppod.msptime=NaN*ones(1,nseconds);
                        ppod.ds=NaN*ones(1,nseconds);
                        ppod.msp=NaN*ones(1,nseconds);
                        ppod.boardtemp=NaN*ones(1,nseconds);
                        ppod.p_us40=NaN*ones(1,nseconds*40);
                        ppod.time40=NaN*ones(1,nseconds*40);
                        htemp =NaN*ones(1,nseconds*40);
                        hstemp=NaN*ones(1,40);
                        countoffset = 140000;
                        % now read the data from the file
                        for ii=1:nseconds
                            btype = fread(fid,1,'uint32=>double');
                            msptime = fread(fid,1,'uint32=>double');
                            dstime = fread(fid,1,'uint32=>double');
                            spare = fread(fid,1,'uint32=>double');
                            bdtemp = fread(fid,1,'float32=>double');
                            dummy = fread(fid,1,'uint32=>double');
                            syncint = fread(fid,1,'uint16=>double');
                            dstate = fread(fid,1,'uint16=>double');
                            ppd= fread(fid,1,'float32=>double');
                            tpd= fread(fid,1,'float32=>double');
                            hstemp=fread(fid,40,'uint16=>double');
                            hstemp = 140000 + hstemp;
                            ppod.ds(ii)=dstime;
                            ppod.boardtemp(ii)=bdtemp;
                            ppod.msptime(ii)=(msptime)/86400+double(datenum(1970,1,1));
                            ppod.p_us(ii) = ppd(1);
                            ppod.t_us(ii) = tpd(1);
                            % now put the high-speed 40Hz data into the HS pressure period
                            % array
                            ppod.p_us40(ii*40-39:ii*40)= 1000000*(hstemp(1:40)./ppod.header.OSFREQ)/704.0;
                        end % for ii=1:nseconds
                        % next, interpolate the temperature periods to get t periods at 40hz
                        k = [1:0.025:nseconds+1-0.025];
                        t_us40 = interp1( ppod.t_us,k,'spline');
                        ppod.time40 = interp1(ppod.msptime,k);
                        ppod.readme=char('boardtemp is CPU temperature',...
                            'p_us is pressure in microseconds at 1Hz','p_us40 is pressure in microseconds at 40Hz',...
                            't_us is temperature in microseconds at 1Hz',...
                            'p is absolute pressure in psi at 1Hz','p40 is absolute pressure in psi at 40Hz',...
                            't is temperature in C at 1Hz',...
                            'msp is msp time saved at the beginning of each block',...
                            'ds is accurate RTC time saved at the beginning of each block',...
                            'msptime is based on msp time (this time drifts) interpolated inside each block',...
                            'dstime is updated with an accurate RTC and interpolated inside each block',...
                            'dstime should be used for analysis');
                    elseif ppod.header.firmware(1)=='5'
                        line = 1;
                        sync = 0;
                        pdcounter = 0;
                        fseek(fid,0,'eof'); % move to end of file
                        pos2 = ftell(fid); % pos2 is overall length of file
                        fseek(fid,8192,'bof'); % move to just past the header
                        nblocks=floor((pos2-8192)/984); % number of full 120 sec blocks
                        ntail=floor((mod((pos2-8192),984)-24)/8); % number of measurements in the last block
                        % initialize variables and allocate space
                        ppod.p_us=NaN*ones(1,nblocks*120+ntail);
                        ppod.t_us=NaN*ones(1,nblocks*120+ntail);
                        ppod.msptime=NaN*ones(1,nblocks*120+ntail);
                        %                         ppod.dstime=NaN*ones(1,nblocks*120+ntail);
                        ppod.ds=NaN*ones(1,nblocks);
                        ppod.msp=NaN*ones(1,nblocks);
                        ppod.boardtemp=NaN*ones(1,nblocks*120+ntail);
                        for ii=1:nblocks
                            btype = fread(fid,1,'uint32=>double');
                            msptime = fread(fid,1,'uint32=>double');
                            dstime = fread(fid,1,'uint32=>double');
                            spare = fread(fid,1,'uint32=>double');
                            bdtemp = fread(fid,1,'float32=>double');
                            syncint = fread(fid,1,'uint16=>double');
                            dstate = fread(fid,1,'uint16=>double');
                            ppdtpd= fread(fid,240,'float32=>double');
                            ppod.p_us(ii*120-119:ii*120)=ppdtpd(1:2:end);
                            ppod.t_us(ii*120-119:ii*120)=ppdtpd(2:2:end);
                            ppod.msptime(ii*120-119:ii*120)=(msptime+[0:119])/86400+epoch;
%                             ppod.dstime(ii*120-119:ii*120)=(dstime+[0:119])/86400+epoch;
                            ppod.msp(ii)=msptime;
                            ppod.ds(ii)=dstime;
                            ppod.boardtemp(ii*120-119:ii*120)=bdtemp;
                        end % for ii=1:nblocks
                        ppod.dstime=interp1([1:120:nblocks*120-119],ppod.ds,[1:nblocks*120],'linear','extrap');
                        % now read the last unfinished block
                        if ntail>0
                            btype = fread(fid,1,'uint32=>double');
                            msptime = fread(fid,1,'uint32=>double');
                            dstime = fread(fid,1,'uint32=>double');
                            spare = fread(fid,1,'uint32=>double');
                            bdtemp = fread(fid,1,'float32=>double');
                            syncint = fread(fid,1,'uint16=>double');
                            dstate = fread(fid,1,'uint16=>double');
                            ppdtpd= fread(fid,240,'float32=>double');
                            ppod.p_us(ii*120+1:ii*120+ntail)=ppdtpd(1:2:end-1);
                            ppod.t_us(ii*120+1:ii*120+ntail)=ppdtpd(2:2:end);
                            ppod.msp(ii)=msptime;
                            ppod.ds(ii)=dstime;
                            ppod.msptime(ii*120+1:ii*120+ntail)=(msptime+[0:ntail-1])/86400+epoch;
%                             ppod.dstime(ii*120+1:ii*120+ntail)=(dstime+[0:ntail-1])/86400+epoch;
%                             ppod.dstime=interp1([1:length(ppod.dstime)+1],[ppod.dstime dstime],[1:length(ppod.dstime)+ntail],'linear','extrap');
                            ppod.boardtemp(ii*120+1:ii*120+ntail)=bdtemp;
                        end % if ntail>0
                        ppod.dstime(end+1:length(ppod.msptime))=ppod.dstime(end)+...
                            [1:length(ppod.msptime)-length(ppod.dstime)]*mean(diff(ppod.dstime));
                        ppod.dstime=ppod.dstime/86400+epoch;
                        ppod.msp=ppod.msp/86400+epoch;
                        ppod.ds=ppod.ds/86400+epoch;
                        ppod.readme=char('boardtemp is CPU temperature','p_us is pressure in microseconds',...
                            't_us is temperature in microseconds','p is absolute pressure in psi',...
                            't is temperature in C',...
                            'msp is msp time saved at the beginning of each block',...
                            'ds is accurate RTC time saved at the beginning of each block',...
                            'msptime is based on msp time (this time drifts) interpolated inside each block',...
                            'dstime is updated with an accurate RTC and interpolated inside each block',...
                            'dstime should be used for analysis');
                    else
                        fseek(fid,1024,'bof');
                        TMPOFF=0.985;
                        dfactor=64;
                        matlab_sec(1:120)= [0  double([1:119])./double(86400.0) ];
                        oldtime= -1;
                        Y=zeros(1,3)* NaN;
                        C=zeros(1,3)* NaN;
                        D=zeros(1,2)* NaN;
                        T=zeros(1,5)* NaN;
                        bln=0;
                        while ~feof(fid)
                            %**** READ BLOCK **********
                            % read block marker
                            btype=fread(fid,4,'uchar=>uchar'); %4*8=32 bits=4 bytes
                            if size(btype,1)==4
                                test= (btype ==[187 187 187 187]');
                            else
                                test=0;
                            end
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
                                    d_tmpd1=1e6*(double(tct1)/ppod.header.OSFREQ)...
                                        /(1024*double(tcy1));
                                else d_tmpd1=0.0; end
                                
                                if (tcy2 ~= 0)
                                    d_tmpd2=1e6*(double(tct2)/ppod.header.OSFREQ)...
                                        /(1024*double(tcy2));
                                else
                                    d_tmpd2=0.0;
                                end
                                
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
                                    1e6*(double(fcount)/ppod.header.OSFREQ)./(dfactor.*double(fcy));
                                
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
                            end % if sum(test)==4
                        end % while ~feof(fid)
                        % When elapsed between two blocks real time (rounded to 1 sec)
                        % happens to be 121 sec we get 0's in our arrays,
                        % because there are still 120 data points in the block.
                        % We linearly interpolate into these periods.
                        good=find(ppod.time~=0);
                        ppod.time=interp1(good,ppod.time(good),[1:length(ppod.time)]);
                        ppod.boardtemp=interp1(good,ppod.boardtemp(good),[1:length(ppod.time)]);
                        ppod.p_us=interp1(good,ppod.p_us(good),[1:length(ppod.time)]);
                        ppod.t_us=interp1(good,ppod.t_us(good),[1:length(ppod.time)]);
                        ppod.readme=char('boardtemp is CPU temperature','p_us is pressure in microseconds',...
                            't_us is temperature in microseconds','p is absolute pressure in psi',...
                            't is temperature in C',...
                            'PLEASE NOTE:',...
                            'CPU clock drifts, but real time (within 1 sec) is saved once every',...
                            '120 measurements. When elapsed between two blocks real time (rounded to 1 sec)',...
                            'happens to be 119 sec we overwrite one value from the previous block.',...
                            'When elapsed between two blocks real time (rounded to 1 sec)',...
                            'happens to be 121 sec we insert in the block a ficticious 121st "measurement".');
                    end % if ppod.header.firmware(1)=='5'
                    if isfield(ppod.header,'parocoefs')
                        [ppod.p,ppod.t]=convert_paro2(ppod.header.parocoefs.U0,...
                            ppod.header.parocoefs.Y,ppod.header.parocoefs.C,...
                            ppod.header.parocoefs.D,ppod.header.parocoefs.T,ppod.p_us,ppod.t_us);
                        if isfield(ppod,'p_us20')
                            [ppod.p20,t20]=convert_paro2(ppod.header.parocoefs.U0,...
                                ppod.header.parocoefs.Y,ppod.header.parocoefs.C,...
                                ppod.header.parocoefs.D,ppod.header.parocoefs.T,ppod.p_us20,t_us20);
                        end
                        if isfield(ppod,'p_us40')
                            [ppod.p40,t40]=convert_paro2(ppod.header.parocoefs.U0,...
                                ppod.header.parocoefs.Y,ppod.header.parocoefs.C,...
                                ppod.header.parocoefs.D,ppod.header.parocoefs.T,ppod.p_us40,t_us40);
                        end
                    end
%                 end % try
            end % if fid
%             ppod.boardtemp(ppod.boardtemp==0)=NaN;
            fclose all;
            save([fname '.mat'],'ppod')
        end %~isempty(strfind(d(jj).name,'.mat'))
    end % for ii=1:length(d)
end % if type=='a'
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
            ppod.readme=char('p is absolute pressure in psi');
            save([fname '.mat'],'ppod')
        end
    end
end % if type=='i'
%% convert ppod 5,6&7
function [pressure, temperature]= convert_paro2( u0, y ,c ,d ,t ,pp ,tp )
% use calibration coefficients 
% paroscientific model 2200A
% pp is pressure period in uS
% tp is temperature period in uS
u= tp -u0 ;  % tp is temperature period
if length(y)==2
    temperature =(y(1).*u) + (y(2).*u.^2);
elseif length(y)==3
    temperature =(y(1).*u) + (y(2).*u.^2) +( y(3).*u.^3 ) ;
end
cee=c(1)+ (c(2).*u) + (c(3).*u.^2) ;
dee=d(1)+ (d(2).*u);
t0 =t(1)+ (t(2).*u) + (t(3).*u.^2) + (t(4).*u.^3)+ (t(5).*u.^4) ;
aa=1-(t0.^2./double(pp) .^2);
pressure =cee.*aa.*(1-dee.*aa);
return;
