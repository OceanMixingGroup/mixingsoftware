function calibrate_3pitot(fname)
% Function to calibrate Chipod pressure senser
% loads 2 column ASCII file
% 1st column - pressure [PSI]
% 2nd column - counts
% uses fname to create .png images with callibration coefficients\

% [fnam,pat]=uigetfile('C:\ZepelinDataC\Chipod\*.*','pick it');
% path(path,pat)
% fnam
a=load(fname);
fstart=find(fname=='/' | fname=='\');fstart=fstart(end)+1;
fstop=find(fname=='.');fstop=fstop(end)-1;
pres1=a(:,1);pres2=pres1;pres3=pres1;
w1=a(:,2);
w2=a(:,3);
w3=a(:,4);
[c imin]=min(pres1);
[c imax]=max(pres1);
if w1(imin)>w1(imax)
    pres1=-pres1;
end
if w2(imin)>w2(imax)
    pres2=-pres2;
end
if w3(imin)>w3(imax)
    pres3=-pres3;
end
% if pres1(1)<pres1(end) && w1(1)>w1(end)
%     pres1=-pres1;
% end
% if pres2(1)<pres2(end) && w2(1)>w2(end)
%     pres2=-pres2;
% end
% if pres3(1)<pres3(end) && w3(1)>w3(end)
%     pres3=-pres3;
% end
% least square fit
[p1,s1]=polyfit(w1,pres1,1);
lsfits1=polyval(p1,w1);
[p2,s2]=polyfit(w2,pres2,1);
lsfits2=polyval(p2,w2);
[p3,s3]=polyfit(w3,pres3,1);
lsfits3=polyval(p3,w3);
% robust linear regression
[r1,sr1]=robustfit(w1,pres1);
r1=flipud(r1);
rfits1=polyval(r1,w1);
[r2,sr2]=robustfit(w2,pres2);
r2=flipud(r2);
rfits2=polyval(r2,w2);
[r3,sr3]=robustfit(w3,pres3);
r3=flipud(r3);
rfits3=polyval(r3,w3);


figure(1);
% W1
subplot(3,2,1)
plot(w1,pres1,'r<',w1,lsfits1,'b-',w1,rfits1,'k-')
xlabel('Volts')
ylabel('Pressure [cm]')
legend('Data Points','Least Square Fit','Robust Fit','location','SE')
grid on
if p1(1)>0; pp1=['+' num2str(p1(1))]; else pp1=num2str(p1(1));end
if r1(1)>0; rr1=['+' num2str(r1(1))]; else rr1=num2str(r1(1));end
if length(pp1)>8; pp1=pp1(1:8);end;if length(rr1)>8; rr1=rr1(1:8);end
[ttle1,err]=sprintf('%s W1 ',fname(fstart:fstop));
[ttle2,err]=sprintf('LSF: PSI =%.4f%s*V  RF: PSI =%.4f%s*V',p1(2),pp1,r1(2),rr1);
tt=title({ttle1;ttle2},'interpreter','none');
subplot(3,2,2)
plot(w1,lsfits1-pres1,'b*',w1,rfits1-pres1,'k*');
xlabel('Volts')
ylabel('Diff Pressure (Fit-Data) [cm]')
grid on
legend('Least Square Fit','Robust Fit','location','best')
[ttle,err]=sprintf('Fit Minius Actual Values');
title(ttle);
% W2
subplot(3,2,3)
plot(w2,pres2,'r<',w2,lsfits2,'b-',w2,rfits2,'k-')
xlabel('Volts')
ylabel('Pressure [cm]')
legend('Data Points','Least Square Fit','Robust Fit','location','SE')
grid on
if p2(1)>0; pp2=['+' num2str(p2(1))]; else pp2=num2str(p2(1));end
if r2(1)>0; rr2=['+' num2str(r2(1))]; else rr2=num2str(r2(1));end
if length(pp2)>8; pp2=pp2(1:8);end;if length(rr2)>8; rr2=rr2(1:8);end
[ttle1,err]=sprintf('%s W2 ',fname(fstart:fstop));
[ttle2,err]=sprintf('LSF: PSI =%.4f%s*V  RF: PSI =%.4f%s*V',p2(2),pp2,r2(2),rr2);
tt=title({ttle1;ttle2},'interpreter','none');
subplot(3,2,4)
plot(w2,lsfits2-pres2,'b*',w2,rfits2-pres2,'k*');
xlabel('Volts')
ylabel('Diff Pressure (Fit-Data) [cm]')
grid on
legend('Least Square Fit','Robust Fit','location','best')
% W3
subplot(3,2,5)
plot(w3,pres3,'r<',w3,lsfits3,'b-',w3,rfits3,'k-')
xlabel('Volts')
ylabel('Pressure [cm]')
legend('Data Points','Least Square Fit','Robust Fit','location','SE')
grid on
if p3(1)>0; pp3=['+' num2str(p3(1))]; else pp3=num2str(p3(1));end
if r3(1)>0; rr3=['+' num2str(r3(1))]; else rr3=num2str(r3(1));end
if length(pp3)>8; pp3=pp3(1:8);end;if length(rr3)>8; rr3=rr3(1:8);end
[ttle1,err]=sprintf('%s W3 ',fname(fstart:fstop));
[ttle2,err]=sprintf('LSF: PSI =%.4f%s*V  RF: PSI =%.4f%s*V',p3(2),pp3,r3(2),rr3);
tt=title({ttle1;ttle2},'interpreter','none');
subplot(3,2,6)
plot(w3,lsfits3-pres3,'b*',w3,rfits3-pres3,'k*');
xlabel('Volts')
ylabel('Diff Pressure (Fit-Data) [cm]')
grid on
legend('Least Square Fit','Robust Fit','location','best')

orient tall
print('-dpng','-r200',fname(1:end-4));
