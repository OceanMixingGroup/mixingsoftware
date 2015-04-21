function data = freqconvert(data, cfg)
  
data.p = freq2pressure(data.p, data.pst, cfg.pcal);
data.t1 = freq2temp(data.t1, cfg.t1cal);
data.t2 = freq2temp(data.t2, cfg.t2cal);
data.c1 = freq2cond(data.c1, data.t1, data.p, cfg.c1cal);
data.c2 = freq2cond(data.c2, data.t2, data.p, cfg.c1cal);

data.s1 = sw_salt(10*data.c1/sw_c3515, data.t1, data.p);
data.s2 = sw_salt(10*data.c2/sw_c3515, data.t2, data.p);

data.theta1 = sw_ptmp(data.s1, data.t1, data.p,0);
data.theta2 = sw_ptmp(data.s2, data.t2, data.p,0);

data.sigma1 = sw_pden(data.s1, data.t1, data.p, 0);
data.sigma2 = sw_pden(data.s2, data.t2, data.p, 0);

data.oxygen = volt2ox(data.oxygen, data.s1, data.t1, data.p, cfg.oxcal);
