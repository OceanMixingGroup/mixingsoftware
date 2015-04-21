  function [datad, datau] = ctd_correction_updn(datain); 
% function [datad, datau] = ctd_correction_updn(datain); 
% separate into up and down
% T lag, tau; lowpass T, C, oxygen

[pmax, ipmax] = max(datain.p);
np = length(datain.p);

fnames = fieldnames(datain);
insnan = 0;

if isfield(datain,'tcfit')

disp('downcast:')
datad = structcat(fnames(1:end-1), '', 'col', insnan, datain, [1:ipmax]'); datad.tcfit=datain.tcfit;
datad = ctd_correction2(datad); 

disp('upcast:')
datau = structcat(fnames(1:end-1), '', 'col', insnan, datain, [ipmax:np]'); datau.tcfit=datain.tcfit;
datau = ctd_correction2(datau); 

else
    
disp('downcast:')
datad = structcat(fnames, '', 'col', insnan, datain, [1:ipmax]');
datad = ctd_correction2(datad); 

disp('upcast:')
datau = structcat(fnames, '', 'col', insnan, datain, [ipmax:np]');
datau = ctd_correction2(datau); 

end
    