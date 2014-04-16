% toggles a few parameters based on temp
if (temp==4)
  eval(['y_axis=(1:(length(data.' deblank(q.series(1,:)) ')/irep.' deblank(q.series(1,:)) '))''/slow_samp_rate;']);
  q.yaxis_label='time (sec)';
  mins.y=min(y_axis)+.001*(max(y_axis)-min(y_axis));
  maxs.y=max(y_axis)-.001*(max(y_axis)-min(y_axis));
  y_axis8=interp8(y_axis,8);
  %  mins.y=y_axis(index(1))
  %  ymax=y_axis(index(length(index)))
  qv_now;
elseif (temp==3 & exist('p'));

  y_axis=p;,q.yaxis_label='depth (m)';
  %  mins.y=y_axis(index(1))
  %  ymax=y_axis(index(length(index)))
  mins.y=min(y_axis)+.001*(max(y_axis)-min(y_axis));
  maxs.y=max(y_axis)-.001*(max(y_axis)-min(y_axis));
  y_axis8=interp8(y_axis,8);
  qv_now;
elseif (temp==1)
  axis_type='vert';
  qv_now;
elseif (temp==2)
  axis_type='horz';
  qv_now;
elseif (temp==5)
  q.units='Engin';
  series=lower(Sensor_name);
elseif (temp==6)
  q.units='Volts';
  series=Sensor_name;
elseif (temp==7)
  q.plot_type='fit';
  qv_now;
elseif (temp==8)
  q.plot_type='spread'
  qv_now;
end
