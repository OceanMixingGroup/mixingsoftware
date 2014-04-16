function [data,head,cal,k]=plot_profiles(dpath_raw,dpl,ip)
% [data,head,cal,k]=plot_profiles(dpath_raw,dpl,ip)
% plot profiles for transfer functions
% dpath_raw - path to the directory where raw data files are saved
% dpl - deployment ID, i.e. 'yq06b'
% ip - profile number
%   $Revision: 1.2 $  $Date: 2009/06/09 22:21:42 $
% Originally J.Nash

clear global
global data head cal q

q.script.prefix=dpl;
q.script.pathname=dpath_raw;
q.script.num=ip;
temp=q.script;
clear global data head cal q
q.script=temp;

[data,head]=raw_load(q);
names=fieldnames(data);
k=0;
for ii=1:4
    if isfield(data,{['CHT' num2str(ii) 'P']})
        k=k+1;
    end
end
cali_transfer;
% eval(['cali_' dpl]);

%do other stuff
hfig.fig12=figure(12);orient tall;
clf;
ylabel('Depth [m]');
s(1)=subplot(1,k+4,1);
if isfield(data,'MHT')
    plot(cal.MHT(1:head.irep.MHT:length(cal.MHT)),-cal.P,'k');
    xmx=max(cal.MHT);
    xmn=min(cal.MHT);
    xlabel('MHT [C]');
else
    plot(cal.T(1:head.irep.T:length(cal.T)),-cal.P,'k');
    xmx=max(cal.T);
    xmn=min(cal.T);
    xlabel('T [C]');end
grid on;
dx=xmx-xmn;
yl=ylim;
dy=yl(2)-yl(1);
axis([xmn-0.035*dx xmx+0.035*dx yl]);
ylabel('Depth [m]');

s(2)=subplot(1,k+4,2);
hold on
leg=[];
col='gbmcky';
if isfield(data,'CH4T')
    data.CHT4=data.CH4T;
    head.irep.CHT4=head.irep.CH4T;
end
if isfield(data,'UKTC')
    plot(-.25*(data.UKTC(1:head.irep.UKTC:end)-nanmean(data.UKTC)),-cal.P,'r');leg={'UKTC'};
end
for ii=1:k
    plot(data.(['CHT' num2str(ii)])(1:head.irep.(['CHT' num2str(ii)]):length(data.(['CHT' num2str(ii)])))-nanmean(data.(['CHT' num2str(ii)])),-cal.P,col(ii));
    leg=[leg {['CHT' num2str(ii)]}];
end
grid on
box on
legend(leg)
legend boxoff
xmx=.25*max(data.UKTC-nanmean(data.UKTC));
xmn=.25*min(data.UKTC-nanmean(data.UKTC));dx=xmx-xmn;
axis([xmn-0.005*dx xmx+0.005*dx yl])
set(gca,'yticklabel','')

for ii=1:k
s(ii+2)=subplot(1,k+4,ii+2);
plot(data.(['CHT' num2str(ii) 'P'])(1:head.irep.(['CHT' num2str(ii) 'P']):end),-cal.P,'k');grid on
xlabel(['CHT' num2str(ii) 'P'])
xmx=max(data.(['CHT' num2str(ii) 'P']));
xmn=min(data.(['CHT' num2str(ii) 'P']));
axis([xmn-0.035*dx xmx+0.035*dx yl])
set(gca,'yticklabel','')
end
% title([q.script.prefix,'  profile ',num2str(ip)],'fontsize',14)



s(k+3)=subplot(1,k+4,k+3);
plot(data.UKTCP(1:head.irep.UKTCP:length(data.UKTCP)),-cal.P,'k');grid on
xlabel('UKTCP')
xmx=max(data.UKTCP);
xmn=min(data.UKTCP);
axis([xmn-0.035*dx xmx+0.035*dx yl])
set(gca,'yticklabel','')

s(k+4)=subplot(1,k+4,k+4);
plot(data.S1(1:head.irep.S1:length(data.S1)),-cal.P,'k');grid on
xlabel('S1')
axis([-2.75 2.75 yl])
set(gca,'yticklabel','')

linkaxes(s,'y')

