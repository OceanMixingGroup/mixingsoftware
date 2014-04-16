for i=[5:5];
q.script.num=i;
q.script.prefix='batt';
q.script.pathname='j:\';
clear cal data

raw_load

cali_marlin_tst

%do other stuff

%[pxx_p1,f_p1]=psd(cal.P1,1024,head.irep.P1*slow_samp_rate);
%pxx_p1=2*pxx_p1/(head.irep.P1*slow_samp_rate);
%[pxx_s1,f_s1]=psd(cal.S1,1024,head.irep.S1*slow_samp_rate);
%pxx_s1=2*pxx_s1/(head.irep.S1*slow_samp_rate);
[pxx_t2p,f_t2p]=psd(cal.T2P,1024,head.irep.T2P*slow_samp_rate);
pxx_t2p=2*pxx_t2p/(head.irep.T2P*slow_samp_rate);

%loglog(f_t2p,pxx_t2p)



end
