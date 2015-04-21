
cruise = 'iwise10';
icast = 1;

datadir = ['/Users/jen/projects/swirm/Ladc/data/'];
ctddir = [datadir 'ctd/'];
ctdlist = dirs(fullfile(ctddir, '*.cnv'), 'fullfile', 1);
hdrlist = dirs(fullfile(ctddir, '*.hdr'), 'fullfile', 1);
ctdname = ctdlist(icast).name;
disp(['CTD file = ' ctdname])

%%
% 24 Hz data 
disp('loading:')
clear d
fid = fopen(ctdname);
d = textscan(fid,'%f%f%f%f%f%f%f%f%f%f%f%f%d%f%d%d%d', 'HeaderLines', 69);
fclose(fid);
 
data.p = d{3};
data.t1 = d{4};
data.t2 = d{5};
data.c1 = d{6};
data.c2 = d{7};
data.s1 = d{8};
data.s2 = d{9};
data.fl = d{10}; % *** approx nonsense
data.oxygen = d{11}; % *** hysteresis, need to lag 6 s according to instrument info 
data.trans = d{12}; % ***nonsense 
data.time = d{13};
unk = d{14};
data.mc = d{15};
mcb = d{16};

fm = find(unk < 1000);
data.mc(fm) = mcb(fm);
dmc = diff(double(data.mc));
mmc = mod(dmc, 256);
figure(1); plot(mmc); title('mod diff modcount')
fmc = find(mmc - 1);
if ~isempty(fmc)
  disp('Warning: bad modcount')
end

clear d unk mcb
%%
if icast <= 3
  disp('*******************************')
  disp(['Cast ' num2str(icast) ': replacing c1 with c2'])
  data.c1 = data.c2;
  disp('*******************************')
end
%%
% despike p
disp('despike p:')
figure(2)
prodp = 1.0;    diffp = 2.0;   
data.p = tms_tc_glitchcorrect(data.p, diffp, prodp, 0, 0, 1);

[pmax, ipmax] = max(data.p);
%%
% eliminate surface data and time on deck
fdeep = find(data.p > 5.1);
ideep = findsegments(fdeep);
ii = find(ideep.start < ipmax, 1, 'last');
jj = find(ideep.stop > ipmax, 1, 'first');
data = structcat(fieldnames(data), '', 'col', data, ideep.start(ii):ideep.stop(jj));

[pmax, ipmax] = max(data.p);
n = length(data.p);
%%
% remove spikes
disp('preen:')
data = ctdpreen(data); % no trans, fl ***

%% despike T C
disp('despike T, C:')
prodc = 5e-7;   diffc = 1e-3;   
%prodc = 1e-7;   diffc = 5e-4;   
prodt = 5e-5;   difft = 1e-2;   
ibefore = 1;    iafter = 1;
data.c1 = tms_tc_glitchcorrect(data.c1, diffc, prodc, ibefore, iafter, 1);
data.c2 = tms_tc_glitchcorrect(data.c2, diffc, prodc, ibefore, iafter, 1);
data.t1 = tms_tc_glitchcorrect(data.t1, difft, prodt, ibefore, iafter, 1);
data.t2 = tms_tc_glitchcorrect(data.t2, difft, prodt, ibefore, iafter, 1);


%% T sensor lag, time constant, recalc S
disp('ctd corrections:')
data = ctd_correction(data); 


break


% eliminate depth loops
tsmooth = 1; % seconds
fs = 24; % Hz
w = wsink(data.p, tsmooth, fs);
wthresh = 0.1;
fup = find(w < wthresh & [1:n]' < ipmax);
%plot(w); hold on; plot(fup, w(fup), 'rx'); hold off
iup = findsegments(fup);
nup = length(iup.start);
for ii = 1:nup
  pm = max(data.p(1:iup.stop(ii)));
  idn = find(data.p > pm & [1:n]' > iup.stop(ii), 1, 'first');

% ***



end


tsmooth = 20; % seconds
wsmooth = wsink(data.p, tsmooth, fs);

data = sw_calc(data);
data.s3 = sw_salt(10*data.c2/sw_c3515,data.t1,data.p);

s3 = sw_salt(10*c1/sw_c3515, t1,data.p);


plot(diff(data.s1))
hold on
plot(diff(CTD.s1(fdeep)), 'r--')
hold off