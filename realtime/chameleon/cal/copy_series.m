function message=copy_series(old_name,new_name)
% function copy_series(old_name,new_name) copies one series into another
% series.  At the same time, it updates head so that all variables
% associated with that series are copied over.  This includes:
% HEAD.IREP, HEAD.COEF, HEAD.SENSOR_INDEX

global data cal head
if isstruct(cal)
  if any(strcmp((fieldnames(cal)),upper(old_name)))
    eval(['cal.' upper(new_name) '=cal.' upper(old_name) ';']);
    message=['Series cal.' upper(new_name) ' created from cal.' upper(old_name) ];
  elseif any(strcmp((fieldnames(data)),upper(old_name)))
    eval(['data.' upper(new_name) '=data.' upper(old_name) ';']);
    message=['Series data.' upper(new_name) ' created from data.' ...
	  upper(old_name) ];
  else
    warning(['cal.' upper(old_name) ' or data.' upper(old_name) ' not found'])
    return
  end
elseif any(strcmp((fieldnames(data)),upper(old_name)))
  eval(['data.' upper(new_name) '=data.' upper(old_name) ';']);
  message=['Series data.' upper(new_name) ' created from data.' ...
	upper(old_name) ];
else
  warning(['cal.' upper(old_name) ' or data.' upper(old_name) ' not found'])
  return
end
eval(['head.sensor_index.' upper(new_name) '=head.sensor_index.' upper(old_name) ';']);
eval(['head.coef.' upper(new_name) '=head.coef.' upper(old_name) ';']);
eval(['head.irep.' upper(new_name) '=head.irep.' upper(old_name) ';']);
return