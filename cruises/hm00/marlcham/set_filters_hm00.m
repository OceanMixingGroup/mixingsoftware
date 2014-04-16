% set_filters.m
% A suppliment file for average_data_gen.
% Here you can set filters that will be used to calculate
% EPSILON in calc_epsilon_filt_gen.m routine.
% In addition high and low frequency cutoff and high frequency 
% cutoff coefficient are defined here (see documentation to 
% calc_epsilon_filt_gen.m).
% Choice of filters and coefficients depends on cast number
% (it could be different for different tows)
% Note: variable CAST (cast number) should be defined as GLOBAL
% in main script and in average_data_gen.m routine
%$$$$$$$$ DO NOT CHANGE THIS SECTION!! $$$$$$$$$$$$$$$$$$$$$
cast=q.script.num;
clear filters;
% SET DEFAULTS
filters={};
k_start=2; % [cpm]
k_stop=90; % [cpm]
kstop_coef=0.5;
eps=eval(['avg.EPSILON' prb '(n)']);
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

%##### IN THIS SECTION YOU SET FILTERS AND COEFFICIENTS ####
%##### AS FUNCTION OF CAST NUMBER ##########################
% Filters set according to EPSILON estimation (variable eps)
% EPSILON estimated in average_data_gen script before applying filters
% Filters could be different for diferent probes (variable prb)
% and could depend on ADP (variable cal.FLAG, cal.FLAG(:)=1 when 
% ADP is ON)
k_start=1; % [cpm]
if cast>=194 & cast<=407 
    % TOW #1
    if eps<3e-8 % filters set according to EPSILON estimation
        if cal.FLAG(1)==1 % cal.FLAG=1 when ADP was turned ON
                          % filters depend on ADP
            if prb==1 | prb==2 % prb is the probe number. Filters could
                               % be different for different probes
                filters={'n2.4-6.8','l12'};
            else
                filters={'n3-8','l12'};
            end
        else % ADP turned OFF
            if prb==1 | prb==2 
                filters={'n2.4-6.8','n12-18','n27-32'};
            else
                filters={'n3-8','n12-18','n27-32'};
            end
        end
    elseif eps<8e-8
        if prb==1 | prb==2
            filters={'n2.4-6.8'};
        else
            filters={'n3-8'};
        end
    end
elseif cast>=417 & cast<=592
    % TOW #2
    if eps<3e-8 % filters set according to EPSILON estimation
        if cal.FLAG(1)==1
            filters={'l11'};
        else % ADP turned OFF
            filters={'n11-21','n26.6-32.5'};
        end
    elseif eps<8e-8
        filters={'n11-21','n26.5-32.5'};
    elseif eps<1.2e-7
        filters={'n12-19'};
    end
elseif cast>=605 & cast<=855
    % TOW #3
    if eps<3e-8 % filters set according to EPSILON estimation
        if cal.FLAG(1)==1
            filters={'l10'};
        else % ADP turned OFF
            filters={'n10-21','n27-32'};
        end
    else
        filters={'n10-21'};
    end
elseif cast>=873 & cast<=942
    % TOW #4
    if eps<1e-8 % filters set according to EPSILON estimation
        if cal.FLAG(1)==1
            filters={'n3-6','l12'};
        else % ADP turned OFF
            filters={'n3-6','n12-22','n28-31'};
        end
    elseif eps<3e-8 % filters set according to EPSILON estimation
        if cal.FLAG(1)==1
            filters={'n3-6','l12'};
        else % ADP turned OFF
            filters={'n3-6'};
        end
    elseif eps<8e-8
        filters={'n3-6'};
    end
elseif cast>=984 & cast<=1913
    % TOW #5-7
    if eps<1e-8 % filters set according to EPSILON estimation
        if cal.FLAG(1)==1
            filters={'l4'};
        else % ADP turned OFF
            filters={'n4-12'};
        end
    elseif eps<3e-8 % filters set according to EPSILON estimation
        if cal.FLAG(1)==1
            if prb==1 | prb==2
               filters={'n4-10.5','l12'}
            else
                filters={'n4-11','l12'};
            end
        else % ADP turned OFF
            if prb==1 | prb==2 
                filters={'n4-10.5'};
            else
                filters={'n4-11'};
            end
        end
    elseif eps<5e-8
        if prb==1 | prb==2
            filters={'n4-10.5'};
        else
            filters={'n4-11'};
        end
    end
elseif cast>=1925 & cast<=4614
    % TOW #8-37
    if eps<2e-8 % filters set according to EPSILON estimation
        if cal.FLAG(1)==1
            filters={'l3.5'};
        else % ADP turned OFF
            filters={'n3.5-12'};
        end
    elseif eps<3e-8 % filters set according to EPSILON estimation
        if cal.FLAG(1)==1
            filters={'n4-10.5','l12'};
        else % ADP turned OFF
            filters={'n4-10.5'};
        end
    end
end
%#########################################################    
