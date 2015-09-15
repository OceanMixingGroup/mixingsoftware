function inds=calc_order(series_name,depth_name)
% function INDS=CALC_ORDER(SERIES_NAME,DEPTH_NAME) determines the reordered
% profile for SERIES_NAME and creates a variable cal.SERIES_NAME_ORDER.  It
% also creates a variable cal.THORPE_{SERIES_NAME} for the Thorpe displacements.
% the length of each of these is the same as the DEPTH series.
% This routine assumes that any series starting with a T is temperature,
% otherwise it is density.  Also, this uses cal.fallspd to determine whether
% we are profiling up or down ; positve fallspeeds correspond to downward profiling

global cal head

eval(['seriesvar=cal.' upper(series_name) ';,depth=cal.' upper(depth_name) ... 
      ';,irep_t=head.irep.' upper(series_name) ';,irep_p=head.irep.' ...
      upper(depth_name) ';']);

if irep_p ~= irep_t
  seriesvar=seriesvar(1:irep_t/irep_p:length(seriesvar));
end

% Check to see how the seriesvar is oriented: assume that any seriesvar starting
% with a T is temperature, otherwise it is density.
test=mean(cal.FALLSPD>0) ;
if (test & upper(series_name(1))=='T') | (~test & upper(series_name(1))~='T')
  [Tth,inds]=sort(-seriesvar);
  Tth=-Tth;
 else
  [Tth,inds]=sort(seriesvar);
end
% if any(strcmp(fieldnames(cal),'THORPE'))
eval(['cal.THORPE_' upper(series_name) '(inds,1)=(depth(inds)-depth(1:length(depth)));'])
eval(['head.irep.THORPE_' upper(series_name) '=irep_p;'])
%  else
%    cal.THORPE=depth(inds)-depth(1:length(depth));
%    head.irep.THORPE=irep_p;
%  end    
eval(['cal.' upper(series_name) '_ORDER=Tth;']);
eval(['head.irep.' upper(series_name) '_ORDER=irep_p;']);
