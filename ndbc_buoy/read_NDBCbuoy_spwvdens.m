function spwvdens=read_NDBCbuoy_spwvdens(dpath,station_id,year)
% read_NDBCbuoy_spwvdens(dpath,station_id,year)
% reads spectral wave density data from NDBC buoy and returns it
% in structure spwvdens
% Spectral wave density - Energy in (meter*meter)/Hz, 
% for each frequency bin (typically from 0.03 Hz to 0.40 Hz).
%
% data should be save in files as: 
% 51028w2004.txt or 51028wb2004.txt
% where 51028 is the station ID and 2004
% is the year when data was collected
% this is hourly data
% dpath - data path
% station_id is the station id (string)
% year - year of measurements

d=dir([dpath station_id 'w*' num2str(year) '*']);
for i=1:length(d)
    fid = fopen([dpath d(i).name]);
    fr=textscan(fid,'%s',1,'delimiter','\n');fr=char(fr{:});
    ik=strfind(fr,'mm');
    if ~isempty(ik);
        fr=fr(ik+2:end);mm=5;
    else
        ik=strfind(fr,'hh');mm=4;
        fr=fr(ik+2:end);
    end
    in=find(fr==' ');
    k=0;
    for j=1:length(in)-1
        if (in(j+1)-in(j))>1
            k=k+1;
            freq(k)=str2num(fr(in(j)+1:in(j+1)-1));
        end
    end
    freq(k+1)=str2num(fr(in(end)+1:end));
    FormatString=repmat('%f',1,length(freq)+mm);
    tx=textscan(fid,FormatString); % Read data
    x=cell2mat(tx);
    fclose(fid);
    if mm==4
        spwvdens(i).time=datenum(x(:,1),x(:,2),x(:,3),x(:,4),0,0);
    else
        spwvdens(i).time=datenum(x(:,1),x(:,2),x(:,3),x(:,4),x(:,5),0);
    end
    spwvdens(i).freq=freq;
    for k=1:length(freq)
        spwvdens(i).pp(:,k)=x(:,k+mm);
    end
end
spwvdens(1).readme=strvcat(['Spectral wave density data from station ' station_id],...
'Owned and maintained by National Data Buoy Center',...
['http://www.ndbc.noaa.gov/station_history.php?station=' station_id],...
'3-meter discus buoy',...
'TIME: Time of the measurement.',...
'FREQ: frequency [Hz] ',...
'PP - Spectral wave density data [m^2/Hz]');
