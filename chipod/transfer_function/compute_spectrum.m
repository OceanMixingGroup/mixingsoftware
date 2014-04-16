% compute_spectrum.m
% called from the GUI
% computhe spectra for transfer functions and plots it
%   $Revision: 1.1.1.1 $  $Date: 2008/01/31 20:22:42 $
% Originally J.Nash
figure(hfig.fig12)

plims=get(gca,'ylim');

tmp=find(-cal.P>plims(1) & -cal.P<plims(2));

indices.P=[min(tmp):max(tmp)];
the_series={'UKTCP'};
for ii=1:k
    indices.(['CHT' num2str(ii) 'P'])=[((min(tmp)-1)*head.irep.(['CHT' num2str(ii) 'P'])+1):max(tmp)* ...
        head.irep.(['CHT' num2str(ii) 'P'])];
    the_series=[the_series {['CHT' num2str(ii) 'P']}];
end
indices.UKTCP=[((min(tmp)-1)*head.irep.UKTCP+1):max(tmp)* ...
               head.irep.UKTCP];

nfft=min(length(tmp),128);
col='rgbmcky';
hfig.fig13=figure(13);
hold off

for a=1:length(the_series)
  ser=the_series{a};
  indices.(ser)=[((min(tmp)-1)*head.irep.(ser)+1):max(tmp)* ...
               head.irep.(ser)];
  [power.(ser),freq.(ser)]=fast_psd(data.(ser)(indices.(ser)),nfft* ...
                                    head.irep.(ser),head.slow_samp_rate*head.irep.(ser));
  cfreq=max(find(freq.(ser)<5));% select 0-10 Hz for normalization.
  power.(ser)=power.(ser)./mean(power.(ser)(1:cfreq));
hfig.specplot(a)=loglog(freq.(ser),power.(ser),col(a))
hold on
end

axis([0.5     500   1e-05   10]);

legend(hfig.specplot,the_series,'location','southwest')


