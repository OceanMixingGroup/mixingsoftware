function d = hex_read(ctdname)
  
hdrname = [ctdname(1:end - 4) '.hdr'];
%disp(['loading: ' hdrname])
fid = fopen(hdrname);
nhdrlines = 0;
while 1
  tline = fgetl(fid);
  if ~ischar(tline), break, end
  %disp(tline)
  nhdrlines = nhdrlines + 1;
end
fclose(fid);

%disp(['loading: ' ctdname])
fid = fopen(ctdname);
d = textscan(fid, '%s', 'HeaderLines', nhdrlines);
fclose(fid);

