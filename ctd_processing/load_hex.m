
cruise = 'hippo';


 
%icast = 1; % t1
%icast = 2; % t1 
%icast = 3; % t1 t2 - only to 100 m
%icast = 4; % t1 
%icast = 5; % t1 t2 c1
%icast = 6; % t1 t2 c1
%icast = 7; % t1 t2 c1
%icast = 8; % t1 t2 c1
%icast = 9; % t1 t2 c1
%icast = 10; % t1 t2 c1
%icast = 11; % t1 t2 c1
%icast = 12; % t1 t2 c1
%icast = 13; % t1 t2 c1
%icast = 14; % t1 t2 c1
%icast = 15; % t1 t2, up c1
%icast = 16; % down to 1000 m, no up, garbage
%icast = 17; % down to 1000 m, no up, garbage
%icast = 18; % down to 500 m, garbage
%icast = 19; % up t1 t2 c1
%icast = 20; % up t1 t2 c1
%icast = 21; % up t1 t2 c1
%icast = 22; % up t1 t2 c1
%icast = 23; % up t1 t2 c1
%icast = 24; % up t1 t2 c1
%icast = 25; % up t1 t2 c1
%icast = 26; % up t1 t2 c1
%icast = 27; % up t1 t2 c1
%%
disp('=============================================================')
datadir = ['/Users/jen/projects/swirm/Ladcp/data/ctd/'];
outdir=['/Users/jen/projects/swirm/Ladcp/data/ctd/miku/ctd/'];
ctdlist = dirs(fullfile(datadir, [cruise '*.hex']));
ctdname = [datadir ctdlist(icast).name];
outname=ctdlist(icast).name;
matname = [outdir outname(1:end - 4) '.mat'];
disp(['CTD file: ' ctdname])
%%
disp('configuring:')
if icast == 1
  cfgload001
elseif icast >= 2 & icast <= 4
  cfgload002
elseif icast >= 5 & icast <= 13
  cfgload014 % diff not in tc
elseif icast >= 14
  cfgload014
end

% 24 Hz data 
disp('loading:')
% *** include ch4
d = hex_read(ctdname);

disp('parsing:')
data1 = hex_parse(d);

% check for modcount errors
dmc = diff(data1.modcount);
mmc = mod(dmc, 256);
figure; plot(mmc); title('mod diff modcount')
fmc = find(mmc - 1); 
if ~isempty(fmc); 
  disp(['Warning: ' num2str(length(dmc(mmc > 1))) ' bad modcounts']); 
  disp(['Warning: ' num2str(sum(mmc(fmc))) ' missing scans']); 
end

% check for time errors
dt = data1.time(end) - data1.time(1);
ds = dt*24;
np = length(data1.p);
mds = np - ds;
if abs(mds) >= 24; disp(['Warning: ' num2str(mds) ' difference in time scans']); end

% convert freq, volatage data
disp('converting:')
% *** fl, trans, ch4 
data2 = physicalunits(data1, cfg);

%%
disp('cleaning:')
data3 = ctd_cleanup(data2, icast);

disp('correcting:')
% ***include ch4
[datad4, datau4] = ctd_correction_updn(data3); % T lag, tau; lowpass T, C, oxygen

disp('calculating:')
% *** despike oxygen
datad5 = swcalcs(datad4, cfg); % calc S, theta, sigma, depth
datau5 = swcalcs(datau4, cfg); % calc S, theta, sigma, depth

%%
disp('removing loops:')
wthresh = 0.1;
datad6 = ctd_rmloops(datad5, wthresh, 1);
datau6 = ctd_rmloops(datau5, wthresh, 0);

%% compute epsilon now, as a test
disp('Calculating epsilon:')
[epsilon]=ctd_overturns(datad6.p,datad6.t1,datad6.s1,33,5,5e-4);
datad6.epsilon1=epsilon;
[epsilon]=ctd_overturns(datad6.p,datad6.t2,datad6.s2,33,5,5e-4);
datad6.epsilon2=epsilon;

%%
disp('binning:')
dz = 1; % m
zmin = 10; % surface
[zmax, imax] = max([max(datad6.depth) max(datau6.depth)]);
zmax = ceil(zmax); % full depth
datad = ctd_bincast(datad6, zmin, dz, zmax);
datau = ctd_bincast(datau6, zmin, dz, zmax);

