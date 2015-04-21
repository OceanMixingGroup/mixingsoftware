  function f = hexword2freq(h)
% function f = hexword2freq(h)
%
% each byte is given as two hex digits
% each SB freq word is 3 bytes
% calculates freq from 3 byte word
  
f = hex2dec(h(:, 1:2))*256 + hex2dec(h(:, 3:4)) + hex2dec(h(:, 5:6))/256;
