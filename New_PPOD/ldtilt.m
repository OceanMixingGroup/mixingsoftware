function [tilt]=ldtilt(headerskip)
% load a new tiltlogger data file and convert 
% skip past headerskip bytes
[raw_name,temp,filterindex]=uigetfile('*.*','Load Binary File');
filnam=[temp raw_name];
disp(sprintf('Reading data from %s',raw_name));
fid = fopen(raw_name,'r');
fseek(fid,0,'eof'); % move to end of file
pos2 = ftell(fid) - headerskip; % pos2 is overall length of data portion file
fseek(fid,headerskip,'bof'); % fseek to beginning of actual data
nseconds=floor((pos2)/28); % number of full 28-byte one second blocks
disp(sprintf('%d seconds of data in the file',nseconds));
tic;
% Each second of data contains the following:
%   Armtime     uint32  Unix seconds
%   adc0min 	int16   Accelerometer Z counts
%   adc0max 	int16   
%   adc1min 	int16   Accelerometer X counts
%   adc1max     int16  
%   adc2min     int16  Accelerometer Y count
%   adc2max     int16  
%   adsum0      int32  Sum of 100 Z counts
%   adsum1      int32  
%   adsum2      int32     // 28 bytes total
% initialize variables and allocate space at start, so Matlab doesn't waste
% time increasing the array sizes as data is read into arrays
% the tilt structure is built
	tilt.Armtime = NaN*ones(1,nseconds);
    tilt.Zmin = NaN*ones(1,nseconds);
    tilt.Zmax = NaN*ones(1,nseconds);
    tilt.Xmin = NaN*ones(1,nseconds);
    tilt.Xmax = NaN*ones(1,nseconds);
    tilt.Ymin = NaN*ones(1,nseconds);
    tilt.Ymax = NaN*ones(1,nseconds);
    tilt.Zavg = NaN*ones(1,nseconds);
    tilt.Xavg = NaN*ones(1,nseconds);  
    tilt.Yavg = NaN*ones(1,nseconds);  
    tilt.aZ = NaN*ones(1,nseconds);
    tilt.aX = NaN*ones(1,nseconds);  
    tilt.aY = NaN*ones(1,nseconds);  



    % now read the data from the file
	for ii=1:nseconds
        x = fread(fid,1,'uint32=>double'); 
        tilt.Armtime(ii) = x/86400+double(datenum(1970,1,1));
        %tilt.Armtime(ii) = x;
        x = fread(fid,1,'int16=>double');
        tilt.Zmin(ii) = x;
    	x = fread(fid,1,'int16=>double');
        tilt.Zmax(ii) = x;
    	x = fread(fid,1,'int16=>double');
        tilt.Xmin(ii) = x;
    	x = fread(fid,1,'int16=>double');
        tilt.Xmax(ii) = x;
        x = fread(fid,1,'int16=>double');
        tilt.Ymin(ii) = x;
        x = fread(fid,1,'int16=>double');
        tilt.Ymax(ii) = x;
        x = fread(fid,1,'int32=>double');
        tilt.Zavg(ii) = x/100.0;
        x = fread(fid,1,'int32=>double'); 
        tilt.Xavg(ii) = x/100.0;
        x = fread(fid,1,'int32=>double'); 
        tilt.Yavg(ii) = x/100.0;

       % ppod.Armtime(ii)=(Armtime)/86400+double(datenum(1970,1,1));
    end % for ii=1:nseconds
        tilt.Zmin = min(tilt.Zavg);
        tilt.Zmax = max(tilt.Zavg);
        tilt.Xmin = min(tilt.Xavg);
        tilt.Xmax = max(tilt.Xavg);
        tilt.Ymin = min(tilt.Yavg);
        tilt.Ymax = max(tilt.Yavg);
        Zoff = (tilt.Zmin+tilt.Zmax)/2;
        Xoff = (tilt.Xmin+tilt.Xmax)/2;
        Yoff = (tilt.Ymin+tilt.Ymax)/2;
        Zscale = (tilt.Zmax-tilt.Zmin)/2;
        Xscale = (tilt.Xmax-tilt.Xmin)/2;
        Yscale = (tilt.Ymax-tilt.Ymin)/2;
       
    for ii=1:nseconds
        tilt.aZ(ii) = (tilt.Zavg(ii)-Zoff)/Zscale;
        tilt.aX(ii) = (tilt.Xavg(ii)-Xoff)/Xscale;
        tilt.aY(ii) = (tilt.Yavg(ii)-Yoff)/Yscale;       
    end %  for ii = 1:nseconds
        
fclose(fid);
plot(tilt.Armtime,tilt.aX, tilt.Armtime,tilt.aY,tilt.Armtime,tilt.aZ);
datetick('x',15);
disp(sprintf('X offset: %5.1f   Xscale: %5.1f',Xoff, Xscale));
disp(sprintf('Y offset: %5.1f   Yscale: %5.1f',Yoff, Yscale));
disp(sprintf('Z offset: %5.1f   Zscale: %5.1f',Zoff, Zscale));

toc
end
