function [outH2t,outT2t,outH2x,outT2x,outH1t,outT1t,outH1x,outT1x,inptstar,inpxstar,oute2t,outo2t,oute2x,outo2x,oute1t,outo1t,oute1x,outo1x,tH,xH]=FetDurHTUxt(inpU,inpxkm,inpthr);
% compute significant wave height (outH) and significant wave period (outT)
% using the fetch and duration growth functions. Interpolate from user
% input of inpU, inpx, inpt (these 3 are arrays of equal size)
%
% Paul Hwang 23 June 2005 revision (phwang@nrlssc.navy.mil)
%
% Ref. Hwang and Wang (JPO, 34, 2316-2326, 2004; JPO, 35, 268-270, 2005)
% "Field measurements of duration-liited growth of wind-generated ocean
% surface waves at young stage of development" and "Corrigendum"
%
% inpU (m/s), inpxkm (km), inpthr (hr)
% computation uses MKS, input covert to MKS
%
%  function example
% inpU=[5:5:20];
% inpxkm=[300 300 300 300]
% inpthr=[12 12 12 12];
% % note inpU, inpxkm, inpthr need to be arrays of same size
% [outH2t,outT2t,outH2x,outT2x,outH1t,outT1t,outH1x,outT1x,inptstar,inpxstar,oute2t,outo2t,oute2x,outo2x,oute1t,outo1t,oute1x,outo1x,tH,xH]=FetDurHTUxt(inpU,inpxkm,inpthr);
% 
% % inptstar,inpxstar,
% 
% figmax;
% subplot(1,2,1);
% plot(inpU,outH2t,'ob',inpU,outH1t,'sb',inpU,outH2x,'+r',inpU,outH1x,'xr');
% xlabel('U_{10} (m/s)'); ylabel('H_s (m)');
% qh=legend('12 h duration (2nd order)','12 h duration (1st order)','300 km fetch (2nd order)','300 km fetch (1st order)',2);
% subplot(1,2,2);
% plot(inpU,outT2t,'ob',inpU,outT1t,'sb',inpU,outT2x,'+r',inpU,outT1x,'xr');
% xlabel('U_{10} (m/s)'); ylabel('T_s (s)');
% 
% return



inpt=inpthr*3600;
inpx=inpxkm*1e3;

% compute dimensionless inpxstar, inptstar

g=9.8;

inpxstar=inpx*g./inpU.^2;
inptstar=inpt*g./inpU;

[Aet1,aet1,Aet2,aet2,e1t,e2t,Aot1,aot1,Aot2,aot2,o1t,o2t, ...
        AH,aH,Aex2,aex2,e1x,e2x,BH,bH,Aox2,aox2,o1x,o2x,tH,xH,s1t,s2t,s1x,s2x, ...
        Aex2us,aex2us,Aox2us,aox2us,e2xus,o2xus,xHus,tHus,Aex1us,aex1us,Aox1us,aox1us,e1xus,o1xus, ...
        Aet2us,aet2us,Aot2us,aot2us,e2tus,o2tus,Aet1us,aet1us,Aot1us,aot1us,e1tus,o1tus,s1tus,s2tus,s1xus,s2xus,tofxH1,tofxH2, ...
        Aeo1,aeo1,Aeo2,aeo2]=suexet;
[oute2t]=interp1(tH,e2t,inptstar); oute=oute2t.*inpU.^4/g^2; outH2t=4*sqrt(oute);
[outo2t]=interp1(tH,o2t,inptstar); outo=outo2t*g./inpU; outT2t=2*pi./outo;
[oute1t]=interp1(tH,e1t,inptstar); oute=oute1t.*inpU.^4/g^2; outH1t=4*sqrt(oute);
[outo1t]=interp1(tH,o1t,inptstar); outo=outo1t*g./inpU; outT1t=2*pi./outo;
[oute2x]=interp1(xH,e2x,inpxstar); oute=oute2x.*inpU.^4/g^2; outH2x=4*sqrt(oute);
[outo2x]=interp1(xH,o2x,inpxstar); outo=outo2x*g./inpU; outT2x=2*pi./outo;
[oute1x]=interp1(xH,e1x,inpxstar); oute=oute1x.*inpU.^4/g^2; outH1x=4*sqrt(oute);
[outo1x]=interp1(xH,o1x,inpxstar); outo=outo1x*g./inpU; outT1x=2*pi./outo;


