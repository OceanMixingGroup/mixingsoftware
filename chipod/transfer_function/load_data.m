% load_data.m
% called from the GUI
% loads a new file and plots data again
%   $Revision: 1.1.1.1 $  $Date: 2008/01/31 20:22:42 $
% Originally J.Nash
hmenu.thisfile=str2num(cell2mat(inputdlg('Please enter new file number')));

[data,head,cal]=plot_profiles(dpath_raw,dpl,hmenu.thisfile);
hfig.fig12=figure(12);
title(['File ' num2str(hmenu.thisfile)])
hmenu.base=uimenu('label','Region Select');
hmenu.spectrum=uimenu(hmenu.base,'label','PSD','callback','compute_spectrum');
hmenu.save=uimenu(hmenu.base,'label','Save Data','callback','save_data');
hmenu.save=uimenu(hmenu.base,'label','Load New File','callback','load_data');

clear power freq plims
