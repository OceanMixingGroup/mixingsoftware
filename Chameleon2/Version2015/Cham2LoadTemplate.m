function [tmpl]=Cham2LoadTemplate(filnam)
%  Read and return a Chameleon2 Template
% function header = CHAM2LoadTemplate(filnam)

%
%typedef char tchname[16];
%struct stCham2Template{
%    unsigned long samplerate;
% 	tchname chnames[16];
%    unsigned short chnums[64];    // 388 bytes to here
%    unsigned long baudrate
%    char description[108];  // 496 to here
%    char padding[16];   // 512 byte record size
%}


fid = fopen(filnam,'r');
tmpl.samplerate  = fread(fid,1,'float32=>float32');
for n = 1:16
    tmpl.chnames(n,(1:16)) = fread(fid, 16, 'char=>char');    
end    
% now read the channel numbers vector.  Add one to each channel
% number since matlab starts indices at one, not zero as in the C program
% some have only 32 virtual channels
%tmpl.virtualchannels = 32;
for n = 1:64
    tmpl.chnums(n) = fread(fid, 1, 'uint16=>uint16')+1;
end
% now read and discard an additional 32 words, since templates allow
% for 64 virtual channels also
%skipped = fread(fid,32, 'uint16=>uint16');
% now find out how many of the 64 virtualchannels are actually used
tmpl.virtualchannels = fread(fid, 1,'uint16=>uint16');
tmpl.baudrate = fread(fid,1,'uint32');
% due to irregularities in packing, the description begins at byte 394
fseek(fid,394,'bof');

tmpl.description = fgets(fid, 108);  
fclose(fid);