function [h]=figmax(ip,bx);
%function [h]=figmax(ip,bx);
%h=figure('position',bx);
%create a plot region maximize screen area
%ip=1: landscape (default)
%   2: portrate
% use figsq if a sqaure plot is needed
% figpor is the same as figmax(2);

if(nargin<1); ip=1; end
if(nargin<2);
    if(ip==1);
        %      bx=[50 50 1000 720]; %this fits the ppt frame quite well for MS figures. Desktop
        bx=[50 50 1100 720]; %this is about max size for print -depsc to get a full page display
        %%    bx=[20 50 900 600]; %this fits the ppt frame quite well for MS figures. Laptop
        %   bx=[100 100 1050 800]*0.77; %this fits the ppt frame quite well for MS figures
        % create a max plotting area
    elseif(ip==-1); %smaller landscape
        bx=[50 50 700 500];
    else
        bx=[50 50 750 900];
        %%   bx=[20 50 450 600]; %laptop
        %   bx=[100 100 800 960]*0.77;
        % create a portrait plotting area; still use max area because
        %   printer output may rescale, use max to minimize impact
    end
end
h=figure('position',bx);
return

function [Aet1,aet1,Aet2,aet2,e1t,e2t,Aot1,aot1,Aot2,aot2,o1t,o2t, ...
        AH,aH,Aex2,aex2,e1x,e2x,BH,bH,Aox2,aox2,o1x,o2x,tH,xH,s1t,s2t,s1x,s2x, ...
        Aex2us,aex2us,Aox2us,aox2us,e2xus,o2xus,xHus,tHus,Aex1us,aex1us,Aox1us,aox1us,e1xus,o1xus, ...
        Aet2us,aet2us,Aot2us,aot2us,e2tus,o2tus,Aet1us,aet1us,Aot1us,aot1us,e1tus,o1tus,s1tus,s2tus,s1xus,s2xus,tofxH1,tofxH2, ...
        Aeo1,aeo1,Aeo2,aeo2]=suexet...
    (iplot,FigNumber,sigprasc,BH,bH,beta0,beta1,beta2,AH,aH,alpha0,alpha1,alpha2,Ac,ac);
% function [Aet1,aet1,Aet2,aet2,e1t,e2t,Aot1,aot1,Aot2,aot2,o1t,o2t, ...
%         AH,aH,Aex2,aex2,e1x,e2x,BH,bH,Aox2,aox2,o1x,o2x,tH,xH,s1t,s2t,s1x,s2x, ...
%         Aex2us,aex2us,Aox2us,aox2us,e2xus,o2xus,xHus,tHus,Aex1us,aex1us,Aox1us,aox1us,e1xus,o1xus, ...
%         Aet2us,aet2us,Aot2us,aot2us,e2tus,o2tus,Aet1us,aet1us,Aot1us,aot1us,e1tus,o1tus,s1tus,s2tus,s1xus,s2xus,tofxH1,tofxH2, ...
%         Aeo1,aeo1,Aeo2,aeo2]=suexet...
%     (iplot,FigNumber,sigprasc,BH,bH,beta0,beta1,beta2,AH,aH,alpha0,alpha1,alpha2,Ac,ac);
%
% Paul Hwang 23 June 2005 revision (phwang@nrlssc.navy.mil)
%
% Ref. Hwang and Wang (JPO, 34, 2316-2326, 2004; JPO, 35, 268-270, 2005)
%

if(nargin<1); iplot=0; end
if(nargin<2); FigNumber=' '; end
if(nargin<3); sigprasc='suexet.m'; end;
if(nargin<4); BH=11.86; end
if(nargin<5); bH=-0.2368; end
if(nargin<6); beta0=3.0377; end
if(nargin<7); beta1=-0.3990; end
if(nargin<8); beta2=0.0110; end
if(nargin<9); AH=6.191e-7; end
if(nargin<10); aH=0.8106; end
if(nargin<11); alpha0=-17.6158; end
if(nargin<12); alpha1=1.7645; end
if(nargin<13); alpha2=-0.0647; end
if(nargin<14); Ac=1.22e-2; end % Hwang (2004) JO
if(nargin<15); ac=0.704; end % Hwang (2004) JO

%  BH=11.86;bH=-0.2368;beta0=3.0377;beta1=-0.3990;beta2=0.0110;AH=6.191e-7;aH=0.8106;alpha0=-17.6158;alpha1=1.7645;alpha2=-0.0647;

xH=10.^[0:0.01:6]; X=log(xH); % good for interpolation %  tH=xH; T=log(tH); note, t should be t(x), correct expressions below (tofxH1, tofxH2)
% xH=10.^[0:0.2:6]; X=log(xH); %  tH=xH; T=log(tH); note, t should be t(x), correct expressions below (tofxH1, tofxH2)

