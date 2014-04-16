% plot_data_select_patch.m
% plot profiles for transfer functions
% dpath - path to where directory with raw data saved, i.e.
% i.e. dpath='\\mserver\Data\yq06b\ukitik\';
% dpl - deployment ID, i.e. 'yq06b'
% start_file - profile number
%   $Revision: 1.2 $  $Date: 2009/06/09 22:21:02 $
% Originally J.Nash

dpath='c:\work\eq08\chipods\transfer\';
dpl='YQ08a';
start_file=130;


hmenu.thisfile=start_file;
dpath_raw=[dpath '\raw\'];
[data,head,cal,k]=plot_profiles(dpath_raw,dpl,hmenu.thisfile);
title(['File ' num2str(hmenu.thisfile)])
hfig.fig12=figure(12);

hmenu.base=uimenu('label','Region Select');
hmenu.spectrum=uimenu(hmenu.base,'label','PSD','callback','compute_spectrum');
hmenu.save=uimenu(hmenu.base,'label','Save Data','callback','save_data');
hmenu.save=uimenu(hmenu.base,'label','Load New File','callback','load_data');
fn_index=1;
