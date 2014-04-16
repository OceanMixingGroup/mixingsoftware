function sbd = read_seabird_HOME2000(pname,prefix,fnum,plot); 
% sbd = read_seabird_HOME2000(pname,fname,plot); 
%
%	OK - this is critical - the o/p series bb contains a number that
%	represents the number of 5Mhz clock cycles counted by the counter
%	card in 1000 SeaBird zero crossings
%	we determine frequency from this as
%		frequency = #zero_crossings * 5e6/(#clock_cycles)
%	
%	prior to HOME (m99b for example) we counted 2000 cycles
% 	so old conversions from counts to frequency (in kHz) were 
%					f_t = 1.0e07./(bb(2:2:length(bb)))
%					f_c = 1.0e07./(bb(1:2:length(bb)));
%
%	after m99b that we decided to count 1000 cycles
%	new conversion is 
%					f_t = 5.0e06./(bb(2:2:length(bb)))
%					f_c = 5.0e06./(bb(1:2:length(bb)));
%

fname = sprintf('%s%04d.sbd',prefix,fnum);
  
if nargin<4
  plot=0;
end;

NOMRECLEN = 320; %s;
if isempty(fname)
  [fname,pname]= ...
      uigetfile('d:\raw_data\m99b\seabird\reordered\*.sbd',...
		'Seabird File Selection');

end;

fid=fopen([pname fname]);
start_time=char((fread(fid,20))');
end_time=char((fread(fid,20))');
temp_id=char((fread(fid,20))');
cond_id=char((fread(fid,20))');
if 0
  disp(start_time)
  disp(end_time)
  disp(temp_id)
  disp(cond_id)
end;

junk=((fread(fid,1,'float32')));
a=((fread(fid,1,'float32')));
b=((fread(fid,1,'float32')));
c=((fread(fid,1,'float32')));
d=((fread(fid,1,'float32')));
f0=((fread(fid,1,'float32')));
g=((fread(fid,1,'float32')));
h=((fread(fid,1,'float32')));
i=((fread(fid,1,'float32')));
if i~=-0.0025
   i=-0.0025;
end
j=((fread(fid,1,'float32')));
if 0
disp(a)
disp(b)
disp(c)
disp(d)
disp(f0)
disp(g)
disp(h)
disp(i)
disp(j)
end;

bb=fread(fid,'ulong');
%size(bb)
%bs=reshape(bb,2,320);
%f_t=bs(1,:);

%
%	OK - this is critical - the o/p series bb contains a number that
%	represents the number of 5Mhz clock cycles counted by the counter
%	card in 1000 SeaBird zero crossings
%	we determine frequency from this as
%		frequency = #zero_crossings * 5e6/(#clock_cycles)
%	
%	prior to HOME (m99b for example) we counted 2000 cycles
% 	so old conversions from counts to frequency (in kHz) were 
%					f_t = 1.0e07./(bb(2:2:length(bb)))
%					f_c = 1.0e07./(bb(1:2:length(bb)));
%
%	after m99b that we decided to count 1000 cycles
%	new conversion is 
%					f_t = 5.0e06./(bb(2:2:length(bb)))
%					f_c = 5.0e06./(bb(1:2:length(bb)));
%

f_t = 5.0e06./(bb(2:2:length(bb)));
%disp(size(f_t))
%f_c=bs(2,:)/1000;% convert frequency to kHz for
                 % Seabird calibration fit
f_c = 5.0e06./(bb(1:2:length(bb)));
%disp(size(f_c))
% conductivity [S/m] - SeaBird formula 1
cond=(g+h*f_c.^2+i*f_c.^3+j*f_c.^4)./10;

% temperature [C]
var=log(f0./f_t);
temperature=1./(a+b*var+c*var.^2+d*var.^3)-273.15;

salinity=sw_salt(10*cond/sw_c3515,temperature,0);
density=sw_dens(salinity,temperature,0);

sbd.temperature = temperature;
sbd.cond = cond;
sbd.salinity = salinity;
sbd.f_c = f_c;
sbd.f_t = f_t;
sbd.start_time = start_time;
sbd.end_time = end_time;

% make sbd.time....
ttime = sbd.start_time;
hour = str2num(ttime(6:7));
minu = str2num(ttime(9:10));
sec = str2num(ttime(12:13));
yday = str2num(ttime(15:17))-1;
sbd.yday =  yday+((sec/60+minu)/60+hour)/24;
dt = 0.625;
len = length(sbd.f_c);
sbd.yday =  sbd.yday + [0:dt:dt*(len-1)]'/(24*3600);

% make a ptime
sbd.ptime = fnum + [0:dt:dt*(len-1)]'/NOMRECLEN;




if plot
  figure(1)
  subplot(411),plot(temperature);grid
  ylabel('Temp [C]')
  title(['Temperature and Conductivity   '  fname])
  set(gca,'xticklabel','')
  subplot(412),plot(f_t);grid
  set(gca,'xticklabel','')
  ylabel('T-freq (Hz)')
  subplot(413),plot(cond);grid
  % title('Conductivity [S/m]')
  ylabel('Cond [S m^{-1}]')
  set(gca,'xticklabel','')
  subplot(414),plot(f_c);grid
  ylabel('C-freq (kHz)')
  
  figure(2)
  subplot(311), plot(salinity);grid
  title('Salinity, Temperature and Density')
  ylabel('Salinity [psu]')
  set(gca,'xticklabel','')
  subplot(312), plot(temperature);grid
  ylabel('Temperature [^o C]')
  set(gca,'xticklabel','')
  subplot(313), plot(density);grid
  ylabel('Density [kg m^{-3}]')
  xlabel('record number')
end;

