function [tilt]=ldtilt(headerskip)
% load a new tiltlogger data file and convert 
% skip past headerskip bytes
% uses fread with skip to speed up structure reads
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


    timeoffset = double(datenum(1970,1,1));
    % now read the data from the file using skip and precision specs
    % skip is 28 minus the size of the element read
    % even though this involves reading through the file once for each
    % element of the structure, it is still about 17 times faster
    % than reading one structure element at a time. (2.2 vs. 36.5 seconds)
    fseek(fid,headerskip,'bof'); % fseek to beginning of actual data
    tilt.Armtime = fread(fid,nseconds,'uint32=>double',24); 
    tilt.Armtime = tilt.Armtime./86400+timeoffset;
    
    fseek(fid, headerskip+4,'bof');
    tilt.Zmin = fread(fid,nseconds,'int16=>double',26);
    fseek(fid, headerskip+6,'bof');    
    tilt.Zmax = fread(fid,nseconds,'int16=>double',26);

    fseek(fid, headerskip+8,'bof');
    tilt.Xmin = fread(fid,nseconds,'int16=>double',26);
    fseek(fid, headerskip+10,'bof');    
    tilt.Xmax = fread(fid,nseconds,'int16=>double',26);

    fseek(fid, headerskip+12,'bof');
    tilt.Ymin = fread(fid,nseconds,'int16=>double',26);
    fseek(fid, headerskip+14,'bof');    
    tilt.Ymax = fread(fid,nseconds,'int16=>double',26);

    fseek(fid, headerskip+16,'bof');
    tilt.Zavg = fread(fid,nseconds,'int32=>double',24);
    tilt.Zavg = tilt.Zavg./100;
    fseek(fid, headerskip+20,'bof');
    tilt.Xavg = fread(fid,nseconds,'int32=>double',24);
    tilt.Xavg = tilt.Xavg./100;
    fseek(fid, headerskip+24,'bof');
    tilt.Yavg = fread(fid,nseconds,'int32=>double',24);
    tilt.Yavg = tilt.Yavg./100;
    

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
       
   tilt.aZ = (tilt.Zavg-Zoff)./Zscale;
   tilt.aX = (tilt.Xavg-Xoff)./Xscale;
   tilt.aY = (tilt.Yavg-Yoff)./Yscale;       

        
fclose(fid);
plot(tilt.Armtime,tilt.aX, tilt.Armtime,tilt.aY,tilt.Armtime,tilt.aZ);
datetick('x',15);
disp(sprintf('X offset: %5.1f   Xscale: %5.1f',Xoff, Xscale));
disp(sprintf('Y offset: %5.1f   Yscale: %5.1f',Yoff, Yscale));
disp(sprintf('Z offset: %5.1f   Zscale: %5.1f',Zoff, Zscale));
toc

end
