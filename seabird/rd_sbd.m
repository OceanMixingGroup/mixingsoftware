% function to read seabird files 


%FILE *stream;
%unsigned short data[1280];
%char start_time[20], endtime[20], seabird_temp_ID[20], seabird_cond_ID[20];

%stream = fopen("qqqq0001.sbd","r+b");

%fread( start_time, sizeof(char), 20, stream);
%fread( end_time, sizeof(char), 20, stream);
%fread( seabird_temp_ID, sizeof(char), 20, stream);
%fread( seabird_cond_ID, sizeof(char), 20, stream);
%fread( (char *)data, sizeof(unsigned short), 1280, stream);

%fclose(stream);
%[fname,pname]=uigetfile('*.sbd','Seabird FIle Selection');
% fname=input('enter file name: ','s');

function [temperature,cond,start_time,end_time,f_c,f_t]=rd_sbd(pname,fname)

fid=fopen([pname fname]);
start_time=char((fread(fid,20))');
end_time=char((fread(fid,20))');
temp_id=char((fread(fid,20))');
cond_id=char((fread(fid,20))');
disp(start_time)
disp(end_time)
%disp(temp_id)
%disp(cond_id)
junk=((fread(fid,1,'float32')));
a=((fread(fid,1,'float32')));
b=((fread(fid,1,'float32')));
c=((fread(fid,1,'float32')));
d=((fread(fid,1,'float32')));
f0=((fread(fid,1,'float32')));
g=((fread(fid,1,'float32')));
h=((fread(fid,1,'float32')));
i=((fread(fid,1,'float32')));
j=((fread(fid,1,'float32')));

bb=fread(fid,'ushort');
sr=2; %sample rate [Hz]
size(bb);
%bs=reshape(bb,2,320);
%f_t=bs(1,:);
f_t = sr*bb(1:2:length(bb));
%disp(size(f_t))
%f_c=bs(2,:)/1000;% convert frequency to kHz for
                 % Seabird calibration fit
f_c = sr*bb(2:2:length(bb))/1000;
%disp(size(f_c))
% conductivity [S/m] - SeaBird formula 1
cond=(g+h*f_c.^2+i*f_c.^3+j*f_c.^4)./10;

% temperature [C]
var=log(1000*f0./f_t);
temperature=1./(a+b*var+c*var.^2+d*var.^3)-273.15;

%figure(1)
%subplot(411),plot(temperature);grid
%ylabel('Temp [C]')
%title(['Temperature and Conductivity   '  fname])
%set(gca,'xticklabel','')
%subplot(412),plot(f_t);grid
%set(gca,'xticklabel','')
%ylabel('T-freq (Hz)')
%subplot(413),plot(cond);grid
% title('Conductivity [S/m]')
%ylabel('Cond [S m^{-1}]')
%set(gca,'xticklabel','')
%subplot(414),plot(f_c);grid
%ylabel('C-freq (kHz)')

%figure(2)
%salinity=sw_salt(10*cond/sw_c3515,temperature,0);
%density=sw_dens(salinity,temperature,0);
%subplot(311), plot(salinity);grid
%title('Salinity, Temperature and Density')
%ylabel('Salinity [psu]')
%set(gca,'xticklabel','')
%subplot(312), plot(temperature);grid
%ylabel('Temperature [^o C]')
%set(gca,'xticklabel','')
%subplot(313), plot(density);grid
%ylabel('Density [kg m^{-3}]')
%xlabel('record number')
