% function t_xfr_fcn_from_noise_3pitot(datadir)
%   t_xfr_fcn_from_noise3pitot
%       computes dc and differentiator gain 
%       for 3pitot boards from data obtained 
%       using Agilent signal generator noise source
%       assumes Column 1 - noise source filtered at 360 Hz
%               Column 2-5 - Differentiated pitot signal for Channels 1-4
%                            filtered at 40 Hz
%
%       gains are computed over the frequency range freq_range
%       datadir - path to the directory in which
%       the calibration files are saved
datadir='\\mserver\data2\chipodGL\3PitotDiff\';
warning off
dra=dir([datadir]);
mkdir([datadir '\figs2']);

sr=4000; % sample rate 
att_gain=1;  % attenuation applied to input noise ahead of TC input
s=[date];
freq_range=[15 33];
nfft=2^13;

pp.xlm1=[1 1000];
pp.xlm2=[5 100];
pp.xlm2=[0.1 40];
% pp.xlm2=[5 40];

pp.ylm1=[1e-11 5e-2];
pp.ylm2=[1e-3 20];
pp.ylm2=[0.1 30];
% pp.ylm2=[0.1 3];
pp.fs=8;
for i0=3:length(dra)
    if ~dra(i0).isdir
        fn=([datadir dra(i0).name]);
        dat=load(fn);
        fn(fn=='_')='-';
        
        in=dat(:,2:5);
        W=dat(:,1);
        
        for ii=1:size(in,2)
            [pin(:,ii),f]=fast_psd(in(:,ii),nfft,sr);
        end
        [pW,f]=fast_psd(W,nfft,sr);
        figure(89+i0);clf;
        for ii=1:size(in,2)
            
            subplot(size(in,2),2,ii*2-1)
            pWPg(:,ii)=(pin(:,ii)./pW)./(2*pi*f).^2;
            semilogx(f,sqrt(pWPg(:,ii)),'b');grid on
            if ii==1
                title([fn],'fontsize',pp.fs)
            end
            if ii==size(in,2)
                xlabel('frequency [Hz]','fontsize',pp.fs)
                ylabel('(\Phi_{WP}/\Phi_{W})^{1/2}/(2\pif)','fontsize',pp.fs)
            end
            set(gca,'xlim',pp.xlm2,'ylim',pp.ylm2)
            
            subplot(size(in,2),2,ii*2)
            pWPg(:,ii)=(pin(:,ii)./pW)./(2*pi*f).^2;
            loglog(f,sqrt(pWPg(:,ii)),'b');grid on
            hold on
            plot([freq_range(1) freq_range(1)],pp.ylm2,'k-')
            plot([freq_range(2) freq_range(2)],pp.ylm2,'k-')
            set(gca,'xlim',pp.xlm2,'ylim',pp.ylm2)
            if ii==size(in,2)
                xlabel('frequency [Hz]','fontsize',pp.fs)
                ylabel('(\Phi_{WP}/\Phi_{W})^{1/2}/(2\pif)','fontsize',pp.fs)
            end
            diff_gain=nanmean(sqrt(pWPg(f>freq_range(1)& f<freq_range(2),ii))); %differentiator gain over freq_range
            title(['diff gain(' int2str(freq_range(1)) '-' int2str(freq_range(2)) 'Hz)=',num2str(diff_gain)])
            
            annotation('textbox','units','normalized','position',[.01 .95 .1 .05],'string',[s],'fontsize',9,'fontweight','bold','linestyle','none');
            bs=0;
            orient tall
            print('-dpng','-r150',[datadir '/figs2/' dra(i0).name(1:end-bs) '.png'])
        end
    end
end