R=0.4;

%first order

o1x=BH*xH.^bH;
aot1=(bH/(bH+1));
Aot1=(BH^(1/bH)*R*(bH+1))^aot1;

% comput t(x)
RH=0.4;
tofxH1=BH/(RH*(bH+1))*xH.^(bH+1); % tofxH2=Aox2./(RH*(aox2+1)).*xH.^(aox2+1);
tH=tofxH1;

o1t=Aot1*tH.^aot1;

e1x=AH*xH.^aH;
aet1=aH/(bH+1);
Aet1=AH*(R*(bH+1)/BH)^(aet1);
e1t=Aet1*tH.^aet1;

%for omega(xH) 2nd order
Aox2=exp(beta0)*xH.^(-beta2*X);
aox2=beta1+2*beta2*X;
o2x=Aox2.*xH.^aox2;

% comput t(x)
tofxH2=Aox2./(RH*(aox2+1)).*xH.^(aox2+1);
tH=tofxH2;

Aex2=exp(alpha0)*xH.^(-alpha2*X);
aex2=alpha1+2*alpha2*X;
e2x=Aex2.*xH.^aex2;

%O=beta0+beta1*X+beta2*X.^2; o2x=exp(O);
%E=alpha0+alpha1*X+alpha2*X.^2; e2x=exp(E);

%approximation translation
b2=aox2; %beta1+2*beta2*X;
B2=Aox2; %exp(beta0)./xH.^(beta2*X);
aot2=(b2./(b2+1));
Aot2=(R*B2.^(1./b2).*(b2+1)).^aot2;
o2t=Aot2.*tH.^aot2;

a2=aex2; %alpha1+2*alpha2*X;
A2=Aex2; %exp(alpha0)./xH.^(alpha2*X);
aet2=a2./(b2+1);
Aet2=A2.*((R*(b2+1)./B2)).^(aet2); 
e2t=Aet2.*tH.^(aet2);

% s*=e*o*^4; added on 3 Nov 2004 (note p. 169)
s1t=e1t.*o1t.^4; s2t=e2t.*o2t.^4;
s1x=e1x.*o1x.^4; s2x=e2x.*o2x.^4;

Aex1=AH; aex1=aH;
Aox1=BH; aox1=bH;
Aeo1=(AH^bH/BH^aH)^(1/bH); aeo1=aH/bH;
Aeo2=(Aex2.^aox2./Aox2.^aex2).^(1./aox2); aeo2=aex2./aox2;


% translation to scaling with u* (note 4 Nov 2004, p. 175)
% duration growth with u* scaling
tofxH1=BH/(RH*(bH+1))*xH.^(bH+1); % tofxH2=Aox2./(RH*(aox2+1)).*xH.^(aox2+1);
tH=tofxH1;
xHus=xH/(1.2e-3); tHus=tH/sqrt(1.2e-3); Tus=log(tHus); Xus=log(xHus); % note 3 Nov 2004, p. 174

aex1=aH; Aex1=AH; aox1=bH; Aox1=BH;
aox1us=aox1/(1-ac*(0.5+aox1)); 
Aox1us=(Aox1*Ac^(0.5+aox1))^(1/(1-ac*(0.5+aox1)));
aex1us=aex1+aox1us*ac.*(aex1-2); 
Aex1us=Aex1*Ac^(aex1-2)*Aox1us^(ac*(aex1-2));

o1xus=Aox1us*xHus.^aox1us;
e1xus=Aex1us*xHus.^aex1us;

%first order
aot1us=(aox1us/(aox1us+1));
% Aot1us=Aox1us*(R*(aox1us+1))^aox1us;
Aot1us=(Aox1us^(1/aox1us)*R*(aox1us+1))^aot1us;
o1tus=Aot1us*tHus.^aot1us;

aet1us=aex1us/(aox1us+1);
Aet1us=Aex1us*(R*(aox1us+1)/Aox1us)^(aet1us);
e1tus=Aet1us*tHus.^aet1us;

% 2nd order
tofxH2=Aox2./(RH*(aox2+1)).*xH.^(aox2+1);
tH=tofxH2;
xHus=xH/(1.2e-3); tHus=tH/sqrt(1.2e-3); Tus=log(tHus); Xus=log(xHus); % note 3 Nov 2004, p. 174

