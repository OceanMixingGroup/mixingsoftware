for i=[454];
  
  % first the pathname, filename and file number must be placed into
  % q.script for raw_load to load the data.
  q.script.num=i;
  q.script.prefix='ch98a';
  q.script.pathname='/home/nalu/data1/ch98a/raw/';
  
  % the script RAW_LOAD does the loading of the raw file into two structured
  % variables: DATA (the voltages) and HEAD (the header information)
  raw_load

  % Now a calibration script must be run.  This script should place
  % calibrated series into the structured variable CAL.  Any additional
  % valiables that you add to CAL (that weren't in DATA) should also get a
  % fieldname in HEAD.IREP.** where ** is the series name and the value is
  % the same as the IREP from which the series was derived.
  
  % See the example CALI_SCRIPT for a sample.
  
  cali_script

  % FInally We must average the data into depth bins:  We'll place the data
  % into the structure AVG using the function AVERAGE_DATA  
  q.series={'t1','p','fallspd','epsilon1'};
  avg=average_data(q.series,'binsize',1,'nfft',128);

  % Now define an output filename and path and save the data:
  temp=num2str(q.script.num+10000)
  fn=[q.script.prefix temp(2:5)];
  
  % The following saves only the header and average values:
  eval(['save ' fn ' avg head'])

  % The following saves all of the calibrated series (but not averages):
  %eval(['save ' fn ' cal head'])
  
  % The folloowing saves all of the data for some selected series:
  %q.series={'s1','c','fallspd','t1'};
  %save_matfile(fn,q.series);

  % The following saves data in an unstructured manner (which can be read by
  % matview, for example:
  %q.series={'s1','c','fallspd','t1'};
  %save_matview_file(fn,q.series);
end