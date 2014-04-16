function run_compute_cali_compass(unit,datadir)
% makes mat file and figure with Chipod compass calibration coefficients
% from text file with compass calibrations
fname=['compass_' num2str(unit) '.txt'];
data=load([datadir fname]);
cname=['comp' num2str(unit)];
compass_coeffs.(cname)=compute_compass_calibration_coefficients(data(:,1),data(:,2),1,8);
save([datadir 'compass_coeffs' num2str(unit)],'compass_coeffs')
figure(1)
subplot(3,1,1)
title(['Compass calibration. Chipod ' num2str(unit)])
print('-dpng','-r200',[datadir fname(1:end-4)]);