aox2us=aox2./(1-ac*(0.5+aox2)); 
Aox2us=(Aox2.*Ac.^(0.5+aox2)).^(1./(1-ac*(0.5+aox2)));
aex2us=aex2+aox2us*ac.*(aex2-2); 
Aex2us=Aex2.*Ac.^(aex2-2).*Aox2us.^(ac.*(aex2-2));

o2xus=Aox2us.*xHus.^aox2us;
e2xus=Aex2us.*xHus.^aex2us;


%approximation translation
b2=aox2us; %beta1+2*beta2*X;
B2=Aox2us; %exp(beta0)./xH.^(beta2*X);
aot2us=(b2./(b2+1));
Aot2us=(R*B2.^(1./b2).*(b2+1)).^aot2us;
o2tus=Aot2us.*tHus.^aot2us;

a2=aex2us; %alpha1+2*alpha2*X;
A2=Aex2us; %exp(alpha0)./xH.^(alpha2*X);
aet2us=a2./(b2+1);
Aet2us=A2.*((R*(b2+1)./B2)).^(aet2us); 
e2tus=Aet2us.*tHus.^(aet2us);

% s*=e*o*^4; added on 3 Nov 2004 (note p. 169)
s1tus=e1tus.*o1tus.^4; s2tus=e2tus.*o2tus.^4;
s1xus=e1xus.*o1xus.^4; s2xus=e2xus.*o2xus.^4;

if(iplot<1); return; end
    
figmax;
subplot(1,2,1); 
loglog(xH,o2x,'-',xH,o1x,'--',xH,e2x,'-',xH,e1x,'--'); 
xlabel('x_*');ylabel('e_*                                             \omega_*'); 
gridpah(0,-8,1,1,11);
qh=legend('second order','first order',1); legendafter(qh,12);
axis([1 1e6 1e-8 100]);
labelab1('(a)');
subplot(1,2,2); 
loglog(tH,o2t,'-',tH,o1t,'--',tH,e2t,'-',tH,e1t,'--'); 
xlabel('t_*');ylabel('e_*                                              \omega_*'); 
gridpah(0,-8,1,1,11);
axis([1 1e6 1e-8 100]);
labelab1('(b)');
sigpr00;

if(iplot<2); return; end


figmax;
subplot(2,2,1); 
loglog(xH,o2x,'-',xH,o1x,'--'); xlabel('x_*');ylabel('\omega_*'); gridpah(0,-1,1,1,11);
qh=legend('second order','first order',1); legendafter(qh,12);
axis([1 1e6 0.1 100]);
labelab1('(a)');
subplot(2,2,2); 
loglog(tH,o2t,'-',tH,o1t,'--'); xlabel('t_*');ylabel('\omega_*'); gridpah(0,-1,1,1,11);
axis([1 1e6 0.1 100]);
labelab1('(b)');
subplot(2,2,3); 
semilogx(xH,b2,'-',[1 1e6],[b b],'--'); xlabel('x_*');ylabel('b_{\omegax}'); 
gridpah(0,-0.7,1,0.1,10);
axis([1 1e6 -0.7 0]);
labelab1('(c)');
subplot(2,2,4); 
semilogx(tH,aot2,'-',[1 1e6],[aot1 aot1],'--'); xlabel('t_*');ylabel('b_{\omegat}'); 
gridpah(0,-0.7,1,0.1,10);
axis([1 1e6 -0.7 0]);
labelab1('(d)');
sigpr00;

figmax;
subplot(2,2,1); 
loglog(xH,e2x,'-',xH,e1x,'--'); xlabel('x_*');ylabel('e_*'); gridpah(0,-9,1,1,11);
qh=legend('second order','first order',1); legendafter(qh,12);
axis([1 1e6 1e-9 1e-1]);
labelab1('(a)');
subplot(2,2,2); 
loglog(tH,e2t,'-',tH,e1t,'--'); xlabel('t_*');ylabel('e_*'); gridpah(0,-9,1,1,11);
axis([1 1e6 1e-9 1e-1]);
labelab1('(b)');
subplot(2,2,3); 
semilogx(xH,a2,'-',[1 1e6],[a a],'--'); xlabel('x_*');ylabel('a_{ex}'); 
gridpah(0,0,1,0.5,10);
axis([1 1e6 0 3]);
labelab1('(c)');
subplot(2,2,4); 
semilogx(tH,aet2,'-',[1 1e6],[aet1 aet1],'--'); xlabel('t_*');ylabel('a_{et}'); 
gridpah(0,0,1,0.5,10);
axis([1 1e6 0 3]);
labelab1('(d)');
sigpr00;

return
