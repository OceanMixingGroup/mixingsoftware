function [inds cal head]=mg_calc_order(series_name,depth_name,cal,head)
% [INDS CAL HEAD]=CALC_ORDER(SERIES_NAME,DEPTH_NAME,CAL,HEAD) determines
% the reordered profile for SERIES_NAME and creates a variable
% cal.SERIES_NAME_ORDER.  It also creates a variable
% cal.THORPE_{SERIES_NAME} for the Thorpe displacements. 
% 
% the length of each of these is the same as the DEPTH series.
% This routine assumes that any series starting with a T is temperature,
% otherwise it is density.  Also, this uses cal.fallspd to determine whether
% we are profiling up or down ; positve fallspeeds correspond to downward
% profiling 

series=cal.(upper(series_name));
depth=cal.(upper(depth_name));

% Check to see how the series is oriented: assume that any series starting
% with a T is temperature, otherwise it is density.
test=mean(cal.FALLSPD)>0;
if (test & upper(series_name(1))=='T') | (~test & upper(series_name(1))~='T')
  [order inds thorpe]=thorpeSort(-series,depth);
  order=-order;
 else
   [order inds thorpe]=thorpeSort(series,depth);
end

cal.(['THORPE_' upper(series_name)])=thorpe;
cal.([upper(series_name) '_ORDER'])=order;
head.irep.(['THORPE_' upper(series_name)])=head.irep.P;
head.irep.([upper(series_name) '_ORDER'])=head.irep.P;
