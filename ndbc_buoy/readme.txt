Run make_ndbc_buoy.m to processes all ndbc data for a particular year 
and save it in matlab structures. make_ndbc_buoy.m calls for functions 

read_NDBCbuoy_meteo.m to process met data,
read_NDBCbuoy_wind.m to process wind data,
read_NDBCbuoy_spwvdens.m to process spectral wave density data and
read_NDBCbuoy_spwvdir.m to process spectral wave direction data

In this file you must specify directory where the data to be 
processed is saved, year of the processed data and station number, e.g.

dpath='C:\work\ndbc_buoy\data\';
year=2004;
station_id='51028';


Data to process should be saved with default NDBC names, e.g.
51028h*2004.txt for standard meteorological data
51028c*2004.txt for continious wind data
51028w*2004.txt for spectral wave density data
51028d*2004.txt for spectral wave direction alpha1 data
51028i*2004.txt for spectral wave direction alpha2 data
51028j*2004.txt for spectral wave direction r1 data
51028k*2004.txt for spectral wave direction r2 data

If there was no data format change during the year there will be only
one file in each data category for the year and no letter 
in place of '*' in the file name.
 
If there was data format change during the year there will be more than 
one file in each data category for the year second and following files will 
have different letters in place of '*'. You should download
all the files for that year that NDBC provides.

Check readme in all structures for explanations about variables saved.