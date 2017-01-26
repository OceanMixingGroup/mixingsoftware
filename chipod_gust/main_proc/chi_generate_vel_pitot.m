function [vel_p] = chi_generate_vel_pitot(basedir)
%% [vel_p] = chi_generate_vel_piitot(basedir)
% 
%        This function generates an input file for chi-processing vel_p.mat
%        directory input
%        
%        Input
%           basedir     : unit base directory
% 
%        Output
%           vel_p.time  : time vector  
%           vel_p.U     : complex velocity vector
%           vel_p.u     : east velocity vector
%           vel_p.v     : north velocity vector
%           vel_p.spd   : speed
%           vel_p.cmp   : cpmpass
%
%   created by: 
%        Johannes Becherer
%        Wed Sep 21 14:13:34 PDT 2016

%_____________________load the pitot data______________________
load([basedir filesep 'proc' filesep 'pitot.mat']);

%_____________________contruct vel_p ______________________
vel_p.U     = pitot.U;
vel_p.u     = pitot.u;
vel_p.v     = pitot.v;
vel_p.time  = pitot.time;
vel_p.cmp   = pitot.cmp;
vel_p.spd   = pitot.spd;

%_____________________save______________________
sdir = [basedir filesep 'input' filesep ];
save([sdir 'vel_p.mat'], 'vel_p');
