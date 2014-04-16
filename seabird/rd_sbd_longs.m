function [temperature,cond,start_time,end_time,f_c,f_t]=rd_sbd_longs(pname,fname)

fid=fopen([pname fname]);
start_time=char((fread(fid,20))');
end_time=char((fread(fid,20))');
temp_id=char((fread(fid,20))');
cond_id=char((fread(fid,20))');
%%disp(start_time);
%%disp(end_time);
%disp(temp_id);
%disp(cond_id);
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
%disp(a);
%disp(b);
%disp(c);
%disp(d);
%disp(f0);
%disp(g);
%disp(h);
%disp(i);
%disp(j);

bb=fread(fid,'ulong');
size(bb);
%bs=reshape(bb,2,320);

%f_c=bs(2,:)/1000;% convert frequency to kHz for
                 % Seabird calibration fit
f_c = 1.0e07./(bb(1:2:length(bb)));
%%disp(size(f_c))
% conductivity [S/m] - SeaBird formula 1
cond=(g+h*f_c.^2+i*f_c.^3+j*f_c.^4)./10;


%f_t=bs(1,:);
f_t = 1.0e07./(bb(2:2:length(bb)));
%%disp(size(f_t))

% fix for reordering f_t due to wierdness at begining Aug. 99
% cruise
%for ii=1:floor(length(f_t)/5)
%   A= f_t(5*(ii-1)+1:5*ii);
%   B= [A(5);A(1:4)];
%   f_t(5*(ii-1)+1:5*ii)=B;
%end

% temperature [C]
var=log(f0./f_t);
temperature=1./(a+b*var+c*var.^2+d*var.^3)-273.15;

