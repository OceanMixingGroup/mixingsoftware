% I don't remember what this is for.  Seems to set a bunch of stuff
% for initializing the plotting.

%###### THESE PARAMETERS SHOULD BE AJUSTED FOR EVERY CRUISE ######

%###### PARAMETERS FOR PROCESSING ################################
path_raw='\\Ladoga\DATAd\cruises\tx01\chameleon\raw\';
path_sum='\\Ladoga\datad\cruises\tx01\chameleon\summaries\';
cruise_id='tx01';
year=2001;
%#################################################################
%###### PARAMETERS FOR PLOTTING ##################################
% WHAT TO PLOT
fig.toplot={'log10(sum.EPS1)','log10(sum.EPS2)','sum.SCAT','sum.SIGMA',...
        'sum.THETA','sum.S'};
% CORRESPONDING FIGURE TITLES
fig.names={'log_{10} \epsilon_1','log_{10} \epsilon_2','SCAT [v]','\sigma', ... 
        '\theta [^oC]','S [psu]'};
% INITIAL COLOR LIMITS, CORRESPONDING TO PLOTTING VARIABLES
% could be changed in figure window when show_chameleon is running
fig.colmin=[-10 -10  0 25  7 32.5];
fig.colmax=[-6 -6 .2 26.8 11 34.5];
%#################################################################
