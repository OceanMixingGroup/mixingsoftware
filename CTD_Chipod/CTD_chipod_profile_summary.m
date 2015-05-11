function ax=CTD_chipod_profile_summary(avg,chi_todo_now)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function h=CTD_chipod_profile_summary(avg,chi_todo_now)
%
%
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%
figure;clf
agutwocolumn(1)
wysiwyg
ax = MySubplot(0.1, 0.03, 0.02, 0.06, 0.1, 0.07, 3,2);

axes(ax(1))
plot(log10(abs(avg.dTdz)),avg.P),axis ij
grid on
axis tight
xlabel('log_{10}(avg dTdz)')
ylabel('Depth [m]')
%title(['cast ' cast_suffix])

axes(ax(2))
plot(log10(abs(avg.N2)),avg.P),axis ij
grid on
xlabel('log_{10}(avg N^2)')
axis tight
ytloff
%title([short_labs{up_down_big}],'interpreter','none')

axes(ax(3))
%                    plot(chidat.cal.T1P(chi_inds),chidat.cal.P(chi_inds)),axis ij
plot(chi_todo_now.T1P,chi_todo_now.P),axis ij
grid on
xlabel('dT/dt')
axis tight
ytloff

axes(ax(4))
plot(log10(avg.chi1),avg.P,'.'),axis ij
xlabel('log_{10}(avg chi)')
axis tight
grid on
ylabel('Depth [m]')

axes(ax(5))
plot(log10(avg.KT1),avg.P,'.'),axis ij
axis tight
xlabel('log_{10}(avg Kt1)')
grid on
ytloff

axes(ax(6))
plot(log10(avg.eps1),avg.P,'.'),axis ij
%xlim([-11 -4])
axis tight
xlabel('log_{10}(avg eps1)')
grid on
ytloff

linkaxes(ax,'y')

return
%%