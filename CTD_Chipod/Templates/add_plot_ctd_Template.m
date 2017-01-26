%%

clear ; close all

%***
project='P15S'

addpath /Users/Andy/Cruises_Research/mixingsoftware/CTD_Chipod/mfiles/

proc_info = Add_CTD_to_XC(project)

%%

ax=plot_ctd_from_proc_info(proc_info)

%%

figname=[project '_ctd_t_s.png']
print(fullfile(BaseDir,'Figures',figname),'-dpng')

%%