disp(['saving: ' matname])
save(matname, 'datad', 'datau')

%%
%%%%%%%%%%%%%

testing = 0;
if testing
  
  load ../../model/TS/ts_swir_03 % Te Se Ze
  Pe = sw_pres(Ze, -33);
  
  data3.s1 = sw_salt(10*data3.c1/sw_c3515, data3.t1, data3.p);
  data3.s2 = sw_salt(10*data3.c2/sw_c3515, data3.t2, data3.p);
 
  figure; orient tall; wysiwyg
  ax(1) = subplot(411); plot(real(data3.c1), 'b'); grid; set(gca, 'YLim', [3 5]); title('c1')
  ax(2) = subplot(412); plot(real(data3.c2), 'r'); grid; set(gca, 'YLim', [3 5]); title('c2')
  ax(3) = subplot(413); plot(real(data3.t1), 'b'); grid; set(gca, 'YLim', [0 23]); title('t1') 
  ax(4) = subplot(414); plot(real(data3.t2), 'r'); grid; set(gca, 'YLim', [0 23]); title('t2')
  linkaxes(ax, 'x');

  figure; orient landscape; wysiwyg
  ax(1) = subplot(141); plot(datad.s1, datad.p, 'b', datad.s2, datad.p, 'r--'); grid; axis ij; set(gca, 'XLim', [34.2 36]); title('s dn'); 
  hold on; plot(Se, Pe, 'g'); hold off
  ax(2) = subplot(142); plot(datad.t1, datad.p, 'b', datad.t2, datad.p, 'r--'); grid; axis ij; set(gca, 'XLim', [0 23]); title('t dn');
  hold on; plot(Te, Pe, 'g'); hold off
  ax(3) = subplot(143); plot(datau.s1, datau.p, 'b', datau.s2, datau.p, 'r--'); grid; axis ij; set(gca, 'XLim', [34.2 36]); title('s up');
  hold on; plot(Se, Pe, 'g'); hold off
  ax(4) = subplot(144); plot(datau.t1, datau.p, 'b', datau.t2, datau.p, 'r--'); grid; axis ij; set(gca, 'XLim', [0 23]); title('t up');
  hold on; plot(Te, Pe, 'g'); hold off
  linkaxes(ax,'y');

  figure; orient landscape; wysiwyg; clear ax
  ax(1) = subplot(131); plot(data3.s1,data3.p,'b', data3.s2,data3.p,'r--'); grid; axis ij; set(gca, 'XLim', [34.2 36]); title('data3.s1 s2')
  hold on; plot(Se, Pe, 'g'); hold off
  ax(2) = subplot(132); plot(datau6.s1,datau6.p,'b', datau6.s2,datau6.p,'r--'); grid; axis ij; set(gca, 'XLim', [34.2 36]); title('datau6.s1 s2')
  hold on; plot(Se, Pe, 'g'); hold off
  ax(3) = subplot(133); plot(datad6.s1,datad6.p,'b', datad6.s2,datad6.p,'r--'); grid; axis ij; set(gca, 'XLim', [34.2 36]); title('datad6.s1 s2')
  hold on; plot(Se, Pe, 'g'); hold off
  linkaxes(ax,'xy');
    
  figure; orient landscape; wysiwyg; clear ax
  ax(1) = subplot(131); plot(data3.t1,data3.p,'b', data3.t2,data3.p,'r--'); grid; axis ij; set(gca, 'XLim', [0 23]); title('data3.t1 t2')
  hold on; plot(Te, Pe, 'g'); hold off
  ax(2) = subplot(132); plot(datau6.t1,datau6.p,'b', datau6.t2,datau6.p,'r--'); grid; axis ij; set(gca, 'XLim', [0 23]); title('datau6.t1 t2')
  hold on; plot(Te, Pe, 'g'); hold off
  ax(3) = subplot(133); plot(datad6.t1,datad6.p,'b', datad6.t2,datad6.p,'r--'); grid; axis ij; set(gca, 'XLim', [0 23]); title('datad6.t1 t2')
  hold on; plot(Te, Pe, 'g'); hold off
  linkaxes(ax,'xy');

end

testing2 = 0;
if testing2
  
  
  zd = runmean(datad.depth, 5);
  sd = runmean(datad.sigma1, 5);
  zz = runmean(zd, 2);
  [sigmas, isig] = sort(sd);
  figure; plot(diff(isig), zz)

end

