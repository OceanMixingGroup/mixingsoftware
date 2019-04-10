function [data] = raw_load_solo()
%com_load_solo loads a compressed data file which has been uploaded from ChiSolo
%   The ChiSolo cmpressed data files
% 


% /*******************************************************************
%      This is the output data structure written to the compressed data
%      file with a subset sent by satellite
%  *********************************************************************/
% struct ofiletype {
%   uint32_t unixseconds;  // start of collection interval

%   float pMean;
%   float t1Mean, t1Var;
%   float t2Mean, t2Var;
%   float t1PVar, t2PVar; //
%   float s1Var, s2Var;   // shear probe variances
%   float wMean, wVar;    // pitot mean and variance
%   float axMean, ayMean, azMean;
%   float axVar, ayVar, azVar;
%   float headingMean, pitchMean, rollMean;    // from 4Hz data
%   // 1 4-byte integer and 20 4-byte floats or 84 bytes
%   uint32_t validbins;  // 88 bytes to here3
%   float t1PAmplitudes[MAXMAGBINS];   // bin averaged t' PSD amplitudes
%   float t2PAmplitudes[MAXMAGBINS];   // maxmagbins = 25
%   float s1Amplitudes[MAXMAGBINS];   // frequencies are constant over deployment
%   float s2Amplitudes[MAXMAGBINS];   // and kept in header file
%   // amplitudes take up 100 4-byte words or 400 bytes
%   // total packet length is 488 bytes
% };



[raw_name,temp,filterindex]=uigetfile('*.*','Load Binary File');
filnam=[temp raw_name];

fid = fopen(filnam,'r');
% first get the number of bytes in file
fseek(fid,0,'eof'); % move to end of file
pos2 = ftell(fid); % pos2 is overall length of file
frewind(fid); % move back to beginning of file
nrecs = pos2/488;

disp(sprintf('%d 5-second records in the file',nrecs));
tbase = double(datenum(1970,1,1));
for i =1:nrecs
    data.secs(i,1) = fread(fid,1,'uint32');
    data.time(i,1) = data.secs(i)/86400.0 + tbase;
    data.pMean(i,1) = fread(fid,1,'single');
    data.t1Mean(i,1) = fread(fid,1,'single');
    data.t1Var(i,1) = single(fread(fid,1,'single'));
    data.t2Mean(i,1) = fread(fid,1,'single');
    data.t2Var(i,1) = fread(fid,1,'single');
    data.t1PVar(i,1) = fread(fid,1,'single');
    data.t2PVar(i,1) = fread(fid,1,'single');
    data.s1Var(i,1) = fread(fid,1,'single');
    data.s2Var(i,1) = fread(fid,1,'single');
    data.wMean(i,1) = fread(fid,1,'single');
    data.wVar(i,1) = fread(fid,1,'single');
    data.axMean(i,1) = fread(fid,1,'single');
    data.ayMean(i,1) = fread(fid,1,'single');
    data.azMean(i,1) = fread(fid,1,'single');
    data.axVar(i,1) = fread(fid,1,'single');
    data.ayVar(i,1) = fread(fid,1,'single');
    data.azVar(i,1) = fread(fid,1,'single');
    data.headingMean(i,1) = fread(fid,1,'single');
    data.pitchMean(i,1) = fread(fid,1,'single');
    data.rollMean(i,1) = fread(fid,1,'single');
    data.validbins(i,1) = fread(fid,1,'uint32');
    mvals = fread(fid,[25,4],'single');
    data.t1PAmplitudes(i,1:data.validbins) = mvals(1:data.validbins,1);
    data.t2PAmplitudes(i,1:data.validbins) = mvals(1:data.validbins,2);
    data.s1Amplitudes(i,1:data.validbins) = mvals(1:data.validbins,3);
    data.s2Amplitudes(i,1:data.validbins) = mvals(1:data.validbins,4);

end


fclose(fid);
end
