function out=read_metstation_03stb(fname)
fid=fopen(fname);
data=textscan(fid,'%s',1e6,'delimiter','\r');
fclose(fid);
data=char(data{:});
ik=strmatch('META_DATA_PRECISION',data);
out.readme=data(1:ik,:);
out.readme=char('Backup metstation','Use metstation_bow when possible',...
    'P - pressure [hPa]','T_air - air temperature [degC]',...
    'RH - relative humidity [%]','T_wetbulb - wet bulb temperature [degC]',...
    'T_dewpoint - dewpoint temperature [degC]',...
    'AH - absolute humidity [g/m^3]',out.readme);
tt=data(ik+1:end,:);
tt(:,end+1)=',';

% frm='%s %s %s %f %s %f %s %f %s %f %s %f %s %s %s %s %s %s %s %s %s %s';
frm='%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s';
data=textscan(tt',frm,size(tt,1),'delimiter',',','bufsize',1e6);

%time
tm=char(data{2});
if strcmp(tm(1,1),'"') == 1
    tm = tm(:,2:end-1);
end
out.time=datenum(tm(:,1:10))+datenum(tm(:,12:23))-fix(datenum(tm(:,12:23)));

% pressure
if strcmp(data{4}(1),'********') == 1
    out.P = NaN*data.time;
else
    out.P=str2num(char(data{4}));
end

% T_air
if strcmp(data{6}(1),'********') == 1
    out.T_air = NaN*out.time;
else
    out.T_air=str2num(char(data{6}));
end

% T_wetbulb
if strcmp(data{10}(1),'********') == 1
    out.T_wetbulb = NaN*out.time;
else
    out.T_wetbulb = str2num(char(data{10}));
end


% T_dewpoint
if strcmp(data{12}(1),'********') == 1
    out.T_dewpoint = NaN*out.time;
else
    out.T_dewpoint = str2num(char(data{12}));
end


% relative humidity
if strcmp(data{8}(1),'********') == 1
    out.RH = NaN*out.time;
else
    out.RH = str2num(char(data{8}));
end


% absolute humidity
if strcmp(data{14}(1),'********') == 1
    out.AH = NaN*out.time;
else
    out.AH = str2num(char(data{14}));
end



