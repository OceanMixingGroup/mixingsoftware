function t_xfr_fcn_from_noise(datadir,sr)
%   t_xfr_fcn_from_noise
%   computes dc and differentiator gain from data obtained 
%   using Agilent signal generator noise source
%   column 1 in data file - noise source
%   column 2 in data file - TC out
%
%   gains are computed over the frequency range freq_range
%   In two forms: 1. mean gain over the range.
%   This coefficient is used if \phi_{out}/\phi_{white noise} is flat
%   In this case this coefficient should be in second place in 
%   head.coef.TP, and third and forth place should be zero: [1 mg 0 0 1] 
%   2. functional fit over the range in form 10^(c1*log10(f)+c0).
%   This coefficient is used if \phi_{out}/\phi_{white noise} is not flat
%   In this case these coefficient should be in third and forth place in 
%   head.coef.TP, and second coefficient should be one: [1 1 c0 c1 1] 
%
%   datadir - path to the directory in which
%   sr - sample rate; usually 1000 or 4000 (sr=4000; or sr=1000;)
%   $Revision: 1.1.1.1 $  $Date: 2011/05/17 18:08:06 $

% datadir='\\baltic\data2\chipod\tao_may08\calibration\Tdiff\C\';

warning off
dra=dir([datadir '\data\']);
mkdir([datadir '\figs']);

freq_range=[2.5 20];
% freq_range=[4 20];
nfft=2^13;

pp.xlm=[.2 1000];
pp.figpos=[300 100 800 800];
pp.figpappos=[.25 1.5 8 8];
pp.ylm1=[1e-11 1e-3];
pp.ylm2=[1e-5 10];

for i0=3:length(dra)
    if ~dra(i0).isdir
        fn=([datadir '\data\' dra(i0).name]);
        dat=load(fn);
        fn(fn=='_')='-';
        output=dat(:,2);
        white_noise=dat(:,1);
        
        [pout,f]=fast_psd(output,nfft,sr);
        [pwn,f]=fast_psd(white_noise,nfft,sr);
        figure(89+i0);clf;set(gcf,'position',pp.figpos,'paperposition',pp.figpappos)
        
        subplot(2,1,1)
        loglog(f,pout,'r',f,pwn,'k');grid
        legend('\Phi_{output}','\Phi_{white noise}','location','southwest')
        title([fn])
        xlabel('frequency [Hz]')
        ylabel('data as sampled [V^2/Hz]')
        xlim(pp.xlm),ylim(pp.ylm1)
        set(gca,'xtick',10.^[-3:4])
        
        subplot(2,1,2)
        % find differentiator gain
        pTPg=(pout./pwn)./(2*pi*f).^2;
        % calculate mean differentiator gain over freq_range
        infr=f>freq_range(1)& f<freq_range(2);
        mean_diff_gain=nanmean(sqrt(pTPg(infr))); 
        % fit differentiator gain wit a function over freq_range
%         dg1=polyfit(f(infr),pTPg(infr),1);
%         dg2=polyfit(f(infr),log10(pTPg(infr)),1);
        dg3=polyfit(log10(f(infr)),log10(pTPg(infr)),1);

        loglog(f,sqrt(pTPg),'k');hold on
%         loglog(f,sqrt(dg1(1).*f+dg1(2)),'g');
%         loglog(f,sqrt(10.^(dg2(1).*f+dg2(2))),'m');
        loglog(f,sqrt(10.^(dg3(1).*log10(f)+dg3(2))),'b')
        plot([15 15],pp.ylm2,'k-',[freq_range(1) freq_range(1)],pp.ylm2,'k--',...
            [freq_range(2) freq_range(2)],pp.ylm2,'k--')
        grid,set(gca,'xtick',10.^[-3:4]),xlim(pp.xlm),ylim(pp.ylm2)
        xlabel('frequency [Hz]')
%         legend('(pTPg)^{1/2}=(\Phi_{output}/\Phi_{white noise})^{1/2}/(2\pi\cdotf)',...
%             ['Fit to pTPg over (' num2str(freq_range(1)) '-' num2str(freq_range(2)) 'Hz): a_1*f+a_0'],...
%             ['Fit to pTPg over (' num2str(freq_range(1)) '-' num2str(freq_range(2)) 'Hz): 10^{b_1*f+b_0}'],...
%             ['Fit to pTPg over (' num2str(freq_range(1)) '-' num2str(freq_range(2)) 'Hz): 10^{c_1*log_{10}f+c_0}'],...
%             'location','southwest')
        legend('(pTPg)^{1/2}=(\Phi_{output}/\Phi_{white noise})^{1/2}/(2\pi\cdotf)',...
            ['Fit to pTPg over (' num2str(freq_range(1)) '-' num2str(freq_range(2)) 'Hz): 10^{c_1*log_{10}f+c_0}'],...
            'location','southwest')
        text(0.65,0.95,['mean diff gain(' num2str(freq_range(1)) '-' num2str(freq_range(2)) 'Hz)=',num2str(mean_diff_gain)],...
            'units','normalized')
%         text(0.65,0.74,['a_1=' num2str(dg1(1)) ', a_0=' num2str(dg1(2))],'units','normalized')
%         text(0.65,0.81,['b_1=' num2str(dg2(1)) ', b_0=' num2str(dg2(2))],'units','normalized')
        text(0.65,0.88,['c_1=' num2str(dg3(1)) ', c_0=' num2str(dg3(2))],'units','normalized')
        ylabel('(\Phi_{output}/\Phi_{white noise})^{1/2}/(2\pi\cdotf)')
        bs=0;
        print('-dpng','-r300',[datadir '/figs/' dra(i0).name(1:end-bs) '.png'])
    end
end


