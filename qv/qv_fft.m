max_ind=maxs.ind
nfft=min(length(index),256);
% repeats=length(indexstr2num(get(h6(7),'string'));
% if repeats>(2*length(index)/nfft-1);
repeats=min(6,fix(2*length(index)/nfft-1))
%;,end;
tic;
new_fig=figure(new_fig);
subplot(1,1,1)
hold off
for j=1:length(q.display_series)
  eval(['reps= irep.' q.series(q.display_series(j),:) ';']);
  first_ind=(min(index)-1)*reps+1;
  last_ind=max(index)*reps;
  len_ft=min([last_ind-first_ind+1 max_ind*reps]);
  eval(['v=data.' deblank(q.series(q.display_series(j),:)) '(first_ind:first_ind+len_ft);']);
  nf=nfft*reps;
  wind=hanning(nf);
  W1=2/norm(wind)^2 ;
  % jonathan's psd routine which is about twice the speed of the canned
  % one....  this one removes the mean from each subsample
  % tic
  % total=fft((v(1:nf)-mean(v(1:nf))).*wind);
  total=fft(detrend(v(1:nf)).*wind);
% vvv=var(detrend(v(1:nf)));
  powe=total(2:(nf/2+1)).*conj(total(2:(nf/2+1)));
%  figure(5);loglog(powe,'c'); hold on
  if (repeats-1)
    step=round((len_ft-nf)/(repeats-1));
    for i=step:step:(len_ft-nf);
      
%      total=fft((v(i:(i+nf-1))-mean(v(i:(i+nf-1)))).*wind);
      total=fft(detrend(v(i:(i+nf-1))).*wind);
      powe=powe+total(2:nf/2+1).*conj(total(2:nf/2+1));
  %    vvv=vvv+var(detrend(v(i:(i+nf-1))));
    end;
  end;
  powe=W1*powe'/repeats/slow_samp_rate/reps;
  fre=linspace(slow_samp_rate*reps/nf,slow_samp_rate*reps/2,nf/2);
  eval([deblank(q.series(q.display_series(j),:)) '_power=powe;']);
  eval([deblank(q.series(q.display_series(j),:)) '_freq=fre;']);
  
  % Make a rough estimate of the quantity <u^2> 
  
% disp(sprintf ('Series %s has variance= %6.4e and integrated psd= %6.4e ' , ...
 %    deblank(series(display_series(j),:)), vvv/repeats, sum(powe)/nf*slow_samp_rate*reps))
% if (series(display_series(j),1:2)=='s1' | series(display_series(j),1:2)=='s2')
%  disp(sprintf('epsilon = %8.6e ' , 15*1.34510E-06*sum(powe)/nf*slow_samp_rate*reps))
% end
% if (series(display_series(j),1:2)=='tp' )
 % disp(sprintf('chi = %8.6e ' , 6*1.5e-07*sum(powe)/nf*slow_samp_rate*reps))
% end
% if (series(display_series(j),1:3)=='ucp' )
%  disp(sprintf('chi_con? = %8.6e ' , ...
%      6*1.5e-07*sum(powe)/nf*slow_samp_rate*reps))
%end
% toc
  
  loglog(fre,powe);
  hold on
  % grid
end
handles=get(gca,'children') ;
for i=1:length(q.display_series) % length(handles)+1-length(display_series):length(handles)
  set(handles(length(handles)+1-i),'color',cmap(q.display_series(i),:))
end
ft_axis=axis;
axis([slow_samp_rate/nfft slow_samp_rate*4 ft_axis(3) ft_axis(4)])
% legend(series(q.display_series,:))
title('Power Spectral Density')
xlabel('Frequency (Hz)')
% if length(zoomhandle)~=new_fig
%   zoomhandle(new_fig)=uicontrol('Style','Popup','Position',[.91 .955 .088 .04], 'String','zoom|in|out','Callback','zoomm(zoomhandle)');
% end
% grid on
zoom on
toc;



