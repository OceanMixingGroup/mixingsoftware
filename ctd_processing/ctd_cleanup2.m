  function data = ctd_cleanup2(data)
% function data = ctd_cleanup2(data)
% 

% remove spikes
ib=find(abs(diff(data.t1))>.5); data.t1(ib)=NaN;
ib=find(abs(diff(data.t2))>.5); data.t2(ib)=NaN;


%
% despike T C
prodc = 5e-7;   diffc = 1e-1;   
%prodc = 1e-7;   diffc = 5e-4;   
prodt = 1e-4;   difft = 1e-1;   
ibefore = 1;    iafter = 1;%
figures=0;

 data.c1 = tms_tc_glitchcorrect(data.c1, diffc, prodc, ibefore, iafter, figures);
 data.c2 = tms_tc_glitchcorrect(data.c2, diffc, prodc, ibefore, iafter, figures);
 data.t1 = tms_tc_glitchcorrect(data.t1, difft, prodt, ibefore, iafter, figures);
 data.t2 = tms_tc_glitchcorrect(data.t2, difft, prodt, ibefore, iafter, figures);
 
data.s1 = sw_salt(10*data.c1/sw_c3515, data.t1, data.p);
data.s2 = sw_salt(10*data.c2/sw_c3515, data.t2, data.p);

% despike S
% remove spikes
ib=find(abs(diff(data.s1))>.1); data.s1(ib)=NaN;
ib=find(abs(diff(data.s2))>.1); data.s2(ib)=NaN;

% remove out of bounds data
smin=33; smax=36;
ib=find(data.s1<smin|data.s1>smax); data.s1(ib)=NaN;
ib=find(data.s2<smin|data.s2>smax); data.s2(ib)=NaN;

% despike salinity
prods = 1e-8;   diffs = 1e-3;   
ibefore = 2;    iafter = 2;
figures=0;
data.s1 = tms_tc_glitchcorrect(data.s1, diffs, prods, ibefore, iafter, figures);
data.s2 = tms_tc_glitchcorrect(data.s2, diffs, prods, ibefore, iafter, figures);

data.theta1 = sw_ptmp(data.s1, data.t1, data.p,0);
data.theta2 = sw_ptmp(data.s2, data.t2, data.p,0);

data.sigma1 = sw_pden(data.s1, data.t1, data.p, 0);
data.sigma2 = sw_pden(data.s2, data.t2, data.p, 0);


