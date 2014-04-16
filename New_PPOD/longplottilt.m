function [alltilt]=longplottilt(headerskip)
% Read one or more tiltlogger data files and plot approximate G levels. 
% If more % than one file is selected, the data is concatenated into a single array.
% Reading will skip past headerskip bytes in each file  because some
% files start with headers and some don't.  
% readtilt uses  fread with skip to speed up structure reads
[raw_name,tpath,filterindex]=uigetfile('*.*','PPOD TiltLogger File(s)','MultiSelect','on');
nfiles = length(raw_name);
alltilt.Armtime = [];
alltilt.Xavg = [];
alltilt.Yavg = [];
alltilt.Zavg = [];

alltilt.Xmin = [];
alltilt.Xmax = [];
alltilt.Ymin = [];
alltilt.Ymax = [];
alltilt.Zmin = [];
alltilt.Zmax = [];

for ii = 1:nfiles
    filnam=[tpath raw_name{1,ii}];
    shortname = raw_name{1,ii};
    disp(sprintf('Reading data from %s',shortname));
    tic;
    % readtilt returns a structure with the 1-second max, min, and average for
    % each axis, as well as the time for each reading

    tilt = readtilt(filnam, headerskip);
    
    alltilt.Armtime = vertcat(alltilt.Armtime, tilt.Armtime);    
    alltilt.Xavg = vertcat(alltilt.Xavg, tilt.Xavg);
    alltilt.Yavg = vertcat(alltilt.Yavg, tilt.Yavg);    
    alltilt.Zavg = vertcat(alltilt.Zavg, tilt.Zavg); 

    alltilt.Xmin = vertcat(alltilt.Xmin, tilt.Xmin);
    alltilt.Ymin = vertcat(alltilt.Ymin, tilt.Ymin);    
    alltilt.Zmin = vertcat(alltilt.Zmin, tilt.Zmin); 

    alltilt.Xmax = vertcat(alltilt.Xmax, tilt.Xmax);
    alltilt.Ymax = vertcat(alltilt.Ymax, tilt.Ymax);    
    alltilt.Zmax = vertcat(alltilt.Zmax, tilt.Zmax); 

    
    % the following may help with debugging and performance analysis
    % toc    % for measuring elapsed time for reading file
end

%  these are rather ad-hoc coefficients to get a normalized plot
%  the tiltlogger results are 0 to 4095 counts (the MSP430 ADC is 12 bits).
%  At 0 G, the result is nominally 2048.  Max and min values occur at
%  + and - 1.5G for the normal settings of the accelerometer gain.
   offset = 2048;
   scale = 2048/1.5;

   aZ = (alltilt.Zavg-offset)./scale;
   aX = (alltilt.Xavg-offset)./scale;
   aY = (alltilt.Yavg-offset)./scale;       
disp('Plotting Acceleration Data');
subplot(3,1,1);
plot(alltilt.Armtime,aX);
datetick('x',23);   % format 23 is mm/dd/yyyy
title('X-Acceleration');

subplot(3,1,2);
plot(alltilt.Armtime,aY);
datetick('x',23);
title('Y-Acceleration');

subplot(3,1,3);
plot(alltilt.Armtime,aZ);
datetick('x',23);
title('Z-Acceleration');

end



