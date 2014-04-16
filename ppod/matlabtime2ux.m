function [ ux ]= matlabtime2ux( ml )
% convert unix time to matlabtime

ux = (ml -datenum(1970,1,1) ) .* (24*60*60) ; 

return;


