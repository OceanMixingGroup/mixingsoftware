% recalibrate_TC.m
% Script recalibrates Chameleon temperature and conductivity sensors
% using saved by labTCcalibration calibration data
%
% $Revision: 1.1 $ $Date: 2011/05/24 22:17:55 $ $Author: aperlin $	
% A. Perlin, September 2010
T_polynom_order=2;
C_polynom_order=1;
caldir='c:\work\temp2\calibrate\';
d=dir([caldir '2*']);
for jj=1:length(d)
    dd=dir([caldir d(jj).name '\ca*']);
    for kk=1:length(dd)
        load([caldir d(jj).name '\' dd(kk).name]);
        circuits=calibration.circuits;
        sensors=calibration.sensors;
        caltype=calibration.type;
        calibration.coeff=zeros(4,length(sensors));
        for ii=1:length(sensors)
            sens=char(caltype(ii));
            clear coeff;
            if char(caltype(ii))=='T'
                p=polyfit(calibration.sensor(:,ii),...
                    calibration.sbdT,T_polynom_order);
                coeff(1:T_polynom_order+1)=fliplr(p);
            elseif char(caltype(ii))=='C'
                p=polyfit(calibration.sensor(:,ii),...
                    calibration.sbdC,C_polynom_order);
                coeff(1:C_polynom_order+1)=fliplr(p);
            end
            calibration.coeff(1:length(coeff),ii)=coeff;
            save([caldir d(jj).name '\' dd(kk).name],'calibration');
%             % plot calibration figure
%             fc=figure(38);clf
%             subplot(3,1,1)
%             if length(coeff)==4
%                 plot(calibration.sensor(:,ii),coeff(1)+...
%                     coeff(2).*calibration.sensor(:,ii)+...
%                     coeff(3).*calibration.sensor(:,ii).^2+...
%                     coeff(4).*calibration.sensor(:,ii).^3,'k-')
%                 title(['Circuit ' char(circuits(ii)) ' Sensor ' char(sensors(ii)) ...
%                     ': ' num2str(coeff(1)) ' + ' num2str(coeff(2)) '\cdotV + '...
%                     num2str(coeff(3)) '\cdotV^2 + ' num2str(coeff(4)) '\cdotV^3'])
%             elseif length(coeff)==3
%                 plot(calibration.sensor(:,ii),coeff(1)+...
%                     coeff(2).*calibration.sensor(:,ii)+...
%                     coeff(3).*calibration.sensor(:,ii).^2,'k-')
%                 title(['Circuit ' char(circuits(ii)) ' Sensor ' char(sensors(ii)) ...
%                     ': ' num2str(coeff(1)) ' + ' num2str(coeff(2)) '\cdotV + '...
%                     num2str(coeff(3)) '\cdotV^2'])
%             elseif length(coeff)==2
%                 plot(calibration.sensor(:,ii),coeff(1)+...
%                     coeff(2).*calibration.sensor(:,ii),'k-')
%                 title(['Circuit ' char(circuits(ii)) ' Sensor ' char(sensors(ii)) ...
%                     ': ' num2str(coeff(1)) ' + ' num2str(coeff(2)) '\cdotV'])
%             end
%             if ~isnan(calibration.sensor(:,ii))
%                 set(gca,'ylim',[min(calibration.(['sbd' sens])) ...
%                     max(calibration.(['sbd' sens]))],...
%                     'xlim',[min(calibration.sensor(:,ii)) ...
%                     max(calibration.sensor(:,ii))]);
%             end
%             xlabel('V')
%             ylabel(['Fit ' sens])
%             
%             subplot(3,1,2)
%             plot(calibration.(['sbd' sens]),'b.','markersize',15)
%             hold on
%             if length(coeff)==4
%                 plot(coeff(1)+coeff(2).*calibration.sensor(:,ii)+...
%                     coeff(3).*calibration.sensor(:,ii).^2+...
%                     coeff(4).*calibration.sensor(:,ii).^3,'r.','markersize',15)
%             elseif length(coeff)==3
%                 plot(coeff(1)+coeff(2).*calibration.sensor(:,ii)+...
%                     coeff(3).*calibration.sensor(:,ii).^2,'r.','markersize',15)
%             elseif length(coeff)==2
%                 plot(coeff(1)+coeff(2).*calibration.sensor(:,ii),'r.','markersize',15)
%             end
%             legend(['Seabird ' sens],['Sensor ' sens],'location','best')
%             if sens=='T'
%                 ylabel('T [\circC]')
%             elseif sens=='C'
%                 ylabel('C [S/m]')
%             end
%             subplot(3,1,3)
%             if length(coeff)==4
%                 plot(coeff(1)+coeff(2).*calibration.sensor(:,ii)+...
%                     coeff(3).*calibration.sensor(:,ii).^2+...
%                     coeff(4).*calibration.sensor(:,ii).^3-...
%                     calibration.(['sbd' sens]),'b.','markersize',15)
%             elseif length(coeff)==3
%                 plot(coeff(1)+coeff(2).*calibration.sensor(:,ii)+...
%                     coeff(3).*calibration.sensor(:,ii).^2-...
%                     calibration.(['sbd' sens]),'b.','markersize',15)
%             elseif length(coeff)==2
%                 plot(coeff(1)+coeff(2).*calibration.sensor(:,ii)-...
%                     calibration.(['sbd' sens]),'b.','markersize',15)
%             end
%             legend(['Sensor ' sens ' - ' 'Seabird ' sens],'location','best')
%             if char(caltype(ii))=='T'
%                 ylabel('T [\circC]')
%             elseif char(caltype(ii))=='C'
%                 ylabel('C [S/m]')
%             end
%             orient(fc,'tall');
%             print(fc,'-dpng','-r200',[caldir d(jj).name '\' char(circuits(ii)) '_' char(sensors(ii)) '_' char(caltype(ii)) 'cals' num2str(jj) '.png']);
        end
    end
end
