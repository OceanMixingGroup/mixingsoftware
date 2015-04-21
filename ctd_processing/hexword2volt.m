  function [v1, v2] = hexword2volt(h)
% function [v1, v2] = hexword2volt(h)
% each byte is given as two hex digits
% each SB voltage is 1.5 words (8 MSB + 4 LSB)
% calculates 2 voltages from 3 byte word
 
byte1 = dec2bin(hex2dec(h(:, 1:2)), 8);
byte2 = dec2bin(hex2dec(h(:, 3:4)), 8);
byte3 = dec2bin(hex2dec(h(:, 5:6)), 8);

v1 = bin2dec([byte1 byte2(:, 1:4)]);
v2 = bin2dec([byte2(:, 5:8) byte3]);

v1 = 5*(1 - v1/4095);
v2 = 5*(1 - v2/4095);
