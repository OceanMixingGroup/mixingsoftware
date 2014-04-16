function spwvdir=read_NDBCbuoy_spwvdir(dpath,station_id,year)
% read_NDBCbuoy_spwvdir(dpath,station_id,year)
% reads spectral wave direction data from NDBC buoy and returns it
% in structure spwvdir
% Spectral wave direction - Mean wave direction, in degrees from true North,
% for each frequency bin. 
% Directional Wave Spectrum = C11(f) * D(f,A), f=frequency (Hz), 
% A=Azimuth angle measured clockwise from true North to the direction wave is from.
% D(f,A) = (1/PI)*(0.5+R1*COS(A-ALPHA1)+R2*COS(2*(A-ALPHA2))). 
% R1 and R2 are the first and second normalized polar coordinates of the 
% Fourier coefficients and are nondimensional. ALPHA1 and ALPHA2 are 
% respectively mean and principal wave directions.
% In terms of Longuet-Higgins Fourier Coefficients
%
%    * R1 = (SQRT(a1*a1+b1*b1))/a0
%    * R2 = (SQRT(a2*a2+b2*b2))/a0
%    * ALPHA1 = 270.0-ARCTAN(b1,a1)
%    * ALPHA2 = 270.0-(0.5*ARCTAN(b2,a2)+{0. or 180.})
%
% data should be save in files as: 
% 51028d2004.txt or 51028db2004.txt for alpha1
% 51028i2004.txt or 51028ib2004.txt for alpha2
% 51028j2004.txt or 51028jb2004.txt for r1
% 51028k2004.txt or 51028kb2004.txt for r2
% where 51028 is the station ID and 2004
% is the year when data was collected
% this is hourly data
% dpath - data path
% station_id is the station ID (string)
% year - year of measurements

if year>2004; mm=5; else mm=4; end
%% alpha1
d=dir([dpath station_id 'd*' num2str(year) '*']);
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
        spwvdir(i).time=datenum(x(:,1),x(:,2),x(:,3),x(:,4),0,0);
    else
        spwvdir(i).time=datenum(x(:,1),x(:,2),x(:,3),x(:,4),x(:,5),0);
    end
    spwvdir(i).freq=freq;
    for k=1:length(freq)
        spwvdir(i).alpha1(:,k)=x(:,k+mm);
    end
end
%% alpha2
d=dir([dpath station_id 'i*' num2str(year) '*']);
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
    FormatString=repmat('%f',1,length(spwvdir(i).freq)+mm);
    tx=textscan(fid,FormatString); % Read data
    x=cell2mat(tx);
    fclose(fid);
    for k=1:length(length(spwvdir(i).freq))
        spwvdir(i).alpha2(:,k)=x(:,k+mm);
    end
end
%% r1
d=dir([dpath station_id 'j*' num2str(year) '*']);
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
    FormatString=repmat('%f',1,length(spwvdir(i).freq)+mm);
    tx=textscan(fid,FormatString); % Read data
    x=cell2mat(tx);
    fclose(fid);
    for k=1:length(length(spwvdir(i).freq))
        spwvdir(i).r1(:,k)=x(:,k+mm);
    end
end
%% r2
d=dir([dpath station_id 'k*' num2str(year) '*']);
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
    FormatString=repmat('%f',1,length(spwvdir(i).freq)+mm);
    tx=textscan(fid,FormatString); % Read data
    x=cell2mat(tx);
    fclose(fid);
    for k=1:length(length(spwvdir(i).freq))
        spwvdir(i).r2(:,k)=x(:,k+mm);
    end
end
%% readme
spwvdir(1).readme=strvcat(['Directional Wave Spectrum data from station ' station_id],...
'Owned and maintained by National Data Buoy Center',...
['http://www.ndbc.noaa.gov/station_history.php?station=' station_id],...
'3-meter discus buoy',...
'TIME: Time of the measurement.',...
'FREQ: frequency [Hz] ',...
'Directional Wave Spectrum = C11(f) * D(f,A), f=frequency (Hz),',... 
'A=Azimuth angle measured clockwise from true North to the ',...
'  direction the wave is coming from.',...
'D(f,A) = (1/PI)*(0.5+R1*COS(A-ALPHA1)+R2*COS(2*(A-ALPHA2))).',... 
'R1 and R2 are the first and second normalized polar coordinates of the',...
'Fourier coefficients and are nondimensional. ALPHA1 and ALPHA2 are',... 
'  respectively mean and principal wave directions.',...
'In terms of Longuet-Higgins Fourier Coefficients',...
'R1 = (SQRT(a1*a1+b1*b1))/a0',...
'R2 = (SQRT(a2*a2+b2*b2))/a0',...
'ALPHA1 = 270.0-ARCTAN(b1,a1)',...
'ALPHA2 = 270.0-(0.5*ARCTAN(b2,a2)+{0. or 180.})');
