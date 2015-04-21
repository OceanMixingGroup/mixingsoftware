  function [lon, lat, newpos] = hexword2lonlat(h)
% function [lon, lat, newpos] = hexword2lonlat(h)

% each byte is given as two hex digits
% each SB word is 3 bytes
% calculates lon and lat from 3 byte word
  
b = dec2bin(hex2dec(h(:, 13:14)), 8);
newpos = str2num(b(1,8)); % 1/0 = new/old position
latneg = str2num(b(1,1)); 
lonneg = str2num(b(1,2));

lat = (-1).^latneg*(hex2dec(h(:, 1:2))*65536 + hex2dec(h(:, 3:4))*256 + hex2dec(h(:, 5:6)))/5e4;
lon = (-1).^lonneg*(hex2dec(h(:, 7:8))*65536 + hex2dec(h(:, 9:10))*256 + hex2dec(h(:, 11:12)))/5e4;
