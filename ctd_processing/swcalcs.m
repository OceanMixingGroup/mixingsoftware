  function data = swcalcs(data, cfg)
% function data = swcalcs(data, cfg)
% calc s1 s2 theta1 theta2 sigma1 sigma2 oxygen depth
  
data.s1 = sw_salt(10*data.c1/sw_c3515, data.t1, data.p);
data.s2 = sw_salt(10*data.c2/sw_c3515, data.t2, data.p);

data.theta1 = sw_ptmp(data.s1, data.t1, data.p,0);
data.theta2 = sw_ptmp(data.s2, data.t2, data.p,0);

data.sigma1 = sw_pden(data.s1, data.t1, data.p, 0);
data.sigma2 = sw_pden(data.s2, data.t2, data.p, 0);

%data.oxygen = volt2ox(data.oxygen, data.s1, data.t1, data.p, cfg.oxcal);

data.depth = sw_dpth(data.p, data.lat);

 
