% ***********************
% WRAPPER
% ***********************
%
%   Help file for running the .dll split_ADP.dll:  This wrapper is included for help
%   file and input info.
% 
% 	splitADP(directory,extension,startfile#,endfile#)
% 
% where: 
%  *directory: the directory in which the persistor ADV files are located, and the output files
%  will be written to.  Input persistor files should be of type ########.YYY  where ########
%  *is the unique time stamp written by the persistor and the YYY is the file extension for that instrument.  
%  *Extension: see above, YYY
%  *startfile#: first filename in sequence (enter as a string)
%  *endfile#: last filename in sequence (enter as a string)
%  *
%  *Thus to process files named 01011111.CH1 to 01011234.CH1 you would use the command:
%  *splitADV('c:\directory\offiles','CH1','01011111','01011234');
%  *
%  *program will output ADP files suitable for reading in read_adp.m.  Each file will include 3600 ADP 
%  data per file.  Files will be written as OUTZZZZ.adp where ZZZZ is a number starting
%  *from 0000 and counting upwards.
%
%  Also note that a file named ADPheader.inf must be present in the ADP data
%  directory:  This file must contain the header information for the ADP
%  deployment so it can be appeneded to the .ADP files and thus read by
%  read_adp.m
% 
% $Author: aperlin $ $Date: 2008/01/31 20:22:41 $ $Revision: 1.1.1.1 $

function splitADP(directory,extension,startfile,endfile);

split_ADP(directory,extension,startfile,endfile);

    