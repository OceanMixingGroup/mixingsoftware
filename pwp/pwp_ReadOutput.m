%pwp_ReadOutput Routine to read output of Matlab version of PWP
%
%
% Open Binary Files
fidu = fopen([runname '_u'],'r','b');
fidv = fopen([runname '_v'],'r','b');
fidt = fopen([runname '_t'],'r','b');
fids = fopen([runname '_s'],'r','b');

% Load Data
V = fread(fidv,[nz,inf],'float32');
U = fread(fidu,[nz,inf],'float32');
temp = fread(fidt,[nz,inf],'float32');
sal  = fread(fids,[nz,inf],'float32');

% Close them all
fclose('all');

% Select right time
time = time(tstart:tstop);

% Write MAT File
%save([runname '_Output'],'U','V','time','z','temp','sal');
save([runname '_Output']);%,'U','V','time','z','temp','sal');
