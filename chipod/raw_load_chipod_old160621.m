function [data head]=raw_load_chipod(filnam)
%
% function [data head]=raw_load_chipod(filnam)
%
% read chipod data structure
%
% Modified 4/11/05 to read 65Hz data
% Modified 05/10/07
% Modified 05/24/10 to read Chipod2
% Modified 12/21/10 to read MPChipod2
% global data head
%   $Revision: 1.12 $  $Date: 2011/02/17 22:46:47 $

if nargout<2
  % if no output arguments, assume that we want the globalized
  % version.  
  global data head
end 
data=[];
head=[];
if nargin<1
    [raw_name,temp]=uigetfile('*.*','Load Binary File');
    filnam=[temp raw_name];
    if raw_name==0
        error('File not found')
        return
    end
end
epoch=datenum(1970,1,1);%reference time - times written in days since epoch

data_temp.cmp = [];
fid = fopen(filnam,'r','l');
if fid==-1
    disp('No file found...')
    data=[];head=[];
    return
end
% read header
head.thisfile=filnam;
head.version  = fread(fid,1,'int32=>double','b');
if head.version==80; % Chipod2
    F=fread(fid,2,'uchar');
    head.maxsensors=F(1);
    head.numberchannels=F(2);
    head.inst_id = fread(fid, 16, 'char=>char')';
    head.cf2_id = fread(fid, 16, 'char=>char')';
    head.AD_convertor_id = fread(fid, 16, 'char=>char')';
    head.primary_sample_rate = fread(fid, 1, 'uint16=>double');
    for n = 1:head.maxsensors
        sensor_name= upper(fread(fid, 12, 'char=>char')');
        sensor_name(sensor_name=='''')='P';
        head.sensor_name(n,(1:12))=sensor_name;
        head.module_num(n,1:10) = fread(fid, 10, 'char=>char')';
        head.calibration_id(n,1:12) = fread(fid, 12, 'char=>char')';
        head.filter_freq(n) = fread(fid, 1, 'float32=>double')';
        head.oversample(n) = fread(fid, 1, 'uint16=>double');
        head.offset(n) = fread(fid, 1, 'uint16=>double');
        head.das_channel_num(n) = fread(fid, 1, 'uint16=>double');
        head.sensor_id(n,1:12) = fread(fid, 12, 'char=>char')';
         head.coef.(head.sensor_name(n, regexpi(head.sensor_name(n,1:5),'\w'))) = ...
               fread(fid,5,'float32=>double');
         head.sensor_index.(head.sensor_name(n, regexpi(head.sensor_name(n,:),'\w'))) = n;
    end 
    head.samplerate=head.primary_sample_rate./head.oversample;
    head.submax_oversample=max(setdiff(head.oversample,20));
    head.slow_samp_rate=min(head.samplerate);
    head.modulas=head.samplerate./head.slow_samp_rate;
    for n = 1:head.maxsensors
         head.irep.(head.sensor_name(n, regexpi(head.sensor_name(n,:),'\w')))  = ...
               head.samplerate(n)./head.slow_samp_rate;
    end
    status = fseek(fid,76*(head.numberchannels-head.maxsensors),'cof');
    head.filename=fread(fid,32, 'char=>char')';
    head.init_gps_position=fread(fid,32,'char=>char')';
    head.end_gps_position=fread(fid,32,'char=>char')';
    junk=fread(fid,4,'uint32');
    head.deploy_depth = fread(fid, 1,'float32=>double')';
    head.comments = fread(fid,52,'char=>char')';
    % go to the beginning of the data
    status = fseek(fid,8192,'bof');
    % read all data
    dta=fread(fid,Inf,'uint16=>double');
    dat=reshape(dta,11,length(dta)/11);
    tt=dat(1,:)+dat(2,:).*2^16;
    data.tick=dat(3,:)';
    data.datenum=epoch+tt'/86400+data.tick/8640000;
    % find beginning of the first block and end of the last block
    % block starts from tick=1
    modtick=find(mod(data.tick,20)==1);starttick=modtick(1);
    endtick=modtick(end)-1;
    startdta=(starttick-1)*11+1;
    enddta=endtick*11;
    data.datenum=data.datenum(starttick:endtick);
    data.tick=data.tick(starttick:endtick);
    dta=dta(startdta:enddta);
    offset=head.offset;
    kk=0;
    for ii=0:8:max(head.offset)+10
        kk=kk+1;
        ind=find(head.offset>=ii & head.offset<ii+8);
        offset(ind)=offset(ind)+kk*3+1;
    end
%     rate=head.primary_sample_rate./head.modulas*2 ...
%         +max(head.modulas)./head.modulas;
    rate=11*head.primary_sample_rate./head.samplerate;
    for ii=1:head.maxsensors
          data.(head.sensor_name(ii, regexpi(head.sensor_name(ii,:),'\w'))) = ...
             dta(offset(ii):rate(ii):end);

    end
    names=fieldnames(data);
    % do not convert following signals
    nm={'datenum','tick','VD','CMP','QUE','MK0','MK1','MK5','MK6'};
    names=setdiff(names,nm);
    % convert to Volts
    for ii=1:length(names)
        data.(char(names(ii)))=data.(char(names(ii)))/65535*4.098;
    end
    fclose(fid);
elseif head.version==96; % MPChipod2
    F=fread(fid,2,'uchar');
    head.maxsensors=F(1);
    head.numberchannels=F(2);
    head.inst_id = fread(fid, 16, 'char=>char')';
    head.cf2_id = fread(fid, 16, 'char=>char')';
    head.AD_convertor_id = fread(fid, 16, 'char=>char')';
    head.primary_sample_rate = fread(fid, 1, 'uint16=>double');
    for n = 1:head.maxsensors
        sensor_name= upper(fread(fid, 12, 'char=>char')');
        sensor_name(sensor_name=='''')='P';
        head.sensor_name(n,(1:12))=sensor_name;
        head.module_num(n,1:10) = fread(fid, 10, 'char=>char')';
        head.calibration_id(n,1:12) = fread(fid, 12, 'char=>char')';
        head.filter_freq(n) = fread(fid, 1, 'float32=>double')';
        head.oversample(n) = fread(fid, 1, 'uint16=>double');
        head.offset(n) = fread(fid, 1, 'uint16=>double');
        head.das_channel_num(n) = fread(fid, 1, 'uint16=>double');
        head.sensor_id(n,1:12) = fread(fid, 12, 'char=>char')';
         head.coef.(head.sensor_name(n, regexpi(head.sensor_name(n,1:5),'\w'))) = ...
               fread(fid,5,'float32=>double');
         head.sensor_index.(head.sensor_name(n, regexpi(head.sensor_name(n,:),'\w'))) = n;
    end
    head.samplerate=head.primary_sample_rate./head.oversample;
    head.submax_oversample=max(setdiff(head.oversample,20));
    head.slow_samp_rate=min(head.samplerate);
    head.modulas=head.samplerate./head.slow_samp_rate;
    for n = 1:head.maxsensors
         head.irep.(head.sensor_name(n, regexpi(head.sensor_name(n,:),'\w')))  = ...
               head.samplerate(n)./head.slow_samp_rate;
    end
    status = fseek(fid,76*(head.numberchannels-head.maxsensors),'cof');
    head.filename=fread(fid,32, 'char=>char')';
    head.init_gps_position=fread(fid,32,'char=>char')';
    head.end_gps_position=fread(fid,32,'char=>char')';
    junk=fread(fid,4,'uint32');
    head.deploy_depth = fread(fid, 1,'float32=>double')';
    head.comments = fread(fid,52,'char=>char')';
    % go to the beginning of the data
    status = fseek(fid,8192,'bof');
    % read all data
    dta=fread(fid,Inf,'uint16=>double');
    dat=reshape(dta,13,length(dta)/13);
    tt=dat(1,:)+dat(2,:).*2^16;
    data.tick=dat(3,:)';
    data.datenum=epoch+tt'/86400+data.tick/8640000;
    % find beginning of the first block and end of the last block
    % block starts from tick=1
    modtick=find(mod(data.tick,20)==1);starttick=modtick(1);
    endtick=modtick(end)-1;
    startdta=(starttick-1)*13+1;
    enddta=endtick*13;
    data.datenum=data.datenum(starttick:endtick);
    data.tick=data.tick(starttick:endtick);
    dta=dta(startdta:enddta);
    offset=head.offset;
    kk=0;
    for ii=0:10:max(head.offset)+12
        kk=kk+1;
        ind=find(head.offset>=ii & head.offset<ii+10);
        offset(ind)=offset(ind)+kk*3+1;
    end
    rate=13*head.primary_sample_rate./head.samplerate;
    for ii=1:head.maxsensors
        data.(head.sensor_name(ii,:))=dta(offset(ii):rate(ii):end);
    end
    names=fieldnames(data);
    % do not convert following signals
    nm={'datenum','tick','VD','CMP','QUE','MK0','MK1','MK5','MK6','MK7','MK8','MK9'};
    names=setdiff(names,nm);
    % convert to Volts
    for ii=1:length(names)
        data.(char(names(ii)))=data.(char(names(ii)))/65535*4.098;
    end
    fclose(fid);
else % Chipod1
    if head.version==16;
        DataPointsPerStructure=1800;
        number_of_sensors=8;
    elseif head.version==32;
        DataPointsPerStructure=1200;
        number_of_sensors=12;
    elseif head.version==48;
        DataPointsPerStructure=1800;
        number_of_sensors=9;
    elseif head.version==64;
        DataPointsPerStructure=1200;
        number_of_sensors=13;
    end
    %     head.version
    head.inst_id = fread(fid, 16, 'char=>char')';
    head.cf2_id = fread(fid, 16, 'char=>char')';
    head.AD_convertor_id = fread(fid, 16, 'char=>char')';
    head.primary_sample_rate = fread(fid, 1, 'uint16=>double');
    for n = 1:number_of_sensors
        sensor_name= upper(fread(fid, 12, 'char=>char')');
        sensor_name(sensor_name=='''')='P';
        head.sensor_name(n,(1:12))=sensor_name;
        head.module_num(n,1:10) = fread(fid, 10, 'char=>char')';
        head.calibration_id(n,1:12) = fread(fid, 12, 'char=>char')';
        head.filter_freq(n) = fread(fid, 1, 'float32=>double')';
        head.oversample(n) = fread(fid, 1, 'uint16=>double');
        head.das_channel_num(n) = fread(fid, 1, 'uint16=>double');
        head.sensor_id(n,1:12) = fread(fid, 12, 'char=>char')';
        coefficients(n,1:5) = fread(fid, 5, 'float32=>double');
    end
    % read the padding
    if head.version==16;
        head.padding = fread(fid, 118, 'char=>char')';
    elseif head.version==32;
        head.padding = fread(fid, 2, 'char=>char')';
    elseif head.version==48;
        head.padding = fread(fid, 44, 'char=>char')';
    end
    head.filename = fread(fid,32,'char=>char')';
    head.init_gps_position = fread(fid,32,'char=>char')';
    head.end_gps_position = fread(fid,32,'char=>char')';
    head.start_cf2_time = fread(fid,1,'uint32=>double');
    head.start_cf2_datenum=epoch+double(head.start_cf2_time)/86400;
    head.end_cf2_time = fread(fid,1,'uint32=>double');
    head.end_cf2_datenum=epoch+double(head.end_cf2_time)/86400;
    head.start_msp_time = fread(fid,1,'uint32=>double');
    head.start_msp_datenum=epoch+double(head.start_msp_time)/86400;
    head.end_msp_time = fread(fid,1,'uint32=>double');
    head.end_msp_datenum=epoch+double(head.end_msp_time)/86400;
    head.deploy_depth = fread(fid,1,'float32=>double');
    if head.version==16;
        head.comments = fread(fid,120,'char=>char')';
    elseif head.version==32;
        head.comments = fread(fid,140,'char=>char')';
    elseif head.version==48;
        head.comments = fread(fid,120,'char=>char')';
    elseif head.version==64;
        head.comments = fread(fid,68,'char=>char')';
    end
    for a=1:number_of_sensors
        data_temp.ch{a} = [];
    end
    
    if head.version==48 || head.version==64
        number_of_sensors=number_of_sensors-1;
    end
    while  feof(fid) == 0
        % read one record
        for n = 1:number_of_sensors
            chx = fread(fid,double(DataPointsPerStructure/head.oversample(n)),'uint16=>double');
            if n <= 8;
                chx = chx / 65536 * 4.096; %1 part in 2^16 Vref 4.096V
            else
                chx = chx / 16384 * 2.5; %4 values added, 1 part in 2^12 Vref 2.5V
            end
            if ~isempty(chx)
                data_temp.ch{n} = vertcat(data_temp.ch{n},chx);
            end;
        end
        % now read compass data
        if head.version==16;
            chx = fread(fid,15,'uint16=>double');% 15 valid values for 8 channels
        elseif head.version==32;
            chx = fread(fid,10,'uint16=>double');% 10 valid values for 12 channels
            %             junk = fread(fid,5,'uint16');% Remove this for files after 3/8/2007 and uncomment the
            %                                          %  next line
        elseif head.version==48;
            chx = fread(fid,15,'uint16=>double');% 15 valid values for 9 channels
        elseif head.version==64;
            chx = fread(fid,10,'uint16=>double');% 10 valid values for 13 channels
        end
        
        if ~isempty(chx)
            data_temp.cmp = vertcat(data_temp.cmp, chx);
        end
    end   %  end of while feof(fid....
    fclose(fid);
    head.samplerate=head.primary_sample_rate./head.oversample;
    head.submax_oversample=max(setdiff(head.oversample,120));
    head.slow_samp_rate=1; % CMP sample rate
    sr=double(head.primary_sample_rate)/double(head.submax_oversample);
    for n=1:number_of_sensors
        if ~isletter(head.sensor_name(n,1))
            if n>1
                head.sensor_name(n,1:7)=head.sensor_name(n-1,1:7);
            else
                head.sensor_name(n,1:7)=head.sensor_name(n+1,1:7);
            end
            head.sensor_name(n,1:7)='No_Name';
        end
        head.coef.(head.sensor_name(n,:))=coefficients(n,:);
        head.irep.(head.sensor_name(n,:))=head.submax_oversample/head.oversample(n);
        head.sensor_index.(head.sensor_name(n,:))=n;
        head.modulas(n)=head.irep.(head.sensor_name(n,:));
        data.(head.sensor_name(n,:))=data_temp.ch{n};
    end
    data.CMP=data_temp.cmp;
    % make time base
    n=find(head.modulas==1);n=n(1);
    time=([1:length(data.(head.sensor_name(n,:)))]'-1)./sr;
    data.datenum=double(head.start_cf2_datenum+time./24./3600);
end


