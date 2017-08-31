%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% PlotChipodSpectra_Template.m
%
% Template script to plot spectra from chi-pods. These should be examined
% to check for quality and where roll-off is etc.
%
% There is option in DoChiCalc... to save spectra? Though this makes the
% files size much larger. Probably better to just pick a few profiles and
% check spectra for those.
%
% ** IN PROGRESS **
%
%----------------
% 07/08/16 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

Project = 'IO8'

mixpath = '/Users/Andy/Cruises_Research/mixingsoftware/';
addpath(fullfile(mixpath,'CTD_Chipod','mfiles'))

eval(['Load_chipod_paths_' Project])
eval(['Chipod_Deploy_Info_' Project])


%% Now we want to cycle through some profiles and plot spectra

whSN='SN1013'
file_list = dir(fullfile(chi_proc_path,whSN,'cal','*.mat'))

load(fullfile(chi_proc_path,whSN,'cal',file_list(12).name))

id1 = round(.42*length(C.datenum)) ;
inds = [id1 : 100+id1 ] ;

figure(1) ; clf
plot(C.datenum,C.T1P)
ylim([-1 1])

hold on
plot(C.datenum(inds),C.T1P(inds),'r')

% now plot spectra

addpath /Users/Andy/Cruises_Research/mixingsoftware/general
nfft = 128
samplerate = 1./nanmedian(diff(C.datenum))/24/3600;
fspd = abs(nanmean(C.fspd(inds))) ;

clear tp_power freq
[fspec,freq]=fast_psd(C.T1P(inds),nfft,samplerate);

k=freq/fspd;
spec_time=fspec/fspd^2;% If tp_power is power of dT/dt, than our units are
% K^2/[s^2 Hz]=[K^2/s] we need to
% divide by fspd^2 to get [K^2/m^2/Hz]
kspec=spec_time*fspd;% to convert from K/[m^2*Hz] to K/[m^2*cpm]

figure(2);clf
agutwocolumn(1);wysiwyg

subplot(311)
plot(C.datenum([inds(1)-100:inds(end)+100]),C.T1P([inds(1)-100 : inds(end)+100]))
hold on
plot(C.datenum(inds),C.T1P(inds),'r')
grid on

subplot(312)
loglog(freq,fspec)
xlabel('frequency')
ylabel('TP spectra')
grid on
axis tight
xlim([1e0 1e2])

subplot(313)
loglog(k,kspec)
xlabel('wavenumber')
ylabel('TP spectra')
grid on
axis tight

%%
