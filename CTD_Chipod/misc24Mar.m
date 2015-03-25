
% working on a better way to enter chipod info for different cruises etc.
% and save it after

%%


chi_1.chi_path=fullfile(chi_data_path,'1012')
chi_1.az_correction=-1; % -1 if the Ti case is pointed down or up
chi_1.suffix='A1012';
chi_1.isbig=0;
chi_1.cal.coef.T1P=0.097;
chi_1.is_downcast=0;


%chi_2.chi_path='/Users/Andy/Cruises_Research/Tasmania/Data/Chipod_CTD/1013/'
chi_1.chi_path=fullfile(chi_data_path,'1013')
chi_2.az_correction=1;
chi_2.suffix='A1013';
chi_2.isbig=0;
chi_2.cal.coef.T1P=0.097;
chi_2.is_downcast=1;
%%