function save_matview_file(fn,series,qmini,qmaxi)
% this saves a small matview file
global head cal
nplots=length(series);
instrument=head.instrument;
slow_samp_rate=head.slow_samp_rate;
raw_name=head.filename;
coef=head.coef;
%if ~exist('extrastring'), extrastring='';, end
eval(['save ' fn ' slow_samp_rate instrument raw_name head coef'])
if nargin==4
  for i=1:nplots
    tempser=[lower(deblank(char(series(i))))];
    eval(['irep_' tempser '= head.irep.' upper(tempser) ';,' tempser '=cal.' ...
        upper(tempser) '(((qmini-1)*irep_' tempser ...
        '+1):qmaxi*irep_' tempser ');']);
    eval(['save ' fn ' irep_' tempser ' ' tempser ' -append'])
  end
else
  for i=1:nplots
    tempser=[lower(deblank(char(series(i))))];
    eval(['irep_' tempser '= head.irep.' upper(tempser) ';,' tempser '=cal.' ...
        upper(tempser) ';'])
    eval(['save ' fn ' irep_' tempser ' ' tempser ' -append'])
  end
  
end