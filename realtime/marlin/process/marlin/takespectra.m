function spec=takespectra(head,cal,todo,nfft);
% takes the data in cal and makes spectra of the variables
% specified in todo.  spec.S1.f,spec,S1.p....
%
  spec=[];
for i=1:length(todo);
  irep= getfield(head.irep,todo{i});
  dat = getfield(cal,todo{i});
  t = (1:length(dat))/head.slow_samp_rate/irep;
  p = matrix_psd(t,dat,nfft*irep,2);
  spec=setfield(spec,todo{i},p);
end;

  