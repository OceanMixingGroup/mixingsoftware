
q.mini=max(find(cal.p<q.top));
if(isempty(q.mini))
  q.mini=1;
end
q.maxi=min(find(cal.p>(max(cal.p)-q.bot)));
if q.maxi<q.mini
  q.maxi=length(data.P);
  q.mini=1;
end


nplots=length(q.series);
temp=num2str(q_script.num+10000)
fn=['../mat/' q_script.prefix temp(2:5)]
instrument=head.instrument
eval(['save ' fn ' slow_samp_rate instrument raw_name head coef'])
for i=1:nplots
  tempser=[lower(deblank(char(q.series(i))))];
  eval(['irep_' tempser '= irep.' upper(tempser) ';,' tempser '=cal.' ...
	tempser '(1+(q.mini-1)*irep_' tempser ':q.maxi*irep_' tempser ');']);
  eval(['save ' fn ' irep_' tempser ' ' tempser ' -append'])
end