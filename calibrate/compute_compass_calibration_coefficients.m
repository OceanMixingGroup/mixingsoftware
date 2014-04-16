function coeffs=compute_compass_calibration_coefficients(true_heading, ...
                                                    compass_output,do_plots,polynom_order)
% function coeffs=compute_compass_calibration_coefficients(true_heading,
% compass_output,do_plots) computes the coefficients for the compass that can be
% used with calibrate_compass.m  ****Important to put these coefficients
% into head.coef.(series_name) so that calibrate_compass works.  I.e.,
% call as
% head.coef.CMP=compute_compass_calibration_coefficients(true_heading,compass_output)
%   $Revision: 1.2 $  $Date: 2012/04/04 22:54:47 $
%
%

if nargin==2
  do_plots=1;
  polynom_order=4;
elseif nargin==3
  polynom_order=4;
end

% First we resort in terms of the raw compass output
[raw_comp,ind]=sort(compass_output);
true_heading=true_heading(ind);
true_heading=180/pi*unwrap(true_heading/180*pi);

if mean(true_heading)>180
  true_heading=true_heading-360;
end

% now we check to make sure the raw_output spans 0 to 360 degrees.

true_heading=[true_heading(end)-360 ; true_heading ; true_heading(1)+360];
raw_comp=[raw_comp(end)-360 ; raw_comp ; raw_comp(1)+360];

[true_heading raw_comp];
% coeffs=polyfit(raw_comp,true_heading,round(length(true_heading)/2));
coeffs=polyfit(raw_comp,true_heading,polynom_order);
% cfs=fliplr(round(coeffs.*1e7)./1e7);
if do_plots
  test_output=polyval(coeffs,raw_comp);
  figure(1);clf
  subplot(311);
  plot(raw_comp,true_heading,'r',raw_comp,test_output,'b');
  xlabel('compass output [deg]');
  ylabel('true heading [deg]');
  legend('data','calibrated (fit)','location','SE')
  text(0.01,0.92,'Fit coefficients in acscending power','Units','normalized')
  pcf=fliplr(coeffs);
  if polynom_order==4
      text(0.01,0.8,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g',pcf),'Units','normalized')
  elseif polynom_order==5
      text(0.01,0.8,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g %3.5g',pcf),'Units','normalized')
  elseif polynom_order==6
      text(0.01,0.8,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g %3.5g %3.5g',pcf),'Units','normalized')
  elseif polynom_order==7
      text(0.01,0.8,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g %3.5g %3.5g',pcf(1:7)),'Units','normalized')
      text(0.01,0.7,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g %3.5g %3.5g',pcf(8:end)),'Units','normalized')
  elseif polynom_order==8
      text(0.01,0.8,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g %3.5g %3.5g',pcf(1:7)),'Units','normalized')
      text(0.01,0.7,sprintf('%3.5g',pcf(8:end)),'Units','normalized')
  elseif polynom_order==9
      text(0.01,0.8,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g %3.5g %3.5g',pcf(1:7)),'Units','normalized')
      text(0.01,0.7,sprintf('%3.5g %3.5g',pcf(8:end)),'Units','normalized')
  elseif polynom_order==10
      text(0.01,0.8,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g %3.5g %3.5g',pcf(1:7)),'Units','normalized')
      text(0.01,0.7,sprintf('%3.5g %3.5g %3.5g',pcf(8:end)),'Units','normalized')
  elseif polynom_order==11
      text(0.01,0.8,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g %3.5g %3.5g',pcf(1:7)),'Units','normalized')
      text(0.01,0.7,sprintf('%3.5g %3.5g %3.5g %3.5g',pcf(8:end)),'Units','normalized')
  elseif polynom_order==12
      text(0.01,0.8,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g %3.5g %3.5g',pcf(1:7)),'Units','normalized')
      text(0.01,0.7,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g',pcf(8:end)),'Units','normalized')
  elseif polynom_order==13
      text(0.01,0.8,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g %3.5g %3.5g',pcf(1:7)),'Units','normalized')
      text(0.01,0.7,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g %3.5g',pcf(8:end)),'Units','normalized')
  elseif polynom_order==14
      text(0.01,0.8,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g %3.5g %3.5g',pcf(1:7)),'Units','normalized')
      text(0.01,0.7,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g %3.5g %3.5g',pcf(8:end)),'Units','normalized')
  elseif polynom_order==15
      text(0.01,0.8,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g %3.5g %3.5g',pcf(1:7)),'Units','normalized')
      text(0.01,0.7,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g %3.5g %3.5g',pcf(8:14)),'Units','normalized')
      text(0.01,0.6,sprintf('%3.5g',pcf(15:end)),'Units','normalized')
  elseif polynom_order==16
      text(0.01,0.8,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g %3.5g %3.5g',pcf(1:7)),'Units','normalized')
      text(0.01,0.7,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g %3.5g %3.5g',pcf(8:14)),'Units','normalized')
      text(0.01,0.6,sprintf('%3.5g %3.5g',pcf(15:end)),'Units','normalized')
  elseif polynom_order==17
      text(0.01,0.8,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g %3.5g %3.5g',pcf(1:7)),'Units','normalized')
      text(0.01,0.7,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g %3.5g %3.5g',pcf(8:14)),'Units','normalized')
      text(0.01,0.6,sprintf('%3.5g %3.5g %3.5g',pcf(15:end)),'Units','normalized')
  elseif polynom_order==18
      text(0.01,0.8,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g %3.5g %3.5g',pcf(1:7)),'Units','normalized')
      text(0.01,0.7,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g %3.5g %3.5g',pcf(8:14)),'Units','normalized')
      text(0.01,0.6,sprintf('%3.5g %3.5g %3.5g %3.5g',pcf(15:end)),'Units','normalized')
  elseif polynom_order==19
      text(0.01,0.8,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g %3.5g %3.5g',pcf(1:7)),'Units','normalized')
      text(0.01,0.7,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g %3.5g %3.5g',pcf(8:14)),'Units','normalized')
      text(0.01,0.6,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g',pcf(15:end)),'Units','normalized')
  elseif polynom_order==20
      text(0.01,0.8,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g %3.5g %3.5g',pcf(1:7)),'Units','normalized')
      text(0.01,0.7,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g %3.5g %3.5g',pcf(8:14)),'Units','normalized')
      text(0.01,0.6,sprintf('%3.5g %3.5g %3.5g %3.5g %3.5g %3.5g',pcf(15:end)),'Units','normalized')
  end 
  subplot(312);
  plot(true_heading,test_output)
  set(gca,'xlim',[min(true_heading) max(true_heading)],'ylim',[min(true_heading) max(true_heading)])
  xlabel('true heading [deg]')
  ylabel('calibrated heading [deg]')
  grid on;
  axis square
  subplot(313);
  plot(true_heading,true_heading-test_output)
  set(gca,'xlim',[min(true_heading) max(true_heading)],'ylim',[-1 1])
  xlabel('true heading [deg]')
  ylabel('true heading - calibrated heading [deg]')
  grid on;
end
