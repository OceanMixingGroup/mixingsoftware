function [data head]=raw_load_chipod(filnam)
% read chi-pod 15-second data structures
% function [data,head]=raw_load_chipod(filnam)
% Modified 4/11/05 to read 65Hz data
% Modified 05/10/07
% global data head
%   $Revision: 1.3 $  $Date: 2008/05/23 18:33:06 $

if nargout<2
  % if no output arguments, assume that we want the globalized
  % version.  
  global data head q
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
DataPointsPerStructure=1200;
epoch=datenum(1970,1,1);%reference time - times written in days since epoch

data_temp.cmp = [];
fid = fopen(filnam,'r')

if(fid)
    % read header
    head.version  = fread(fid,1,'uint32=>uint32','b')
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
    for a=1:number_of_sensors
        data_temp.ch{a} = [];
    end
    head.inst_id = fread(fid, 16, 'char=>char')';
    head.cf2_id = fread(fid, 16, 'char=>char')';
    head.AD_convertor_id = fread(fid, 16, 'char=>char')';
    head.primary_sample_rate = fread(fid, 1, 'uint16=>uint16');
    for n = 1:number_of_sensors
        sensor_name= upper(fread(fid, 12, 'char=>char')');
        sensor_name(find(sensor_name==''''))='P';
        head.sensor_name(n,(1:12))=sensor_name;
        head.module_num(n,1:10) = fread(fid, 10, 'char=>char')';
        head.calibration_id(n,1:12) = fread(fid, 12, 'char=>char')';
        head.filter_freq(n) = fread(fid, 1, 'float=>float')';
        head.oversample(n) = double(fread(fid, 1, 'uint16=>uint16'));
        head.das_channel_num(n) = fread(fid, 1, 'uint16=>uint16');
        head.sensor_id(n,1:12) = fread(fid, 12, 'char=>char')';
        coefficients(n,1:5) = fread(fid, 5, 'float=>float');
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
    head.start_cf2_time = fread(fid,1,'uint32=>uint32');
    head.start_cf2_datenum=epoch+double(head.start_cf2_time)/86400;
    head.end_cf2_time = fread(fid,1,'uint32=>uint32');
    head.end_cf2_datenum=epoch+double(head.end_cf2_time)/86400;
    head.start_msp_time = fread(fid,1,'uint32=>uint32');
    head.start_msp_datenum=epoch+double(head.start_msp_time)/86400;
    head.end_msp_time = fread(fid,1,'uint32=>uint32');
    head.end_msp_datenum=epoch+double(head.end_msp_time)/86400;
    head.deploy_depth = fread(fid,1,'float=>float');
    if head.version==16;
        head.comments = fread(fid,120,'char=>char')';
    elseif head.version==32;
        head.comments = fread(fid,140,'char=>char')';
    elseif head.version==48;
        head.comments = fread(fid,120,'char=>char')';
    elseif head.version==64;
        head.comments = fread(fid,68,'char=>char')';
    end

    if head.version==48 || head.version==64
        number_of_sensors=number_of_sensors-1;
    end
    while  feof(fid) == 0
        % read one record
        for n = 1:number_of_sensors
            chx = fread(fid,double(DataPointsPerStructure/head.oversample(n)),'uint16');
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
            chx = fread(fid,15,'uint16');% 15 valid values for 8 channels
        elseif head.version==32;
            chx = fread(fid,10,'uint16');% 10 valid values for 12 channels
            %             junk = fread(fid,5,'uint16');% Remove this for files after 3/8/2007 and uncomment the
            %                                          %  next line
        elseif head.version==48;
            chx = fread(fid,15,'uint16');% 15 valid values for 9 channels
        elseif head.version==64;
            chx = fread(fid,10,'uint16');% 10 valid values for 13 channels
        end

        if ~isempty(chx)
            data_temp.cmp = vertcat(data_temp.cmp, chx);
        end
    end   %  end of while feof(fid....
    fclose(fid);

    head.submax_oversample=max(setdiff(head.oversample,120));
    head.slow_samp_rate=double(head.primary_sample_rate)/double(head.submax_oversample);
    for n=1:number_of_sensors
        head.coef.(head.sensor_name(n,:))=coefficients(n,:);
        head.irep.(head.sensor_name(n,:))=head.submax_oversample/head.oversample(n);
        head.sensor_index.(head.sensor_name(n,:))=n;
        head.modulas(n)=head.irep.(head.sensor_name(n,:));
        data.(head.sensor_name(n,:))=data_temp.ch{n};
    end
    data.CMP=data_temp.cmp;
    % make time base
    sr=head.slow_samp_rate;
    n=find(head.modulas==1);n=n(1);
    time=([1:length(data.(head.sensor_name(n,:)))]'-1)./sr;
    data.datenum=double(head.start_cf2_datenum+time./24./3600);
end % end of function if no file found

