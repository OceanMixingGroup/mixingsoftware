function shear_xfr_fcn_from_noise(datadir)
%   shear_xfr_fcn_from_noise
%       computes dc and differentiator gain from data obtained 
%       using Agilent signal generator noise source
%       assumes Ch1 - noise source
%               Ch2 - Shear out
%
%       for now file path should be changed in script
%       also sample rate and attenuator gain
%
%       gains are computed over the frequency range freq_range
%       with 30Hz, 60Hz centre bands notched out
% datadir - path to the directory in which
%  the calibration files are saved

warning off
dra=dir([datadir]);
mkdir([datadir '\figs']);

sr=4000; % sample rate 
att_gain=1;  %1./11232; % attenuation applied to input noise ahead of shear input
s=['Xpod Shear diff Xfer Fn, ' date];
freq_range=[2 40];
nfft=2^13;

pp.xlm=[.2 400];
pp.figpos=[300 100 800 800];
pp.figpappos=[.25 1.5 8 8];
pp.ylm1=[1e-11 1e-2];
pp.ylm2=[1e-5 1];

for i0=3:length(dra)
    if ~dra(i0).isdir
        fn=([datadir dra(i0).name]);
        dat=load(fn);
        fn(fn=='_')='-';
        in=dat(:,2);
        Sh=dat(:,1);
        
        [pin,f]=fast_psd(in,nfft,sr);
        [pSh,f]=fast_psd(Sh,nfft,sr);
        figure(89+i0);clf;set(gcf,'position',pp.figpos,'paperposition',pp.figpappos)
        
        subplot(2,1,1)
        loglog(f,pin,'r',f,pSh,'k');grid
        legend('\Phi_{output}','\Phi_{white noise}','location','northwest')
        title([fn])
        xlabel('frequency [Hz]')
        ylabel('data as sampled [V^2/Hz]')
        xlim(pp.xlm),ylim(pp.ylm1)
        %     set(gca,'xtick',10.^[-3:4])
        
        subplot(2,1,2)
        pShPg=(pin./pSh)./(2*pi*f).^2;
        loglog(f,sqrt(pShPg),'b');grid,xlim(pp.xlm),ylim(pp.ylm2)
        xlabel('frequency [Hz]')
        ylabel('(\Phi_{ShP}/\Phi_{Sh})^{1/2}/(2\pif)')
        diff_gain=nanmean(sqrt(pShPg(f>freq_range(1)& f<freq_range(2)))); %differentiator gain over freq_range
        title(['diff gain(' int2str(freq_range(1)) '-' int2str(freq_range(2)) 'Hz)=',num2str(diff_gain)])
        
        annotation('textbox','units','normalized','position',[.01 .95 .1 .05],'string',[s],'fontsize',9,'fontweight','bold','linestyle','none');
        bs=0;
        print('-dpng','-r150',[datadir '/figs/' dra(i0).name(1:end-bs) '.png'])
    end
end


