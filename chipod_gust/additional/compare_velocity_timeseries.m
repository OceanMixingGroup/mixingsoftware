function [fig] = compare_velocity_timeseries(a_time, a_U, a_L, p_time, p_U, p_L)
%%    [fig] = compare_velocity_timeseries(a_time, a_U , a_L, p_time, p_U, p_L)
%           
%           Generates a monster plot that compares both velocity time series
%
%           INPUT
%              a_time      :  (adcp time time vector)
%              a_U         :  complex velocity for a
%              a_L         :  Label for a
%              r_time      :  (pitot time time vector)
%              r_U         :  complex velocity for p
%              p_L         :  Label for p
%
%   created by: 
%        Johannes Becherer
%        Thu Nov 10 10:26:01 PST 2016

%_____________________identify common limits______________________
xl = [max([a_time(1), p_time(1)]) min([a_time(end), p_time(end)])];
aii = find( a_time>=xl(1) & a_time<xl(end) );
pii = find( p_time>=xl(1) & p_time<xl(end) );

%_____________________common time vector______________________
% choose the courser time resolution
adt = diff(a_time(1:2));
pdt = diff(p_time(1:2));
if adt>pdt
   C.time = a_time(aii);
   C.a_U  = a_U(aii);
   C.p_U  = interp1( p_time(pii), qbutter(p_U(pii), pdt/adt), C.time);
   
else
   C.time = p_time(pii);
   C.p_U  = p_U(pii);
   C.a_U  = interp1( a_time(aii), qbutter(a_U(aii), adt/pdt), C.time);
end

%_____________________Plot figure______________________
 col = get(groot,'DefaultAxesColorOrder');

 % limits
 sl = [0 max([ max(abs(a_U)), max(abs(p_U)) ])]; 

 fig = figure('Color',[1 1 1],'visible','on','Paperunits','centimeters',...
         'Papersize',[30 40],'PaperPosition',[0 0 30 40])
   
         % angle axes
          [axa, ~] = create_axes(fig,1,2, 0);
            squeeze_axes(axa, 1,.3);
            shift_axes(axa, 0,.6);
          
         % time sereis axes
          [axt, ~] = create_axes(fig,1,1, 0);
            squeeze_axes(axt, 1,.25);
            shift_axes(axt, 0,.32);
          
         % histo axes
          [axh, ~] = create_axes(fig,1,2, 0);
            squeeze_axes(axh, 1,.3);

   %---------------------plot time series----------------------
   ax = axt; a=1;
   hold(ax(a),'on');
   plot(ax(a), xl, [0 0], 'k--', 'Linewidth', 1);
   pj = 1; p(pj) = plot(ax(a), C.time, real(C.a_U), 'color', [col(pj,:) 1], 'Linewidth', 2);
   pj = 2; p(pj) = plot(ax(a), C.time, imag(C.a_U), 'color', [col(1,:)./1.5 1], 'Linewidth', 1);
   pj = 3; p(pj) = plot(ax(a), C.time, real(C.p_U), 'color', [col(2,:)  1], 'Linewidth', 2);
   pj = 4; p(pj) = plot(ax(a), C.time, imag(C.p_U), 'color', [col(2,:)./1.5 1], 'Linewidth', 1);
      xlim(ax(a), xl);
      datetick(ax(a), 'keeplimits');
      xlabel(ax(a), datestr(nanmedian(C.time), 'dd mmm yyyy'));
      legend(p, ['u_{' a_L '}'], ['v_{' a_L '}'], ['u_{' p_L '}'], ['v_{' p_L '}'],...
            'orientation', 'horizontal', 'location', 'northwest');
      ylabel(ax(a), 'm s^{-1}');

   %---------------------angle plot----------------------
   hold(axa(1),'off')
   rose(axa(1), angle(C.a_U), 50);
   hold(axa(1),'on')
   rose(axa(1), angle(C.p_U), 50);
   legend(axa(1), a_L, p_L, 'location', 'northeastoutside')
   
   %---------------------angle histogram----------------------
   histogram(axa(2),  angle(C.a_U), [-pi:.1:pi])
   histogram(axa(2),  angle(C.p_U), [-pi:.1:pi])
   t = text_corner(axa(2), ['flow direction'], 6);
   xlabel(axa(2), '[rad]')
   xlim(axa(2), [-pi pi]);
   legend(axa(2), a_L, p_L);
   
   
   %---------------------speed histogram----------------------
   histogram(axh(2),  abs(C.a_U), [0:diff(sl)/100:sl(2)])
   histogram(axh(2),  abs(C.p_U), [0:diff(sl)/100:sl(2)])
   t = text_corner(axh(2), ['speed'], 6);
   xlabel(axh(2), '[m s^{-1}]')
   xlim(axh(2), sl);
   legend(axh(2), a_L, p_L);
   
   %_____________________Title______________________
   bins = [0:(diff(sl)/100):sl(2)];
   [hist,mn,mdn,md] = hist2d(bins, bins, abs(C.a_U), 0, abs(C.p_U), 0, 3);
   pcolor(axh(1), bins, bins, hist);
       shading(axh(1),'flat');
       load cmap;
       colormap(axh(1), cmap.chi);
       plot(axh(1), bins, bins,'k', 'Linewidth', 1);
      ylabel(axh(1), ['|u_{' p_L '}| [m s^{-1}]'])
      xlabel(axh(1), ['|u_{' a_L '}| [m s^{-1}]'])
       
   
   %_____________________abc______________________
   abc='abcdefghijklmnopqrst';
   ax(1) = axa(1);
   ax(2) = axa(2);
   ax(3) = axt(1);
   ax(4) = axh(1);
   ax(5) = axh(2);
   for a = 1:(size(ax,1)*size(ax,2))
      text_corner(ax(a), abc(a), 9);
   end
   
   
   
   
      
   
   
   
   
   
   



