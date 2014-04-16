function calibrate_Tnode(filename,unit,t1,t2,t3,t4,polinom_order)
% filename is matfile name Tnode and seabird data
% unit is Tnode unit number(integer)
% t1 through t4 are sensor IDs (strings)
% polinom_order is the order of the polinom for calibration fit
% A. Perlin 25 July 2011
if ~exist('polinom_order','var')
    polinom_order=2;
end
%% Load and plot data 
load(filename);
coeffT1=[0 0 0 0 0];
coeffT2=[0 0 0 0 0];
coeffT3=[0 0 0 0 0];
coeffT4=[0 0 0 0 0];
tlims=[min(sbe.temp)-1 max(sbe.temp)+1];
% plot the data
figure(1), clf
s(1)=subplot(2,1,1);
plot(sbe.time,sbe.temp,'k.')
datetick
title('Seabird')
set(gca,'xlim',[sbe.time(1) sbe.time(end)])
s(2)=subplot(2,1,2);
hold on
plot(node.time,node.T1,'b.')
plot(node.time,node.T2,'r.')
plot(node.time,node.T3,'g.')
plot(node.time,node.T4,'m.')
kdatetick
legend(['T1: ' t1],['T2: ' t2],['T3: ' t3],['T4: ' t4],'location','best')
title(['Tnode ' num2str(unit)])
set(gca,'xlim',[sbe.time(1) sbe.time(end)])
linkaxes(s,'x')
ddr=find(filename=='/' | filename=='\'); 
if ~isempty(ddr)
    filedir=filename(1:ddr(end));
else
    filedir=[];
end
print('-dpng','-r200',[filedir num2str(unit) 'seabird_T']);

%% calibrate
clear cal
for jj=1:4
    tt=eval(['t' num2str(jj)]);
    for ii=1:max(sbe.count)
        in=find(sbe.count==ii);
        sbt=sbe.temp(in);
        time=sbe.time(in);
        %     good=find(time>time(1)+1/24/12 & time<time(end)-1/24/12);
        good=find(time>time(1)+1/24/10 & time<time(end)-1/24/10);
        time=time(good);
        cal.sbt(ii)=nanmean(sbt(good));
        cal.tv(ii)=nanmean(node.(['T' num2str(jj)])(node.time>time(1) & node.time<time(end)));
    end
    good=find(~isnan(cal.tv));
    if ~isempty(good)
        cal.tv=cal.tv(good);
        cal.sbt=cal.sbt(good);
    end
    v=min(cal.tv):(max(cal.tv)-min(cal.tv))/100:max(cal.tv);
    p=polyfit(cal.tv,cal.sbt,polinom_order);
    coeffT(1:polinom_order+1)=fliplr(p);
    figure(3),clf
    subplot(3,1,1)
    if polinom_order==3
        plot(v,coeffT(1)+coeffT(2).*v+coeffT(3).*v.^2+coeffT(4).*v.^3,'b-')
        title(['Unit ' num2str(unit) ' T' num2str(jj) '(' tt '): ' num2str(coeffT(1)) ' + ' num2str(coeffT(2))...
            '\cdotV + ' num2str(coeffT(3)) '\cdotV^2 + ' num2str(coeffT(4)) '\cdotV^3'])
    elseif polinom_order==2
        plot(v,coeffT(1)+coeffT(2).*v+coeffT(3).*v.^2,'b-')
        title(['Unit ' num2str(unit) ' T' num2str(jj) '(' tt '): ' num2str(coeffT(1)) ' + ' num2str(coeffT(2))...
            '\cdotV + ' num2str(coeffT(3)) '\cdotV^2'])
    elseif polinom_order==1
        plot(v,coeffT(1)+coeffT(2).*v,'b-')
        title(['Unit ' num2str(unit) ' T' num2str(jj) '(' tt '): ' num2str(coeffT(1)) ' + ' num2str(coeffT(2))...
            '\cdotV'])
    end
    if ~isnan(v)
        set(gca,'ylim',tlims,'xlim',[min(v) max(v)]);
    end
    xlabel('V')
    ylabel('Fit T')
    subplot(3,1,2)
    plot(cal.sbt,'k.','markersize',10)
    hold on
    if polinom_order==3
        plot(coeffT(1)+coeffT(2).*cal.tv+coeffT(3).*cal.tv.^2+coeffT(4).*cal.tv.^3,'b.','markersize',10)
    elseif polinom_order==2
        plot(coeffT(1)+coeffT(2).*cal.tv+coeffT(3).*cal.tv.^2,'b.','markersize',10)
    elseif polinom_order==1
        plot(coeffT(1)+coeffT(2),'b.','markersize',10)
    end
    legend('Seabird T',['Tnode T' num2str(jj)],'location','best')
    ylabel('T [\circC]')
    subplot(3,1,3)
    if polinom_order==3
        plot(coeffT(1)+coeffT(2).*cal.tv+coeffT(3).*cal.tv.^2+coeffT(4).*cal.tv.^3-cal.sbt,'c.','markersize',10)
    elseif polinom_order==2
        plot(coeffT(1)+coeffT(2).*cal.tv+coeffT(3).*cal.tv.^2-cal.sbt,'c.','markersize',10)
    elseif polinom_order==1
        plot(coeffT(1)+coeffT(2)-cal.sbt,'c.','markersize',10)
    end
    legend(['Tnode T' num2str(jj) ' - Seabird T'],'location','best')
    ylabel('T [\circC]')
    fname=[filedir 'Tnode' num2str(unit) '_T' num2str(jj) '_' tt '_cals'];
    print('-dpng','-r200',fname);
    coeff.(['T' num2str(jj)])=coeffT;
end
save([filedir 'calcoeff' num2str(unit)],'coeff')
