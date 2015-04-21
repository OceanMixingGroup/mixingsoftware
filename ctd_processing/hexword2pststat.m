  function [pst, ctdstatus] = hexword2pststat(h)
% function [pst, ctdstatus] = hexword2pststat(h)
% each byte is given as two hex digits
% 12 bit number from 0-4095 represents P sensor temperature 
% 4 bit CTD status:
%   bit 0 = pump status = 1/0 = on/off
%   bit 1 = bottom contact = 1/0 = no contact/contact
%   bit 2 = water sampler confirm = 1/0 = deck unit detetcts/does not signal
%   bit 3 = CTD modem carrier detects/does not detect deck unit = 1/0
  
byte1 = dec2bin(hex2dec(h(:, 1:2)), 8);
byte2 = dec2bin(hex2dec(h(:, 3:4)), 8);

pst = bin2dec([byte1 byte2(:, 1:4)]);
ctdstatus = byte2(:, 5:8);
