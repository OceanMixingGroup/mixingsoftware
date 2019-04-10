function droppoint(shearcal)
% edited jnm April 2019 - for clarity of presentation only

%Updated by Pavan Vutukur 04/09/2019 display of + and - signs on fit
%equation in sp(3)=subplot(4,1,3)
if nargin<1
    [raw_name,dirname]=uigetfile('*.*','Load Shear Calibration File');
    filnam=[dirname raw_name];
    if raw_name==0
        error('File not found')
        return
    else
        load(filnam);
    end
end
fnames={'angle','Vtotal','U_flow','U_noflow','meanU_flow','meanU_noflow',...
    'V_flow','V_noflow','rmsV_flow','rmsV_noflow'};
% % &&&&&&&&&&& FOR  TEST PURPOSES ONLY!!! &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
% shearcal.angle=[20:-2:-20];
% shearcal.meanU_flow=[.9582 .9644 .9644 .9711 .9683 .9739 .974 .9723 .9747 .975 .973 .9712 .9703 ...
%     .9743 .9704 .9722 .9715 .9704 .9689 .9698 .9709];
% shearcal.rmsV_noflow=[.0357 .0511 .029 .0446 .0545 .0245 .0411 .0211 .0418 .0227 0 .0322 .0671 ...
%     .0235 .0444 .0304 .025 .0284 .0713 .049 .0368];
% shearcal.rmsV_flow=[1.1343 1.0215 0.8755 .7753 .6439 .5307 .4134 .3048 .1924 .098 0 .1776 .2944 ...
%     .4137 .5282 .6491 .7824 .9055 1.0371 1.1665 1.2984];
% shearcal.Vtotal=(shearcal.rmsV_flow+shearcal.rmsV_noflow)/shearcal.gain;
% shearcal.Vtotal(shearcal.angle<0)=-shearcal.Vtotal(shearcal.angle<0);
% shearcal.meanU_noflow=zeros(1,21);
% fnames={'angle','Vtotal','meanU_flow','meanU_noflow',...
%     'rmsV_flow','rmsV_noflow'};
% % &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

% fminsearch runs fiteq to minimize difference between fitting equation
% curve and shearcal.Vtotal./shearcal.meanU_flow.^2
start_coef=[0 0.3 0];
shearcal.coef=fminsearch(@fiteq,start_coef);
sin2a=sind(2*shearcal.angle);
stu2=shearcal.Vtotal./shearcal.meanU_flow.^2;
fit=shearcal.coef(1)+shearcal.coef(2)*sin2a+shearcal.coef(3)*sin2a.^3;
slope=gradient(fit,sin2a);

drop_point = 1;
% plot Yfit & Ydata vs sin(2*alpha) and slope vs sin(2*alpha)
sz=get(0,'ScreenSize');
fd=figure(100);
set(fd,'Position',[0.5*sz(3),0.4*sz(4),0.49*sz(3),0.47*sz(4)]);
set(fd,'Menubar','none','color',[1 1 1]);clf
set(fd,'Name','DROP  POINT')
set(fd,'UserData',shearcal)
sp(1)=subplot(2,1,1);
spp=get(gca,'position');
set(sp(1),'position',[spp(1) spp(2)+0.05, spp(3) spp(4)]);
pp(1)=plot(sin2a,stu2,'b-','marker','.','markersize',15);
hold on
pp(2)=plot(sin2a,fit-stu2,'r-','marker','.','markersize',15);
xlabel('sin(2\alpha)')
legend('V_s^T/U^2','S_{fit}-V_s^T/U^2')
grid on
sp(2)=subplot(2,1,2);
spp=get(gca,'position');
set(sp(2),'position',[spp(1) spp(2)+0.1, spp(3) spp(4)]);
pp(3)=plot(sin2a,slope,'r-','marker','.','markersize',15);
xlabel('sin(2\alpha)')
legend('Slope')
grid on
linkaxes(sp,'x')
hset = uicontrol('Style','pushbutton','String',...
    'DONE','Units','normalized','Position',[.35 .02 .3 .07],...
    'Fontsize',14,'Fontweight','Bold',...
    'callback','drop_point=0;');

% now we should drop bad points from the calibration (including
% 0 deg point)
while drop_point
    if drop_point==0
%         break;
        return
    end
    [x,y]=ginput(1);
    if y<1.05*min(get(gca,'ylim'))
        drop_point=0;
        break
