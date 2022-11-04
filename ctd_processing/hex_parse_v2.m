function data = hex_parse_v2(h)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function data = hex_parse_v2(h)
%
% Same as hex_parse, except for files where data.time has slightly
% different format.
%
% Parse hex data from Seabird CTD file.
%
% h is hex data read from CTD file (w/ hex_read.m)
%
% Original code from Jen MacKinnon in 'ctd_proc2' folder.
% Added to 'ctd_processing' folder by A. Pickering - April 2015
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

h = char(h{1}(:)); % hex scans
data.t1 = hexword2freq(h(:, 1:6));
data.c1 = hexword2freq(h(:, 7:12));
data.p = hexword2freq(h(:, 13:18));
data.t2 = hexword2freq(h(:, 19:24));
data.c2 = hexword2freq(h(:, 25:30));

% 2 voltages per 3 words or 6 hex symbols
% ch1, ch3, ch5, ch7 = 0 = not used
data.fl = hexword2volt(h(:, 31:36)); % ch0, ch1
data.trans = hexword2volt(h(:, 37:42)); % ch2, ch3
%data.ch4 = hexword2volt(h(:, 43:48)); % ch4, ch5
data.oxygen = hexword2volt(h(:, 49:54)); % ch6, ch7

%h(55:57) = 0 = not used

%data.spar = hexword2spar(h(:, 58:60));

[data.lon, data.lat] = hexword2lonlat(h(:, 55:68)); % lonneg, latneg ***

end_offset=88-size(h,2);
data.pst = hexword2pststat(h(:, [75:78]-end_offset));
%[data.pst, data.ctdstatus] = hexword2pststat(h(:, 75:78));
data.modcount = hex2dec(h(:, [73:74]-end_offset));

% seconds since 1970/1/1 0000
data.time =  hex2dec(h(:, [87:88 85:86 83:84 81:82]-end_offset)); % original

% following is corresponding line in older version of hex-parse from
% IWISE/LADCP_processing/ctd_proc2/ , which doesn't have the -6 at end..
% data.time =  hex2dec(h(:, [87:88 85:86 83:84 81:82])); 

%%