%
% Routines for reading and plotting BioSonics echosounder data.
%
% fastreadbio.m - quick way to read biosonics data; uses mex
% routine readbiodrv.dll to make things much faster.
%
% readbiodrv.dll - w32 dll for reading in biosonics data/
%
% src/ - directory with source code for biosonics reading routine
% in it.  To compile run >> mex readbiodrv.c 
%
% readbio.m - the all MatLab way to read biosonics files.
%
% plot_bio_decimated - A specialized routine that assumes files of
% the form  yyyymmddhhmm.mat have been made.
% realtime/biosonics/run_backup.m makes mat files of this format.
% See also make_decimatedfiles.m
%
% make_decimatedfiles.m - makes decimated matlab files (not very
% general yet).   

% $Author: aperlin $ $Date: 2008/01/31 20:22:42 $ $Revision: 1.1.1.1 $