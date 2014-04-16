function out=ma(in)
% function out=ma(in) converts the raw integer UINT8 signal from 
% Marlin into (DOUBLE) voltage (-5 V to +5 V)  
    
out=((double(in(:,1))+256*double(in(:,2)))/32768-1)*5;