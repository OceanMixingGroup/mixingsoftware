function d = hex_read(ctdname,nhdrlines)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function d = hex_read(ctdname)
%
% Read hex file from Seabird CTD. Opens header (.hdr) file first to figure out
% many header lines to skip in .hex file.
%
% Original code from Jen MacKinnon in 'ctd_proc2' folder.
% Added to 'ctd_processing' folder by A. Pickering
%
% July 31, 2015 - A. Pickering - add nhdrlines optional input. For cruises
% where .hdr files not saved, just manually specify # of header lines.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

if ~exist('nhdrlines','var')
    
    hdrname = [ctdname(1:end - 4) '.hdr'];
    %disp(['loading: ' hdrname])
    fid = fopen(hdrname);
    
    % figure out how many lines in header
    nhdrlines = 0;
    while 1
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        %disp(tline)
        nhdrlines = nhdrlines + 1;
    end
    fclose(fid);
    
end

%disp(['loading: ' ctdname])

% read in hex file, skipping the header lines
fid = fopen(ctdname);
d = textscan(fid, '%s', 'HeaderLines', nhdrlines);
fclose(fid);

%%
