%%
%ctd calibration data for ttide leg 1, starting 14 january

%%

% ctd
cfg.ctdsn = '381';

% c1
cfg.c1sn = 2818;
cfg.c1cal.ghij = [-1.01991982e+001 1.39657496e+000 8.63266930e-004 2.35390719e-005]; 
cfg.c1cal.ctpcor = [3.2500e-006 -9.5700e-008];
cfg.c1date = '10-Oct-14';

% t1
cfg.t1sn = 4138;
cfg.t1cal.ghij = [4.32587997e-003 6.28766782e-004 2.09691008e-005 1.75833345e-006];
cfg.t1cal.f0 = 1000;
cfg.t1date = '07-Oct-2014';
    
% c2
cfg.c2sn = 2765;
cfg.c2cal.ghij = [-9.94163417e+000 1.36322370e+000 -6.82053414e-004 2.35390719e-005]; 
cfg.c2cal.ctpcor = [3.2500e-006 -9.5700e-008];
cfg.c2date = '10-Oct-14';

% t2
%cfg.t2sn = 2322;
%cfg.t2cal.ghij = [4.32435585e-003 6.42069090e-004 2.34449820e-005 1.28207735e-004];
%cfg.t2cal.f0 = 1000;
%cfg.t2date = '14-Oct-2014';

% t2 / JN changing 
cfg.t2sn = 2322;
cfg.t2cal.ghij = [4.32435585e-003 6.42069090e-004 2.34449820e-005 2.29796303E-006];
cfg.t2cal.f0 = 1000;
cfg.t2date = '14-Oct-2014';

% p
cfg.psn = 0401;	
cfg.pcal.c = [-4.587324e+004 2.203974e-001 1.428573e-002];
cfg.pcal.d = [3.996177e-002 0.000000e+0];
cfg.pcal.t = [2.998631e+001 2.524827e-004 4.059283e-006 2.815200e-009 0.000000e+0];
cfg.pcal.AD590 = [1.117000e-002 -8.668320e+000];
cfg.pcal.linear = [1.0000 0];
cfg.pdate = '01-OCT-2014';

% oxygen ***from PsaReport.txt not cal sheet
cfg.oxsn = 0875;
cfg.oxcal.soc = 4.8090e-001;
cfg.oxcal.boc = 0.0;
cfg.oxcal.tcor = 0.0009;
cfg.oxcal.pcor = 1.35e-004;
cfg.oxcal.voffset = -0.5165;
cfg.oxdate = '';
