function out=ch(in)
% function out=ch(in) converts the raw integer UINT8 signal from 
% chameleon into (DOUBLE) voltage (-4.5 V to +4.5 V)  
    
out=((double(in(:,1))+256*double(in(:,2)))/32768-1)*4.5;