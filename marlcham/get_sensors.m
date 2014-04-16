function sensors=get_sensors(rawdir,prefix,year)
% function sensors=get_sensors(rawdir,prefix)
% get list of all sensors used in the cruise
% rawdir - directody with raw Chameleon data
% prefix - cruise prefix
% year - year of the cruise
% e.g., rawdir='\\baltic_data\Data\st08\chameleon\raw\';
% prefix='st08';
% $Revision: 1.2 $ $Date: 2009/01/05 17:58:07 $ $Author: aperlin $	

% Originally, A. Perlin, Dec 2008 
q.script.pathname=rawdir;
q.script.prefix=prefix;
sensors=[];
dirdata=dir([q.script.pathname q.script.prefix '*']);
if isempty(dirdata)
    disp('There are no data in your path')
    return
end
read_modify_header=0;
if exist(['modify_header_' prefix],'file')
    read_modify_header=1;
else
    disp(['modify_header_' prefix ' is not found in your path.'])
    cont=input(['Header information will not be corrected. Continue? '],'s');
    if ~strncmpi(cont,'y',1)
        return
    end
end
for i=1:length(dirdata)
    q.script.num=str2num(dirdata(i).name(5:end))*1000;
    disp(i)
%     disp(q.script.num)
    temp1=q;
    clear global head data q
    global data head q
    q=temp1;
    [data head]=raw_load(q);
    if read_modify_header      
        eval(['modify_header_' prefix])
    end
    sensors.cast(i)=q.script.num;
    if length(head.lon.start)==10
        lon_start_b=str2num(head.lon.start(1:3))+str2num(head.lon.start(4:10))/60;
        cham.lon(1,i)=-lon_start_b;
    elseif length(head.lon.start)==11
        lon_start_b=str2num(head.lon.start(1:3))+str2num(head.lon.start(4:11))/60;
        cham.lon(1,i)=-lon_start_b;
    else
        cham.lon(1,i)=NaN;
    end
    if length(head.lat.start)==9
        lat_start_b=str2num(head.lat.start(1:2))+str2num(head.lat.start(3:9))/60;
        cham.lat(1,i)=lat_start_b;
    elseif length(head.lat.start)==10
        lat_start_b=str2num(head.lat.start(1:2))+str2num(head.lat.start(3:10))/60;
        cham.lat(1,i)=lat_start_b;
    else
        cham.lat(1,i)=NaN;
    end
    sensors.compstarttime(i)=datenum(year,0,str2num(head.starttime(end-5:end)))+ datenum(head.starttime(6:13),'HH:MM:SS')-datenum(year,1,1);
    sensors.compendtime(i)=datenum(0,0,str2num(head.endtime(end-5:end)))+ datenum(head.endtime(6:13),'HH:MM:SS')-datenum(year,1,1);
    sensors.gpsstarttime(i)=datenum(year,0,str2num(head.starttime(end-5:end)))+ datenum(head.time.start,'HHMMSS')-datenum(year,1,1);
    sensors.gpsendtime(i)=datenum(year,0,str2num(head.starttime(end-5:end)))+ datenum(head.time.end,'HHMMSS')-datenum(year,1,1);
    in=find(head.instrument=='_');
    sensors.instrument(i)=cellstr(head.instrument(1:in-1));
    in=find(head.sensor_name(:,1)=='P');
    if ~isempty(in)
        ik=find(head.sensor_id(in,:)==' ');
        sensors.P(i)=cellstr(head.sensor_id(in,1:ik(1)-1));
        sensors.P_coef(i,:)=head.coef.P;
        ik=find(head.module_num(in,:)==' ');
        sensors.P_module_num(i)=cellstr(head.module_num(in,1:ik(1)-1));
        sensors.P_filter_freq(i,:)=head.filter_freq(in);
        sensors.P_das_channel_num(i,:)=head.das_channel_num(in);
        sensors.P_offset(i,:)=head.offset(in);
        sensors.P_modulas(i,:)=head.modulas(in);
        sensors.P_num_probes(i,:)=head.num_probes(in);
    end
    in=strmatch('S1',head.sensor_name);
    if ~isempty(in)
        ik=find(head.sensor_id(in,:)==' ');
        sensors.S1(i)=cellstr(head.sensor_id(in,1:ik(1)-1));
        sensors.S1_coef(i,:)=head.coef.S1;
        ik=find(head.module_num(in,:)==' ');
        sensors.S1_module_num(i)=cellstr(head.module_num(in,1:ik(1)-1));
        sensors.S1_filter_freq(i,:)=head.filter_freq(in);
        sensors.S1_das_channel_num(i,:)=head.das_channel_num(in);
        sensors.S1_offset(i,:)=head.offset(in);
        sensors.S1_modulas(i,:)=head.modulas(in);
        sensors.S1_num_probes(i,:)=head.num_probes(in);
    end
    in=strmatch('S2',head.sensor_name);
    if ~isempty(in)
        ik=find(head.sensor_id(in,:)==' ');
        sensors.S2(i)=cellstr(head.sensor_id(in,1:ik(1)-1));
        sensors.S2_coef(i,:)=head.coef.S2;
        ik=find(head.module_num(in,:)==' ');
        sensors.S2_module_num(i)=cellstr(head.module_num(in,1:ik(1)-1));
        sensors.S2_filter_freq(i,:)=head.filter_freq(in);
        sensors.S2_das_channel_num(i,:)=head.das_channel_num(in);
        sensors.S2_offset(i,:)=head.offset(in);
        sensors.S2_modulas(i,:)=head.modulas(in);
        sensors.S2_num_probes(i,:)=head.num_probes(in);
    end
    in=find(head.sensor_name(:,1)=='T' & head.sensor_name(:,2)==' ');
    if ~isempty(in)
        ik=find(head.sensor_id(in,:)==' ');
        sensors.T(i)=cellstr(head.sensor_id(in,1:ik(1)-1));
        sensors.T_coef(i,:)=head.coef.T;
        ik=find(head.module_num(in,:)==' ');
        sensors.T_module_num(i)=cellstr(head.module_num(in,1:ik(1)-1));
        sensors.T_filter_freq(i,:)=head.filter_freq(in);
        sensors.T_das_channel_num(i,:)=head.das_channel_num(in);
        sensors.T_offset(i,:)=head.offset(in);
        sensors.T_modulas(i,:)=head.modulas(in);
        sensors.T_num_probes(i,:)=head.num_probes(in);
    end
    in=strmatch('MHT',head.sensor_name);
    if ~isempty(in)
        ik=find(head.sensor_id(in,:)==' ');
        sensors.MHT(i)=cellstr(head.sensor_id(in,1:ik(1)-1));
        sensors.MHT_coef(i,:)=head.coef.MHT;
        ik=find(head.module_num(in,:)==' ');
        sensors.MHT_module_num(i)=cellstr(head.module_num(in,1:ik(1)-1));
        sensors.MHT_filter_freq(i,:)=head.filter_freq(in);
        sensors.MHT_das_channel_num(i,:)=head.das_channel_num(in);
        sensors.MHT_offset(i,:)=head.offset(in);
        sensors.MHT_modulas(i,:)=head.modulas(in);
        sensors.MHT_num_probes(i,:)=head.num_probes(in);
    end
    in=strmatch('MHC',head.sensor_name);
    if ~isempty(in)
        ik=find(head.sensor_id(in,:)==' ');
        sensors.MHC(i)=cellstr(head.sensor_id(in,1:ik(1)-1));
        sensors.MHC_coef(i,:)=head.coef.MHC;
        ik=find(head.module_num(in,:)==' ');
        sensors.MHC_module_num(i)=cellstr(head.module_num(in,1:ik(1)-1));
        sensors.MHC_filter_freq(i,:)=head.filter_freq(in);
        sensors.MHC_das_channel_num(i,:)=head.das_channel_num(in);
        sensors.MHC_offset(i,:)=head.offset(in);
        sensors.MHC_modulas(i,:)=head.modulas(in);
        sensors.MHC_num_probes(i,:)=head.num_probes(in);
    end
    in=strmatch('C',head.sensor_name);
    if ~isempty(in)
        ik=find(head.sensor_id(in,:)==' ');
        sensors.C(i)=cellstr(head.sensor_id(in,1:ik(1)-1));
        sensors.C_coef(i,:)=head.coef.C;
        ik=find(head.module_num(in,:)==' ');
        sensors.C_module_num(i)=cellstr(head.module_num(in,1:ik(1)-1));
        sensors.C_filter_freq(i,:)=head.filter_freq(in);
        sensors.C_das_channel_num(i,:)=head.das_channel_num(in);
        sensors.C_offset(i,:)=head.offset(in);
        sensors.C_modulas(i,:)=head.modulas(in);
        sensors.C_num_probes(i,:)=head.num_probes(in);
    end
    in=strmatch('W1',head.sensor_name);
    if ~isempty(in)
        ik=find(head.sensor_id(in,:)==' ');
        sensors.W1(i)=cellstr(head.sensor_id(in,1:ik(1)-1));
        sensors.W1_coef(i,:)=head.coef.W1;
        ik=find(head.module_num(in,:)==' ');
        sensors.W1_module_num(i)=cellstr(head.module_num(in,1:ik(1)-1));
        sensors.W1_filter_freq(i,:)=head.filter_freq(in);
        sensors.W1_das_channel_num(i,:)=head.das_channel_num(in);
        sensors.W1_offset(i,:)=head.offset(in);
        sensors.W1_modulas(i,:)=head.modulas(in);
        sensors.W1_num_probes(i,:)=head.num_probes(in);
    end
    in=strmatch('W2',head.sensor_name);
    if ~isempty(in)
        ik=find(head.sensor_id(in,:)==' ');
        sensors.W2(i)=cellstr(head.sensor_id(in,1:ik(1)-1));
        sensors.W2_coef(i,:)=head.coef.W2;
        ik=find(head.module_num(in,:)==' ');
        sensors.W2_module_num(i)=cellstr(head.module_num(in,1:ik(1)-1));
        sensors.W2_filter_freq(i,:)=head.filter_freq(in);
        sensors.W2_das_channel_num(i,:)=head.das_channel_num(in);
        sensors.W2_offset(i,:)=head.offset(in);
        sensors.W2_modulas(i,:)=head.modulas(in);
        sensors.W2_num_probes(i,:)=head.num_probes(in);
    end
    in=strmatch('W3',head.sensor_name);
    if ~isempty(in)
        ik=find(head.sensor_id(in,:)==' ');
        sensors.W3(i)=cellstr(head.sensor_id(in,1:ik(1)-1));
        sensors.W3_coef(i,:)=head.coef.W3;
        ik=find(head.module_num(in,:)==' ');
        sensors.W3_module_num(i)=cellstr(head.module_num(in,1:ik(1)-1));
        sensors.W3_filter_freq(i,:)=head.filter_freq(in);
        sensors.W3_das_channel_num(i,:)=head.das_channel_num(in);
        sensors.W3_offset(i,:)=head.offset(in);
        sensors.W3_modulas(i,:)=head.modulas(in);
        sensors.W3_num_probes(i,:)=head.num_probes(in);
    end
    in=strmatch('AX',head.sensor_name);
    if ~isempty(in)
        ik=find(head.sensor_id(in,:)==' ');
        sensors.AX(i)=cellstr(head.sensor_id(in,1:ik(1)-1));
        sensors.AX_coef(i,:)=head.coef.AX;
        ik=find(head.module_num(in,:)==' ');
        sensors.AX_module_num(i)=cellstr(head.module_num(in,1:ik(1)-1));
        sensors.AX_filter_freq(i,:)=head.filter_freq(in);
        sensors.AX_das_channel_num(i,:)=head.das_channel_num(in);
        sensors.AX_offset(i,:)=head.offset(in);
        sensors.AX_modulas(i,:)=head.modulas(in);
        sensors.AX_num_probes(i,:)=head.num_probes(in);
    end
    in=strmatch('AY',head.sensor_name);
    if ~isempty(in)
        ik=find(head.sensor_id(in,:)==' ');
        sensors.AY(i)=cellstr(head.sensor_id(in,1:ik(1)-1));
        sensors.AY_coef(i,:)=head.coef.AY;
        ik=find(head.module_num(in,:)==' ');
        sensors.AY_module_num(i)=cellstr(head.module_num(in,1:ik(1)-1));
        sensors.AY_filter_freq(i,:)=head.filter_freq(in);
        sensors.AY_das_channel_num(i,:)=head.das_channel_num(in);
        sensors.AY_offset(i,:)=head.offset(in);
        sensors.AY_modulas(i,:)=head.modulas(in);
        sensors.AY_num_probes(i,:)=head.num_probes(in);
    end
    in=strmatch('AZ',head.sensor_name);
    if ~isempty(in)
        ik=find(head.sensor_id(in,:)==' ');
        sensors.AZ(i)=cellstr(head.sensor_id(in,1:ik(1)-1));
        sensors.AZ_coef(i,:)=head.coef.AZ;
        ik=find(head.module_num(in,:)==' ');
        sensors.AZ_module_num(i)=cellstr(head.module_num(in,1:ik(1)-1));
        sensors.AZ_filter_freq(i,:)=head.filter_freq(in);
        sensors.AZ_das_channel_num(i,:)=head.das_channel_num(in);
        sensors.AZ_offset(i,:)=head.offset(in);
        sensors.AZ_modulas(i,:)=head.modulas(in);
        sensors.AZ_num_probes(i,:)=head.num_probes(in);
    end
    in=strmatch('SCAT',head.sensor_name);
    if ~isempty(in)
        ik=find(head.sensor_id(in,:)==' ');
        sensors.SCAT(i)=cellstr(head.sensor_id(in,1:ik(1)-1));
        sensors.SCAT_coef(i,:)=head.coef.SCAT;
        ik=find(head.module_num(in,:)==' ');
        sensors.SCAT_module_num(i)=cellstr(head.module_num(in,1:ik(1)-1));
        sensors.SCAT_filter_freq(i,:)=head.filter_freq(in);
        sensors.SCAT_das_channel_num(i,:)=head.das_channel_num(in);
        sensors.SCAT_offset(i,:)=head.offset(in);
        sensors.SCAT_modulas(i,:)=head.modulas(in);
        sensors.SCAT_num_probes(i,:)=head.num_probes(in);
    end
    in=strmatch('FLR',head.sensor_name);
    if ~isempty(in)
        ik=find(head.sensor_id(in,:)==' ');
        sensors.FLR(i)=cellstr(head.sensor_id(in,1:ik(1)-1));
        sensors.FLR_coef(i,:)=head.coef.FLR;
        ik=find(head.module_num(in,:)==' ');
        sensors.FLR_module_num(i)=cellstr(head.module_num(in,1:ik(1)-1));
        sensors.FLR_filter_freq(i,:)=head.filter_freq(in);
        sensors.FLR_das_channel_num(i,:)=head.das_channel_num(in);
        sensors.FLR_offset(i,:)=head.offset(in);
        sensors.FLR_modulas(i,:)=head.modulas(in);
        sensors.FLR_num_probes(i,:)=head.num_probes(in);
    end
end
