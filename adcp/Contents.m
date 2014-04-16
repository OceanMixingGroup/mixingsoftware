% mixingsoftware/adcp
%
% Routines for RDI Transect ADCP translation
%  
% despike.m
% 	% function [outy]=despike(iny,despikelen,limit,doplot);
% 	    % this is too short to despike....
% get_adcp_gps_fname.m
% 	% get_adcp_gps.m
% 	% example: gps=get_adcp_gps('\\atlantic\tgtall\adcp\t122\t122003n');
% mergefields.m
% rdpadcp.m
% 	% read (binary) processed ADCP files, puts all the relevant data into a 
% 	% structure, and saves it to a mat-file for future use. 
% read_workhorse.m
% 	% function [adcp]=read_workhorse(name);
% 	% Reads workhorse ADCP data.
% trimbad.m
% 	% function adp=trimbad(adp,bad,refname);
% 	% trims all the data in adp with the indices given by bad.  This is
% updatedplot2.m
% 	% function updatedplot2(savefile,timetowait);
% 	% keep loading savefile every timetowait seconds and plot it up...
% updatedsave.m
% 	% function updatedsave(adcppath,savepath,prefix,num,trannum);
% 	% updatedsave copies the latest adcp data into the savepath.  It
% workhorsetosci.m
% 	% function adcp = workhorsetosci(fname);
% 	% read a file of workhorse adcp data and output in sensible units.
