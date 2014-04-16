% save_data.m
% called from the GUI
% saves relevant power spectra information to directory dpath/saves/
%   $Revision: 1.1.1.1 $  $Date: 2008/01/31 20:22:42 $
% Originally J.Nash

fname=[dpl num2str(hmenu.thisfile) '_p_' ...
       num2str(round(abs(mean(plims))))];
disp(fname);

mkdir(dpath,'saves');
save([dpath '/saves/' fname],'power','freq','plims','fname','indices')

filenames{fn_index}=fname;
fn_index=fn_index+1;
mkdir(dpath,'figs');
print('-dpng','-r100',[dpath 'figs\' fname])

save([dpath '/saves/filename_list'],'filenames')
