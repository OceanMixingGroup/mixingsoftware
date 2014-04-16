% set_chameleon.m
%###### THESE PARAMETERS SHOULD BE AJUSTED FOR EVERY CRUISE ######

%###### PARAMETERS FOR PROCESSING ################################
path_raw='\\graf-zeppelin\data2\ttp10\data\Chameleon\';
path_cham='\\masada\work\ttp10\chameleon\mat\';
cruise_id='ttp10';
year=2010;
%#################################################################
%###### PARAMETERS FOR PLOTTING ##################################
% WHAT TO PLOT
fig.toplot={'log10(cham.EPSILON1)','log10(cham.EPSILON2)','cham.SIGMA',...
        'cham.T','cham.T2','cham.S'};
% CORRESPONDING FIGURE TITLES
fig.names={'log_{10} \epsilon_1','log_{10} \epsilon_2','\sigma', ... 
        'T [^oC]','T2 [^oC]','S [psu]'};
% INITIAL COLOR LIMITS, CORRESPONDING TO PLOTTING VARIABLES
% could be changed in figure window when show_chameleon is running
fig.colmin=[-10 -10  23 7 7 29];
fig.colmax=[-6 -6 27 13 13 31];
%#################################################################
