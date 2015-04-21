  function v2 = hexword2spar(h)
% function v2 = hexword2spar(h)
% each byte is given as two hex digits
% each SB voltage is 1.5 words (8 MSB + 4 LSB)
% calculates SPAR voltages from 1.5 byte half word
 
byte2 = dec2bin(hex2dec(h(1)), 4);
byte3 = dec2bin(hex2dec(h(2:3)), 8);
v2 = bin2dec([byte2 byte3])/819;