%         return
    end
    [cc, im]=min(abs(sind(2*shearcal.angle)-x));
    if im==1
        indc=[im+1:length(shearcal.angle)];
    elseif im==length(shearcal.angle)
        indc=[1:im-1];
    else
        indc=[1:im-1 im+1:length(shearcal.angle)];
    end
    for ii=1:length(fnames)
        shearcal.(char(fnames(ii)))=shearcal.(char(fnames(ii)))(1,indc);
    end
    shearcal.coef=fminsearch(@fiteq,start_coef);
    sin2a=sind(2*shearcal.angle);
    stu2=shearcal.Vtotal./shearcal.meanU_flow.^2;
    fit=shearcal.coef(1)+shearcal.coef(2)*sin2a+shearcal.coef(3)*sin2a.^3;
    slope=gradient(fit,sin2a);
    delete(pp);
    sp(1)=subplot(2,1,1);
    spp=get(gca,'position');
    set(sp(1),'position',[spp(1) spp(2)+0.05, spp(3) spp(4)]);
    pp(1)=plot(sin2a,stu2,'b-','marker','.','markersize',15);
    hold on
    pp(2)=plot(sin2a,fit-stu2,'r-','marker','.','markersize',15);
    xlabel('sin(2\alpha)')
    legend('V_s^T/U^2','V_{fit}-V_s^T/U^2')
    grid on
    sp(2)=subplot(2,1,2);
    spp=get(gca,'position');
    set(sp(2),'position',[spp(1) spp(2)+0.1, spp(3) spp(4)]);
    pp(3)=plot(sin2a,slope,'r-','marker','.','markersize',15);
    xlabel('sin(2\alpha)')
    legend('Slope')
    grid on
end
shearcal.Sensitivity=shearcal.coef(2);

clf(fd)
set(fd,'position',[0.5*sz(3),0.07*sz(4),0.49*sz(3),0.9*sz(4)]);
sp(1)=subplot(4,1,1);
plot(sin2a,shearcal.meanU_flow,'k-','marker','.','markersize',15);
ylabel('flow speed U [m/s]')
grid on
title(['Probe #' shearcal.prb '   Sensitivity: ' num2str(shearcal.Sensitivity,4) ...
    '   ' datestr(now,'dd-mmm-yyyy')],'fontsize',18,'fontweight','bold')

sp(2)=subplot(4,1,2);
plot(sin2a,shearcal.rmsV_flow,'g-','marker','.','markersize',15);
hold on
plot(sin2a,shearcal.rmsV_noflow,'r-','marker','.','markersize',15);
legend('V_s^{flow}','V_s^{no flow}','location','North')
ylabel('shear rms voltage [V]')
grid on

sp(3)=subplot(4,1,3);
plot(sin2a,stu2,'b-','marker','.','markersize',15);
hold on
plot(sin2a,fit,'r-','marker','.','markersize',15);
plot(sin2a,fit-stu2,'c-','marker','.','markersize',15);
legend('V_s^T/(\omegaGU^2)','fit','fit-V_s^T/(\omegaGU^2)','location','NorthWest')
text(.7,.225,'V_s^T = V_s^{flow}+V_s^{no flow} with sign change for sin2\alpha<0','fontsize',10,'units','normalized')
text(.7,.15,'\omega=rotation rate / G=differentiator gain','fontsize',10,'units','normalized')
text(.7,.075,'slope of fit line at sin2\alpha=0 is the probe sensitivity','fontsize',10,'units','normalized')
ylabel('[V_{rms}/U^2]')
grid on
sgn1='';sgn2='';

%Updated by Pavan Vutukur 04/09/2019 display of + and - signs on fit
%equation
%%%%
if (sign(shearcal.coef(2)) == 1)
    sgn1='+';
elseif (sign(shearcal.coef(2)) == -1)
    sgn1 = '-';
end
if (sign(shearcal.coef(3)) == 1)
    sgn2='+';
elseif (sign(shearcal.coef(3)) == -1)
    sgn2 = '-';
end
text(0.35,0.1,['fit = ' num2str(shearcal.coef(1),'%5.4f') sgn1 ...
    num2str(abs(shearcal.coef(2)),'%5.4f') 'sin2\alpha' sgn2 ...
    num2str(abs(shearcal.coef(3)),'%5.4f') '(sin2\alpha)^3'],'fontsize',12,'units','normalized')

%%%% 


sp(4)=subplot(4,1,4);
plot(sin2a,slope,'r-','marker','.','markersize',15);
ylabel('Slope')
grid on
xlabel('sin(2\alpha)')

orient tall
set(gcf,'paperorient','portrait')
if nargin<1
    print('-dpng','-r300',[filnam '_final'])
    save([filnam '_final'],'shearcal')
else
    k=strfind(shearcal.filename,'.mat');
    if isempty(k)
        k=length(shearcal.filename)+1;
    end
    print('-dpng','-r300',[shearcal.savedir shearcal.filename '_final'])
    save([shearcal.savedir shearcal.filename(1:k-1) '_final'],'shearcal')
%     multi_print([shearcal.savedir shearcal.filename '_final'],'png','same','-r200');
end
    

% fiteq accepts curve parameters as inputs and outputs sse,
% the sum of squares error for A + B*x + C*x^3.
    function sse = fiteq(start_coef)
        A = start_coef(1);
        B = start_coef(2);
        C = start_coef(3);
        FittedCurve = A + B*sind(2*shearcal.angle) + C*sind(2*shearcal.angle).^3;
        ErrorVector = FittedCurve - shearcal.Vtotal./shearcal.meanU_flow.^2;
        sse = sum(ErrorVector .^ 2);
    end
end