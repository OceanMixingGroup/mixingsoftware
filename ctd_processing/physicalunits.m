function data = physicalunits(data, cfg)
  
p_atm = 10.1353;
data.p = freq2pressure(data.p, data.pst, cfg.pcal) - p_atm;
data.t1 = freq2temp(data.t1, cfg.t1cal);
data.t2 = freq2temp(data.t2, cfg.t2cal);
data.c1 = freq2cond(data.c1, data.t1, data.p, cfg.c1cal);
data.c2 = freq2cond(data.c2, data.t2, data.p, cfg.c2cal);
data = rmfield(data, 'pst');
