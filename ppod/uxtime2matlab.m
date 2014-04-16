function [mlt ]= uxtime2matlab( ux )
% convert unix time to matlabtime

mlt = ux./(24*60*60) + datenum(1970,1,1) ;


return;


