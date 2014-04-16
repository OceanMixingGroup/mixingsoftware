from_series=display_series(get(h6(3),'value'));
new_series=get(h6(5),'string');
cut_freq=str2num(get(h6(7),'string'));
filt_type=get(h6(9),'value')-1;
filt_ord=str2num(get(h6(11),'string'));
for i=1:13;,delete(h6(i));,end
eval(['irep_' new_series ' = irep_' series(from_series,:) ';'])
if ~exist(new_series)
nseries=nseries+1;
new_series=[new_series '           '];
series(nseries,:)=new_series(1:10);
display_series=[display_series nseries];
display_series_list=[display_series_list '|' deblank(new_series)]; 
i=nseries;
check_ser(i)=uicontrol('Style','checkbox','string',(series(i,:)),'Position',[0.91 .90-i*.03 .088 .03],'callback','doactive','Value', any(display_series==i));
popseries_current=nplots+1;
active=display_series(popseries_current);
end
end
set(popseries,'string',display_series_list,'value',popseries_current)
high='high';
if ~(filt_type)
eval(['[chebyb chebya]=butter(filt_ord,2*cut_freq/slow_samp_rate/irep_' series(from_series,:) ',' high ');'])
else
eval(['[chebyb chebya]=butter(filt_ord,2*cut_freq/slow_samp_rate/irep_' series(from_series,:) ');'])
end
eval([deblank(new_series) '=filtfilt(chebyb,chebya,' deblank(series(from_series,:)) ');']);

newparams=1;
replot;

