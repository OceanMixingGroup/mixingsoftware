function d = ctdpreen(d)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function d = ctdpreen(d)
%
% remove spikes in p t1 t2 t2 c1 c2
% and oxygen trans fl in volts
%
%-------------------
% 11/12/15 - AP - lower t limit (looking at Arctic data!)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%
d.p = preen(d.p, 0, 6200);
d.t1 = preen(d.t1, -3, 35);
d.t2 = preen(d.t2, -3, 35);
d.c1 = preen(d.c1, 2.5, 6);
d.c2 = preen(d.c2, 2.5, 6);
d.oxygen = preen(d.oxygen, 0.5, 3.5); % volts
%d.trans = preen(d.trans, 3, 5);
%d.fl = preen(d.fl, 3, 5);
%%