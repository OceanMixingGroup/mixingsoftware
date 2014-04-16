function make_time_series
% function MAKE_TIME_SERIES creates a time series based on
% head.slow_samp_rate.  The time series is stored in cal.TIME and has a
% repition rate of 1 (head.irep.TIME=1)

global data cal head

eval(['len=length(data.' head.sensor_name(1,:) ')/head.irep.' ...
      head.sensor_name(1,:) ';']);
cal.TIME=1/(head.slow_samp_rate)*[0:(len-1)]';
head.irep.TIME=1;
