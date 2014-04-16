if q.nser > head.num_sensors
  for i=head.num_sensors+1:q.nser
    delete(h.update(i),h.select(i));
  end
  q.display_series=q.display_series(find(q.display_series<=head.num_sensors));
  if isempty(q.display_series)
    q.display_series=2;
    h.selected(2)=qv_sel(h.select(2),h.selected(2),h.update(2));
  end
  q.nplots=length(q.display_series);
  h.update=h.update(1:head.num_sensors);
  h.selected=h.selected(1:head.num_sensors);
  h.select=h.select(1:head.num_sensors);
end
q.last_display_series=q.display_series;
clear head data irep;
qv_load
  qv_now
