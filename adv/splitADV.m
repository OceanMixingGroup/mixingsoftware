% ***********************
% WRAPPER
% ***********************
%
%   Help file for running the .dll split_ADV.dll:  This wrapper is included for help
%   file and input info.
% 
% 	splitADV(directory,extension,startfile#,endfile#,samplefreq)
% 
% where: 
%  *directory: the directory in which the persistor ADV files are located, and the output files
%  will be written to.  Input persistor files should be of type ########.YYY  where ########
%  *is the unique time stamp written by the persistor and the YYY is the file extension for that instrument.  
%  *Extension: see above, YYY
%  *startfile#: first filename in sequence (enter as a string)
%  *endfile#: last filename in sequence (enter as a string)
%  * samplefreq - sample frequency
%  *
%  *Thus to process files named 01011111.CH1 to 01011234.CH1 you would use the command:
%  *splitADV('c:\directory\offiles','CH1','01011111','01011234',9.96);
%  *
%  *program will output ADV files suitable for reading in read_adv.m.  Each file will include 36000 ADV 
%  data per file.  Files will be written as OUTZZZZ.adv where ZZZZ is a number starting
%  *from 0000 and counting upwards.
%
% 
% $Author: aperlin $ $Date: 2008/01/31 20:22:41 $ $Revision: 1.1.1.1 $

function splitADV(directory,extension,startfile,endfile,samplefreq);

split_ADV(directory,extension,startfile,endfile,samplefreq);

    