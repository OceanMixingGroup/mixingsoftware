function [datad, datau] = ctd_correction_updn(datain);
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [datad, datau] = ctd_correction_updn(datain);
%
% Same as ctd_correction.m, except separate into up and down casts
% T lag, tau; lowpass T, C, oxygen
%
% See also ctd_correction.m
%
% Calls ctd_correction2.m (should be original, not '2'?)
%
% Original code from Jen MacKinnon in 'ctd_proc2' folder.
% Added to 'ctd_processing' folder by A. Pickering - April 2015
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%
[pmax, ipmax] = max(datain.p);
np = length(datain.p);

fnames = fieldnames(datain);
insnan = 0;

if isfield(datain,'tcfit')
    
    disp('downcast:');
    datad = structcat(fnames(1:end-1), '', 'col', insnan, datain, [1:ipmax]'); datad.tcfit=datain.tcfit;
    datad = ctd_correction2(datad);
    
    disp('upcast:');
    datau = structcat(fnames(1:end-1), '', 'col', insnan, datain, [ipmax:np]'); datau.tcfit=datain.tcfit;
    datau = ctd_correction2(datau);
    
else
    
    disp('downcast:');
    datad = structcat(fnames, '', 'col', insnan, datain, [1:ipmax]');
    datad = ctd_correction2(datad);
    
    disp('upcast:');
    datau = structcat(fnames, '', 'col', insnan, datain, [ipmax:np]');
    datau = ctd_correction2(datau);
    
end
%%