%function load_hex_ttide = load_hex_ttide(icast)
cruise= 'ttide_leg1';
%icast=56; 
close all
%
disp('=============================================================')
%datadir = ['/Users/jen/projects/iwise/ctd/raw/'];
% datadir=['/Volumes/current_cruise/ctd/'];
% outdir=['/Users/jen/projects/iwise/ctd/processed/']; % for final processed data, saved at 25 cm grid
% outdir2=['/Users/jen/projects/iwise/ctd/raw/']; % to output mat files of raw data, and ascii files for ladcp processing

datadir=['/Volumes/current_cruise/ctd/data/'];
outdir=['/Volumes/scienceparty_share/TTIDE-RR1501/data/ctd_processed/'];
outdir2=['/Volumes/scienceparty_share/TTIDE-RR1501/data/ctd_processed/24hz/'];

%datadir=['../../../current_cruise/CTD/'];
%outdir=['../../ctd/processed/']; % for final processed data, saved at                                    % 25 cm grid
%outdir2=['../../ctd/processed/raw/'];

ctdlist = dirs(fullfile(datadir, [cruise '*.hex']))
ctdname = [datadir ctdlist(icast).name];
outname=ctdlist(icast).name;
matname = [outdir outname(1:end - 4) '.mat'];
ctdlist = dirs(fullfile(datadir, [cruise '*.hex']))
ctdname = [datadir ctdlist(icast).name];
outname=ctdlist(icast).name;
matname = [outdir outname(1:end - 4) '.mat'];

ctdname=[datadir sprintf('ttide_leg1_%03d',icast) '.hex'];

%ctdname=[datadir sprintf('ttide_leg1_%01d',icast) '.hex'];

outname=[sprintf('ttide_leg1_%03d',icast) '.mat'];
matname=[outdir outname];
disp(['CTD file: ' ctdname])

%%
disp('configuring:')
% I've input all the calibration data for the sensors during MENDO12.  If
% we swap out a sensor, copy this file to cgfload001 and update the new
% file. 


cfgload000

% 24 Hz data 
disp('loading:')
% *** include ch4
d = hex_read(ctdname);

disp('parsing:')
data1 = hex_parse(d);

% check for modcount errors
dmc = diff(data1.modcount);
mmc = mod(dmc, 256);
%figure; plot(mmc); title('mod diff modcount')
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

% time is discretized
nt=length(data1.time);
time0=data1.time(1):1/24:data1.time(end);

% convert freq, volatage data
disp('converting:')
% *** fl, trans, ch4 
data2 = physicalunits(data1, cfg);

% if cast 153 do this part manually
% load in both 153b (as data2_a) and 153 as data2
%aa=fieldnames(data2)
%for iaa=1:length(aa)
%data2.(aa{iaa})=[data2.(aa{iaa});data2_a.(aa{iaa})];
%end
%% output raw data for jonathan
disp(['saving: ' matname])
matname0 = [outdir2 outname(1:end - 4) '_0.mat'];
save(matname0, 'data2')

%% specify the depth range over which t-c lag fitting is done. For deep
% stations, use data below 500 meters, otherwise use the entire depth
% range. 
%if max(data2.p)>800
%    data2.tcfit=[500 max(data2.p)];
%else
%    data2.tcfit=[200 max(data2.p)];
%end

% new for ttide - fit data over depth range above salinity minimum (AAIW),
% since t-s relationship is relatively linear here
data2.tcfit=[150 450];

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
% modified to have different standards of removing loops based on how much
% stuf is on the rosette. for TTIDE< after cast 77 we removed some stuff
% from rosette, so standards changed a bit. 
if icast<77
    wthresh = 0.5   ;

    datad6 = ctd_rmloops2(datad5, wthresh, 1);
    datau6 = ctd_rmloops2(datau5, wthresh, 0);
else
    wthresh = 0.4   ;
    datad6 = ctd_rmloops(datad5, wthresh, 1);
    datau6 = ctd_rmloops(datau5, wthresh, 0);
end
%% despike

datad7 = ctd_cleanup2(datad6);
datau7 = ctd_cleanup2(datau6);


%% compute epsilon now, as a test
doeps=0;
if doeps
sigma_t=0.0042; sigma_rho=0.0011;

disp('Calculating epsilon:')
[Epsout,Lmin,Lot,runlmax,Lttot]=compute_overturns2(datad6.p,datad6.t1,datad6.s1,nanmean(datad6.lat),0,3,sigma_t,1);
%[epsilon]=ctd_overturns(datad6.p,datad6.t1,datad6.s1,33,5,5e-4);
datad6.epsilon1=Epsout;
datad6.Lot=Lot;
end
%%
dobin=1;
if dobin
disp('binning:')
dz = 0.25; % m
zmin = 0; % surface
[zmax, imax] = max([max(datad7.depth) max(datau7.depth)]);
zmax = ceil(zmax); % full depth
datad = ctd_bincast(datad7, zmin, dz, zmax);
datau = ctd_bincast(datau7, zmin, dz, zmax);
datad.datenum=datad.time/24/3600+datenum([1970 1 1 0 0 0]);
datau.datenum=datau.time/24/3600+datenum([1970 1 1 0 0 0]);

disp(['saving: ' matname])
save(matname, 'datad', 'datau')

end

%% 1-m bin
dobin=1;
if dobin
disp('binning:')
dz = 1; % m
zmin = 0; % surface
[zmax, imax] = max([max(datad7.depth) max(datau7.depth)]);
zmax = ceil(zmax); % full depth
datad_1m = ctd_bincast(datad7, zmin, dz, zmax);
datau_1m = ctd_bincast(datau7, zmin, dz, zmax);
datad_1m.datenum=datad_1m.time/24/3600+datenum([1970 1 1 0 0 0]);
datau_1m.datenum=datau_1m.time/24/3600+datenum([1970 1 1 0 0 0]);
%%%%%%%%% remove 0s from cast 153 %%%%%%%%%%%%%%%%%
if icast == 153
  flds = fieldnames(datau);
  for a = 1:11
    datau.([flds{a}])(datau.([flds{a}])==0) = NaN;
    datad.([flds{a}])(datad.([flds{a}])==0) = NaN;
    datau_1m.([flds{a}])(datau_1m.([flds{a}])==0) = NaN;
    datad_1m.([flds{a}])(datad_1m.([flds{a}])==0) = NaN;
  end
end


disp(['saving: ' matname])
save(matname, 'datad_1m', 'datau_1m','datad','datau')

end

%% save as a text file for use by LADCP

% a little  too high resolution in time, stalls ladcp processing
% try to reduce a bit
data3b = swcalcs(data3, cfg); % calc S, theta, sigma, depth

sec=data3b.time-min(data3b.time);
p=data3b.p;
t=data3b.t1;
s=data3b.s1;
lat=data3b.lat;
lon=data3b.lon;


dataout=[sec p t s lat lon];
ig=find(~isnan(mean(dataout,2))); dataout=dataout(ig,:);
save([outdir outname(1:end-4) '.cnv'],'dataout','-ascii','-tabs')

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

